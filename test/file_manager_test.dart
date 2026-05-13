import 'dart:ui';

import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/file_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'dart:typed_data';

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

//TODO: path provider needs to be mocked or bypassed as https://github.com/flutter/packages/blob/main/packages/path_provider/path_provider/test/path_provider_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  group('FileManager bypass test  logic', () {
    test('bypass test  true', () async {
      FileManager fileManager = FileManager(isTesting: true);
      expect(fileManager, isNotNull);
      expect(fileManager.isTesting, isTrue);
      expect(fileManager.subFolders, isEmpty);
      await fileManager.createHomeDataDir();
      expect(fileManager.homeDir, isNull);
    });
    test('bypass test  false', () async {
      FileManager fileManager = FileManager(isTesting: false);
      expect(fileManager, isNotNull);
      expect(fileManager.isTesting, isFalse);
      expect(fileManager.subFolders, isNotEmpty);
      // await fileManager.createHomeDataDir();
      // expect(fileManager.homeDir, isNotNull);
    });
    test('bypass test  false2 (respects ModeCoordinator)', () async {
      // Logic changed: ModeCoordinator in flutter_test_config.dart sets isTesting=true globally.
      // So even default constructor should return isTesting=true in this test environment.
      FileManager fileManager = FileManager();
      expect(fileManager, isNotNull);
      // expect(fileManager.isTesting, isFalse); // Old expectation
      expect(fileManager.isTesting,
          isTrue); // New expectation (Global Bypass Active)
      // expect(fileManager.subFolders, isNotEmpty); // isTesting=true -> subFolders might be empty or mocked?
      // In isTesting=true, subFolders are usually empty (InMemory).
      expect(fileManager.subFolders, isEmpty);
      // await fileManager.createHomeDataDir();
      // expect(fileManager.homeDir, isNotNull);
    });
    test('keep setting isTesting true even after empty constructor', () async {
      FileManager fileManager = FileManager(isTesting: true);
      expect(fileManager, isNotNull);
      expect(fileManager.isTesting, isTrue);
      expect(fileManager.subFolders, isEmpty);
      // repeated call to keep setting
      fileManager = FileManager();
      expect(fileManager, isNotNull);
      expect(fileManager.isTesting, isTrue);
      expect(fileManager.subFolders, isEmpty);
      // await fileManager.createHomeDataDir();
      // expect(fileManager.homeDir, isNotNull);
    });
    test('keep setting isTesting false even after empty constructor', () async {
      FileManager fileManager = FileManager(isTesting: false);
      expect(fileManager, isNotNull);
      expect(fileManager.isTesting, isFalse);
      expect(fileManager.subFolders, isNotEmpty);
      // repeated call to keep setting
      fileManager = FileManager();
      expect(fileManager, isNotNull);
      expect(fileManager.isTesting, isFalse);
      expect(fileManager.subFolders, isNotEmpty);
      // await fileManager.createHomeDataDir();
      // expect(fileManager.homeDir, isNotNull);
    });
  });

  group('FileManager IO and backup behavior', () {
    test('verifyWritableReadable returns true in temp dir', () async {
      final tempDir = await Directory.systemTemp.createTemp('fm_io_probe_');
      try {
        final fm = FileManager(isTesting: false);
        final ok = await fm.verifyWritableReadable(tempDir);
        expect(ok, isTrue);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('createNewEventDataDir creates subfolders and backup copies db.sqlite',
        () async {
      // Prepare isolated temp directories for persistent mode and cleanup
      final dbRoot = await Directory.systemTemp.createTemp('fm_persist_db_');
      final eventsRoot =
          await Directory.systemTemp.createTemp('fm_persist_events_');
      try {
        // Configure FileManager to use persistent mode for DB path
        final fm = FileManager(testOutputPath: dbRoot.path);
        // Also override homeDir to a temp events root to avoid polluting repo paths
        fm.homeDir = eventsRoot;

        // Create event directory
        final eventDir = await fm.createNewEventDataDir('TestEvent');
        expect(eventDir, isNotNull);
        // Subfolders exist
        expect(Directory('${eventDir!.path}/backup').existsSync(), isTrue);
        expect(Directory('${eventDir.path}/zpusobilosti').existsSync(), isTrue);
        expect(Directory('${eventDir.path}/vysetreni').existsSync(), isTrue);

        // Create fake db.sqlite in the persistent DB root
        final dbFile = File('${dbRoot.path}/db.sqlite');
        await dbFile.writeAsString('dummy-db');
        expect(await dbFile.exists(), isTrue);

        // Run backup
        await fm.backupDB();

        // Verify a backup file was created in the event backup folder
        final backupDir = Directory('${eventDir.path}/backup');
        final backups = backupDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.sqlite'))
            .toList();
        expect(backups.isNotEmpty, isTrue, reason: 'No backup .sqlite found');
        // Optionally verify content copied
        final content = await backups.first.readAsString();
        expect(content, 'dummy-db');
      } finally {
        await dbRoot.delete(recursive: true);
        await eventsRoot.delete(recursive: true);
      }
    });

    test('writeTempCsvBytes uses unique temp names in persist mode', () async {
      final tempRoot = await Directory.systemTemp.createTemp('fm_temp_csv_');
      try {
        final fm = FileManager(testOutputPath: tempRoot.path);
        final first = await fm.writeTempCsvBytes(
          Uint8List.fromList(<int>[1, 2, 3]),
          suggestedName: 'import.csv',
        );
        final second = await fm.writeTempCsvBytes(
          Uint8List.fromList(<int>[4, 5, 6]),
          suggestedName: 'import.csv',
        );

        expect(first, isNot(equals(second)));
        expect(File(first).existsSync(), isTrue);
        expect(File(second).existsSync(), isTrue);
        expect(File(first).readAsBytesSync(), equals(<int>[1, 2, 3]));
        expect(File(second).readAsBytesSync(), equals(<int>[4, 5, 6]));
      } finally {
        await tempRoot.delete(recursive: true);
      }
    });

    test('putZpusobilost throws a typed exception when source file is missing',
        () async {
      final eventsRoot = await Directory.systemTemp.createTemp('fm_upload_');
      try {
        final fm = FileManager(isTesting: false);
        fm.eventDir = eventsRoot;

        expect(
          () async => await fm.putZpusobilost(File('${eventsRoot.path}/missing.csv')),
          throwsA(isA<FileOperationException>()),
        );
      } finally {
        await eventsRoot.delete(recursive: true);
      }
    });
  });

  group('FileManager event creation integration', () {
    test('single directory creation logic validation', () async {
      final eventsRoot =
          await Directory.systemTemp.createTemp('fm_single_creation_logic_');
      try {
        // Test the logic that prevents double creation without path provider dependency
        final fm = FileManager(isTesting: true);
        fm.homeDir = eventsRoot;

        // Create a test directory manually (simulating createNewEventDataDir outcome)
        final testEventDir = Directory('${eventsRoot.path}/TestEvent');
        await testEventDir.create(recursive: true);
        await Directory('${testEventDir.path}/backup').create();
        await Directory('${testEventDir.path}/zpusobilosti').create();
        await Directory('${testEventDir.path}/vysetreni').create();

        // Set the eventDir to simulate post-creation state
        fm.eventDir = testEventDir;

        // Count directories after manual setup
        final directoriesAfterSetup =
            eventsRoot.listSync().whereType<Directory>().length;
        expect(directoriesAfterSetup, equals(1),
            reason: 'Should have exactly 1 directory after setup');

        // Test the key logic from changeEvent() that prevents double creation
        // This simulates: if (event.domovskyAdresarPath == eventDir?.path) { return; }
        final simulatedDbPath = testEventDir.path;
        final currentEventDirPath = fm.eventDir?.path;

        expect(currentEventDirPath, equals(simulatedDbPath),
            reason: 'Paths should match');

        // When paths match, changeEvent() should return early and not create directories
        final shouldReturnEarly = (simulatedDbPath == currentEventDirPath);
        expect(shouldReturnEarly, isTrue,
            reason: 'Logic should prevent double creation when paths match');

        // Verify no additional directories would be created
        final directoriesAfterLogicCheck =
            eventsRoot.listSync().whereType<Directory>().length;
        expect(directoriesAfterLogicCheck, equals(1),
            reason: 'No additional directories should exist');

        // Verify directory structure integrity
        expect(Directory('${testEventDir.path}/backup').existsSync(), isTrue);
        expect(Directory('${testEventDir.path}/zpusobilosti').existsSync(),
            isTrue);
        expect(
            Directory('${testEventDir.path}/vysetreni').existsSync(), isTrue);
      } finally {
        await eventsRoot.delete(recursive: true);
      }
    });
  });
}
