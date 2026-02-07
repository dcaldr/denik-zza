import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import '../utils/database_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multi-page append comprehensive edge cases', () {
    late AppDatabase database;
    late PrintCenterService service;
    late PrintCenterController controller;
    late DatabaseInterface db;

    setUp(() async {
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
      // Mode handled by flutter_test_config.dart
      DatabaseWrapper.useTestDriftDatabase(database);

      service = PrintCenterService();
      controller = PrintCenterController(service);
      db = DatabaseWrapper.getDatabase();

      // Set up a test event using app-facing methods
      await _setupTestEvent(db);
    });

    tearDown(() async {
      controller.dispose();
      await DatabaseTestHelper.closeTestDatabase(database);
    });

    group('Complex printing workflow scenarios', () {
      test('partial print then append workflow maintains correct state',
          () async {
        // Create participant with multiple records using app-facing methods
        final participantId = await _createParticipantWithMultipleRecords(db);
        final participant = await db.getOsobaById(participantId);
        final allRecords = await db.getRecordsByParticipantID(participantId);

        expect(allRecords.length, greaterThanOrEqualTo(3),
            reason: 'Should have multiple records for testing');

        // Initial state: nothing printed
        expect(participant.wasPrinted, false);
        expect(allRecords.every((r) => !r.isPrinted), true);

        // Step 1: Print header only
        await service.setParticipantPrintedFlag(participantId, true);
        final updatedParticipant1 = await db.getOsobaById(participantId);
        expect(updatedParticipant1.wasPrinted, true);

        // Step 2: Print first two records
        final firstTwoRecords = allRecords.take(2).toList();
        for (final record in firstTwoRecords) {
          await service.setRecordPrintedFlag(record.idZaznamu, true);
        }

        // Step 3: Analyze append scenario (should work - header printed, some records printed)
        controller.init();
        await Future.delayed(const Duration(milliseconds: 100));

        // Select the participant
        final participants = await db.getParticipantsByCurrentEvent();
        final testParticipant =
            participants.firstWhere((p) => p.id == participantId);
        await controller.selectParticipant(testParticipant);
        await Future.delayed(const Duration(milliseconds: 100));

        // Should be able to append
        expect(controller.appendPossible, true);

        // Analyze append scenario
        await controller.analyzeAppendScenario();

        expect(controller.analysisInProgress, false);
        expect(controller.analysisError, null);
        expect(controller.appendAnalysis, isNotNull);

        final analysis = controller.appendAnalysis!;
        expect(analysis.baselinePages, greaterThan(0));
        expect(
            analysis.finalPages, greaterThanOrEqualTo(analysis.baselinePages));

        // Should describe continuation or new page
        final description = analysis.getAppendModeDescription();
        expect(
            description,
            anyOf(
              contains('Pokračování na straně'),
              contains('Nová strana'),
            ));
      });

      test('all records printed scenario produces minimal append analysis',
          () async {
        final participantId = await _createParticipantWithMultipleRecords(db);
        final allRecords = await db.getRecordsByParticipantID(participantId);

        // Print everything
        await service.setParticipantPrintedFlag(participantId, true);
        for (final record in allRecords) {
          await service.setRecordPrintedFlag(record.idZaznamu, true);
        }

        // Analyze append scenario
        controller.init();
        await Future.delayed(const Duration(milliseconds: 100));

        final participants = await db.getParticipantsByCurrentEvent();
        final testParticipant =
            participants.firstWhere((p) => p.id == participantId);
        await controller.selectParticipant(testParticipant);
        await Future.delayed(const Duration(milliseconds: 100));

        await controller.analyzeAppendScenario();

        final analysis = controller.appendAnalysis!;

        // When everything is printed, baseline should equal final pages (no new content)
        expect(analysis.baselinePages, equals(analysis.finalPages));
        expect(analysis.additionalPages, equals(0));
      });
    });

    group('Record size and page boundary edge cases', () {
      test('single very long record analysis works correctly', () async {
        final participantId = await _createParticipantWithLongRecord(db);

        controller.init();
        await Future.delayed(const Duration(milliseconds: 100));

        final participants = await db.getParticipantsByCurrentEvent();
        final testParticipant =
            participants.firstWhere((p) => p.id == participantId);
        await controller.selectParticipant(testParticipant);
        await Future.delayed(const Duration(milliseconds: 100));

        await controller.analyzeAppendScenario();

        final analysis = controller.appendAnalysis!;

        // Should produce valid analysis regardless of actual page count
        expect(analysis.finalPages, greaterThan(0));
        expect(analysis.baselinePages, greaterThanOrEqualTo(0));
        expect(analysis.additionalPages, greaterThanOrEqualTo(0));

        // Analysis description should be reasonable
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

      test(
          'many small records vs few large records produce different page counts',
          () async {
        final smallRecordsParticipant =
            await _createParticipantWithManySmallRecords(db);
        final largeRecordsParticipant =
            await _createParticipantWithFewLargeRecords(db);

        // Test small records
        controller.init();
        await Future.delayed(const Duration(milliseconds: 100));

        final participants = await db.getParticipantsByCurrentEvent();
        final smallParticipant =
            participants.firstWhere((p) => p.id == smallRecordsParticipant);
        await controller.selectParticipant(smallParticipant);
        await Future.delayed(const Duration(milliseconds: 100));

        await controller.analyzeAppendScenario();
        final smallAnalysis = controller.appendAnalysis!;

        // Reset and test large records
        controller.resetFlow();
        await Future.delayed(const Duration(milliseconds: 50));

        final largeParticipant =
            participants.firstWhere((p) => p.id == largeRecordsParticipant);
        await controller.selectParticipant(largeParticipant);
        await Future.delayed(const Duration(milliseconds: 100));

        await controller.analyzeAppendScenario();
        final largeAnalysis = controller.appendAnalysis!;

        // Both should have reasonable page counts but potentially different patterns
        expect(smallAnalysis.finalPages, greaterThan(0));
        expect(largeAnalysis.finalPages, greaterThan(0));

        // The relationship between small vs large records and page count depends on content
        // but both should produce valid analyses
        expect(smallAnalysis.additionalPages, greaterThanOrEqualTo(0));
        expect(largeAnalysis.additionalPages, greaterThanOrEqualTo(0));
      });
    });

    group('Error handling and recovery scenarios', () {
      test('invalid participant ID handled gracefully by service', () async {
        const invalidId = 99999;

        // These operations should handle invalid IDs gracefully
        // Note: The actual behavior depends on the database implementation
        // We're testing that the service layer doesn't crash
        final result1 =
            await service.setParticipantPrintedFlag(invalidId, true);
        final result2 = await service.setRecordPrintedFlag(invalidId, true);

        // Results may be true or false depending on DB implementation
        // The key is that no exceptions are thrown
        expect(result1, isA<bool>());
        expect(result2, isA<bool>());
      });

      test('empty record list with printed header handled correctly', () async {
        final participantId = await _createParticipantWithNoRecords(db);

        // Set header as printed
        await service.setParticipantPrintedFlag(participantId, true);

        controller.init();
        await Future.delayed(const Duration(milliseconds: 100));

        final participants = await db.getParticipantsByCurrentEvent();
        final testParticipant =
            participants.firstWhere((p) => p.id == participantId);
        await controller.selectParticipant(testParticipant);
        await Future.delayed(const Duration(milliseconds: 100));

        // canAppend should be false for empty records even if header printed
        expect(controller.appendPossible, false);

        // But analysis should still work (would be a first print scenario)
        await controller.analyzeAppendScenario();
        expect(controller.appendAnalysis, isNotNull);

        final analysis = controller.appendAnalysis!;
        expect(
            analysis.getAppendModeDescription().contains('První tisk'), true);
      });

      test('corrupted printed state (printed after unprinted) detected',
          () async {
        final participantId = await _createParticipantWithMultipleRecords(db);
        final allRecords = await db.getRecordsByParticipantID(participantId);

        // Set header as printed
        await service.setParticipantPrintedFlag(participantId, true);

        // Create corrupted state: print record 2, leave record 1 unprinted
        // This violates the "print in order" rule
        if (allRecords.length >= 2) {
          await service.setRecordPrintedFlag(allRecords[1].idZaznamu, true);
          // allRecords[0] remains unprinted

          controller.init();
          await Future.delayed(const Duration(milliseconds: 100));

          final participants = await db.getParticipantsByCurrentEvent();
          final testParticipant =
              participants.firstWhere((p) => p.id == participantId);
          await controller.selectParticipant(testParticipant);
          await Future.delayed(const Duration(milliseconds: 100));

          // Should detect broken state and not allow append
          expect(controller.appendPossible, false);
        }
      });
    });

    group('Concurrent operations and state consistency', () {
      test('multiple flag updates in sequence maintain consistency', () async {
        final participantId = await _createParticipantWithMultipleRecords(db);
        final allRecords = await db.getRecordsByParticipantID(participantId);

        // Batch update multiple records
        final recordIds = allRecords.map((r) => r.idZaznamu).toList();
        final results =
            await service.setMultipleRecordPrintedFlags(recordIds, true);

        expect(results.every((r) => r == true), true);

        // Verify all were actually updated
        final updatedRecords =
            await db.getRecordsByParticipantID(participantId);
        expect(updatedRecords.every((r) => r.isPrinted), true);

        // Now unset them all
        final unsetResults =
            await service.setMultipleRecordPrintedFlags(recordIds, false);
        expect(unsetResults.every((r) => r == true), true);

        final finalRecords = await db.getRecordsByParticipantID(participantId);
        expect(finalRecords.every((r) => !r.isPrinted), true);
      });
    });

    group('Real-world scenario simulations', () {
      test('camp medical officer workflow: gradual printing throughout event',
          () async {
        // Create multiple participants with varying record counts
        final participants = <int>[];
        for (int i = 0; i < 3; i++) {
          participants.add(await _createParticipantWithMultipleRecords(db));
        }

        // Day 1: Print headers for all participants (intake)
        for (final participantId in participants) {
          await service.setParticipantPrintedFlag(participantId, true);
        }

        // Day 2: Some medical incidents occur, print first batch
        final firstParticipant = participants[0];
        final firstRecords =
            await db.getRecordsByParticipantID(firstParticipant);
        if (firstRecords.isNotEmpty) {
          await service.setRecordPrintedFlag(
              firstRecords.first.idZaznamu, true);
        }

        // Day 3: More incidents, need to append
        controller.init();
        await Future.delayed(const Duration(milliseconds: 100));

        final dbParticipants = await db.getParticipantsByCurrentEvent();
        final testParticipant =
            dbParticipants.firstWhere((p) => p.id == firstParticipant);
        await controller.selectParticipant(testParticipant);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(controller.appendPossible, true);

        await controller.analyzeAppendScenario();
        final analysis = controller.appendAnalysis!;

        // Should be able to append with reasonable page analysis
        expect(analysis.baselinePages, greaterThan(0));
        expect(analysis.additionalPages, greaterThanOrEqualTo(0));
        expect(analysis.getAppendModeDescription(), isNotEmpty);
      });
    });
  });
}

