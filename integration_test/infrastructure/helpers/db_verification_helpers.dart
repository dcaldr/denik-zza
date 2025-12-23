import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';

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

    return p;
  }

  // ==================== MEDICATION VERIFICATION ====================

  /// Verifies medications for a participant.
  ///
  /// Uses CORRECT method: getLekyByParticipantID
  Future<void> verifyMedications({
    required int participantId,
    required List<TestMedication> expectedMedications,
  }) async {
    final meds = await db.getLekyByParticipantID(participantId);

    expect(meds.length, equals(expectedMedications.length),
        reason:
            'Medication count mismatch for participant $participantId - expected ${expectedMedications.length}, got ${meds.length}');

    for (final expected in expectedMedications) {
      final found = meds.any((m) => m.nazev.contains(expected.nazev));
      expect(found, isTrue,
          reason:
              'Medication "${expected.nazev}" not found for participant $participantId');
    }
  }

  // ==================== RESTRICTION VERIFICATION ====================

  /// Verifies restrictions for a participant.
  ///
  /// Uses CORRECT method: getOmezeniByParticipantID
  Future<void> verifyRestrictions({
    required int participantId,
    required List<TestRestriction> expectedRestrictions,
  }) async {
    final restrictions = await db.getOmezeniByParticipantID(participantId);

    expect(
        restrictions.length, greaterThanOrEqualTo(expectedRestrictions.length),
        reason:
            'Restriction count mismatch for participant $participantId - expected at least ${expectedRestrictions.length}, got ${restrictions.length}');

    for (final expected in expectedRestrictions) {
      // MemoryOmezeni uses 'omezeni' field, not 'text'
      final found = restrictions.any((r) => r.omezeni.contains(expected.popis));
      expect(found, isTrue,
          reason:
              'Restriction "${expected.popis}" not found for participant $participantId');
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
    final p = await verifyParticipantExists(
      jmeno: testData.jmeno,
      prijmeni: testData.prijmeni,
      rodneCislo: testData.rodneCislo,
      datumNarozeni: DateTime.parse(testData.datumNarozeni),
      pohlavi: testData.pohlavi,
      pojistovna: testData.pojistovna,
      adresa: testData.adresa,
      telefonRodice: testData.telefonRodice,
    );

    // Verify medications if present
    if (testData.leky.isNotEmpty) {
      await verifyMedications(
        participantId: p.id, // MemoryOsoba.id is non-nullable (late int)
        expectedMedications: testData.leky,
      );
    }

    // Verify restrictions if present
    if (testData.omezeni.isNotEmpty) {
      await verifyRestrictions(
        participantId: p.id, // MemoryOsoba.id is non-nullable (late int)
        expectedRestrictions: testData.omezeni,
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
  /// Useful when you need the ID for medication/restriction verification
  /// but don't need full participant verification.
  Future<int?> getParticipantId(String jmeno, String prijmeni) async {
    final participants = await db.getParticipantsByCurrentEvent();
    try {
      final p = participants.firstWhere(
        (p) => p.jmeno == jmeno && p.prijmeni == prijmeni,
      );
      return p.id;
    } catch (_) {
      return null;
    }
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

  /// Verifies count of arrived participants.
  ///
  /// Used after intake phase to verify correct number arrived.
  Future<void> verifyArrivedCount(int expectedCount) async {
    final participants = await db.getParticipantsByCurrentEvent();
    final arrivedCount = participants.where((p) => p.prisel).length;
    expect(arrivedCount, equals(expectedCount),
        reason: 'Expected $expectedCount arrived, got $arrivedCount');
  }
}
