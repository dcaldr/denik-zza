import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import '../utils/database_test_helper.dart';
import '../utils/print_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Print PDF page counts', () {
    late AppDatabase database;

    setUp(() {
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
    });

    tearDown(() async {
      await DatabaseTestHelper.closeTestDatabase(database);
    });

    test('fixture records yield expected pages', () async {
      final person = buildTestPerson(id: 1);
      final fixture = await PrintTestFixture.build(
        person: person,
        db: database,
      );

      final one = await countPagesForRecords(
        person: person,
        records: fixture.singlePageRecords,
        db: database,
      );
      final two = await countPagesForRecords(
        person: person,
        records: fixture.twoPageRecords,
        db: database,
      );
      final three = await countPagesForRecords(
        person: person,
        records: fixture.threePageRecords,
        db: database,
      );
      final exactOne = await countPagesForRecords(
        person: person,
        records: fixture.exactlyFullPageRecords,
        db: database,
      );

      expect(one, 1);
      expect(two, 2);
      expect(three, 3);
      expect(exactOne, 1);
    });
  });
}
