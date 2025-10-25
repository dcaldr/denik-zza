import 'dart:io';
import 'dart:typed_data';

import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/services/models/csv_import_payload.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.tempPath);

  final String tempPath;

  @override
  Future<String?> getTemporaryPath() async => tempPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CsvImportService service;
  late PathProviderPlatform originalPlatform;
  late Directory tempDir;

  setUp(() async {
    service = CsvImportService();
    originalPlatform = PathProviderPlatform.instance;
    tempDir = await Directory.systemTemp.createTemp('csv_payload_test');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
  });

  tearDown(() async {
    PathProviderPlatform.instance = originalPlatform;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('loadCsvFromPayload writes bytes to temp and cleans up', () async {
    final Uint8List bytes =
        await File('test/data/first.csv').readAsBytes();
    final CsvImportPayload payload = CsvImportPayload.fromBytes(
      bytes: bytes,
      displayName: 'people.csv',
    );

    final CsvImportSession session =
        await service.loadCsvFromPayload(payload);

    expect(session.review.rows, isNotEmpty);
    expect(session.personResult.goodPersons, isNotEmpty);

    final String expectedPath = p.join(tempDir.path, 'people.csv');
    expect(File(expectedPath).existsSync(), isFalse);
  });
}
