import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:denik_zza/utils/file_exceptions.dart';
import 'package:denik_zza/utils/file_ops_atomic.dart';
import 'package:denik_zza/utils/temp_file_helper.dart';

/// File Manager Mode enumeration following DatabaseWrapper pattern
enum FileManagerMode {
  /// In-memory testing mode - no disk operations, compatible with existing isTesting=true
  inMemory('inMemory'),

  /// Persistent testing mode - writes to test/test_outputs directory for debugging
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
/// - persist: Writes to test/test_outputs directory for debugging
/// - production: Normal filesystem operations
class FileManager {
  //TODO: test if eventDir is updated and returned as is in db

  static final FileManager _instance = FileManager._internal();
  static const String homeFolderName = 'Deník ZZA';

  /// entire app directory
  Directory? homeDir;
  Directory? eventDir;
  Logger logger = AppLogger.l;

  /// DEPRECATED: Use _mode instead. Maintained for backward compatibility.
  /// if true, [FileManager] is in testing mode and does not create directories
  bool isTesting;

  /// Current FileManager mode (inMemory, persist, production)
  FileManagerMode _mode;

  /// Optional path for persistent testing mode
  String? _testOutputPath;

  /// Set of subdirectories that should be created in each event directory
  List<String> subFolders = []; // Set by _updateSubFoldersForMode()

  /// Lightweight toggle: when true, run IO sanity check during changeEvent()
  bool _ioCheckOnChange = false;

  /// Standard event subdirectories for persistent modes
  static const List<String> _standardSubFolders = [
    'backup',
    'zpusobilosti',
    'vysetreni'
  ];

  FileManager._internal()
      : isTesting = false,
        _mode = FileManagerMode.production {
    _updateSubFoldersForMode();
  }

  /// Updates subFolders based on current mode - centralized logic
  void _updateSubFoldersForMode() {
    switch (_mode) {
      case FileManagerMode.inMemory:
        subFolders = [];
        break;
      case FileManagerMode.persist:
      case FileManagerMode.production:
        subFolders = List.from(_standardSubFolders);
        break;
    }
  }

  factory FileManager(
      {Directory? homeDir, bool? isTesting, String? testOutputPath}) {
    // Handle backward compatibility for isTesting parameter
    if (isTesting != null) {
      _instance.isTesting = isTesting;
      _instance._mode =
          isTesting ? FileManagerMode.inMemory : FileManagerMode.production;
      _instance._updateSubFoldersForMode();
    }

    // Handle testOutputPath parameter for persistent testing
    if (testOutputPath != null) {
      _instance._testOutputPath = testOutputPath;
      _instance._mode = FileManagerMode.persist;
      _instance.isTesting =
          false; // persist mode is not the old "isTesting" concept
      _instance._updateSubFoldersForMode();
    }

    if (homeDir != null) {
      _instance.homeDir = homeDir;
    }
    return _instance;
  }

  /// Enable or disable IO sanity checks in changeEvent()
  void setIoCheckOnChange(bool enabled) {
    _ioCheckOnChange = enabled;
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
        // Fallback to default test outputs (under test/)
        const testOutputDir = 'test/test_outputs';
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
    final thisDir = Directory(path.join(directory.path, homeFolderName));
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
    Directory eventDirCandidate = Directory(path.join(currentDir.path, newName));
    try {
      await eventDirCandidate.create(recursive: true);
    } catch (e) {
      logger.e('Error creating event directory: $eventDirCandidate $e');
      return null;
    }
    // Ensure subfolders exist
    final created = await createSubfolders(eventDirCandidate);
    if (created == null) {
      return null;
    }
    // Run quick IO sanity check on creation
    final ok = await verifyWritableReadable(created);
    if (!ok) {
      logger
          .e('IO sanity check failed for new event directory: ${created.path}');
      return null;
    }
    eventDir = created;
    return created;
  }

