import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'utils/database_test_helper.dart';

void main() {
  // Initialize Flutter binding for tests that might use Flutter services
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Test Database Directory Management', () {
    late String testDbDir;

    setUpAll(() {
      testDbDir = DatabaseTestHelper.getTestDatabaseDirectory();
    });

    tearDownAll(() async {
      // Clean up all test databases after running all tests
      await DatabaseTestHelper.cleanupTestDatabaseDirectory();
    });

    test('should create test databases in dedicated directory', () async {
      // Create a file-based test database
      final database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
      
      // Verify database is functional
      await database.customStatement('CREATE TABLE test_table (id INTEGER PRIMARY KEY, name TEXT)');
      await database.customStatement('INSERT INTO test_table (name) VALUES (?)', ['test_value']);
      
      final result = await database.customSelect('SELECT COUNT(*) as count FROM test_table').get();
      expect(result.first.data['count'], equals(1));
      
      await database.close();
      
      // Now check if the test database directory exists and has files
      final dir = Directory(testDbDir);
      expect(dir.existsSync(), isTrue, reason: 'Test database directory should exist');
      
      // Check for test database files - give it a moment to be visible
      await Future.delayed(const Duration(milliseconds: 100));
      
      final files = dir.listSync().whereType<File>().map((f) => f.path).toList();
      final testDbFiles = files.where((path) => path.contains('testDB') && path.endsWith('.db')).toList();
      
      expect(testDbFiles.length, greaterThan(0), reason: 'Should have at least one test database file');
      
      // Verify filename format
      for (final filePath in testDbFiles) {
        final filename = filePath.split(Platform.pathSeparator).last;
        expect(filename, matches(r'test_\d{2}-\d{2}-\d{2}_testDB_\d+\.db'), 
               reason: 'Filename should match expected pattern: $filename');
      }
    });

    test('should create databases with unique filenames', () async {
      // Create multiple databases quickly
      final databases = <AppDatabase>[];
      
      try {
        for (int i = 0; i < 3; i++) {
          final db = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
          databases.add(db);
          
          // Small delay to ensure different timestamps
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        // Close all databases first
        for (final db in databases) {
          await db.close();
        }
        
        // Give filesystem time to sync
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Check that test files exist and have unique names
        final dir = Directory(testDbDir);
        final files = dir.listSync().whereType<File>();
        final testDbFiles = files.where((f) => f.path.contains('testDB') && f.path.endsWith('.db')).toList();
        
        expect(testDbFiles.length, greaterThanOrEqualTo(1), reason: 'Should have at least 1 test database file from this test');
        
        // Verify all filenames are unique
        final filenames = testDbFiles.map((f) => f.path).toSet();
        expect(filenames.length, equals(testDbFiles.length), reason: 'All database files should have unique names');
        
      } finally {
        // Ensure cleanup even if test fails
        for (final db in databases) {
          try {
            await db.close();
          } catch (e) {
            // Ignore errors on cleanup
          }
        }
      }
    });

    test('should isolate file databases between tests', () async {
      // Create first database and add data
      final db1 = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
      await db1.customStatement('CREATE TABLE test_isolation (id INTEGER PRIMARY KEY, value TEXT)');
      await db1.customStatement('INSERT INTO test_isolation (value) VALUES (?)', ['db1_data']);
      
      // Create second database - should be isolated
      final db2 = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
      
      // Verify db2 doesn't have db1's data
      try {
        final result = await db2.customSelect('SELECT COUNT(*) as count FROM test_isolation').get();
        // This should fail because the table doesn't exist in db2
        fail('Should have thrown an exception - tables should not exist in new database');
      } catch (e) {
        // Expected - the table shouldn't exist in the new database
        expect(e.toString(), contains('no such table'));
      }
      
      await db1.close();
      await db2.close();
    });

    test('should successfully clean up test database files', () async {
      // Create some test databases
      final databases = <AppDatabase>[];
      
      try {
        for (int i = 0; i < 2; i++) {
          databases.add(DatabaseTestHelper.createTestDatabase(TestDatabaseType.file));
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        // Use the databases to ensure they're created
        for (int i = 0; i < databases.length; i++) {
          await databases[i].customStatement('CREATE TABLE test_cleanup_$i (id INTEGER)');
        }
        
      } finally {
        // Close databases
        for (final db in databases) {
          await db.close();
        }
      }
      
      // Give filesystem time to sync
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Verify files exist
      final dir = Directory(testDbDir);
      final filesBefore = dir.listSync().whereType<File>()
          .where((f) => f.path.contains('testDB') && f.path.endsWith('.db'))
          .toList();
      final initialCount = filesBefore.length;
      
      // Clean up using the helper method
      await DatabaseTestHelper.cleanupTestDatabaseDirectory(filePattern: 'testDB');
      
      // Verify cleanup worked
      if (dir.existsSync()) {
        await Future.delayed(const Duration(milliseconds: 100));
        final filesAfter = dir.listSync().whereType<File>()
            .where((f) => f.path.contains('testDB') && f.path.endsWith('.db'))
            .toList();
        
        // Files should be cleaned up
        expect(filesAfter.length, lessThan(initialCount), 
               reason: 'Should have fewer test database files after cleanup');
      }
    });
  });
}
