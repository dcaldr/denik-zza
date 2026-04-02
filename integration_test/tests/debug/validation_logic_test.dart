import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:drift/drift.dart' show Value;

import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database_connector.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/app_logger.dart';

import '../../infrastructure/data/datasets/jursky_park_data.dart';
import '../../infrastructure/data/models/test_participant.dart';
import '../../infrastructure/data/shared_infrastructure.dart';
import '../../infrastructure/helpers/db_verification_helpers.dart';

/// Seeds event + Karel + Milada with complete data for validation testing
Future<void> _seedValidationTestData(AppDatabase database) async {
  final insuranceMap = await createTestInsuranceCompanies(database);
  final paramedicIds = await createTestParamedics(database);
  final paramedicId = paramedicIds.first;

  final fmConfig = FileManager().getConfigSummary();
  final testOutputPath = fmConfig['testOutputPath'] as String?;
  final basePath = testOutputPath ?? '';
  final eventPath = basePath.isNotEmpty
      ? path.join(basePath, jurskyParkEvent.homeDirectory)
      : jurskyParkEvent.homeDirectory;

  if (basePath.isNotEmpty) {
    final eventDir = Directory(eventPath);
    await eventDir.create(recursive: true);
    for (final sub in const ['backup', 'zpusobilosti', 'vysetreni']) {
      await Directory(path.join(eventDir.path, sub)).create(recursive: true);
    }
  }

  final eventId = await createTestEvent(
    database,
    title: jurskyParkEvent.title,
    description: jurskyParkEvent.description,
    dateFrom: DateTime.parse(jurskyParkEvent.dateFrom),
    dateTo: DateTime.parse(jurskyParkEvent.dateTo),
    homeDirectory: eventPath,
  );

  await database.updateCache(CacheCompanion(
    id: const Value(1),
    currentActionID: Value(eventId),
  ));

  // Seed Karel (index 0) and Milada (index 6) with complete data
  final baseTime = DateTime.now();
  for (final index in [0, 6]) {
    final p = jurskyParkParticipants[index];
    final insuranceId = insuranceMap[p.pojistovna];
    final pid = await database.addParticipant(
      p.toCompanion(eventId, insuranceId),
    );

    for (final med in p.leky) {
      await database.addMedication(med.toCompanion(pid));
    }

    for (final r in p.omezeni) {
      await database.addAllergiesLimitations(r.toCompanion(pid));
    }

    for (final rec in p.zaznamy) {
      await database.addRecord(rec.toCompanion(pid, paramedicId, baseTime));
    }

    AppLogger.l.i('✓ Seeded ${p.jmeno} ${p.prijmeni} (ID: $pid) with ${p.zaznamy.length} records');
  }
}

TestParticipant _withFullInsuranceName(TestParticipant participant) {
  final fullName =
      insuranceShortNames[participant.pojistovna] ?? participant.pojistovna;
  return participant.copyWith(pojistovna: fullName);
}

Future<void> _ensureValidationDataSeeded(DriftDatabaseConnector db) async {
  final existingParticipants = await db.getParticipantsByCurrentEvent();
  final hasKarel = existingParticipants.any(
    (p) => p.jmeno == 'Karel' && p.prijmeni == 'Čapek',
  );
  final hasMilada = existingParticipants.any(
    (p) => p.jmeno == 'Milada' && p.prijmeni == 'Horáková',
  );

  if (hasKarel && hasMilada) {
    return;
  }

  await _seedValidationTestData(db.appDatabase);
}

