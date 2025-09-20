import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../lib/database/drift_database/database.dart';
import 'utils/database_test_helper.dart';

void main() {
  // Initialize Flutter binding for tests that might use Flutter services
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Test Database Directory Simple Check', () {
    test('should create test database directory and files', () async {
      // Get the test directory path
      final testDbDir = DatabaseTestHelper.getTestDatabaseDirectory();
      print('Test DB directory path: $testDbDir');
      
      // Create a file-based test database
      final database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
      
      // Check if directory exists
      final dir = Directory(testDbDir);
      print('Directory exists: ${dir.existsSync()}');
      
      if (dir.existsSync()) {
        final files = dir.listSync();
        print('Files in directory:');
        for (final file in files) {
          print('  ${file.path}');
        }
        
        final testDbFiles = files.whereType<File>()
            .where((f) => f.path.contains('testDB') && f.path.endsWith('.db'))
            .toList();
        print('Test DB files found: ${testDbFiles.length}');
      }
      
      // Try to use the database
      try {
        await database.customStatement('CREATE TABLE test_simple (id INTEGER PRIMARY KEY)');
        await database.customStatement('INSERT INTO test_simple (id) VALUES (1)');
        
        final result = await database.customSelect('SELECT COUNT(*) as count FROM test_simple').get();
        print('Database query result: ${result.first.data['count']}');
        
        expect(result.first.data['count'], equals(1));
      } finally {
        await database.close();
      }
    });
  });
}
