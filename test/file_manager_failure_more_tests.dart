import 'dart:io';

import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/file_exceptions.dart';
import 'package:denik_zza/utils/file_ops_atomic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('nameCollisionSolver returns null for non-existent base directory', () async {
    final fm = FileManager(isTesting: false);
    // Use a path that should not exist
    final nonExistent = Directory('${Directory.systemTemp.path}/fm_nonexistent_base_${DateTime.now().microsecondsSinceEpoch}');
    // Ensure it does not exist
    if (await nonExistent.exists()) {
      await nonExistent.delete(recursive: true);
    }

    final result = await fm.nameCollisionSolver(nonExistent, 'something.txt');
    expect(result, isNull);
  });

  test('copyAtomic throws when destination parent is a file', () async {
    // Create a valid source file
    final src = await File('${Directory.systemTemp.path}/fm_src_copy_${DateTime.now().microsecondsSinceEpoch}.txt').create();
    await src.writeAsString('hello');

    // Create a file that will act as the destination parent (causing create to fail)
    final badParent = await File('${Directory.systemTemp.path}/fm_bad_parent_${DateTime.now().microsecondsSinceEpoch}').create();
    final destination = File('${badParent.path}/dest.txt');

    try {
      expect(() async => await copyAtomic(src, destination), throwsA(isA<FileOperationException>()));
    } finally {
      try { await src.delete(); } catch (_) {}
      try { await badParent.delete(); } catch (_) {}
    }
  });
}
