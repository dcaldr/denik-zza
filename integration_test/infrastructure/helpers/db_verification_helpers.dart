import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/utils/record_sort_utils.dart';

import '../data/models/test_participant.dart';
import '../data/models/test_medication.dart';
import '../data/models/test_restriction.dart';
import '../data/models/test_record.dart';

/// Test-only database verification helpers.
///
/// Wraps DatabaseInterface methods with expect() assertions for test verification.
/// Uses ONLY public DatabaseInterface - Vojtěch's code remains untouched.
///
/// ## Usage:
/// ```dart
/// final db = DatabaseWrapper.getDatabase() as DatabaseInterface;
/// final helpers = DbVerificationHelpers(db);
///
/// // Verify a participant
/// final participant = await helpers.verifyParticipantExists(
///   jmeno: 'Karel',
///   prijmeni: 'Čapek',
/// );
///
/// // Verify complete data
/// await helpers.verifyCompleteParticipant(testData);
/// ```
///
/// ## CORRECT Database Method Names:
/// - `getParticipantsByCurrentEvent()` - NOT getAllPersons
/// - `getLekyByParticipantID(int)` - NOT getLeksForPerson
/// - `getOmezeniByParticipantID(int)` - NOT getOmezeniForPerson
/// - `getRecordsByParticipantID(int)` - NOT getRecordsForPerson
class DbVerificationHelpers {
  final DatabaseInterface db;

  DbVerificationHelpers(this.db);

  // ==================== PARTICIPANT VERIFICATION ====================

  /// Verifies participant exists with correct data.
  ///
  /// Throws assertion error if not found or data doesn't match.
  /// Returns the found participant for further verification.
  Future<MemoryOsoba> verifyParticipantExists({
    required String jmeno,
    required String prijmeni,
    String? rodneCislo,
    DateTime? datumNarozeni,
    int? pohlavi,
    String? pojistovna,
    String? adresa,
    String? telefonRodice,
    String? jmenoRodice,
    String? emailRodice,
    String? poznamka,
    String? oddil,
    bool? prisel,
    String? potvrzeniPath,
    bool? wasPrinted,
    bool? bezinfekcnost,
    bool? zpusobilost,
  }) async {
    // Use CORRECT method name: getParticipantsByCurrentEvent
    final participants = await db.getParticipantsByCurrentEvent();

    final found = participants.where(
      (p) => p.jmeno == jmeno && p.prijmeni == prijmeni,
    );

    expect(found.length, equals(1),
        reason: 'Participant "$jmeno $prijmeni" not found in database');

    final p = found.first;

    // Verify optional fields if provided
    if (rodneCislo != null) {
      expect(p.cisloPojisteni, equals(rodneCislo),
          reason: 'Rodné číslo mismatch for $jmeno $prijmeni');
    }

    if (datumNarozeni != null) {
      expect(p.datumNarozeni?.day, equals(datumNarozeni.day),
          reason: 'Birth day mismatch for $jmeno $prijmeni');
      expect(p.datumNarozeni?.month, equals(datumNarozeni.month),
          reason: 'Birth month mismatch for $jmeno $prijmeni');
      expect(p.datumNarozeni?.year, equals(datumNarozeni.year),
          reason: 'Birth year mismatch for $jmeno $prijmeni');
    }

    if (pohlavi != null) {
      expect(p.pohlavi, equals(pohlavi),
          reason: 'Pohlavi mismatch for $jmeno $prijmeni');
    }

    if (pojistovna != null) {
      expect(p.zdravotniPojistovna, equals(pojistovna),
          reason: 'Pojistovna mismatch for $jmeno $prijmeni');
    }

    if (adresa != null) {
      expect(p.adresa, equals(adresa),
          reason: 'Adresa mismatch for $jmeno $prijmeni');
    }

    if (telefonRodice != null) {
      expect(p.telefonRodice, equals(telefonRodice),
          reason: 'Telefon rodiče mismatch for $jmeno $prijmeni');
    }

    if (jmenoRodice != null) {
      expect(p.jmenoRodice, equals(jmenoRodice),
          reason: 'Jméno rodiče mismatch for $jmeno $prijmeni');
    }

    if (emailRodice != null) {
      expect(p.emailRodice, equals(emailRodice),
          reason: 'Email rodiče mismatch for $jmeno $prijmeni');
    }

    if (poznamka != null) {
      expect(p.poznamka, equals(poznamka),
          reason: 'Poznámka mismatch for $jmeno $prijmeni');
    }

    if (oddil != null) {
      expect(p.oddil, equals(oddil),
          reason: 'Oddíl mismatch for $jmeno $prijmeni');
    }

    if (prisel != null) {
      expect(p.prisel, equals(prisel),
          reason: 'Příchod mismatch for $jmeno $prijmeni');
    }

    if (potvrzeniPath != null) {
      expect(p.potvrzeniPath, equals(potvrzeniPath),
          reason: 'Potvrzení path mismatch for $jmeno $prijmeni');
    }

    if (wasPrinted != null) {
      expect(p.wasPrinted, equals(wasPrinted),
          reason: 'WasPrinted mismatch for $jmeno $prijmeni');
    }

    if (bezinfekcnost != null) {
      expect(p.bezinfekcnost, equals(bezinfekcnost),
          reason: 'Bezinfekčnost mismatch for $jmeno $prijmeni');
    }

    if (zpusobilost != null) {
      expect(p.zpusobilost, equals(zpusobilost),
          reason: 'Způsobilost mismatch for $jmeno $prijmeni');
    }

    return p;
  }

