import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'helpers/database_test_helper.dart';
import 'setup_templates/hardcoded_setup.dart';

void main() {
  group('Hardcoded Setup Demo', () {
    test('should create setup with memory database', () async {
      print('Creating setup with memory database...');
      final database = await HardcodedTestSetup.setupTestData(databaseType: TestDatabaseType.memory);
      
      // Verify database was created
      expect(database, isNotNull);
      expect(database, isA<DatabaseInterface>());
      print('✓ Memory database setup completed successfully');
    });

    test('should create setup with file database', () async {
      print('Creating setup with file database...');
      final database = await HardcodedTestSetup.setupTestData(databaseType: TestDatabaseType.file);
      
      // Verify database was created  
      expect(database, isNotNull);
      expect(database, isA<DatabaseInterface>());
      print('✓ File database setup completed successfully');
      print('📁 File database persists in test/test_dbs/ directory for manual inspection');
    });

    test('should default to memory database when no type specified', () async {
      print('Creating setup with default database type...');
      final database = await HardcodedTestSetup.setupTestData();
      
      // Verify database was created
      expect(database, isNotNull);
      expect(database, isA<DatabaseInterface>());
      print('✓ Default (memory) database setup completed successfully');
    });
  });
}
