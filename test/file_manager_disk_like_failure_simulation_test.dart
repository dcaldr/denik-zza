import 'dart:io';
import 'dart:typed_data';

import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/file_exceptions.dart';
import 'package:denik_zza/utils/file_ops_atomic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    // Always restore default behavior for other tests.
    resetFileOpsAtomicTestHooks();
  });

  test('writeTempCsvBytes maps disk-like write failure to TempFileException',
      () async {
    final baseDir = await Directory.systemTemp.createTemp('fm_disk_like_temp_');
    try {
      // Simulate a realistic "no space left" write failure.
      setFileOpsAtomicTestHooks(
        writeHook: (target, bytes) async {
          throw FileSystemException(
            'No space left on device',
            target.path,
            const OSError('No space left on device', 28),
          );
        },
      );

      final fm = FileManager(testOutputPath: baseDir.path);

      expect(
        () async => await fm.writeTempCsvBytes(
          Uint8List.fromList([1, 2, 3]),
          suggestedName: 'sample.csv',
        ),
        throwsA(isA<TempFileException>()),
      );
    } finally {
      try {
        await baseDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  test('putZpusobilost maps disk-like copy failure to FileOperationException',
      () async {
    final eventDir = await Directory.systemTemp.createTemp('fm_disk_like_upload_');
    try {
      // Simulate copy failure due to storage exhaustion.
      setFileOpsAtomicTestHooks(
        copyHook: (source, destination) async {
          throw FileSystemException(
            'No space left on device',
            destination.path,
            const OSError('No space left on device', 28),
          );
        },
      );

      final fm = FileManager(isTesting: false);
      fm.eventDir = eventDir;

      final src = File('${eventDir.path}/src_for_upload.txt');
      await src.writeAsString('payload');

      expect(
        () async => await fm.putZpusobilost(src),
        throwsA(isA<FileOperationException>()),
      );
    } finally {
      try {
        await eventDir.delete(recursive: true);
      } catch (_) {}
    }
  });
}
