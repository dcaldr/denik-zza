import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:drift/drift.dart';

import 'package:denik_zza/main.dart' as app;
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database_connector.dart';
import 'package:denik_zza/database/drift_database/database.dart';

import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/app_logger.dart';

import '../../infrastructure/data/datasets/jursky_park_data.dart';
import '../../infrastructure/data/models/test_participant.dart';
import '../../infrastructure/data/models/test_medication.dart';
import '../../infrastructure/data/models/test_restriction.dart';
import '../../infrastructure/data/shared_infrastructure.dart';
import '../../infrastructure/robots/dashboard_robot.dart';
import '../../infrastructure/robots/event_detail_robot.dart';
import '../../infrastructure/robots/participant_editor_robot.dart';
import '../../infrastructure/helpers/db_verification_helpers.dart';

Future<void> _seedEventOnly(AppDatabase database) async {
  final insuranceMap = await createTestInsuranceCompanies(database);
  await createTestParamedics(database);

  final fmConfig = FileManager().getConfigSummary();
  final testOutputPath = fmConfig['testOutputPath'] as String?;
  final basePath = testOutputPath ?? '';
  final eventPath = basePath.isNotEmpty
      ? '$basePath/${jurskyParkEvent.homeDirectory}'
      : jurskyParkEvent.homeDirectory;

  if (basePath.isNotEmpty) {
    final eventDir = Directory(eventPath);
    await eventDir.create(recursive: true);
    for (final sub in const ['backup', 'zpusobilosti', 'vysetreni']) {
      await Directory('${eventDir.path}/$sub').create(recursive: true);
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

  // Ensure at least one known insurance exists for UI flow
  if (!insuranceMap.containsKey('VZP')) {
    await database.addInsuranceCompany(
      InsuranceCompaniesCompanion(
        name: const Value('Všeobecná zdravotní pojišťovna'),
      ),
    );
  }

  // Seed one participant to populate autocomplete suggestions for restrictions.
  const seedParticipant = TestParticipant(
    jmeno: 'Seed',
    prijmeni: 'Autocomplete',
    pohlavi: 1,
    datumNarozeni: '2010-01-01',
    rodneCislo: '100101/0001',
    pojistovna: 'VZP',
    omezeni: [
      TestRestriction.alergie('Alergie na prach (knihy, staré prostory)'),
    ],
  );
  final seedInsuranceId = insuranceMap[seedParticipant.pojistovna];
  final seedParticipantId = await database.addParticipant(
    seedParticipant.toCompanion(eventId, seedInsuranceId),
  );
  // Seed a medication so medication autocomplete has a prior value.
  const seedMedication = TestMedication(
    nazev: 'Ibalgin 400mg',
    davkovani: '1 tableta',
    kdy: 'Při bolesti',
  );
  await database.addMedication(seedMedication.toCompanion(seedParticipantId));
  for (final omezeni in seedParticipant.omezeni) {
    await database.addAllergiesLimitations(
      omezeni.toCompanion(seedParticipantId),
    );
  }

  await database.updateCache(
    CacheCompanion(
      id: const Value(1),
      currentActionID: Value(eventId),
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  void logStep(String message) {
    AppLogger.l.i('🧪 [Focused/Ema] $message');
  }

  group('Focused - Ema restrictions', () {
    setUp(() async {
      await ModeCoordinator.setIntegrationTestMode(
        testName: 'focused_ema_restrictions',
      );

      // Mirrors core E2E setup style from:
      // integration_test/tests/protected_flow/jursky_park_true_e2e_test.dart
      logStep('ModeCoordinator integration-test mode ready');
      final fmConfig = FileManager().getConfigSummary();
      logStep('FileManager config: $fmConfig');

      final db = DatabaseWrapper.getDatabase();
      final appDb = (db as DriftDatabaseConnector).appDatabase;
      logStep('Seeding event only for focused test');
      await _seedEventOnly(appDb);
    });

    tearDown(() async {
      await DatabaseWrapper.dispose();
    });

    testWidgets('Ema Destinnová restrictions add via UI', (tester) async {
      final dashboard = DashboardRobot(tester);
      final eventDetail = EventDetailRobot(tester);
      final participantEditor = ParticipantEditorRobot(tester);
      final dbHelpers = DbVerificationHelpers(DatabaseWrapper.getDatabase());

      final ema = jurskyParkParticipants.firstWhere(
        (p) => p.jmeno == 'Ema' && p.prijmeni == 'Destinnová',
      );

      logStep('Launching app');
      app.main();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      logStep('Waiting for event on dashboard');
      final eventFound = await dashboard.waitForText(
        jurskyParkEvent.title,
        timeout: const Duration(seconds: 10),
      );
      expect(eventFound, isTrue, reason: 'Event should appear in dashboard');

      logStep('Navigating to Event Detail -> Add Participant');
      await dashboard.tapEvent(jurskyParkEvent.title);
      await eventDetail.waitForKey('EventDetail_addButton');
      await eventDetail.tapAddParticipant();
      await participantEditor.waitForFormReady();

      logStep('Asserting clean form');
      await participantEditor.assertFormClean();

      logStep('Filling base participant data');
      await participantEditor.fillFromTestData(ema);

      // Medication additions (match E2E coverage for Ema)
      logStep('Adding medications (${ema.leky.length})');
      for (int j = 0; j < ema.leky.length; j++) {
        final med = ema.leky[j];
        if (j == 2) {
          await participantEditor.addMedicationViaTab(
            'Ibal',
            'Ibalgin 400mg (1 tableta, Při bolesti)',
          );
        } else {
          await participantEditor.addMedication(med);
        }
      }

      // Restriction additions (match E2E coverage for Ema)
      logStep('Adding restrictions (${ema.omezeni.length})');
      for (int j = 0; j < ema.omezeni.length; j++) {
        final r = ema.omezeni[j];
        if (j == 0) {
          await participantEditor.addRestrictionViaDropdownClick(
            'Alergie na pr',
            'Alergie na prach (knihy, staré prostory)',
          );
          await participantEditor.addRestriction(r);
        } else if (j == 1) {
          await participantEditor.addRestrictionRejectSuggestion(
            'Alergie na',
            r.popis,
          );
        } else if (j == 2) {
          await participantEditor.addRestrictionViaTab(
            'Alergie na pr',
            'Alergie na prach (knihy, staré prostory)',
          );
        } else {
          await participantEditor.addRestriction(r);
        }
      }

      logStep('Submitting participant');
      await participantEditor.tapSubmit();
      await participantEditor.waitForFormReady();

      logStep('Verifying participant in DB');
      await dbHelpers.verifyCompleteParticipant(ema);

      final pid = await dbHelpers.getParticipantId(ema.jmeno, ema.prijmeni);
      final db = DatabaseWrapper.getDatabase();
      final omezeni = await db.getOmezeniByParticipantID(pid);
      final leky = await db.getLekyByParticipantID(pid);
      logStep('DB omezeni count: ${omezeni.length} -> ${omezeni.map((o) => o.omezeni).toList()}');
      logStep('DB leky count: ${leky.length} -> ${leky.map((l) => l.nazev).toList()}');
    });
  });
}
