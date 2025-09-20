import 'dart:io';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database_interface.dart';
import '../database/database_wrapper.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';

/// File Manager Mode enumeration following DatabaseWrapper pattern
enum FileManagerMode {
  /// In-memory testing mode - no disk operations, compatible with existing isTesting=true
  inMemory('inMemory'),
  
  /// Persistent testing mode - writes to test_outputs directory for debugging
  persist('persist'),
  
  /// Production mode - normal filesystem operations  
  production('production');

  const FileManagerMode(this.value);
  final String value;

  /// Create FileManagerMode from string value
  static FileManagerMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'inmemory':
        return FileManagerMode.inMemory;
      case 'persist':
        return FileManagerMode.persist;
      case 'production':
        return FileManagerMode.production;
      default:
        throw ArgumentError('Invalid FileManager mode: $value');
    }
  }
}

/// Class to manage file operations - ie. "data directory"
///
/// Provides db location, folder structure for each event, uploading file to each event
/// Also handles possible same name errors
///
/// Enhanced with three-mode architecture for testing infrastructure:
/// - inMemory: No disk operations (compatible with existing isTesting=true)
/// - persist: Writes to test_outputs directory for debugging
/// - production: Normal filesystem operations
class FileManager {
  //TODO: test if eventDir is updated and returned as is in db

  static final FileManager _instance = FileManager._internal();
  static const String homeFolderName = 'Deník ZZA';
  /// entire app directory
  Directory? homeDir;
  Directory? eventDir;
  Logger logger = Logger();
  
  /// DEPRECATED: Use _mode instead. Maintained for backward compatibility.
  /// if true, [FileManager] is in testing mode and does not create directories
  bool isTesting;
  
  /// Current FileManager mode (inMemory, persist, production)
  FileManagerMode _mode;
  
  /// Optional path for persistent testing mode
  String? _testOutputPath;
  
  List<String> subFolders = ['backup', 'zpusobilosti', 'vysetreni']; //FIXME - duplicate maybe keep only the one in factory

  FileManager._internal() : isTesting = false, _mode = FileManagerMode.production;

  factory FileManager({Directory? homeDir, bool? isTesting, String? testOutputPath}) {
    // Handle backward compatibility for isTesting parameter
    if (isTesting != null) {
      _instance.isTesting = isTesting;
      _instance._mode = isTesting ? FileManagerMode.inMemory : FileManagerMode.production;
    }
    
    // Handle testOutputPath parameter for persistent testing
    if (testOutputPath != null) {
      _instance._testOutputPath = testOutputPath;
      _instance._mode = FileManagerMode.persist;
      _instance.isTesting = false; // persist mode is not the old "isTesting" concept
    }
    
    _instance.homeDir = homeDir;
    if (_instance._mode == FileManagerMode.inMemory) {
      _instance.subFolders = [];
    } else {
      _instance.subFolders = ['backup', 'zpusobilosti', 'vysetreni']; //FIXME: dirt fix - duplicate code
    }
    return _instance;
  }

  Future<Directory?> getHomeDir() async {
    switch (_mode) {
      case FileManagerMode.inMemory:
        return null; // Backward compatible with isTesting behavior
      case FileManagerMode.persist:
        // For persistent testing, use test output path if available
        if (_testOutputPath != null) {
          final testDir = Directory(_testOutputPath!);
          if (!testDir.existsSync()) {
            await testDir.create(recursive: true);
          }
          return testDir;
        }
        // Fallback to default test outputs
        const testOutputDir = 'test_outputs';
        final testDir = Directory(testOutputDir);
        if (!testDir.existsSync()) {
          await testDir.create(recursive: true);
        }
        return testDir;
      case FileManagerMode.production:
        // Original production behavior
        return homeDir ?? await createHomeDataDir();
    }
  }

  /// creates home directory for entire app
  ///
  /// or changes the directory if [inputPath] is provided
  Future<Directory?> createHomeDataDir([String? inputPath]) async {
    if (_mode == FileManagerMode.inMemory) return null; // Backward compatible
    
    if (homeDir != null && (inputPath == null || inputPath == homeDir?.path)) {
      return homeDir;
    }
    if (inputPath != null && inputPath.isNotEmpty) {
      homeDir = Directory(inputPath);
      return homeDir;
    }
    final directory = await getApplicationDocumentsDirectory();
    final thisDir = Directory('${directory.path}/$homeFolderName');
    try {
      await thisDir.create(recursive: true);
    } catch (e) {
      logger.e('Error creating home directory: $e');
      return null;
    }
    homeDir = thisDir;
    return thisDir;
  }

