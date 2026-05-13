import 'dart:io';

import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/file_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('preflightWrite succeeds for writable temp dir', () async {
    final tmp = await Directory.systemTemp.createTemp('fm_preflight_ok_');
    try {
      final fm = FileManager(isTesting: false);
      await fm.preflightWrite(tmp);
      // If no exception, test passes
      expect(true, isTrue);
    } finally {
      try { await tmp.delete(recursive: true); } catch (_) {}
    }
  });

  test('preflightWrite throws for non-directory path', () async {
    final file = await File('${Directory.systemTemp.path}/fm_preflight_file_${DateTime.now().microsecondsSinceEpoch}').create();
    try {
      final fm = FileManager(isTesting: false);
      expect(() async => await fm.preflightWrite(Directory(file.path)), throwsA(isA<FileOperationException>()));
    } finally {
      try { await file.delete(); } catch (_) {}
    }
  });
}
