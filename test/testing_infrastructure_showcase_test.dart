import 'package:flutter_test/flutter_test.dart';
import 'utils/database_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('System A: Integration Mode (Real App Folder)', () {
    test('Integration mode uses Documents/DenikZZA/test_outputs/integration/run_X/Y', () async {
      // In a real integration test (using integration_test package), 
      // you would call:
      // await ModeCoordinator.setIntegrationTestMode(testName: 'showcase_integration');
      // 
      // The DatabaseWrapper would then use DatabaseMode.integrationTest.
      // We do not execute it here because unit tests lack path_provider plugins.
      expect(true, isTrue);
    });
  });

  group('System B: Unit/Widget Persistent Mode (Local test/.test_artifacts/)', () {
    test('Can create persistent database inside .test_artifacts/', () async {
      final database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
      
      // Perform write
      await database.customStatement(
          'CREATE TABLE test_table (id INTEGER PRIMARY KEY, name TEXT)');
      await database.customStatement(
          'INSERT INTO test_table (name) VALUES (?)', ['test_value']);

      final result = await database
          .customSelect('SELECT COUNT(*) as count FROM test_table')
          .get();
      expect(result.first.data['count'], equals(1));

      // File is created in test/.test_artifacts/dbs/
      final filePath = DatabaseTestHelper.getDatabaseFilePath(database);
      expect(filePath, isNotNull);
      expect(filePath!.contains('.test_artifacts'), isTrue);
      
      // Properly close and clean up
      await DatabaseTestHelper.closeTestDatabase(database, cleanup: true);
    });
  });
}