  // ==================== MEDICATION VERIFICATION ====================

  /// Verifies medications for a participant.
  ///
  /// Uses CORRECT method: getLekyByParticipantID
  Future<void> verifyMedications({
    required int participantId,
    required List<TestMedication> expectedMedications,
    String? participantName,
  }) async {
    final name = participantName ?? 'ID:$participantId';
    final meds = await db.getLekyByParticipantID(participantId);

    expect(meds.length, equals(expectedMedications.length),
        reason:
            '$name: expected ${expectedMedications.length} medications, got ${meds.length}');

    for (final expected in expectedMedications) {
      final found = meds.any((m) => m.nazev.contains(expected.nazev));
      expect(found, isTrue,
          reason: '$name: medication "${expected.nazev}" not found');
    }
  }

  // ==================== RESTRICTION VERIFICATION ====================

  /// Verifies restrictions for a participant.
  ///
  /// Uses CORRECT method: getOmezeniByParticipantID
  Future<void> verifyRestrictions({
    required int participantId,
    required List<TestRestriction> expectedRestrictions,
    String? participantName,
  }) async {
    final name = participantName ?? 'ID:$participantId';
    final restrictions = await db.getOmezeniByParticipantID(participantId);

    expect(
        restrictions.length, greaterThanOrEqualTo(expectedRestrictions.length),
        reason:
            '$name: expected ${expectedRestrictions.length} restrictions, got ${restrictions.length}');

    for (final expected in expectedRestrictions) {
      final found = restrictions.any((r) => r.omezeni.contains(expected.popis));
      expect(found, isTrue,
          reason:
              '$name: restriction "${expected.popis.substring(0, expected.popis.length > 30 ? 30 : expected.popis.length)}..." not found');
    }
  }

  // ==================== RECORD VERIFICATION ====================

  /// Verifies medical records for a participant.
  ///
  /// Uses CORRECT method: getRecordsByParticipantID
  Future<void> verifyRecords({
    required int participantId,
    required List<TestRecord> expectedRecords,
  }) async {
    final records = await db.getRecordsByParticipantID(participantId);

    expect(records.length, greaterThanOrEqualTo(expectedRecords.length),
        reason:
            'Record count mismatch for participant $participantId - expected at least ${expectedRecords.length}, got ${records.length}');

    for (final expected in expectedRecords) {
      final found = records.any((r) => r.nazev == expected.nazev);
      expect(found, isTrue,
          reason:
              'Record "${expected.nazev}" not found for participant $participantId');
    }
  }