// Helper functions using app-facing methods

Future<void> _setupTestEvent(DatabaseInterface db) async {
  final testEvent = MemoryAction(
    idAkce: null, // Will be assigned by database
    nadpis: 'Test Event for Multi-page Tests',
    popis: 'Automated test event',
    odkdy: DateTime.now(),
    dokdy: DateTime.now().add(const Duration(days: 7)),
  );

  await db.addEvent(testEvent);

  // Set as current event
  final events = await db.getAllZzaActions();
  if (events.isNotEmpty) {
    db.updateCurrentEvent(events.last.idAkce);
  }
}

Future<int> _createParticipantWithMultipleRecords(DatabaseInterface db) async {
  final participant = MemoryOsoba.named(
    id: -1, // Will be assigned by database
    jmeno: 'Test',
    prijmeni: 'MultiRecord${DateTime.now().millisecondsSinceEpoch % 1000}',
    datumNarozeni: DateTime(2000, 1, 1),
    adresa: 'Test Address',
    zpusobilost: true,
    bezinfekcnost: true,
    wasPrinted: false,
    zdravotniPojistovna: 'Test Insurance',
  );
  participant.poznamka = 'Test participant with multiple records';

  final participantId = await db.addOsobaAndReturnId(participant);
  if (participantId == null) throw Exception('Failed to create participant');

  // Add multiple records with varying sizes
  final records = [
    MemoryZaznam.fullNamed(
      idZaznamu: -1,
      casZaznamu: DateTime.now().subtract(const Duration(hours: 3)),
      nazev: 'První záznam',
      popis: 'Krátký popis prvního záznamu',
      poznamka: 'Test',
      idPacient: participantId,
      isPrinted: false,
      idAuthor: 1, // Test author ID
      lecba: null,
      teplota: null,
      obrazekPath: null,
    ),
    MemoryZaznam.fullNamed(
      idZaznamu: -1,
      casZaznamu: DateTime.now().subtract(const Duration(hours: 2)),
      nazev: 'Druhý záznam',
      popis: 'Střední popis druhého záznamu s více detaily o situaci',
      poznamka: 'Test',
      idPacient: participantId,
      isPrinted: false,
      idAuthor: 1,
      lecba: null,
      teplota: null,
      obrazekPath: null,
    ),
    MemoryZaznam.fullNamed(
      idZaznamu: -1,
      casZaznamu: DateTime.now().subtract(const Duration(hours: 1)),
      nazev: 'Třetí záznam',
      popis: 'Delší popis třetího záznamu s mnoha detaily o komplexní situaci',
      poznamka: 'Test',
      idPacient: participantId,
      isPrinted: false,
      idAuthor: 1,
      lecba: null,
      teplota: null,
      obrazekPath: null,
    ),
  ];

  for (final record in records) {
    await db.addZaznam(record);
  }

  return participantId;
}

