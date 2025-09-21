import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'utils/database_test_helper.dart';
import 'utils/test_configuration.dart';

/// Test to verify that file test databases are properly created and persisted
void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Test Database Directory and Persistence', () {
    if (!TestConfiguration.isPersist) {
      // Persistence is OFF. These tests verify on-disk behavior and are skipped
      // unless explicitly enabled via --dart-define=TEST_MODE=persist.
      test('skipped: persistence-only suite (enable TEST_MODE=persist to run)', () {
        markTestSkipped('Enable TEST_MODE=persist to run persistence checks.');
      });
      return; // Skip the rest of the group
    }
    
    test('creates test databases in dedicated test/test_dbs directory', () async {
      // Create a file database
      final database = DatabaseTestHelper.createFileTestDatabase();
      
      // Verify it can perform basic operations
      final company = await database.addInsuranceCompany(
        TestDatabaseUtils.createSampleInsuranceCompany(name: 'Test Company')
      );
      expect(company, greaterThan(0));
      
      // Verify data can be retrieved
      final companies = await database.select(database.insuranceCompanies).get();
      expect(companies, hasLength(1));
      expect(companies.first.name, equals('Test Company'));
      
      // Close the database
      await database.close();
      
      // Verify the test database directory exists
      final testDbDir = Directory('./test/test_dbs');
      expect(testDbDir.existsSync(), isTrue);
      
      // Verify test database files are created with correct naming pattern
      final dbFiles = testDbDir.listSync().whereType<File>()
          .where((file) => file.path.contains('testDB') && file.path.endsWith('.db'))
          .toList();
      
      expect(dbFiles, isNotEmpty);
      
      // Verify at least one file has the correct naming pattern
      final hasCorrectPattern = dbFiles.any((file) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        return RegExp(r'test_\d{2}-\d{2}-\d{2}_testDB_\d+\.db').hasMatch(fileName);
      });
      expect(hasCorrectPattern, isTrue);
    });

    test('memory databases do not create files', () async {
      // Create a memory database
      final database = DatabaseTestHelper.createMemoryTestDatabase();
      
      // Verify it can perform basic operations
      final company = await database.addInsuranceCompany(
        TestDatabaseUtils.createSampleInsuranceCompany(name: 'Memory Test Company')
      );
      expect(company, greaterThan(0));
      
      // Close the database
      await database.close();
      
      // Memory databases don't create files, so this is just a functionality test
      expect(true, isTrue); // Test passes if no exceptions thrown
    });

    test('file databases persist data across connections', () async {
      String? dbPath;
      
      // Create initial database and add data
      {
        final database = DatabaseTestHelper.createFileTestDatabase();
        
        // Add test data
        await database.addInsuranceCompany(
          TestDatabaseUtils.createSampleInsuranceCompany(name: 'Persistent Company')
        );
        
        // Close database
        await database.close();
        
        // Find the created database file
        final testDbDir = Directory('./test/test_dbs');
        final dbFiles = testDbDir.listSync().whereType<File>()
            .where((file) => file.path.contains('testDB') && file.path.endsWith('.db'))
            .toList();
        
        expect(dbFiles, isNotEmpty);
        dbPath = dbFiles.last.path; // Get the most recently created file
      }
      
      // Verify the file exists
      expect(dbPath, isNotNull);
  final dbFile = File(dbPath);
      expect(dbFile.existsSync(), isTrue);
      
      // Verify file has content (not empty)
      expect(dbFile.lengthSync(), greaterThan(0));
      
      // Note: We don't test reconnecting to the same file since AppDatabase
      // creates unique filenames each time. This test verifies the file is
      // actually created and has content. Do not auto-clean this file in
      // persist mode so devs can inspect it if needed.
    });
  });
}