  // ==================== PRINT STATE VERIFICATION ====================

  /// Verifies that participant wasPrinted flag matches expectation.
  Future<void> verifyParticipantPrinted(
    String firstName,
    String lastName,
    bool expected,
  ) async {
    final participant = await verifyParticipantExists(
      jmeno: firstName,
      prijmeni: lastName,
    );

    expect(participant.wasPrinted ?? false, equals(expected),
        reason:
            'Participant "$firstName $lastName" printed mismatch: expected $expected');
  }

  /// Verifies that a record by id has expected isPrinted value.
  Future<void> verifyRecordPrinted(int recordId, bool expected) async {
    final participants = await db.getParticipantsByCurrentEvent();

    for (final p in participants) {
      final records = await db.getRecordsByParticipantID(p.id);
      final match = records.where((r) => r.idZaznamu == recordId);
      if (match.isNotEmpty) {
        expect(match.first.isPrinted, equals(expected),
            reason:
                'Record $recordId printed mismatch: expected $expected');
        return;
      }
    }

    fail('Record id $recordId not found in current event');
  }

  /// Verifies all records for a participant are printed/unprinted.
  Future<void> verifyAllRecordsPrinted(
    int participantId,
    bool expected,
  ) async {
    final records = await db.getRecordsByParticipantID(participantId);
    final allMatch = records.every((r) => r.isPrinted == expected);
    expect(allMatch, isTrue,
        reason:
            'Participant $participantId records expected printed=$expected');
  }

  /// Verifies printed state is a contiguous prefix (no printed after unprinted).
  Future<void> verifyPrintStateContiguous(int participantId) async {
    final records = await db.getRecordsByParticipantID(participantId);
    sortRecordsByTime(records);

    bool foundUnprinted = false;
    for (final record in records) {
      if (!record.isPrinted) {
        foundUnprinted = true;
        continue;
      }
      if (foundUnprinted) {
        fail(
            'Non-contiguous print state for participant $participantId: printed after unprinted');
      }
    }
  }

  // ==================== COUNT VERIFICATION ====================

  /// Verifies total participant count in current event.
  Future<void> verifyParticipantCount(int expectedCount) async {
    final participants = await db.getParticipantsByCurrentEvent();
    expect(participants.length, equals(expectedCount),
        reason:
            'Expected $expectedCount participants, found ${participants.length}');
  }

  // ==================== COMPOSITE VERIFICATION ====================

  /// Verifies complete participant with all related data.
  ///
  /// Convenience method that verifies basic data + medications + restrictions.
  Future<MemoryOsoba> verifyCompleteParticipant(
      TestParticipant testData) async {
    final name = '${testData.jmeno} ${testData.prijmeni}';
    final p = await verifyParticipantExists(
      jmeno: testData.jmeno,
      prijmeni: testData.prijmeni,
      rodneCislo: testData.rodneCislo,
      datumNarozeni: DateTime.parse(testData.datumNarozeni),
      pohlavi: testData.pohlavi,
      pojistovna: testData.pojistovna,
      adresa: testData.adresa,
      telefonRodice: testData.telefonRodice,
      jmenoRodice: testData.jmenoRodice,
      emailRodice: testData.emailRodice,
      bezinfekcnost: testData.bezinfekcnost,
      zpusobilost: testData.zpusobilost,
    );

    // Verify medications if present
    if (testData.leky.isNotEmpty) {
      await verifyMedications(
        participantId: p.id,
        expectedMedications: testData.leky,
        participantName: name,
      );
    }

    // Verify restrictions if present
    if (testData.omezeni.isNotEmpty) {
      await verifyRestrictions(
        participantId: p.id,
        expectedRestrictions: testData.omezeni,
        participantName: name,
      );
    }

    return p;
  }

