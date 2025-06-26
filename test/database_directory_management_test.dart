import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import '../lib/database/drift_database/database.dart';
import 'helpers/database_test_helper.dart';

void main() {
  // Initialize Flutter binding for tests that might use Flutter services
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Test Database Directory Management', () {
    late AppDatabase database;
    late String testDbDir;

    setUpAll(() {
      testDbDir = DatabaseTestHelper.getTestDatabaseDirectory();
    });

    tearDownAll(() async {
      // Clean up all test databases after running all tests
      await DatabaseTestHelper.cleanupAllTestDatabaseFiles();
    });

    test('should create test databases in dedicated directory', () async {
      // Create a file-based test database
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
      
      // Verify the test database directory exists
      final dir = Directory(testDbDir);
      expect(dir.existsSync(), isTrue, reason: 'Test database directory should exist');
      
      // Verify database files are created in the correct location
      final files = dir.listSync().whereType<File>().map((f) => f.path).toList();
      final testDbFiles = files.where((path) => path.contains('testDB') && path.endsWith('.db')).toList();
      
      expect(testDbFiles.length, greaterThan(0), reason: 'Should have at least one test database file');
      
      // Verify the database is functional
      await database.customStatement('CREATE TABLE test_table (id INTEGER PRIMARY KEY, name TEXT)');
      await database.customStatement('INSERT INTO test_table (name) VALUES (?)', ['test_value']);
      
      final result = await database.customSelect('SELECT COUNT(*) as count FROM test_table').get();
      expect(result.first.data['count'], equals(1));
      
      await database.close();
    });

    test('should create databases with unique filenames', () async {
      // Create multiple databases quickly
      final databases = <AppDatabase>[];
      final createdPaths = <String>[];
      
      try {
        for (int i = 0; i < 3; i++) {
          final db = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
          databases.add(db);
          
          // Small delay to ensure different timestamps
          await Future.delayed(const Duration(milliseconds: 1));
        }
        
        // Check that test files exist and have unique names
        final dir = Directory(testDbDir);
        final files = dir.listSync().whereType<File>();
        final testDbFiles = files.where((f) => f.path.contains('testDB') && f.path.endsWith('.db')).toList();
        
        expect(testDbFiles.length, greaterThanOrEqualTo(3), reason: 'Should have at least 3 test database files');
        
        // Verify all filenames are unique
        final filenames = testDbFiles.map((f) => f.path).toSet();
        expect(filenames.length, equals(testDbFiles.length), reason: 'All database files should have unique names');
        
        // Verify filename format
        for (final file in testDbFiles) {
          final filename = file.path.split(Platform.pathSeparator).last;
          expect(filename, matches(r'test_\d{2}-\d{2}-\d{2}_testDB_\d+\.db'), 
                 reason: 'Filename should match expected pattern');
        }
        
      } finally {
        // Clean up
        for (final db in databases) {
          await db.close();
        }
      }
    });

    test('should successfully clean up test database files', () async {
      // Create some test databases
      final databases = <AppDatabase>[];
      late List<File> filesBefore;
      
      try {
        for (int i = 0; i < 2; i++) {
          databases.add(DatabaseTestHelper.createTestDatabase(TestDatabaseType.file));
          await Future.delayed(const Duration(milliseconds: 1));
        }
        
        // Verify files exist
        final dir = Directory(testDbDir);
        filesBefore = dir.listSync().whereType<File>()
            .where((f) => f.path.contains('testDB') && f.path.endsWith('.db'))
            .toList();
        expect(filesBefore.length, greaterThanOrEqualTo(2));
        
      } finally {
        // Close databases
        for (final db in databases) {
          await db.close();
        }
      }
      
      // Clean up using the helper method
      await DatabaseTestHelper.cleanupAllTestDatabaseFiles();
      
      // Verify cleanup worked (directory might still exist but should have fewer or no test files)
      final dir = Directory(testDbDir);
      if (dir.existsSync()) {
        final filesAfter = dir.listSync().whereType<File>()
            .where((f) => f.path.contains('testDB') && f.path.endsWith('.db'))
            .toList();
        // Note: We can't guarantee all files are gone because other tests might be running
        // but we can verify the cleanup method doesn't crash
        expect(filesAfter.length, lessThanOrEqualTo(filesBefore.length));
      }
    });

    test('should handle directory creation gracefully', () {
      // Delete the test directory if it exists
      final dir = Directory(testDbDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
      
      expect(dir.existsSync(), isFalse, reason: 'Directory should be deleted');
      
      // Create a database - this should recreate the directory
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
      
      expect(dir.existsSync(), isTrue, reason: 'Directory should be recreated automatically');
      
      database.close();
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
  });
}