  /// Creates directory for each event
  ///
  /// [eventFolderName] - name of the eventDirectory
  /// Returns [Directory] that doesn't collide with possible existing directories
  Future<Directory?> createNewEventDataDir(String eventFolderName) async {
    if (_mode == FileManagerMode.inMemory) return null; // Backward compatible
    
    Directory? currentDir = await getHomeDir();
    String? newName = await nameCollisionSolver(currentDir!, eventFolderName);
    if (newName == null) {
      logger.e('Error creating event directory: $eventFolderName');
      return null;
    }
    Directory eventDirCandidate = Directory('${currentDir.path}/$newName');
    try {
      await eventDirCandidate.create(recursive: true);
    } catch (e) {
      logger.e('Error creating event directory: $eventDirCandidate $e');
      return null;
    }
    changeEvent();
    return createSubfolders(eventDirCandidate);
  }

  Future<Directory?> createSubfolders(Directory baseDir) async {
    if (_mode == FileManagerMode.inMemory) return null; // Backward compatible
    
    for (var subFolder in subFolders) {
      Directory subDir = Directory('${baseDir.path}/$subFolder');
      try {
        await subDir.create(recursive: true);
      } catch (e) {
        logger.e('Error creating subfolder: $subFolder $e');
        return null;
      }
    }
    return baseDir;
  }

Future<String?> nameCollisionSolver(Directory base, String inName) async {
  if (_mode == FileManagerMode.inMemory) return null; // Backward compatible
  
  if (!await base.exists()) {
    logger.e('Base directory does not exist: ${base.path}');
    return null;
  }
  final entityPath = '${base.path}/$inName';
  final entityType = await FileSystemEntity.type(entityPath);
  if (entityType == FileSystemEntityType.notFound) {
    logger.i('No collision: $inName');
    return inName;
  } else {
    String newName;
    int counter = 1;
    final extension = inName.contains('.') ? inName.substring(inName.lastIndexOf('.')) : '';
    final baseName = inName.replaceAll(extension, '');
    do {
      newName = '${baseName}_${counter.toString().padLeft(3, '0')}$extension';
      FileSystemEntityType newType = await FileSystemEntity.type('${base.path}/$newName');
      if (newType == FileSystemEntityType.notFound) {
        logger.i('New name is available: $newName');
        return newName;
      }
      counter++;
    } while (true);
  }
}

  Future<String?> getDbFilePath() async {
    switch (_mode) {
      case FileManagerMode.inMemory:
        return null; // Triggers in-memory database - backward compatible
        
      case FileManagerMode.persist:
        // Use TestOutputManager for persistent testing paths
        try {
          // For persistent testing, we need a way to get the test database path
          // This is a simplified approach - in a full implementation you'd integrate with TestOutputManager
          if (_testOutputPath != null) {
            final testDir = Directory(_testOutputPath!);
            if (!testDir.existsSync()) {
              await testDir.create(recursive: true);
            }
            return _testOutputPath;
          }
          // Fallback to a default test path if testOutputPath not provided
          const testOutputDir = 'test_outputs/databases';
          final testDir = Directory(testOutputDir);
          if (!testDir.existsSync()) {
            await testDir.create(recursive: true);
          }
          return testOutputDir;
        } catch (e) {
          logger.e('Error setting up persistent testing path: $e');
          return null; // Fallback to in-memory
        }
        
      case FileManagerMode.production:
        // Original production behavior
        final homeDir = await getHomeDir();
        return homeDir?.path;
    }
  }

  @Deprecated('Use getDbFilePath() instead')
  String? getDbFilePathSync() {
    return isTesting ? null : homeDir?.path;
  }

  // Enhanced FileManager methods following DatabaseWrapper pattern

  /// Get current FileManager mode
  FileManagerMode get currentMode => _mode;

  /// Check if running in memory mode (no disk operations)
  bool get isInMemoryMode => _mode == FileManagerMode.inMemory;

  /// Check if running in persistent testing mode
  bool get isPersistMode => _mode == FileManagerMode.persist;

  /// Check if running in production mode
  bool get isProductionMode => _mode == FileManagerMode.production;

  /// Set FileManager to testing mode (in-memory, no disk operations)
  /// Maintains backward compatibility with existing test patterns
  void setTestMode() {
    _mode = FileManagerMode.inMemory;
    isTesting = true;
    subFolders = [];
  }

  /// Set FileManager to persistent testing mode with specified output path
  void setPersistentTestMode(String testOutputPath) {
    _mode = FileManagerMode.persist;
    _testOutputPath = testOutputPath;
    isTesting = false; // persist mode is different from legacy isTesting
    subFolders = ['backup', 'zpusobilosti', 'vysetreni'];
  }

  /// Reset FileManager to production mode
  void resetToProduction() {
    _mode = FileManagerMode.production;
    _testOutputPath = null;
    isTesting = false;
    subFolders = ['backup', 'zpusobilosti', 'vysetreni'];
  }

  /// Get FileManager configuration summary for debugging
  Map<String, dynamic> getConfigSummary() {
    return {
      'mode': _mode.value,
      'isTesting': isTesting,
      'testOutputPath': _testOutputPath,
      'homeDir': homeDir?.path,
      'eventDir': eventDir?.path,
      'subFolders': subFolders,
    };
  }

