import 'package:flutter_test/flutter_test.dart';
import 'helpers/database_test_helper.dart';
import 'setup_templates/hardcoded_setup.dart';

/// Test to validate that the dev_main.dart setup works correctly
void main() {
  group('Dev Main Setup Validation', () {
    test('hardcoded setup creates expected data correctly', () async {
      // Setup test data with memory database (fast SQLite in memory)
      final database = await HardcodedTestSetup.setupTestData(
        databaseType: TestDatabaseType.memory
      );
      
      // Verify event was created and selected
      expect(HardcodedTestSetup.selectedEventId, isNotNull);
      final selectedEventId = HardcodedTestSetup.selectedEventId!;
      
      // Verify event exists in database
      final events = await database.getAllZzaActions();
      expect(events.length, equals(1));
      expect(events.first.id, equals(selectedEventId));
      expect(events.first.actionTitle, equals('Test Test Test'));
      
      // Verify participants exist
      final participants = await database.getAllParticipants();
      expect(participants.length, equals(10));
      
      // Verify we have our Czech cultural references
      final participantNames = participants.map((p) => '${p.firstName} ${p.lastName}').toList();
      expect(participantNames, contains('Václav Havlík'));
      expect(participantNames, contains('Karel Čapková'));
      expect(participantNames, contains('Franz Kafka'));
      
      // Verify medical records exist
      final allRecords = await database.select(database.records).get();
      expect(allRecords.length, equals(10)); // One record per participant
      
      // Verify the easter egg is present (should be in Václav Havlík's record)
      final easterEggRecord = allRecords.firstWhere(
        (record) => record.description.contains('velrybí stoličku')
      );
      expect(easterEggRecord.title, equals('Kontrola zdraví'));
      
      // Clean up
      await HardcodedTestSetup.cleanup(database);
    });
    
    test('file database setup also works', () async {
      // Test that file-based database also works (slower but persistent)
      final database = await HardcodedTestSetup.setupTestData(
        databaseType: TestDatabaseType.file
      );
      
      // Quick verification
      final events = await database.getAllZzaActions();
      expect(events.length, equals(1));
      
      final participants = await database.getAllParticipants();
      expect(participants.length, equals(10));
      
      // Clean up
      await HardcodedTestSetup.cleanup(database);
    });
  });
}
