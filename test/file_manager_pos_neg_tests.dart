import 'dart:io';
import 'dart:typed_data';

import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/file_exceptions.dart';
import 'package:denik_zza/utils/file_ops_atomic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('copyAtomic copies file successfully', () async {
    final src = await File('${Directory.systemTemp.path}/fm_copy_src_${DateTime.now().microsecondsSinceEpoch}.bin').create();
    await src.writeAsBytes([1, 2, 3, 4]);

    final destDir = await Directory.systemTemp.createTemp('fm_copy_dest_');
    final dest = File('${destDir.path}/out.bin');

    try {
      final result = await copyAtomic(src, dest);
      expect(await result.exists(), isTrue);
      expect(await result.readAsBytes(), equals([1, 2, 3, 4]));
    } finally {
      try { await src.delete(); } catch (_) {}
      try { await destDir.delete(recursive: true); } catch (_) {}
    }
  });

  test('writeBytesAtomic writes bytes successfully', () async {
    final tmpDir = await Directory.systemTemp.createTemp('fm_writebytes_');
    final target = File('${tmpDir.path}/blob.bin');
    try {
      final bytes = Uint8List.fromList([9, 8, 7]);
      final written = await writeBytesAtomic(target, bytes);
      expect(await written.exists(), isTrue);
      expect(await written.readAsBytes(), equals(bytes));
    } finally {
      try { await tmpDir.delete(recursive: true); } catch (_) {}
    }
  });

  test('putZpusobilost copies file successfully', () async {
    final eventsRoot = await Directory.systemTemp.createTemp('fm_upload_pos_');
    try {
      final fm = FileManager(isTesting: false);
      fm.eventDir = eventsRoot;

      final src = File('${eventsRoot.path}/src_upload.txt');
      await src.writeAsString('uploaded');

      final newName = await fm.putZpusobilost(src);
      final saved = File('${eventsRoot.path}/zpusobilosti/$newName');
      expect(await saved.exists(), isTrue);
      expect(await saved.readAsString(), equals('uploaded'));
    } finally {
      try { await eventsRoot.delete(recursive: true); } catch (_) {}
    }
  });

  test('nameCollisionSolver returns incremented name when collision exists', () async {
    final base = await Directory.systemTemp.createTemp('fm_collision_');
    try {
      final file = File('${base.path}/file.txt');
      await file.writeAsString('x');
      final fm = FileManager(isTesting: false);
      final newName = await fm.nameCollisionSolver(base, 'file.txt');
      expect(newName, isNotNull);
      expect(newName, isNot('file.txt'));
      expect(newName!.endsWith('.txt'), isTrue);
    } finally {
      try { await base.delete(recursive: true); } catch (_) {}
    }
  });

  // Note: filesystem permission and base-path-as-file negative cases can be
  // platform-dependent and flaky in CI; cover those with integration tests.

  test('putZpusobilost rejects oversized file', () async {
    final eventsRoot = await Directory.systemTemp.createTemp('fm_upload_large_');
    try {
      final fm = FileManager(isTesting: false);
      fm.eventDir = eventsRoot;

      final large = File('${Directory.systemTemp.path}/fm_large_${DateTime.now().microsecondsSinceEpoch}.bin');
      // create ~6MB file
      final bytes = List<int>.filled(6 * 1024 * 1024, 0);
      await large.writeAsBytes(bytes);

      expect(() async => await fm.putZpusobilost(large), throwsA(isA<FileOperationException>()));
    } finally {
      try { await eventsRoot.delete(recursive: true); } catch (_) {}
    }
  });
}