  /// Reflects changes in current event, then tests [eventDir] correct structure
  ///
  /// Should be explicitly called from UI to better handle possible errors
  /// TODO: create UI Popup for catching errors - with option to recreate event directory
  Future<void> changeEvent() async {
    logger.i('Changing event');
    DatabaseInterface db = DatabaseWrapper.getDatabase();
    MemoryAction? event = await db.getCurrentAction();
    if (event == null) {
      eventDir = null;
      logger.w('No current event found');
      return;
    }
    // prevent unnecessary actions
    if (event.domovskyAdresarPath == eventDir?.path) {
      logger.i('Event directory is already set');
      return;
    }
    // if event hasn't been created yet
    if (event.domovskyAdresarPath == null || event.domovskyAdresarPath!.isEmpty) {
      logger.i('Event directory not found in db');
      eventDir = await createNewEventDataDir(event.nadpis);
      event.domovskyAdresarPath = eventDir?.path;
      db.updateEvent(action: event);
      return;
    }
    // if in db but not in class - check folder structure
    logger.i('Event directory found in db, not in class');
    Directory? candidate = Directory(event.domovskyAdresarPath!);
    await _checkEventDirectoryExists(candidate);
    await _validateSubfolders(candidate);
    eventDir = candidate;
  }

  /// Simple backup of the database to event directory
  Future<void> backupDB() async {
    if (eventDir == null) {
      if (_mode != FileManagerMode.inMemory) logger.e('Event directory is null');
      return;
    }

    try {
      final path = await getDbFilePath();
      if (path == null) {
        logger.e('Error getting db path');
        return;
      }
      final dbFile = File('$path/denik_zza.db');
      final backupDir = Directory('${eventDir!.path}/backup');
      await backupDir.create(recursive: true);
      final newName = await nameCollisionSolver(backupDir, 'denik_zza_backup.db');
      if (newName == null) {
        logger.e('Error resolving name collision for backup file');
        return;
      }
      final backupFile = File('${backupDir.path}/$newName');
      await dbFile.copy(backupFile.path);
      logger.i('Backup created: ${backupFile.path}');
    } catch (e) {
      logger.e('Error creating backup: $e');
    }
  }

  /// Returns directory where zpusobilosti are stored for current event
  ///
  /// Use in cooperation when getting zpusobilost files from [MemoryOsoba] instances
  /// If [eventDir] is null, throws an exception
  Future<Directory> getZpusobilostFolder() async {
    if (eventDir == null) {
      if (_mode != FileManagerMode.inMemory) logger.e('Event directory is null', stackTrace: StackTrace.current);
      logger.i('FileManager mode: ${_mode.value}');
      return throw Exception('Event directory is null');
    }
    return Directory('${eventDir!.path}/zpusobilosti');
  }

  Future<String?> putZpusobilost(File pickedFile) async {
    if (eventDir == null) {
      if (_mode != FileManagerMode.inMemory) logger.e('Event directory is null');
      return null;
    }

    try {
      final zpusobilostDir = Directory('${eventDir!.path}/zpusobilosti');
      await zpusobilostDir.create(recursive: true);

      final newName = await nameCollisionSolver(zpusobilostDir, pickedFile.uri.pathSegments.last);
      if (newName == null) {
        logger.e('Error resolving name collision for uploaded file');
        return null;
      }

      final destinationFile = File('${zpusobilostDir.path}/$newName');
      await pickedFile.copy(destinationFile.path);
      logger.i('File uploaded to: ${destinationFile.path}');
      //return destinationFile.path;
      return newName;
    } catch (e) {
      logger.e('Error uploading file: $e');
      return null;
    }
  }

  /// Tests if [MemoryOsoba.zpusobilostPath] is valid (and readable)
  ///
  /// [osoba] - the person object containing the zpusobilost file path
  /// If file is not found, it will set the path to null and return false
  /// TODO: add to intake_form.dart
  Future<bool> validateZpusobilost(MemoryOsoba osoba) async {
    final zpusobilostDir = await getZpusobilostFolder();
    if (osoba.potvrzeniPath == null) {
      return true; // Not an error - file is optional
    }
    final expectedFile = File('${zpusobilostDir.path}/${osoba.potvrzeniPath}');
    if (await expectedFile.exists()) {
      try {
        await expectedFile.openRead().first;
        return true;
      } catch (e) {
        logger.e('File is not readable: ${expectedFile.path}');
      }
    } else {
      logger.e('File not found: ${expectedFile.path}');
    }
    osoba.potvrzeniPath = null;
    return false;
  }

  Future<void> _checkEventDirectoryExists(Directory candidate) async {
    if (!await candidate.exists()) {
      logger.e('Event directory not found: ${candidate.path}');
      throw FileSystemException('Event directory not found: ${candidate.path}');
    }
  }

  Future<void> _validateSubfolders(Directory candidate) async {
    for (var subFolder in subFolders) {
      Directory subDir = Directory('${candidate.path}/$subFolder');
      if (!await subDir.exists()) {
        logger.e('Subfolder not found: $subFolder');
        throw FileSystemException('Subfolder not found: $subFolder in ${candidate.path}');
      }
    }
  }
}