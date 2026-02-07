import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'utils/database_test_helper.dart';
import 'utils/test_configuration.dart';

void main() {
  // Initialize Flutter binding for tests that might use Flutter services
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Test Database Directory Management', () {
    late String testDbDir;

    setUpAll(() {
      testDbDir = Directory(DatabaseTestHelper.getTestDatabaseDirectory())
          .absolute
          .path;
    });

    tearDownAll(() async {
      // Clean up all test databases after running all tests
      await DatabaseTestHelper.cleanupTestDatabaseDirectory();
    });

    test('should create test databases in dedicated directory', () async {
      if (!TestConfiguration.isPersist) {
        markTestSkipped('Requires TEST_MODE=persist (on-disk checks).');
        return;
      }
      // Create a file-based test database
      final database =
          DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);

      // Verify database is functional
      await database.customStatement(
          'CREATE TABLE test_table (id INTEGER PRIMARY KEY, name TEXT)');
      await database.customStatement(
          'INSERT INTO test_table (name) VALUES (?)', ['test_value']);

      final result = await database
          .customSelect('SELECT COUNT(*) as count FROM test_table')
          .get();
      expect(result.first.data['count'], equals(1));

      await database.close();

      // Now check if the test database directory exists and has files
      final dir = Directory(testDbDir);
      expect(dir.existsSync(), isTrue,
          reason: 'Test database directory should exist');

      // Check for test database files - give it a moment to be visible
      await Future.delayed(const Duration(milliseconds: 100));

      final files =
          dir.listSync().whereType<File>().map((f) => f.path).toList();
      final testDbFiles = files
          .where((path) => path.contains('testDB') && path.endsWith('.db'))
          .toList();

      expect(testDbFiles.length, greaterThan(0),
          reason: 'Should have at least one test database file');

      // Verify filename format
      for (final filePath in testDbFiles) {
        final filename = filePath.split(Platform.pathSeparator).last;
        expect(filename, matches(r'test_\d{2}-\d{2}-\d{2}_testDB_\d+\.db'),
            reason: 'Filename should match expected pattern: $filename');
      }
    });

    test('should create databases with unique filenames', () async {
      if (!TestConfiguration.isPersist) {
        markTestSkipped('Requires TEST_MODE=persist (on-disk checks).');
        return;
      }
      // Create multiple databases quickly and track their exact file paths
      final databases = <AppDatabase>[];
      final createdPaths = <String>[];

      try {
        for (int i = 0; i < 3; i++) {
          final db =
              DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
          databases.add(db);
          // Force file creation by performing a write on each DB
          await db.customStatement(
              'CREATE TABLE IF NOT EXISTS _unique_test_$i (id INTEGER)');
          final path = DatabaseTestHelper.getDatabaseFilePath(db);
          if (path != null) {
            createdPaths.add(path);
          }
          // Small delay to reduce timestamp collision chances on some filesystems
          await Future.delayed(const Duration(milliseconds: 10));
        }

        // Close all databases first
        for (final db in databases) {
          await db.close();
        }

        // Wait for all files to appear on disk (NativeDatabase.createInBackground can delay creation)
        Future<void> waitForAllFiles(List<String> paths) async {
          const totalWaitMs = 3000;
          const stepMs = 100;
          int waited = 0;
          bool allExist() => paths.every((p) => File(p).existsSync());
          while (waited < totalWaitMs && !allExist()) {
            await Future.delayed(const Duration(milliseconds: stepMs));
            waited += stepMs;
          }
        }

        await waitForAllFiles(createdPaths);

        // We expect 3 distinct paths (one per created database)
        expect(createdPaths.length, greaterThanOrEqualTo(3),
            reason:
                'Expected at least 3 database instances created by this test');

        // Verify that each recorded path exists on disk and matches expected pattern
        for (final p in createdPaths) {
          expect(File(p).existsSync(), isTrue,
              reason: 'Database file should exist: $p');
          final filename = p.split(Platform.pathSeparator).last;
          expect(filename, matches(r'test_\d{2}-\d{2}-\d{2}_testDB_\d+\.db'),
              reason: 'Filename should match expected pattern: $filename');
        }

        // Verify the paths are unique
        final unique = createdPaths.toSet();
        expect(unique.length, equals(createdPaths.length),
            reason: 'Newly created database files must have unique paths');
      } finally {
        // Ensure cleanup even if test fails
        for (final db in databases) {
          try {
            await db.close();
          } catch (_) {}
        }
      }
    });

    test('should isolate file databases between tests', () async {
      if (!TestConfiguration.isPersist) {
        markTestSkipped('Requires TEST_MODE=persist (on-disk checks).');
        return;
      }
      // Create first database and add data
      final db1 = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
      await db1.customStatement(
          'CREATE TABLE test_isolation (id INTEGER PRIMARY KEY, value TEXT)');
      await db1.customStatement(
          'INSERT INTO test_isolation (value) VALUES (?)', ['db1_data']);

      // Create second database - should be isolated
      final db2 = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);

      // Verify db2 doesn't have db1's data
      try {
        await db2
            .customSelect('SELECT COUNT(*) as count FROM test_isolation')
            .get();
        // This should fail because the table doesn't exist in db2
        fail(
            'Should have thrown an exception - tables should not exist in new database');
      } catch (e) {
        // Expected - the table shouldn't exist in the new database
        expect(e.toString(), contains('no such table'));
      }

      await db1.close();
      await db2.close();
    });

    test('should successfully clean up test database files', () async {
      // IMPORTANT: We only clean files created by THIS test to prove cleanup
      // works. In persist mode, other files are intentionally preserved for
      // manual inspection and debugging.
      if (!TestConfiguration.isPersist) {
        markTestSkipped('Requires TEST_MODE=persist (on-disk checks).');
        return true;
      }
      // Track files before this test
      final dir = Directory(testDbDir);
      final before =
          dir.listSync().whereType<File>().map((f) => f.path).toSet();

      // Create some test databases
      final databases = <AppDatabase>[];

      try {
        for (int i = 0; i < 2; i++) {
          databases.add(
              DatabaseTestHelper.createTestDatabase(TestDatabaseType.file));
          await Future.delayed(const Duration(milliseconds: 10));
        }

        // Use the databases to ensure they're created
        for (int i = 0; i < databases.length; i++) {
          await databases[i]
              .customStatement('CREATE TABLE test_cleanup_$i (id INTEGER)');
        }
      } finally {
        // Close databases
        for (final db in databases) {
          await db.close();
        }
      }

      // Give filesystem time to sync
      await Future.delayed(const Duration(milliseconds: 150));

      // Identify only files created by THIS test
      final after = dir.listSync().whereType<File>().map((f) => f.path).toSet();
      final createdByThisTest = after
          .difference(before)
          .where((p) => p.contains('testDB') && p.endsWith('.db'))
          .toList();

      // Sanity: ensure we actually created some files to clean
      expect(createdByThisTest, isNotEmpty,
          reason: 'This test must create some test database files');

      // Clean up only the files created by this test to avoid interfering with
      // other tests running in parallel.
      await DatabaseTestHelper.cleanupSpecificTestFiles(createdByThisTest);

      // Retry a few times to avoid Windows file-lock hiccups
      Future<bool> allDeleted() async {
        final existing =
            createdByThisTest.where((p) => File(p).existsSync()).toList();
        return existing.isEmpty;
      }

      const totalWaitMs = 2000;
      const stepMs = 150;
      int waited = 0;
      while (waited < totalWaitMs && !await allDeleted()) {
        await Future.delayed(const Duration(milliseconds: stepMs));
        waited += stepMs;
      }

      // Verify the specific files created in this test are gone
      final stillThere =
          createdByThisTest.where((p) => File(p).existsSync()).toList();
      expect(stillThere, isEmpty,
          reason: 'Cleanup should delete files created by this test');
    });
  });
}
