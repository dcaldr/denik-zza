

import 'dart:ui';

import 'package:denik_zza/input/file_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

//TODO: path provider needs to be mocked or bypassed as https://github.com/flutter/packages/blob/main/packages/path_provider/path_provider/test/path_provider_test.dart
main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  group('FileManager bypass test  logic',(){
    test('bypass test  true',() async {
      FileManager fileManager = FileManager(isTesting: true);
      expect(fileManager, isNotNull);
      expect(fileManager.isTesting, isTrue);
      expect(fileManager.subFolders, isEmpty);
      await fileManager.createHomeDataDir();
      expect(fileManager.homeDir, isNull);
    });
    test('bypass test  false',() async {
      FileManager fileManager = FileManager(isTesting: false);
      expect(fileManager, isNotNull);
      expect(fileManager.isTesting, isFalse);
      expect(fileManager.subFolders, isNotEmpty);
      // await fileManager.createHomeDataDir();
      // expect(fileManager.homeDir, isNotNull);
    });
    test('bypass test  false2',() async {
      FileManager fileManager = FileManager();
      expect(fileManager, isNotNull);
      expect(fileManager.isTesting, isFalse);
      expect(fileManager.subFolders, isNotEmpty);
      // await fileManager.createHomeDataDir();
      // expect(fileManager.homeDir, isNotNull);
    });
    test('keep setting isTesting true even after empty constructor',() async {
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
    test('keep setting isTesting false even after empty constructor',() async {
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
}