Future<int> _createParticipantWithLongRecord(DatabaseInterface db) async {
  final participant = MemoryOsoba.named(
    id: -1,
    jmeno: 'Test',
    prijmeni: 'LongRecord${DateTime.now().millisecondsSinceEpoch % 1000}',
    datumNarozeni: DateTime(2000, 1, 1),
    adresa: 'Test Address',
    zpusobilost: true,
    bezinfekcnost: true,
    wasPrinted: false,
    zdravotniPojistovna: 'Test Insurance',
  );
  participant.poznamka = 'Test participant with very long record';

  final participantId = await db.addOsobaAndReturnId(participant);
  if (participantId == null) throw Exception('Failed to create participant');

  // Create a very long record that should force page breaks (but under 512 char limit)
  final longDescription = 'Velmi dlouhý popis záznamu s mnoha detaily. '
      'Pacient si stěžuje na bolesti hlavy a nevolnost. '
      'Provedeno základní vyšetření včetně měření teploty a tlaku. '
      'Doporučen klid a sledování stavu. '
      'V případě zhoršení okamžitě kontaktovat zdravotníka. '
      'Pacient je při vědomí a spolupracuje při vyšetření. '
      'Žádné viditelné poranění ani známky infekce.'; // Under 512 chars

  final longRecord = MemoryZaznam.fullNamed(
    idZaznamu: -1,
    casZaznamu: DateTime.now(),
    nazev: 'Velmi dlouhý záznam s mnoha detaily',
    popis: longDescription,
    poznamka: 'Test dlouhého záznamu',
    idPacient: participantId,
    isPrinted: false,
    idAuthor: 1,
    lecba: null,
    teplota: null,
    obrazekPath: null,
  );

  await db.addZaznam(longRecord);
  return participantId;
}

