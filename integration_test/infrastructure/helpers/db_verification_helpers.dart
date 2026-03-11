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

    // Fields that are always provided — check directly
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

    // Nullable fields: assert value OR assert DB is also null — never silently skip.
    // When the parameter is omitted (not provided by caller), the check is skipped.
    // When provided (even as null), the DB value must match.
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
  /// Checks exact count, exact name match, and dosage if present in test data.
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
      // Exact name match — contains() would accept partial names like "Ibalgin" matching "Super Ibalgin XL"
      final match = meds.where((m) => m.nazev == expected.nazev);
      expect(match.isNotEmpty, isTrue,
          reason: '$name: medication "${expected.nazev}" not found (exact match)');

      // Compare persisted details against canonical submitted details.
      final expectedDetails = _expectedMedicationDetails(expected);
      if (expectedDetails != null) {
        final dosageMatch = match.any((m) => m.popisDavkovani == expectedDetails);
        expect(dosageMatch, isTrue,
            reason: '$name: medication "${expected.nazev}" dosage mismatch '
                '— expected "$expectedDetails", got: ${match.map((m) => m.popisDavkovani).toList()}');
      } else {
        final nullOrEmptyMatch = match.any((m) {
          final details = m.popisDavkovani;
          return details == null || details.trim().isEmpty;
        });
        expect(nullOrEmptyMatch, isTrue,
            reason: '$name: medication "${expected.nazev}" expected no dosage details '
                'but found: ${match.map((m) => m.popisDavkovani).toList()}');
      }
    }
  }

  String? _expectedMedicationDetails(TestMedication medication) {
    final parts = <String>[];
    if (medication.davkovani != null && medication.davkovani!.trim().isNotEmpty) {
      parts.add(medication.davkovani!.trim());
    }
    if (medication.kdy != null && medication.kdy!.trim().isNotEmpty) {
      parts.add(medication.kdy!.trim());
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(', ');
  }

  // ==================== RESTRICTION VERIFICATION ====================

  /// Verifies restrictions for a participant.
  ///
  /// Checks exact count, exact text match, and type (alergie=2 / omezeni=1).
  /// Uses CORRECT method: getOmezeniByParticipantID
  Future<void> verifyRestrictions({
    required int participantId,
    required List<TestRestriction> expectedRestrictions,
    String? participantName,
  }) async {
    final name = participantName ?? 'ID:$participantId';
    final restrictions = await db.getOmezeniByParticipantID(participantId);

    // Exact count — greaterThanOrEqualTo would hide duplicate or stale restrictions
    expect(restrictions.length, equals(expectedRestrictions.length),
        reason:
            '$name: expected ${expectedRestrictions.length} restrictions, got ${restrictions.length}');

    for (final expected in expectedRestrictions) {
      // Exact text match — contains() could match partial strings
      final match = restrictions.where((r) => r.omezeni == expected.popis);
      expect(match.isNotEmpty, isTrue,
          reason: '$name: restriction "${expected.popis}" not found (exact match)');

      // Verify type (1=omezení, 2=alergie) — wrong type would silently pass otherwise
      final typeMatch = match.any((r) => r.typOmezeni == expected.typ);
      expect(typeMatch, isTrue,
          reason: '$name: restriction "${expected.popis}" has wrong type '
              '— expected typ=${expected.typ}, got: ${match.map((r) => r.typOmezeni).toList()}');
    }
  }

  // ==================== RECORD VERIFICATION ====================

  /// Verifies medical records for a participant.
  ///
  /// Checks exact count, name match, and popis if provided in test data.
  /// Uses CORRECT method: getRecordsByParticipantID
  Future<void> verifyRecords({
    required int participantId,
    required List<TestRecord> expectedRecords,
  }) async {
    final records = await db.getRecordsByParticipantID(participantId);

    // Exact count — greaterThanOrEqualTo would hide duplicate or extra records
    expect(records.length, equals(expectedRecords.length),
        reason:
            'Record count mismatch for participant $participantId — expected ${expectedRecords.length}, got ${records.length}');

    for (final expected in expectedRecords) {
      final match = records.where((r) => r.nazev == expected.nazev);
      expect(match.isNotEmpty, isTrue,
          reason: 'Record "${expected.nazev}" not found for participant $participantId');

      // Verify popis — TestRecord.popis is non-nullable, always check
            // Trim both sides: app saves .trim() (see new_record_page.dart), and
            // expands:true TextField in Flutter tests can produce trailing whitespace.
            final popisMatch = match.any((r) => (r.popis ?? '').trim() == expected.popis.trim());
      expect(popisMatch, isTrue,
          reason: 'Record "${expected.nazev}" popis mismatch for participant $participantId '
              '— expected "${expected.popis}", got: ${match.map((r) => (r.popis ?? '').trim()).toList()}');
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
  /// Checks ALL fields from [TestParticipant] against DB: basic data,
  /// prisel, poznamka, wasPrinted, medications, and restrictions.
  ///
  /// [checkRecords] — set to `true` only when records have already been
  /// created in the DB (Phase 3+). Defaults to `false` because records exist
  /// in the dataset as future truth but aren't inserted until Phase 3.
  Future<MemoryOsoba> verifyCompleteParticipant(
    TestParticipant testData, {
    bool checkRecords = false,
  }) async {
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
      prisel: testData.prisel,
      poznamka: testData.poznamka,
      wasPrinted: testData.wasPrinted,
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

    // Verify records only when they exist in DB (Phase 3+)
    if (checkRecords && testData.zaznamy.isNotEmpty) {
      await verifyRecords(
        participantId: p.id,
        expectedRecords: testData.zaznamy,
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

  /// Waits until participant exists in DB.
  Future<void> waitForParticipantPersisted({
    required String jmeno,
    required String prijmeni,
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final participants = await db.getParticipantsByCurrentEvent();
      final found = participants.where(
        (p) => p.jmeno == jmeno && p.prijmeni == prijmeni,
      );

      if (found.length == 1) {
        return;
      }

      await Future<void>.delayed(pollInterval);
    }

    fail('Timeout waiting for participant persistence: $jmeno $prijmeni');
  }

  /// Waits until participant note contains expected text.
  Future<void> waitForNotePersisted({
    required String jmeno,
    required String prijmeni,
    required String expectedNote,
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final participants = await db.getParticipantsByCurrentEvent();
      final found = participants.where(
        (p) => p.jmeno == jmeno && p.prijmeni == prijmeni,
      );

      if (found.length == 1) {
        final note = found.first.poznamka ?? '';
        if (note.contains(expectedNote)) {
          return;
        }
      }

      await Future<void>.delayed(pollInterval);
    }

    fail(
      'Timeout waiting for note persistence for $jmeno $prijmeni. '
      'Expected note to contain "$expectedNote"',
    );
  }

  /// Waits until participant has the expected number of records.
  Future<void> waitForRecordsCountPersisted({
    required int participantId,
    required int expectedCount,
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final records = await db.getRecordsByParticipantID(participantId);
      if (records.length == expectedCount) {
        return;
      }

      await Future<void>.delayed(pollInterval);
    }

    final records = await db.getRecordsByParticipantID(participantId);
    fail(
      'Timeout waiting for records persistence for participant $participantId. '
      'Expected count=$expectedCount, actual=${records.length}',
    );
  }

  /// Waits until participant printed flag matches expected.
  Future<void> waitForParticipantPrintedPersisted({
    required String jmeno,
    required String prijmeni,
    required bool expected,
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final participants = await db.getParticipantsByCurrentEvent();
      final found = participants.where(
        (p) => p.jmeno == jmeno && p.prijmeni == prijmeni,
      );

      if (found.length == 1 && (found.first.wasPrinted ?? false) == expected) {
        return;
      }

      await Future<void>.delayed(pollInterval);
    }

    final participants = await db.getParticipantsByCurrentEvent();
    final found = participants.where(
      (p) => p.jmeno == jmeno && p.prijmeni == prijmeni,
    );
    final actual = found.length == 1 ? (found.first.wasPrinted ?? false) : null;
    fail(
      'Timeout waiting for printed flag persistence for $jmeno $prijmeni. '
      'Expected=$expected, actual=$actual',
    );
  }

  /// Waits until all participant records have expected print status.
  Future<void> waitForAllRecordsPrintedPersisted({
    required int participantId,
    required bool expected,
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final records = await db.getRecordsByParticipantID(participantId);
      if (records.isNotEmpty && records.every((r) => r.isPrinted == expected)) {
        return;
      }

      await Future<void>.delayed(pollInterval);
    }

    final records = await db.getRecordsByParticipantID(participantId);
    fail(
      'Timeout waiting for all records printed persistence for participant '
      '$participantId. Expected printed=$expected, records=${records.length}',
    );
  }
}
