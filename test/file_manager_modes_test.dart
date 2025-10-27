import 'dart:io';

import 'package:denik_zza/input/file_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileManager mode transitions', () {
    test('inMemory -> persist -> production transitions keep subFolders consistent', () async {
      final fm = FileManager(isTesting: true); // inMemory
      expect(fm.currentMode, FileManagerMode.inMemory);
      expect(fm.subFolders, isEmpty);

      final temp = await Directory.systemTemp.createTemp('fm_modes_');
      try {
        fm.setPersistentTestMode(temp.path);
        expect(fm.currentMode, FileManagerMode.persist);
        expect(fm.subFolders, containsAll(['backup','zpusobilosti','vysetreni']));

        fm.resetToProduction();
        expect(fm.currentMode, FileManagerMode.production);
        expect(fm.subFolders, containsAll(['backup','zpusobilosti','vysetreni']));
      } finally {
        await temp.delete(recursive: true);
      }
    });
  });
}
