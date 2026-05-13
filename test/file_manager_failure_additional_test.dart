import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/file_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('putZpusobilost throws when eventDir is null', () async {
    final fm = FileManager(isTesting: false);
    // ensure eventDir is null
    fm.eventDir = null;

    // create a temporary file to pass as picked file
    final temp = await Directory.systemTemp.createTemp('fm_test_eventnull_');
    try {
      final src = File('${temp.path}/dummy.txt');
      await src.writeAsString('hello');

      expect(() async => await fm.putZpusobilost(src), throwsA(isA<FileOperationException>()));
    } finally {
      await temp.delete(recursive: true);
    }
  });

  test('getZpusobilostFolder throws typed exception when eventDir is null',
      () async {
    final fm = FileManager(isTesting: false);
    fm.eventDir = null;

    expect(
      () async => await fm.getZpusobilostFolder(),
      throwsA(isA<FileOperationException>()),
    );
  });
}
