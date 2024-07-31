import 'dart:io';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database_interface.dart';
import '../database/database_wrapper.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';

/// Class to manage file operations - ie. "data directory"
///
/// Provides db location, folder structure for each event, uploading file to each event
/// Also handles possible same name errors
class FileManager {
  //TODO: test if eventDir is updated and returned as is in db

  static final FileManager _instance = FileManager._internal();
  static const String homeFolderName = 'Deník ZZA';
  /// entire app directory
  Directory? homeDir;
  Directory? eventDir;
  Logger logger = Logger();
  /// if true, [FileManager] is in testing mode and does not create directories
  bool isTesting;
  List<String> subFolders = ['backup', 'zpusobilosti', 'vysetreni']; //FIXME - duplicate maybe keep only the one in factory

  FileManager._internal() : isTesting = false;

  factory FileManager({Directory? homeDir, bool? isTesting}) {
    _instance.homeDir = homeDir;
    _instance.isTesting = isTesting ?? false;
    if (_instance.isTesting) {
      _instance.subFolders = [];
    } else {
      _instance.subFolders = ['backup', 'zpusobilosti', 'vysetreni']; //FIXME: dirt fix - duplicate code
    }
    return _instance;
  }
  Future<Directory?> getHomeDir() async {
    return isTesting ? null : (homeDir ?? await createHomeDataDir());
  }
/// creates home directory for entire app
  ///
  /// or changes the directory if [inputPath] is provided
  Future<Directory?> createHomeDataDir([String? inputPath]) async {
    if (isTesting) return null;
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
/// creates directory for each event
  ///
  /// [eventFolderName] - name of the eventDirectory
  /// returns [Directory] that doesn't collide with possible existing directories
  Future<Directory?> createNewEventDataDir(String eventFolderName) async {
    if (isTesting) return null;
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
    return createSubfolders(eventDirCandidate);
  }

  Future<Directory?> createSubfolders(Directory baseDir) async {
    if (isTesting) return null;
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
    if (isTesting) return null;
   // final logger = Logger();
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
      do {
       newName = '${inName}_${counter.toString().padLeft(3, '0')}';
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
    if (isTesting) return null;
    final homeDir = await getHomeDir();
    return homeDir?.path;
  }

  @Deprecated('Use getDbFilePath() instead')
  String? getDbFilePathSync() {
    return isTesting ? null : homeDir?.path;
  }

/// reflect changes in current event, than tests [eventDir] correct structure
  ///
  /// Should be explicitly called from UI to better handle possible errors
  /// TODO: create UI Popup for catching errors - with option to recreate event directory
changeEvent() async {
  DatabaseInterface db = DatabaseWrapper.getDatabase();
  MemoryAction? event = await db.getCurrentAction();
  if (event == null) {
    eventDir = null;
    logger.w('No current event found');
    return;
  }
  // prevent unnecessary actions
  if (event.domovskyAdresarPath == eventDir?.path) {
    return;
  }
  // if event hasn't been created yet
  if (event.domovskyAdresarPath == null || event.domovskyAdresarPath!.isEmpty) {
    eventDir = await createNewEventDataDir(event.nadpis);
    event.domovskyAdresarPath = eventDir?.path;
    db.updateEvent(action: event);
    return;
  }
  // if in db but not in class - check folder structure
  Directory? candidate = Directory(event.domovskyAdresarPath!);
  await _checkEventDirectoryExists(candidate);
  await _validateSubfolders(candidate);
}
/// simple backup of the database
backupDB() async {
  if (eventDir == null) {
    if (!isTesting) logger.e('Event directory is null');
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

/// returns directory where zpusobilosti are for current event
  ///
  /// Use in cooperation when getting zpusobilost files from [MemoryOsoba] instances
  /// if [eventDir] is null, returns null
getZpusobilostFolder() async {
  if (eventDir == null) {
   if (!isTesting) logger.e('Event directory is null');
    return;
  }
  return Directory('${eventDir!.path}/zpusobilosti');
}

Future<String?> putZpusobilost(File pickedFile) async {
  if (eventDir == null) {
    if (!isTesting) logger.e('Event directory is null');
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
/// tests if [MemoryOsoba.zpusobilostPath] is valid (and readable)
  ///
/// [expectedFile] is the file that should be found in the directory
  /// if not found it will null it inside [MemoryOsoba] and return false
  /// TODO: add to intake_form.dart
Future<bool> validateZpusobilost(MemoryOsoba osoba) async {
  final zpusobilostDir = await getZpusobilostFolder();
  if (zpusobilostDir == null || osoba.potvrzeniPath == null) {
    return true; // really true - because it's not an error
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
      throw FileSystemException('Domovský adresář nenalezen: ${candidate.path}');
    }
  }

  Future<void> _validateSubfolders(Directory candidate) async {
    for (var subFolder in subFolders) {
      Directory subDir = Directory('${candidate.path}/$subFolder');
      if (!await subDir.exists()) {
        logger.e('Subfolder not found: $subFolder');
        throw FileSystemException('Podadresář nenalezen: $subFolder');
      }
    }
  }


}