import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'utils/database_test_helper.dart';

/// Integration test: verify that unknown insurer names are still allowed and
/// properly persisted in the database.
///
/// Rationale: CSV parsing will sometimes yield insurer strings that don't
/// match the preset canonical list. The system policy is to accept those
/// values and store them in the DB rather than rejecting them. This test
/// ensures that behaviour.
void main() {
  group('poistovny DB persistence', () {
    late AppDatabase database;

    setUp(() {
      // Use memory DB for fast unit/integration test
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
    });

    tearDown(() async {
      await DatabaseTestHelper.closeTestDatabase(database);
    });

    test('can add and retrieve unknown insurer name', () async {
      final unknownName = 'Můj-Svérázný Poskytovatel 123';

      // The DB method addInsuranceCompany accepts a companion; but we can
      // use the lower-level helper used throughout tests: create a simple
      // insurance company row via the generated companion class.
      final companion = InsuranceCompaniesCompanion.insert(
        name: unknownName,
      );

      final id = await database.addInsuranceCompany(companion);
      final retrieved = await database.getInsuranceCompanyByID(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals(unknownName));
    });
  });
}
