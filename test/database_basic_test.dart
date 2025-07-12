import 'package:flutter_test/flutter_test.dart';
import '../lib/database/drift_database/database.dart';
import 'helpers/database_test_helper.dart';

/// Basic database functionality test
/// 
/// Tests core database operations using the proper test database system.
/// Uses memory database for fast unit testing of basic database operations.
/// 
/// 📖 Available Database Types:
///   - TestDatabaseType.memory: Fast in-memory testing (recommended for unit tests)
///   - TestDatabaseType.file: Persistent test files in test/test_dbs/ (for integration tests)
void main() {
  // Initialize Flutter binding for tests that might use Flutter services
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Database Basic Functionality', () {
    late AppDatabase database;

    setUp(() {
      // Use proper test database helper for consistent test database setup
      // Memory database chosen for fast unit testing of basic database operations
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
    });

    tearDown(() async {
      await DatabaseTestHelper.closeTestDatabase(database);
    });

    test('can create and connect to database', () async {
      // Just verify the database can be created and basic operations work
      final companies = await database.select(database.insuranceCompanies).get();
      expect(companies, isEmpty);
    });

    test('can insert and retrieve insurance company', () async {
      // Insert test data
      final companionData = InsuranceCompaniesCompanion.insert(name: 'Test Company');
      final id = await database.addInsuranceCompany(companionData);
      expect(id, greaterThan(0));
      
      // Retrieve and verify
      final companies = await database.select(database.insuranceCompanies).get();
      expect(companies, hasLength(1));
      expect(companies.first.name, equals('Test Company'));
    });

    test('can insert and retrieve action', () async {
      // Insert test action
      final now = DateTime.now();
      final actionData = ZzaActionsCompanion.insert(
        actionTitle: 'Test Action',
        dateFrom: now,
        dateTo: now.add(const Duration(days: 7)),
      );
      final id = await database.addZzaAction(actionData);
      expect(id, greaterThan(0));
      
      // Retrieve and verify
      final actions = await database.select(database.zzaActions).get();
      expect(actions, hasLength(1));
      expect(actions.first.actionTitle, equals('Test Action'));
    });
  });
}