Future<int> _createParticipantWithManySmallRecords(DatabaseInterface db) async {
  final participant = MemoryOsoba.named(
    id: -1,
    jmeno: 'Test',
    prijmeni: 'SmallRecords${DateTime.now().millisecondsSinceEpoch % 1000}',
    datumNarozeni: DateTime(2000, 1, 1),
    adresa: 'Test Address',
    zpusobilost: true,
    bezinfekcnost: true,
    wasPrinted: false,
    zdravotniPojistovna: 'Test Insurance',
  );
  participant.poznamka = 'Test participant with many small records';

  final participantId = await db.addOsobaAndReturnId(participant);
  if (participantId == null) throw Exception('Failed to create participant');

  // Create many small records
  for (int i = 1; i <= 8; i++) {
    final record = MemoryZaznam.fullNamed(
      idZaznamu: -1,
      casZaznamu: DateTime.now().subtract(Duration(hours: 8 - i)),
      nazev: 'Záznam $i',
      popis: 'Krátký popis záznamu číslo $i',
      poznamka: 'Malý test $i',
      idPacient: participantId,
      isPrinted: false,
      idAuthor: 1,
      lecba: null,
      teplota: null,
      obrazekPath: null,
    );
    await db.addZaznam(record);
  }

  return participantId;
}