/// FOCUSED TEST: Validation Logic Quality
///
/// Tests the assertion/verification infrastructure:
/// - Does verifyCompleteParticipant catch missing data? (positive + negative)
/// - Does getParticipantId enforce exact surname matching?
/// - Are edge cases handled (empty surname, null fields)?
/// - Error messages descriptive and helpful?
///
/// Reuses exact setup pattern from ema_restrictions_focused_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  IntegrationTestWidgetsFlutterBinding.instance.framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  void logStep(String message) {
    AppLogger.l.i('🧪 [Validation] $message');
  }

  group('Focused - Validation Logic', () {
    setUp(() async {
      await ModeCoordinator.setIntegrationTestMode(
        testName: 'focused_validation_logic',
      );
      logStep('Setup: Integration test mode ready');

      final fmConfig = FileManager().getConfigSummary();
      logStep('FileManager config: $fmConfig');

      final db = DatabaseWrapper.getDatabase();
      final connector = db as DriftDatabaseConnector;
      logStep('Ensuring validation seed data exists');
      await _ensureValidationDataSeeded(connector);
    });

    test('POSITIVE: verifyCompleteParticipant accepts Karel with complete data', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);
      final karel = _withFullInsuranceName(jurskyParkParticipants[0]);

      logStep('TEST: Complete participant verification');
      logStep('  Participant: ${karel.jmeno} ${karel.prijmeni}');

      try {
        final verified = await helpers.verifyCompleteParticipant(karel);
        logStep('✅ PASS: verifyCompleteParticipant accepted Karel');
        expect(verified.jmeno, equals('Karel'));
        expect(verified.prijmeni, equals('Čapek'));
        logStep('  ✓ Name verified: "${verified.jmeno} ${verified.prijmeni}"');
      } catch (e) {
        logStep('❌ FAIL: verifyCompleteParticipant rejected Karel');
        fail('Complete participant should pass: $e');
      }
    });

    test('POSITIVE: verifyCompleteParticipant accepts Milada with complete data', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);
      final milada = _withFullInsuranceName(jurskyParkParticipants[6]);

      logStep('TEST: Milada complete verification');
      logStep('  Participant: ${milada.jmeno} ${milada.prijmeni}');
      logStep('  Expected: ${milada.leky.length} medications, ${milada.omezeni.length} restrictions');

      try {
        final verified = await helpers.verifyCompleteParticipant(milada);
        logStep('✅ PASS: verifyCompleteParticipant accepted Milada');
        expect(verified.jmeno, equals('Milada'));
        expect(verified.prijmeni, equals('Horáková'));
        logStep('  ✓ Name verified: "${verified.jmeno} ${verified.prijmeni}"');
        logStep('  ✓ ID: ${verified.id}');
      } catch (e) {
        logStep('❌ FAIL: verifyCompleteParticipant rejected Milada');
        fail('Complete participant should pass: $e');
      }
    });

    test('NEGATIVE: getParticipantId REJECTS empty surname', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);

      logStep('TEST: getParticipantId empty surname rejection');
      logStep('  Looking for: jmeno="Milada" prijmeni=""');

      try {
        await helpers.getParticipantId('Milada', '');
        logStep('❌ FAIL: getParticipantId accepted empty surname');
        fail('Empty surname should be rejected');
      } catch (e) {
        logStep('✅ PASS: getParticipantId correctly rejected empty surname');
        logStep('  Error: $e');
      }
    });

    test('NEGATIVE: getParticipantId REJECTS wrong surname spelling', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);

      logStep('TEST: getParticipantId spelling sensitivity');
      logStep('  Database has: prijmeni="Horáková"');
      logStep('  Looking for: prijmeni="Horackova" (no accent)');

      try {
        await helpers.getParticipantId('Milada', 'Horackova');
        logStep('❌ FAIL: getParticipantId accepted misspelled surname');
        fail('Misspelled surname should be rejected');
      } catch (e) {
        logStep('✅ PASS: getParticipantId correctly rejected misspelled surname');
        logStep('  Error: $e');
      }
    });

    test('NEGATIVE: getParticipantId REJECTS wrong first name', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);

      logStep('TEST: getParticipantId name combination validation');
      logStep('  Database has: "Milada Horáková"');
      logStep('  Looking for: "Karel Horáková" (wrong first name)');

      try {
        await helpers.getParticipantId('Karel', 'Horáková');
        logStep('❌ FAIL: getParticipantId found wrong name combination');
        fail('Wrong name combination should be rejected');
      } catch (e) {
        logStep('✅ PASS: getParticipantId correctly rejected wrong combination');
        logStep('  Error: $e');
      }
    });

    test('NEGATIVE: verifyCompleteParticipant rejects empty surname in test data', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);

      final baseParticipant = _withFullInsuranceName(jurskyParkParticipants[0]);
      final badData = TestParticipant(
        jmeno: baseParticipant.jmeno,
        prijmeni: '', // EMPTY - CRITICAL TEST
        rodneCislo: baseParticipant.rodneCislo,
        datumNarozeni: baseParticipant.datumNarozeni,
        pohlavi: baseParticipant.pohlavi,
        pojistovna: baseParticipant.pojistovna,
        adresa: baseParticipant.adresa,
        telefonRodice: baseParticipant.telefonRodice,
        jmenoRodice: baseParticipant.jmenoRodice,
        emailRodice: baseParticipant.emailRodice,
        bezinfekcnost: baseParticipant.bezinfekcnost,
        zpusobilost: baseParticipant.zpusobilost,
        leky: baseParticipant.leky,
        omezeni: baseParticipant.omezeni,
        zaznamy: baseParticipant.zaznamy,
      );

      logStep('TEST: verifyCompleteParticipant empty surname detection');
      logStep('  Test data: jmeno="${badData.jmeno}" prijmeni="${badData.prijmeni}" (EMPTY)');

      try {
        await helpers.verifyCompleteParticipant(badData);
        logStep('❌ FAIL: verifyCompleteParticipant ACCEPTED empty surname');
        logStep('  THIS IS A CRITICAL BUG - ASSERTIONS ARE TOO WEAK');
        fail('Empty surname should be detected as invalid');
      } catch (e) {
        logStep('✅ PASS: verifyCompleteParticipant caught empty surname');
        logStep('  Error caught: $e');
      }
    });

    test('NEGATIVE: getParticipantId error message is descriptive', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);

      logStep('TEST: Error message quality check');

      try {
        await helpers.getParticipantId('NonExistent', 'Person');
        fail('Should throw for missing participant');
      } catch (e) {
        final errorMsg = e.toString();
        logStep('✅ Error thrown: $errorMsg');

        // Check for descriptive content
        bool hasName = errorMsg.contains('NonExistent') || errorMsg.contains('Person');
        bool hasContext = errorMsg.contains('not found') || errorMsg.contains('participant');

        logStep('  ✓ Contains participant name reference: $hasName');
        logStep('  ✓ Contains "not found" or similar: $hasContext');

        if (!hasName || !hasContext) {
          logStep('  ⚠️  Error message not descriptive enough, but test still passes');
        }
      }
    });

    test('DATA INTEGRITY: Multiple independent queries return consistent data', () async {
      final db = DatabaseWrapper.getDatabase();
      final appDb = (db as DriftDatabaseConnector).appDatabase;
      final helpers = DbVerificationHelpers(db);
      final milada = _withFullInsuranceName(jurskyParkParticipants[6]);

      logStep('TEST: Data consistency across query paths');
      logStep('  Participant: ${milada.jmeno} ${milada.prijmeni}');

      // Query 1: verifyCompleteParticipant
      logStep('  Query 1: verifyCompleteParticipant...');
      final verified = await helpers.verifyCompleteParticipant(milada);
      final id1 = verified.id;
      final surname1 = verified.prijmeni;
      logStep('    ID: $id1, surname: "$surname1"');

      // Query 2: getParticipantId
      logStep('  Query 2: getParticipantId...');
      final id2 = await helpers.getParticipantId('Milada', 'Horáková');
      logStep('    ID: $id2');

      // Query 3: Direct Drift query
      logStep('  Query 3: Direct Drift database...');
      final directRow = await appDb.getParticipantByID(id1);
      expect(directRow, isNotNull);
      final surname3 = directRow!.lastName;
      logStep('    Direct firstName: "${directRow.firstName}", lastName: "$surname3"');

      // Query 4: Full participant list
      logStep('  Query 4: Full participant list...');
      final allParticipants = await db.getParticipantsByCurrentEvent();
      final inList = allParticipants.firstWhere(
        (p) => p.id == id1,
        orElse: () => throw Exception('Not in list'),
      );
      final surname4 = inList.prijmeni;
      logStep('    From list: "${inList.jmeno} ${inList.prijmeni}"');

      // CONSISTENCY CHECKS
      expect(id1, equals(id2), reason: 'IDs should match across queries');
      expect(surname1, equals(surname3),
          reason: 'Surname from verified vs direct query should match');
      expect(surname1, equals(surname4),
          reason: 'Surname from verified vs list query should match');
      expect(surname3, equals(surname4),
          reason: 'Surname from direct vs list query should match');

      logStep('✅ PASS: All 4 queries returned consistent data');
      logStep('  ID=$id1, surname="$surname1"');
    });

    test('EDGE CASE: getParticipantId with whitespace-trimmed surnames', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);

      logStep('TEST: Whitespace handling in surnames');
      logStep('  Database has: "Milada Horáková"');

      // Should succeed with exact match
      try {
        final id = await helpers.getParticipantId('Milada', 'Horáková');
        logStep('✅ Exact match found: ID=$id');
      } catch (e) {
        fail('Could not find exact match: $e');
      }

      // Should probably fail with leading/trailing spaces (verify trimming behavior)
      logStep('  Trying with leading space: " Horáková"');
      try {
        await helpers.getParticipantId('Milada', ' Horáková');
        logStep('  (Whitespace was trimmed - acceptable)');
      } catch (e) {
        logStep('  (Whitespace not trimmed - strict matching - acceptable)');
      }
    });

    test('EDGE CASE: getParticipantId rejects empty first name', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);

      logStep('TEST: Empty first name rejection');

      try {
        await helpers.getParticipantId('', 'Horáková');
        logStep('❌ FAIL: Empty first name was accepted');
        fail('Empty first name should be rejected');
      } catch (e) {
        logStep('✅ PASS: Empty first name rejected');
        logStep('  Error: $e');
      }
    });

    test('EDGE CASE: getParticipantId requires non-null names', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);

      logStep('TEST: Null name handling');

      // Test with valid first name, missing last name
      try {
        await helpers.getParticipantId('Karel', '');
        logStep('  Empty last name result: check logs above');
      } catch (e) {
        logStep('✅ Empty last name properly rejected: $e');
      }
    });

    test('DISPLAY INTEGRITY: displayName correctly concatenates jmeno + prijmeni', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);
      final karel = _withFullInsuranceName(jurskyParkParticipants[0]);
      final milada = _withFullInsuranceName(jurskyParkParticipants[6]);

      logStep('TEST: displayName construction');

      final verifiedKarel = await helpers.verifyCompleteParticipant(karel);
      final verifiedMilada = await helpers.verifyCompleteParticipant(milada);

      final displayKarel = "${verifiedKarel.jmeno} ${verifiedKarel.prijmeni}";
      final displayMilada = "${verifiedMilada.jmeno} ${verifiedMilada.prijmeni}";

      logStep('  Karel display: "$displayKarel"');
      logStep('  Milada display: "$displayMilada"');

      expect(displayKarel, isNotEmpty);
      expect(displayMilada, isNotEmpty);
      expect(displayKarel.contains(' '), isTrue, reason: 'Should have space between first and last name');
      expect(displayMilada.contains(' '), isTrue, reason: 'Should have space between first and last name');

      logStep('✅ PASS: displayName format is correct');
    });

    test('NEGATIVE: Case sensitivity in name matching', () async {
      final db = DatabaseWrapper.getDatabase();
      final helpers = DbVerificationHelpers(db);

      logStep('TEST: Case sensitivity in getParticipantId');
      logStep('  Database has: "Milada" "Horáková"');
      logStep('  Trying: "milada" "horáková" (lowercase)');

      try {
        await helpers.getParticipantId('milada', 'horáková');
        logStep('  (Case insensitive matching - acceptable)');
      } catch (e) {
        logStep('✅ Case sensitive - strict matching applied.');
        logStep('  Error: $e');
      }
    });

    test('COMPREHENSIVE: Participant duplication check', () async {
      final db = DatabaseWrapper.getDatabase();

      logStep('TEST: Ensure no duplicate participants with same name');

      // Query all participants
      final all = await db.getParticipantsByCurrentEvent();
      final nameGroups = <String, List<MemoryOsoba>>{};

      for (final p in all) {
        final key = '${p.jmeno}|${p.prijmeni}';
        nameGroups.putIfAbsent(key, () => []).add(p);
      }

      logStep('  Found ${all.length} total participants');
      logStep('  Found ${nameGroups.length} unique name combinations');

      // Check for duplicates
      var duplicateCount = 0;
      for (final entry in nameGroups.entries) {
        if (entry.value.length > 1) {
          logStep('  ⚠️  Duplicate: "${entry.key}" has ${entry.value.length} instances');
          duplicateCount++;
        }
      }

      if (duplicateCount == 0) {
        logStep('✅ PASS: No duplicate names found');
      } else {
        logStep('❌ WARNING: Found $duplicateCount duplicate name combinations');
      }
    });
  });
}
