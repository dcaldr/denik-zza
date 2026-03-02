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
import 'package:denik_zza/services/system/system_interface.dart';

import '../../infrastructure/data/datasets/jursky_park_data.dart';
import '../../infrastructure/data/shared_infrastructure.dart';
import '../../infrastructure/robots/event_list_robot.dart';
import '../../infrastructure/robots/print_center_robot.dart';
import '../../infrastructure/robots/person_mode_flow_robot.dart';
import '../../infrastructure/helpers/db_verification_helpers.dart';
import '../../../test/utils/capturing_system_interface.dart';

/// Seeds ALL 15 Jurský Park participants into the DB.
/// 
/// This creates the scenario where the participant list is long enough
/// to require scrolling, and selecting a participant near the bottom
/// would previously fail due to hit test issues with ensureVisible not being called.
Future<void> _seedPrintTestDataAllParticipants(AppDatabase database) async {
  final insuranceMap = await createTestInsuranceCompanies(database);
  final paramedicIds = await createTestParamedics(database);
  final paramedicId = paramedicIds.first;

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

  await database.updateCache(CacheCompanion(
    id: const Value(1),
    currentActionID: Value(eventId),
  ));

  // Seed ALL 15 participants
  final baseTime = DateTime.now();
  for (final p in jurskyParkParticipants) {
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
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  IntegrationTestWidgetsFlutterBinding.instance.framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  void logStep(String message) {
    AppLogger.l.i('[Focused/PrintParticipantSelection] $message');
  }

  // Track whether we've already seeded data to avoid duplicate constraints
  bool seedingComplete = false;

  group('Focused - Print Participant Selection (Edge Case)', () {
    setUp(() async {
      await ModeCoordinator.setIntegrationTestMode(
        testName: 'focused_print_participant_selection',
      );
      logStep('ModeCoordinator integration-test mode ready');

      if (!seedingComplete) {
        final fmConfig = FileManager().getConfigSummary();
        logStep('FileManager config: $fmConfig');

        final db = DatabaseWrapper.getDatabase();
        final appDb = (db as DriftDatabaseConnector).appDatabase;
        logStep('Seeding all 15 participants for selection test');
        await _seedPrintTestDataAllParticipants(appDb);
        seedingComplete = true;
      }
    });

    tearDown(() async {
      logStep('Test completed');
      seedingComplete = false; // Reset for next test run
      // Keep DB alive for next test
    });

    tearDownAll(() async {
      logStep('All tests done, disposing DB');
      await DatabaseWrapper.dispose();
    });

    testWidgets(
      'Select participant from long list (reproduces ensureVisible edge case)',
      (tester) async {
        final dashboard = EventListRobot(tester);
        final printCenter = PrintCenterRobot(tester);
        final personMode = PersonModeFlowRobot(tester);
        final dbHelpers =
            DbVerificationHelpers(DatabaseWrapper.getDatabase());
        final capture = CapturingSystemInterface.forCurrentTest();
        SystemInterface.registerWith(capture);

        logStep('Launching app');
        app.main();
        await tester.pump();
        await dashboard.waitForKey('EventList_add_button', timeout: const Duration(seconds: 5));

        logStep('Waiting for event on dashboard');
        final eventFound = await dashboard.waitForText(
          jurskyParkEvent.title,
          timeout: const Duration(seconds: 10),
        );
        expect(eventFound, isTrue, reason: 'Event should appear in dashboard');

        logStep('Navigating to Print Center');
        await dashboard.navigateToPrintCenter();
        await printCenter.verifyPageShown();

        logStep('Tapping Person Mode card');
        await printCenter.tapPersonModeCard();
        await personMode.verifyPageShown();

        // **KEY TEST**: Select participant near the bottom of the list.
        // This previously failed because ensureVisible wasn't called, and the
        // widget at the screen edge couldn't be hit tested properly.
        // The fix: PersonModeFlowRobot.selectParticipant() now calls ensureVisible.
        logStep('Selecting Milada Horáková (triggers scroll, near bottom of list)');
        await personMode.selectParticipant('Milada Horáková');

        // **CRITICAL**: If we reach this point, selectParticipant worked!
        // The controller was called, and the UI transitioned to the mode selection stage.
        // Before the fix, the mode buttons wouldn't exist yet because the tap never triggered.
        logStep('✅ selectParticipant succeeded (controller was called)');

        logStep('Selecting full print mode');
        await personMode.selectFullPrintMode();

        logStep('✅ selectFullPrintMode succeeded (PersonMode_fullPrint key found)');

        logStep('Tapping print button');
        await personMode.tapPrintButton();

        logStep('Confirming print success');
        await personMode.confirmPrintSuccess();
        await tester.pump(const Duration(milliseconds: 500));

        logStep('Verifying DB: Milada printed');
        await dbHelpers.verifyParticipantPrinted('Milada', 'Horáková', true);

        logStep('Verifying captured PDF');
        expect(capture.capturedPdfs.length, equals(1),
            reason: 'Expected 1 captured PDF after Milada full print');

        logStep('✅ All assertions passed: ensureVisible fix works!');
      },
    );

    testWidgets(
      'Select first and last participant from long list (both should work)',
      (tester) async {
        
        final dashboard = EventListRobot(tester);
        final printCenter = PrintCenterRobot(tester);
        final personMode = PersonModeFlowRobot(tester);
        final capture = CapturingSystemInterface.forCurrentTest();
        SystemInterface.registerWith(capture);

        logStep('Launching app');
        app.main();
        await tester.pump();
        await dashboard.waitForKey('EventList_add_button', timeout: const Duration(seconds: 5));

        logStep('Waiting for event on dashboard');
        final eventFound = await dashboard.waitForText(
          jurskyParkEvent.title,
          timeout: const Duration(seconds: 10),
        );
        expect(eventFound, isTrue, reason: 'Event should appear in dashboard');

        logStep('Navigating to Print Center');
        await dashboard.navigateToPrintCenter();
        await printCenter.verifyPageShown();

        logStep('Tapping Person Mode card');
        await printCenter.tapPersonModeCard();
        await personMode.verifyPageShown();

        // Test first participant (no scroll needed)
        logStep('Selecting Karel Čapek (first participant, no scroll)');
        await personMode.selectParticipant('Karel Čapek');
        logStep('✅ First participant selected');

        logStep('Selecting full print mode');
        await personMode.selectFullPrintMode();
        
        logStep('Tapping print button');
        await personMode.tapPrintButton();
        
        logStep('Confirming print success');
        await personMode.confirmPrintSuccess();
        
        await tester.pump(const Duration(milliseconds: 500));
        logStep('✅ First participant print completed');

        // Reset and test last participant (requires max scroll)
        logStep('Tapping Nový tisk to reset');
        await personMode.tapNewPrint();
        await personMode.verifyPageShown();

        logStep('Selecting Bedřich Smetana (last participant, max scroll)');

        await personMode.selectParticipant('Bedřich Smetana');

        logStep('✅ Last participant selected');

        logStep('Selecting full print mode');
        await personMode.selectFullPrintMode();
        
        logStep('Tapping print button');
        await personMode.tapPrintButton();
        
        logStep('Confirming print success');
        await personMode.confirmPrintSuccess();
        await tester.pump(const Duration(milliseconds: 500));
        logStep('✅ Last participant print completed');

        logStep('Verifying both PDFs captured');
        expect(capture.capturedPdfs.length, equals(2),
            reason: 'Expected 2 captured PDFs (first + last participant)');
        logStep('✅ All assertions passed: first + last both work!');
      },
    );
  });
}
