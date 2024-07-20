import 'dart:io';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database_interface.dart';
import '../database/database_wrapper.dart';

/// Class to manage file operations - ie. "data directory"
///
/// provides db location, folder structure for each event, uploading file to each event
/// also handles possible same name errors
class FileManager {
  static final FileManager _instance = FileManager._internal();
  static String homeFolderName = 'Deník ZZA';
  Directory? homeDir;
  bool isTesting = false;
  List<String> subFolders = ['backup','zpusobilosti','vysetreni'];

  /// Constructor
  ///
  /// takes care of detecting if its in testing context
  FileManager._internal({this.homeDir, bool? bypassTesting}) {
    if (bypassTesting == false || bypassTesting == null) {
      assert(() {
        isTesting = true;
        subFolders = [];
        return true;
      }());
    }
  }
  factory FileManager({Directory? homeDir, bool? bypassTesting}) => _instance;

  /// gets "home" data directory
  Future<Directory?> getHomeDir() async {
    return homeDir == null ? null : createHomeDataDir();
  }

  /// creates or leaves home directory under ApplicationDocumentsDirectory
  ///
  /// can be overridden by [inputPath] that must exist prior !!
  /// In testing defaults to current Directory
  Future<Directory?> createHomeDataDir([String? inputPath]) async {
    /// guard for repeating operations
    if (homeDir != null && (inputPath == null || inputPath == homeDir?.path)) {
      return homeDir;
    }
    if (inputPath != null && inputPath.isNotEmpty) {
      homeDir = Directory(inputPath);
      return homeDir;
    }
    final directory = isTesting ? Directory.current : await getApplicationDocumentsDirectory();
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

  /// For given event create new folder directory structure
  ///
  /// when given existing name it chooses new name to prevent collision
  /// returns accepted directory name or null if failed
  Future<Directory?> createNewEventDataDir(String eventFolderName) async{
      /// create all folders from subFolders if not exist yet
      Directory? currentDir = await getHomeDir();
      // create eventFolder to currentDir
      //Directory eventDirCandidate = Directory('${currentDir?.path}/$eventFolderName');
       String? newName = await nameCollisionSolver(currentDir!, eventFolderName);
        if(newName == null){
          Logger().e('Error creating event directory: $eventFolderName');
          return null;
        }
      Directory eventDirCandidate = Directory('${currentDir.path}/$newName');
        // create eventDirCandidate
        try {
          await eventDirCandidate.create(recursive: true);
        } catch (e) {
          Logger().e('Error creating event directory:  $eventDirCandidate $e');
          return null;
        }

    return createSubfolders(eventDirCandidate);
  }
/// creates subfolders in given (event) directory
  ///
  /// returns inputted directory or null if failed
  Future<Directory?> createSubfolders(Directory baseDir) async {
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

  /// checks if file/folder exists and suggests new name if needed
  ///
  /// given [base] path checks if [inName] would collide with existing file/folder
  /// and if so suggests new name
Future<String?> nameCollisionSolver(Directory base, String inName) async {
  final logger = Logger();

  // Check if the base directory exists
  if (!await base.exists()) {
    logger.e('Base directory does not exist: ${base.path}');
    return null;
  }

  final entityPath = '${base.path}/$inName';
  final entityType = await FileSystemEntity.type(entityPath);

  if (entityType == FileSystemEntityType.notFound) {
    // No collision, return the original name
    logger.i('No collision: $inName');
    return inName;
  } else {
    // Collision detected, generate a new name
    String newName;
    int counter = 1;
    do {
      newName = '${inName}_$counter';
      //final newPath = '${base.path}/$newName';
      FileSystemEntityType newType = await FileSystemEntity.type('${base.path}/$newName');
      if (newType == FileSystemEntityType.notFound) {
        logger.i('New name is available: $newName');
        return newName; // New name is available
      }
      counter++;
    } while (true);
  }
}

  /// gets db file path
  ///
  /// If its used in testing context it returns null
  Future<String?> getDbFilePath() async {
    if (isTesting) {
      return null;
    }
    final homeDir = await getHomeDir();
    return homeDir?.path;
  }

  /// sync version of getDbFilePath
  ///
  /// WARN! doesn't create folder structure
  @Deprecated('Use getDbFilePath() instead')
  String? getDbFilePathSync() {
    return homeDir?.path;
  }




}

/// TODO: add class EventFiles nd maybe add class for same methods !

class EventFiles{
  String? currentEventName;
  Directory? currentEventDir;
  Future<String?> uploadZpusobilost(File file ) async {
    // copy to {eventName}/zpusobilosti
    // if collision rename
    // if success return (new)name else null
    // TODO: implement getAllZzaActions
    throw UnimplementedError();
  }
  bool testStructure (){
    if(currentEventDir != null){
      bool isOk = true;
      for (var subFolder in FileManager().subFolders) {
        Directory subDir = Directory('${currentEventDir?.path}/$subFolder');
        // test if exists
        if(! subDir.existsSync()) {
          Logger().e('Error: $subFolder does not exist');
          isOk = false;
          //TODO: implement missing directory logic
        }
        }
      return isOk;
      } return false;
    }

/// gets called when changing events
  Future<void> changeEvent() async {
    DatabaseInterface mydb = DatabaseWrapper.getDatabase();
    MemoryAction? currAction = await mydb.getCurrentAction();
    if(currAction != null) {
      currentEventName = currAction.nadpis;
      String? path = currAction.domovskyAdresarPath;
      currentEventDir = path != null ? Directory(path) : null;

    }
  }
   /// gets called when creating new event, probably call client side
  ///
  /// TODO implement update logic for MemoryAction.domovskyAdresarPath
  Future<MemoryAction?> initNewEvent(MemoryAction? event) async{
      FileManager fm = FileManager();
     if (event != null) {
  event.domovskyAdresarPath = await fm.createNewEventDataDir(event.nadpis).then((value) => value?.path);
}
     return event;
  }

}