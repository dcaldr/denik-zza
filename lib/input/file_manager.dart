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
  /// defines if in testing environment, where creating a lot of dirs is not desirable
  bool isTesting = false;
  List<String> subFolders = ['backup', 'zpusobilosti', 'vysetreni'];

  /// Constructor
  ///
  /// Takes care of detecting if it's in testing context
  FileManager._internal({this.homeDir, bool? bypassTesting}) {
    if (bypassTesting == false || bypassTesting == null) {
      assert(() {
        isTesting = true;
        subFolders = [];
        return true;
      }());
    }
  }

  /// Factory constructor
  ///
  /// Initializes the singleton instance and sets the home directory and testing mode
  factory FileManager({Directory? homeDir, bool? bypassTesting}) {
    _instance.homeDir = homeDir;
    if (bypassTesting != null) {
      _instance.isTesting = bypassTesting;
    }
    return _instance;
  }

  /// Gets "home" data directory
  ///
  /// Returns the home directory if it exists, otherwise creates it
  Future<Directory?> getHomeDir() async {
    return homeDir ?? await createHomeDataDir();
  }

  /// Creates or leaves home directory under ApplicationDocumentsDirectory
  ///
  /// Can be overridden by [inputPath] that must exist prior.
  /// In testing, defaults to current Directory
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

  /// For given event, create new folder directory structure
  ///
  /// When given existing name, it chooses a new name to prevent collision.
  /// Returns accepted directory name or null if failed
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

  /// Creates subfolders in given (event) directory
  ///
  /// Returns inputted directory or null if failed
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

  /// Checks if file/folder exists and suggests new name if needed
  ///
  /// Given [base] path checks if [inName] would collide with existing file/folder
  /// and if so suggests new name
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

  /// Gets db file path
  ///
  /// If it's used in testing context, it returns null
  Future<String?> getDbFilePath() async {
    if (isTesting) return null;
    final homeDir = await getHomeDir();
    return homeDir?.path;
  }

  /// Sync version of getDbFilePath
  ///
  /// WARN\! Doesn't create folder structure
  @Deprecated('Use getDbFilePath() instead')
  String? getDbFilePathSync() {
    return homeDir?.path;
  }
}

/// Class to manage event files
///
/// Provides methods to upload files, test folder structure, and change events
class EventFiles {
  String? currentEventName;
  Directory? currentEventDir;

  /// Uploads a file to the current event directory
  ///
  /// Throws [UnimplementedError] as the method is not yet implemented
  Future<String?> uploadZpusobilost(File file) async {
    throw UnimplementedError();
  }

  /// Tests the structure of the current event directory
  ///
  /// Returns true if all subfolders exist, false otherwise
  bool testStructure() {
    if (currentEventDir != null) {
      bool isOk = true;
      for (var subFolder in FileManager().subFolders) {
        Directory subDir = Directory('${currentEventDir?.path}/$subFolder');
        if (!subDir.existsSync()) {
          Logger().e('Error: $subFolder does not exist');
          isOk = false;
        }
      }
      return isOk;
    }
    return false;
  }

  /// Call when user changes event
  ///
  /// Updates current event name and directory
  Future<void> changeEvent() async {
    DatabaseInterface mydb = DatabaseWrapper.getDatabase();
    MemoryAction? currAction = await mydb.getCurrentAction();
    if (currAction != null) {
      currentEventName = currAction.nadpis;
      String? path = currAction.domovskyAdresarPath;
      currentEventDir = path != null ? Directory(path) : null;
    }
  }

  /// Call when user creates new event
  ///
  /// Updates current event name and directory
  Future<MemoryAction?> initNewEvent(MemoryAction? event) async {
    FileManager fm = FileManager();
    if (event != null) {
      event.domovskyAdresarPath = await fm.createNewEventDataDir(event.nadpis).then((value) => value?.path);
    }
    return event;
  }
}