import 'dart:io';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database_interface.dart';
import '../database/database_wrapper.dart';

/// Class to manage file operations - ie. "data directory"
///
/// Provides db location, folder structure for each event, uploading file to each event
/// Also handles possible same name errors
class FileManager {
  static final FileManager _instance = FileManager._internal();
  static const String homeFolderName = 'Deník ZZA';
  Directory? homeDir;
  bool isTesting;
  List<String> subFolders = ['backup', 'zpusobilosti', 'vysetreni'];

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
      Logger().e('Error creating home directory: $e');
      return null;
    }
    homeDir = thisDir;
    return thisDir;
  }

  Future<Directory?> createNewEventDataDir(String eventFolderName) async {
    if (isTesting) return null;
    Directory? currentDir = await getHomeDir();
    String? newName = await nameCollisionSolver(currentDir!, eventFolderName);
    if (newName == null) {
      Logger().e('Error creating event directory: $eventFolderName');
      return null;
    }
    Directory eventDirCandidate = Directory('${currentDir.path}/$newName');
    try {
      await eventDirCandidate.create(recursive: true);
    } catch (e) {
      Logger().e('Error creating event directory: $eventDirCandidate $e');
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
        Logger().e('Error creating subfolder: $subFolder $e');
        return null;
      }
    }
    return baseDir;
  }

  Future<String?> nameCollisionSolver(Directory base, String inName) async {
    if (isTesting) return null;
    final logger = Logger();
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
        newName = '${inName}_$counter';
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
}