  /// Verifies event exists by title.
  Future<void> verifyEventExists(String title) async {
    final events = await db.getAllZzaActions();
    final found = events.any((e) => e.nadpis == title);
    expect(found, isTrue, reason: 'Event "$title" not found in database');
  }

  /// Gets participant ID by name for further verification.
  ///
  /// Fails with descriptive error if participant not found —
  /// prefer this over silent null to catch test setup bugs early.
  Future<int> getParticipantId(String jmeno, String prijmeni) async {
    final participants = await db.getParticipantsByCurrentEvent();
    final p = participants.firstWhere(
      (p) => p.jmeno == jmeno && p.prijmeni == prijmeni,
      orElse: () => throw TestFailure(
        'Participant "$jmeno $prijmeni" not found in ${participants.length} participants',
      ),
    );
    return p.id;
  }

  /// Verifies participant arrival status (prisel field).
  ///
  /// Used after intake to verify arrival was saved to database.
  Future<void> verifyArrivalStatus({
    required String jmeno,
    required String prijmeni,
    required bool expectedArrived,
  }) async {
    final participants = await db.getParticipantsByCurrentEvent();
    final found = participants.where(
      (p) => p.jmeno == jmeno && p.prijmeni == prijmeni,
    );
    expect(found.length, equals(1),
        reason: 'Participant $jmeno $prijmeni not found');

    final p = found.first;
    expect(p.prisel, equals(expectedArrived),
        reason:
            'Participant $jmeno $prijmeni arrival status mismatch: expected $expectedArrived, got ${p.prisel}');
  }

  /// Waits until participant arrival status is persisted in DB.
  ///
  /// Hard Gate for intake save synchronization. This avoids waiting on static
  /// UI keys (buttons that exist before and after save) and instead waits for
  /// the real business outcome in persistence.
  Future<void> waitForArrivalStatusPersisted({
    required String jmeno,
    required String prijmeni,
    required bool expectedArrived,
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final participants = await db.getParticipantsByCurrentEvent();
      final found = participants.where(
        (p) => p.jmeno == jmeno && p.prijmeni == prijmeni,
      );

      if (found.length == 1 && found.first.prisel == expectedArrived) {
        return;
      }

      await Future<void>.delayed(pollInterval);
    }

    final participants = await db.getParticipantsByCurrentEvent();
    final found = participants.where(
      (p) => p.jmeno == jmeno && p.prijmeni == prijmeni,
    );

    final actual = found.length == 1 ? found.first.prisel : null;
    fail(
      'Timeout waiting for arrival status persistence for $jmeno $prijmeni. '
      'Expected=$expectedArrived, actual=$actual',
    );
  }

  /// Verifies count of arrived participants.
  ///
  /// Used after intake phase to verify correct number arrived.
  Future<void> verifyArrivedCount(int expectedCount) async {
    final participants = await db.getParticipantsByCurrentEvent();
    final arrivedCount = participants.where((p) => p.prisel).length;
    expect(arrivedCount, equals(expectedCount),
        reason: 'Expected $expectedCount arrived, got $arrivedCount');
  }

  /// Verifies participant note (poznamka) field.
  ///
  /// Used after intake to verify note was modified correctly.
  Future<void> verifyNote({
    required String jmeno,
    required String prijmeni,
    required String expectedNote,
  }) async {
    final participants = await db.getParticipantsByCurrentEvent();
    final found = participants.where(
      (p) => p.jmeno == jmeno && p.prijmeni == prijmeni,
    );
    expect(found.length, equals(1),
        reason: 'Participant $jmeno $prijmeni not found');

    final p = found.first;
    expect(p.poznamka, contains(expectedNote),
        reason: '$jmeno $prijmeni: note should contain "$expectedNote"');
  }

  /// Verifies that the database is clean (no participants).
  Future<void> verifyDatabaseEmpty() async {
    // We check current event (which might be null/empty) or just empty list returned
    final participants = await db.getParticipantsByCurrentEvent();
    expect(participants, isEmpty, reason: 'Database polluted! Expected 0 participants, found ${participants.length}');
  }
}
