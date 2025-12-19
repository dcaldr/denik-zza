import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'utils/database_test_helper.dart';
import 'utils/database_test_helper.dart';
import 'setup_templates/hardcoded_setup.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';

void main() {
  // Initialize Flutter binding for tests that use services like rootBundle
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Multi-page Append Integration Tests', () {
    late AppDatabase database;
    late PrintCenterController controller;
    late PrintCenterService service;

    setUp(() async {
      // Set up test database with predefined data
      // Set up test database with predefined data
      ModeCoordinator.setTestingMode();
      database = await HardcodedTestSetup.setupTestData();

      service = PrintCenterService();
      controller = PrintCenterController(service);
      controller.init();
    });

    tearDown(() async {
      controller.dispose();
      await database.close();
    });

    test('analyzeAppendScenario works with test data', () async {
      // Wait for participants to load
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.participants.isNotEmpty, true,
          reason: 'Should have test participants');

      // Select first participant
      final firstParticipant = controller.participants.first;
      await controller.selectParticipant(firstParticipant);

      // Wait for details to load
      await Future.delayed(const Duration(milliseconds: 100));

      // Analyze append scenario
      await controller.analyzeAppendScenario();

      // Verify analysis completed
      expect(controller.analysisInProgress, false);
      expect(controller.analysisError, null);

      // Should have analysis results (even if no records)
      final analysis = controller.appendAnalysis;
      expect(analysis, isNotNull);

      // Analysis should have reasonable values
      expect(analysis!.baselinePages, greaterThanOrEqualTo(0));
      expect(analysis.finalPages, greaterThanOrEqualTo(0));
      expect(analysis.additionalPages, greaterThanOrEqualTo(0));

      // Description should be in Czech
      final description = analysis.getAppendModeDescription();
      expect(description, isNotEmpty);
      expect(
          description,
          anyOf(
            contains('První tisk'),
            contains('Pokračování na straně'),
            contains('Nová strana'),
          ));
    });

    test('controller handles analysis errors gracefully', () async {
      // Wait for participants to load
      await Future.delayed(const Duration(milliseconds: 100));

      // Try analysis without selecting participant
      await controller.analyzeAppendScenario();

      // Should handle gracefully (no crash)
      expect(controller.analysisInProgress, false);
      // Analysis should be null since no participant selected
      expect(controller.appendAnalysis, null);
    });
  });

  group('Database Flag Persistence Tests', () {
    late AppDatabase database;
    late PrintCenterService service;
    late DatabaseInterface db;

    setUp(() async {
      ModeCoordinator.setTestingMode();
      database = await HardcodedTestSetup.setupTestData();
      service = PrintCenterService();
      db = DatabaseWrapper.getDatabase(); // Use the interface
    });

    tearDown(() async {
      await database.close();
    });

    test('participant printed flag persists and can be re-fetched', () async {
      // Get a test participant using the interface
      final participants = await db.getParticipantsByCurrentEvent();
      expect(participants.isNotEmpty, true,
          reason: 'Should have test participants');

      final participant = participants.first;
      final participantId = participant.id;

      // Initially should not be printed
      expect(participant.wasPrinted, false);

      // Set printed flag
      final success =
          await service.setParticipantPrintedFlag(participantId, true);
      expect(success, true);

      // Re-fetch and verify persistence
      final updatedParticipants = await db.getParticipantsByCurrentEvent();
      final updatedParticipant =
          updatedParticipants.firstWhere((p) => p.id == participantId);

      expect(updatedParticipant.wasPrinted, true,
          reason:
              'Participant wasPrinted flag should persist after database update');
    });

    test('record printed flag persists and can be re-fetched', () async {
      // Get a participant with records using the interface
      final participants = await db.getParticipantsByCurrentEvent();
      expect(participants.isNotEmpty, true);

      // Get records for first participant
      final participantId = participants.first.id;
      final records = await db.getRecordsByParticipantID(participantId);

      if (records.isEmpty) {
        // Skip test if no records available
        return;
      }

      final record = records.first;
      final recordId = record.idZaznamu;

      // Initially should not be printed
      expect(record.isPrinted, false);

      // Set printed flag
      final success = await service.setRecordPrintedFlag(recordId, true);
      expect(success, true);

      // Re-fetch and verify persistence
      final updatedRecords = await db.getRecordsByParticipantID(participantId);
      final updatedRecord =
          updatedRecords.firstWhere((r) => r.idZaznamu == recordId);

      expect(updatedRecord.isPrinted, true,
          reason: 'Record isPrinted flag should persist after database update');
    });

    test('multiple record flags can be set and persisted', () async {
      final participants = await db.getParticipantsByCurrentEvent();
      expect(participants.isNotEmpty, true);

      final participantId = participants.first.id;
      final records = await db.getRecordsByParticipantID(participantId);

      if (records.length < 2) {
        // Skip test if insufficient records
        return;
      }

      final recordIds = records.take(2).map((r) => r.idZaznamu).toList();

      // Set multiple flags
      final results =
          await service.setMultipleRecordPrintedFlags(recordIds, true);
      expect(results.every((r) => r == true), true);

      // Re-fetch and verify all are updated
      final updatedRecords = await db.getRecordsByParticipantID(participantId);
      for (final recordId in recordIds) {
        final updatedRecord =
            updatedRecords.firstWhere((r) => r.idZaznamu == recordId);
        expect(updatedRecord.isPrinted, true);
      }
    });
  });
}
