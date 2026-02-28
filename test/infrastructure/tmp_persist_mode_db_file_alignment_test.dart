import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/input/file_manager.dart';

import '../utils/test_configuration.dart';
import '../utils/test_output_manager.dart';
import '../utils/unified_test_setup.dart';

/// Persist-mode integration: DB and FileManager should align to the same per-run directory.
///
/// What this test verifies (only meaningful in persist mode):
/// - Database file is created under test/test_outputs/persist/<runId>/
/// - FileManager writes into the SAME <runId> directory when wired via UnifiedTestSetup
/// - Basic DB operation succeeds (insert + read) to ensure the db file materializes
/// - A simple file write through FileManager lands under the same run directory
///
/// Run with:
///   flutter test --dart-define=TEST_MODE=persist test/infrastructure/tmp_persist_mode_db_file_alignment_test.dart
///
/// Note: Do NOT auto-clean persist outputs; outputs are intentionally preserved for inspection.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tmp_persist_mode_db_file_alignment_test', () {
    late AppDatabase database;
    String? runDir;

    setUp(() async {
      // Skip if not running in persist mode
      if (!TestConfiguration.isPersist) {
        return;
      }

      // Ensure base dirs exist and capture the run directory
      await TestOutputManager.initialize();
      runDir = await TestOutputManager.getOrCreatePersistRunDirectory();

      // Create database and wire FileManager to the same run directory
      database = await UnifiedTestSetup.createDatabase(
        useFileManagerPersist: true,
        useRunDir: true,
      );
    });

    tearDown(() async {
      if (!TestConfiguration.isPersist) {
        return;
      }
      // Close DB but DO NOT delete artifacts in persist mode
    });

    test(
        'persist mode: DB file and FileManager outputs align in the same run directory',
        () async {
      // Skip test body if not in persist mode
      if (!TestConfiguration.isPersist) {
        return;
      }

      // 1) Verify DB file path under runDir after a simple write to materialize the file
      final insertId = await database.addInsuranceCompany(
        InsuranceCompaniesCompanion.insert(name: 'Persist Check Company'),
      );
      expect(insertId, greaterThan(0));

      final rows = await database.select(database.insuranceCompanies).get();
      expect(rows.any((c) => c.name == 'Persist Check Company'), isTrue);

      // Allow a short delay for filesystem to flush on Windows
      await Future.delayed(const Duration(milliseconds: 75));

      // Database path expectations
      // createDatabase(useRunDir: true) uses TestOutputManager.getDatabasePath('test_database.db', useRunDir: true)
      // Internally AppDatabase treats explicit .db file path as a file and opens it directly
      final dbFile = File('${runDir!}/test_database.db');
      expect(await dbFile.exists(), isTrue,
          reason: 'DB file should exist under per-run directory');
      expect(
          dbFile.path
              .replaceAll('\\', '/')
              .startsWith(runDir!.replaceAll('\\', '/')),
          isTrue);

      // 2) Verify FileManager points to the same runDir and can write a file there
      final fm = FileManager();
      expect(fm.isPersistMode, isTrue,
          reason: 'FileManager should be in persist mode');

      final home = await fm.getHomeDir();
      expect(home, isNotNull);
      // In persist mode, UnifiedTestSetup wires FileManager to the runDir
      expect(home!.path.replaceAll('\\', '/'), runDir!.replaceAll('\\', '/'));

      // Create a tiny file in a subfolder to exercise real write
      final subDir = Directory('${home.path}/zpusobilosti');
      if (!await subDir.exists()) {
        await subDir.create(recursive: true);
      }
      final testFile = File('${subDir.path}/fm_probe.txt');
      await testFile.writeAsString('hello persist');

      // Verify file exists and is readable
      expect(await testFile.exists(), isTrue);
      final content = await testFile.readAsString();
      expect(content, 'hello persist');

      // Paths must be under the same runDir
      expect(
          testFile.path
              .replaceAll('\\', '/')
              .startsWith(runDir!.replaceAll('\\', '/')),
          isTrue);
    });
  });
}