  Future<Directory?> createSubfolders(Directory baseDir) async {
    if (_mode == FileManagerMode.inMemory) return null; // Backward compatible

    for (var subFolder in subFolders) {
      Directory subDir = Directory(path.join(baseDir.path, subFolder));
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
    final entityPath = path.join(base.path, inName);
    final entityType = await FileSystemEntity.type(entityPath);
    if (entityType == FileSystemEntityType.notFound) {
      logger.i('No collision: $inName');
      return inName;
    } else {
      String newName;
      int counter = 1;
      final extension =
          inName.contains('.') ? inName.substring(inName.lastIndexOf('.')) : '';
      final baseName = inName.replaceAll(extension, '');
      do {
        newName = '${baseName}_${counter.toString().padLeft(3, '0')}$extension';
        FileSystemEntityType newType =
          await FileSystemEntity.type(path.join(base.path, newName));
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
          const testOutputDir = 'test/test_outputs/databases';
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
    _updateSubFoldersForMode();
  }

  /// Set FileManager mode with optional test output path
  ///
  /// Usage:
  ///   FileManager().setMode(FileManagerMode.inMemory);
  ///   FileManager().setMode(FileManagerMode.persist, testOutputPath: 'test/outputs');
  ///   FileManager().setMode(FileManagerMode.production);
  void setMode(FileManagerMode mode, {String? testOutputPath}) {
    _mode = mode;
    _testOutputPath = testOutputPath;
    isTesting = (mode == FileManagerMode.inMemory);
    _updateSubFoldersForMode();
  }

  /// Set FileManager to persistent testing mode with specified output path
  void setPersistentTestMode(String testOutputPath) {
    _mode = FileManagerMode.persist;
    _testOutputPath = testOutputPath;
    isTesting = false; // persist mode is different from legacy isTesting
    _updateSubFoldersForMode();
  }

  /// Reset FileManager to production mode
  void setProductionMode() {
    _mode = FileManagerMode.production;
    _testOutputPath = null;
    isTesting = false;
    _updateSubFoldersForMode();
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
    if (event.domovskyAdresarPath == null ||
        event.domovskyAdresarPath!.isEmpty) {
      logger.w(
          'Event directory path not set in DB; awaiting explicit creation elsewhere.');
      eventDir = null;
      return;
    }
    // if in db but not in class - check folder structure
    logger.i('Event directory found in db, not in class');
    Directory? candidate = Directory(event.domovskyAdresarPath!);
    await _checkEventDirectoryExists(candidate);
    await _validateSubfolders(candidate);
    if (_ioCheckOnChange) {
      final ok = await verifyWritableReadable(candidate);
      if (!ok) {
        logger.w(
            'IO sanity check failed for existing event directory: ${candidate.path}');
      }
    }
    eventDir = candidate;
  }

  /// Simple backup of the database to event directory
  Future<void> backupDB() async {
    if (eventDir == null) {
      if (_mode != FileManagerMode.inMemory) {
        logger.e('Event directory is null');
      }
      return;
    }

    try {
      final dbDir = await getDbFilePath();
      if (dbDir == null) {
        logger.e('Error getting db path');
        return;
      }
      final dbFile = File('$dbDir/db.sqlite');
      if (!await dbFile.exists()) {
        logger.e('Database file not found for backup: ${dbFile.path}');
        return;
      }
      final backupDir = Directory(path.join(eventDir!.path, 'backup'));
      await backupDir.create(recursive: true);
      final newName = await nameCollisionSolver(backupDir, 'db_backup.sqlite');
      if (newName == null) {
        logger.e('Error resolving name collision for backup file');
        return;
      }
      final backupFile = File(path.join(backupDir.path, newName));
      try {
        await copyAtomic(dbFile, backupFile);
        logger.i('Backup created: ${backupFile.path}');
      } catch (e) {
        logger.e('Error creating backup (atomic): $e');
        throw FileOperationException('Backup failed', e);
      }
    } catch (e) {
      logger.e('Error creating backup: $e');
    }
  }

  /// Returns directory where zpusobilosti are stored for current event
  ///
  /// Use in cooperation when getting zpusobilost files from [MemoryOsoba] instances
  /// If [eventDir] is null in non-inMemory modes, throws an exception
  Future<Directory> getZpusobilostFolder() async {
    // In inMemory mode, return synthetic directory (matches writeTempCsvBytes pattern)
    if (_mode == FileManagerMode.inMemory) {
      logger.d('Zpusobilost folder in memory mode: memory://zpusobilosti');
      return Directory('memory://zpusobilosti');
    }

    // In persistent modes, require eventDir to be set
    if (eventDir == null) {
      logger.e('Event directory is null', stackTrace: StackTrace.current);
      logger.i('FileManager mode: ${_mode.value}');
      return throw Exception('Event directory is null');
    }
    return Directory(path.join(eventDir!.path, 'zpusobilosti'));
  }

  Future<String?> putZpusobilost(File pickedFile) async {
    if (eventDir == null) {
      if (_mode != FileManagerMode.inMemory) {
        logger.e('Event directory is null');
      }
      return null;
    }

    try {
      final zpusobilostDir = Directory(path.join(eventDir!.path, 'zpusobilosti'));
      await zpusobilostDir.create(recursive: true);

      final newName = await nameCollisionSolver(
          zpusobilostDir, pickedFile.uri.pathSegments.last);
      if (newName == null) {
        logger.e('Error resolving name collision for uploaded file');
        return null;
      }

      final destinationFile = File(path.join(zpusobilostDir.path, newName));
      try {
        await copyAtomic(pickedFile, destinationFile);
        logger.i('File uploaded to: ${destinationFile.path}');
        return newName;
      } catch (e) {
        logger.e('Error uploading file atomically: $e');
        throw FileOperationException('Failed to upload file', e);
      }
    } catch (e) {
      logger.e('Error uploading file: $e');
      throw FileOperationException('Failed to upload file', e);
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
    final expectedFile = File(path.join(zpusobilostDir.path, osoba.potvrzeniPath!));
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
      Directory subDir = Directory(path.join(candidate.path, subFolder));
      if (!await subDir.exists()) {
        logger.e('Subfolder not found: $subFolder');
        throw FileSystemException(
            'Subfolder not found: $subFolder in ${candidate.path}');
      }
    }
  }

  /// Quick IO sanity check: create/write/read/delete a tiny probe file in [dir].
  Future<bool> verifyWritableReadable(Directory dir) async {
    final probe = File(path.join(dir.path, '.io_probe'));
    try {
      await probe.writeAsString('probe');
      final content = await probe.readAsString();
      await probe.delete();
      return content == 'probe';
    } catch (e, st) {
      logger.e('IO probe failed in ${dir.path}', error: e, stackTrace: st);
      try {
        if (await probe.exists()) {
          await probe.delete();
        }
      } catch (_) {}
      return false;
    }
  }

  // ========== Temporary CSV File Operations ==========

  /// Writes CSV bytes to a temporary file and returns the absolute path.
  ///
  /// Behavior varies by mode:
  /// - inMemory: Returns synthetic path, no disk write
  /// - persist: Writes to test/test_outputs/temp/ for debugging
  /// - production: Uses path_provider temporary directory
  ///
  /// [bytes] - The CSV data to write
  /// [suggestedName] - Suggested filename (will be sanitized)
  ///
  /// Returns the absolute path to the created temp file.
  Future<String> writeTempCsvBytes(
    Uint8List bytes, {
    required String suggestedName,
  }) async {
    final String sanitized = _sanitizeFileName(suggestedName);
    final String resolvedName = sanitized.isEmpty ? 'import.csv' : sanitized;

    switch (_mode) {
      case FileManagerMode.inMemory:
        // Return synthetic path, don't write to disk
        logger.d('Temp CSV in memory mode: memory://temp/$resolvedName');
        return 'memory://temp/$resolvedName';

      case FileManagerMode.persist:
        // Write to test outputs for debugging
        final String basePath = _testOutputPath ?? 'test/test_outputs';
        final Directory tempDir = Directory(path.join(basePath, 'temp'));
        await tempDir.create(recursive: true);
        final filename = uniqueTempName(resolvedName);
        final File target = File(path.join(tempDir.path, filename));
        try {
          await writeBytesAtomic(target, bytes);
          logger.d('Temp CSV written (persist): ${target.path}');
          return target.path;
        } catch (e) {
          logger.e('Failed to write temp CSV (persist): $e');
          throw TempFileException('Failed to write temp CSV', e);
        }

      case FileManagerMode.production:
        // Use path_provider
        final Directory tempDir = await getTemporaryDirectory();
        final filename = uniqueTempName(resolvedName);
        final File target = File(path.join(tempDir.path, filename));
        try {
          await writeBytesAtomic(target, bytes);
          logger.d('Temp CSV written (production): ${target.path}');
          return target.path;
        } catch (e) {
          logger.e('Failed to write temp CSV (production): $e');
          throw TempFileException('Failed to write temp CSV', e);
        }
    }
  }

  /// Deletes a temporary file created by [writeTempCsvBytes].
  ///
  /// In inMemory mode, this is a no-op. Errors are logged but swallowed
  /// since temp file cleanup is non-critical.
  ///
  /// [filePath] - The absolute path returned by writeTempCsvBytes
  Future<void> deleteTempFile(String filePath) async {
    if (_mode == FileManagerMode.inMemory) {
      logger.d('Temp file deletion skipped (memory mode): $filePath');
      return; // No-op in memory mode
    }

    final File file = File(filePath);
    if (await file.exists()) {
      try {
        await file.delete();
        logger.d('Temp file deleted: $filePath');
      } catch (error) {
        // Make temp deletion failures visible to caller for P0
        logger.w('Failed to delete temp file: $filePath', error: error);
        throw TempFileException('Failed to delete temp file: $filePath', error);
      }
    } else {
      logger.d('Temp file does not exist (already cleaned?): $filePath');
    }
  }

  /// Sanitizes a filename by removing invalid characters and ensuring .csv extension.
  String _sanitizeFileName(String input) {
    final String trimmed = input.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    // Remove filesystem separators and invalid characters
    final String withoutSeparators =
        trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    // Ensure .csv extension
    return withoutSeparators.endsWith('.csv')
        ? withoutSeparators
        : '$withoutSeparators.csv';
  }
}
