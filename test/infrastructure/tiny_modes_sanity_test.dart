import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_configuration.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';
import '../utils/test_output_manager.dart';
import '../utils/unified_test_setup.dart';
import 'package:denik_zza/database/drift_database/database.dart';

void main() {
  group('Tiny mode sanity checks', () {
    group('inMemory mode', () {
      test('getDatabasePath returns empty and no dirs created', () async {
        // Skip if not running in inMemory mode
        if (!TestConfiguration.isInMemory) {
          return; // no-op in other modes
        }

        // Ensure clean slate (only for in-memory mode to avoid interfering with other modes)
        await TestOutputManager.cleanup();

        // Initialize (should not create any test/test_outputs directories)
        await TestOutputManager.initialize();

        final dbPath = await TestOutputManager.getDatabasePath('tiny.db');
        expect(dbPath, isEmpty);

        final outputsDir = Directory(TestOutputManager.getTestOutputsDir());
        expect(await outputsDir.exists(), false);
      });
    });

    group('persist mode', () {
      test('persists data across reopen with per-run directory', () async {
        // Skip unless explicitly running with --dart-define=TEST_MODE=persist
        if (!TestConfiguration.isPersist) {
          return;
        }

        await TestOutputManager.initialize();

        // Use per-run directory to avoid collisions
        const fname = 'tiny_persist_test.db';
        final dbPath =
            await TestOutputManager.getDatabasePath(fname, useRunDir: true);

        // Create DB, write a record into a tiny test table, close, reopen, and verify
        var db = AppDatabase(dbPath);
        await db.customStatement(
            'CREATE TABLE IF NOT EXISTS __tiny_test (id INTEGER PRIMARY KEY, note TEXT)');
        await db
            .customStatement("INSERT INTO __tiny_test (note) VALUES ('hello')");
        await db.close();

        db = AppDatabase(dbPath);
        final row = await db
            .customSelect('SELECT COUNT(*) AS c FROM __tiny_test')
            .getSingle();
        final count = row.data['c'] as int;
        expect(count >= 1, true);
        await db.close();

        // Verify file exists where expected
        final file = File(dbPath);
        expect(await file.exists(), true);
        expect(dbPath.contains('test/test_outputs'), true);
        expect(dbPath.contains('persist'), true);
      });
    });

    group('production mode safety', () {
      test('throws when attempting to initialize without confirmation',
          () async {
        AppLogger.configureForTests(level: Level.off);
        addTearDown(() => AppLogger.configureForTests(level: Level.error));

        // Only meaningful when compiled for production mode
        if (!TestConfiguration.isProduction) {
          return;
        }

        // If confirmation not provided, isProductionSafe should be false
        if (!TestConfiguration.isProductionSafe) {
          // TestOutputManager.initialize should throw when production and not confirmed
          await expectLater(
            TestOutputManager.initialize(),
            throwsA(isA<Exception>()),
          );

          // UnifiedTestSetup.createDatabase should also throw
          await expectLater(
            UnifiedTestSetup.createDatabase(),
            throwsA(isA<Exception>()),
          );
        }
      });

      test(
          'with confirmation, uses production outputs but still isolated under test/test_outputs/production',
          () async {
        // This test only runs in production mode with CONFIRM_PRODUCTION_TESTING=yes
        if (!(TestConfiguration.isProduction &&
            TestConfiguration.isProductionSafe)) {
          return;
        }

        await TestOutputManager.initialize();
        final dbPath = await TestOutputManager.getDatabasePath(
            'tiny_production_test.db',
            useRunDir: true);
        expect(dbPath.contains('test/test_outputs'), true);
        expect(dbPath.contains('production'), true);

        // Sanity: open and close DB
        final db = AppDatabase(dbPath);
        await db.customSelect('SELECT 1').getSingle();
        await db.close();
      });
    });
  });
}