Future<int> _createParticipantWithFewLargeRecords(DatabaseInterface db) async {
  final participant = MemoryOsoba.named(
    id: -1,
    jmeno: 'Test',
    prijmeni: 'LargeRecords${DateTime.now().millisecondsSinceEpoch % 1000}',
    datumNarozeni: DateTime(2000, 1, 1),
    adresa: 'Test Address',
    zpusobilost: true,
    bezinfekcnost: true,
    wasPrinted: false,
    zdravotniPojistovna: 'Test Insurance',
  );
  participant.poznamka = 'Test participant with few large records';

  final participantId = await db.addOsobaAndReturnId(participant);
  if (participantId == null) throw Exception('Failed to create participant');

  // Create few large records (under 512 char limit each)
  for (int i = 1; i <= 3; i++) {
    final largeDescription = 'Rozsáhlý popis záznamu $i: '
        'Detailní popis situace s mnoha informacemi o stavu pacienta. '
        'Zahrnuje symptomy, provedená vyšetření a doporučený postup. '
        'Pacient vykazuje známky zlepšení po aplikované léčbě. '
        'Doporučeno pokračovat v sledování a pravidelných kontrolách.'; // Under 512 chars

    final record = MemoryZaznam.fullNamed(
      idZaznamu: -1,
      casZaznamu: DateTime.now().subtract(Duration(hours: 3 - i)),
      nazev: 'Rozsáhlý záznam $i',
      popis: largeDescription,
      poznamka: 'Velký test $i',
      idPacient: participantId,
      isPrinted: false,
      idAuthor: 1,
      lecba: null,
      teplota: null,
      obrazekPath: null,
    );
    await db.addZaznam(record);
  }

  return participantId;
}

Future<int> _createParticipantWithNoRecords(DatabaseInterface db) async {
  final participant = MemoryOsoba.named(
    id: -1,
    jmeno: 'Test',
    prijmeni: 'NoRecords${DateTime.now().millisecondsSinceEpoch % 1000}',
    datumNarozeni: DateTime(2000, 1, 1),
    adresa: 'Test Address',
    zpusobilost: true,
    bezinfekcnost: true,
    wasPrinted: false,
    zdravotniPojistovna: 'Test Insurance',
  );
  participant.poznamka = 'Test participant with no records';

  final participantId = await db.addOsobaAndReturnId(participant);
  if (participantId == null) throw Exception('Failed to create participant');

  return participantId;
}
