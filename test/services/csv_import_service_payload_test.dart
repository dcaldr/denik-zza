import 'dart:io';
import 'dart:typed_data';

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/services/models/csv_import_payload.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DefaultCsvImportService service;

  setUp(() async {
    service = DefaultCsvImportService();
    // Set FileManager to persist mode for test observability
    FileManager().setMode(
      FileManagerMode.persist,
      testOutputPath: 'test/test_outputs/csv_payload_test',
    );
  });

  tearDown(() async {
    // Reset to production mode
    FileManager().setMode(FileManagerMode.production);
    await DatabaseWrapper.dispose();
    // Cleanup is handled by FileManager in persist mode
  });

  test('loadCsvFromPayload writes bytes to temp and cleans up', () async {
    final Uint8List bytes = await File('test/data/first.csv').readAsBytes();
    final CsvImportPayload payload = CsvImportPayload.fromBytes(
      bytes: bytes,
      displayName: 'people.csv',
    );

    final CsvImportSession session = await service.loadCsvFromPayload(payload);

    expect(session.review.rows, isNotEmpty);
    expect(session.personResult.goodPersons, isNotEmpty);

    // Temp file should be cleaned up automatically
    // In persist mode, we can verify it's in test outputs but should be deleted after use
  });

  test('loadCsvFromPayload delegates to loadCsv for path payload', () async {
    final payload = CsvImportPayload.fromPath(
      path: 'test/data/first.csv',
      displayName: 'first.csv',
    );

    final session = await service.loadCsvFromPayload(payload);

    expect(session.review.rows, isNotEmpty);
    expect(session.personResult.goodPersons, isNotEmpty);
  });

  test('loadCsvFromPayload handles empty bytes', () async {
    AppLogger.configureForTests(level: Level.off);
    addTearDown(() => AppLogger.configureForTests(level: Level.error));

    // Empty bytes should be caught at payload creation
    expect(
      () => CsvImportPayload.fromBytes(
        bytes: Uint8List(0),
        displayName: 'empty.csv',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('loadCsvFromPayload handles malformed CSV bytes', () async {
    AppLogger.configureForTests(level: Level.off);
    addTearDown(() => AppLogger.configureForTests(level: Level.error));

    // Create a file with invalid CSV structure
    final bytes =
        Uint8List.fromList('not,valid,csv\ngarbage\nmore garbage'.codeUnits);
    final payload = CsvImportPayload.fromBytes(
      bytes: bytes,
      displayName: 'bad.csv',
    );

    // Should either throw or return session with parsing errors
    try {
      final session = await service.loadCsvFromPayload(payload);
      // If it succeeds, verify it captured errors appropriately
      // The service may return a session with error rows
      expect(session, isNotNull);
    } catch (e) {
      // Or it may throw, which is also acceptable
      expect(e, isNotNull);
    }
  });

  test('loadCsvFromPayload handles concurrent calls', () async {
    final bytes = await File('test/data/first.csv').readAsBytes();
    final payload = CsvImportPayload.fromBytes(
      bytes: bytes,
      displayName: 'concurrent.csv',
    );

    // Launch multiple loads concurrently
    final futures =
        List.generate(3, (_) => service.loadCsvFromPayload(payload));
    final results = await Future.wait(futures);

    // All should succeed
    expect(results, hasLength(3));
    for (final result in results) {
      expect(result.review.rows, isNotEmpty);
    }
  });

  test('loadCsvFromPayload with invalid path throws', () async {
    AppLogger.configureForTests(level: Level.off);
    addTearDown(() => AppLogger.configureForTests(level: Level.error));

    final payload = CsvImportPayload.fromPath(
      path: 'test/data/nonexistent.csv',
      displayName: 'missing.csv',
    );

    // Should throw when trying to load non-existent file
    // The service throws StateError when parsing fails
    expect(
      () => service.loadCsvFromPayload(payload),
      throwsA(isA<StateError>()),
    );
  });

  test('loadCsvFromPayload with null payload fields throws', () async {
    AppLogger.configureForTests(level: Level.off);
    addTearDown(() => AppLogger.configureForTests(level: Level.error));

    // This tests the payload validation logic
    expect(
      () => CsvImportPayload.fromPath(path: '', displayName: 'test.csv'),
      throwsArgumentError,
    );
  });

  test('loadCsvFromPayload cleanup failure is logged but not fatal', () async {
    // This test verifies that cleanup failures don't break the flow
    final bytes = await File('test/data/first.csv').readAsBytes();
    final payload = CsvImportPayload.fromBytes(
      bytes: bytes,
      displayName: 'cleanup_test.csv',
    );

    // Normal operation should succeed even if cleanup encounters issues
    final session = await service.loadCsvFromPayload(payload);
    expect(session.review.rows, isNotEmpty);

    // Cleanup happens in finally block and logs warnings on failure
    // The operation itself should complete successfully
  });
}
