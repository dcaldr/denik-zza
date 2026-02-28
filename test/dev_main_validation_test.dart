import 'package:flutter_test/flutter_test.dart';
import 'setup_templates/hardcoded_setup.dart';

/// Test to validate that the dev_main.dart setup works correctly
void main() {
  group('Dev Main Setup Validation', () {
    test('hardcoded setup creates expected data correctly', () async {
      // Mode handled by flutter_test_config.dart
      final database = await HardcodedTestSetup.setupTestData();

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
      final participantNames =
          participants.map((p) => '${p.firstName} ${p.lastName}').toList();
      expect(participantNames, contains('Václav Havel'));
      expect(participantNames, contains('Karel Čapek'));
      expect(participantNames, contains('Franz Kafka'));

      // Verify medical records exist
      final allRecords = await database.select(database.records).get();
      expect(allRecords.length, equals(10)); // One record per participant

      // Verify the easter egg is present (should be in Václav Havel's record)
      final easterEggRecord = allRecords.firstWhere(
          (record) => record.description.contains('velrybí stoličku'));
      expect(easterEggRecord.title, equals('Kontrola zdraví'));

      // Clean up
      await HardcodedTestSetup.cleanup(database);
    });

    // and requires complex mocking of path_provider which is redundant here.
  });
}
