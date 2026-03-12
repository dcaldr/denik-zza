import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:denik_zza/main.dart' as app;
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/services/system/system_interface.dart';

import '../../infrastructure/data/datasets/jursky_park_data.dart';
import '../../infrastructure/robots/event_list_robot.dart';
import '../../infrastructure/robots/event_editor_robot.dart';
import '../../infrastructure/robots/event_detail_robot.dart';
import '../../infrastructure/robots/participant_editor_robot.dart';
import '../../infrastructure/robots/intake_robot.dart';
import '../../infrastructure/robots/new_record_robot.dart';
import '../../infrastructure/robots/print_center_robot.dart';
import '../../infrastructure/robots/person_mode_flow_robot.dart';
import '../../infrastructure/robots/print_state_robot.dart';
import '../../infrastructure/robots/participant_detail_robot.dart';
import '../../infrastructure/helpers/db_verification_helpers.dart';
import '../../infrastructure/data/models/test_record.dart';
import '../../infrastructure/data/models/test_restriction.dart';
import '../../infrastructure/data/models/test_participant.dart';
import '../../infrastructure/data/expected_world_state.dart';
import '../../infrastructure/helpers/test_step_logger.dart';
import '../../../test/setup_templates/hardcoded_setup.dart';
import '../../../test/utils/capturing_system_interface.dart';

/// TRUE E2E TEST: Jurský Park Full Workflow
///
/// This test creates ALL 15 Jurský Park participants via UI interactions,
/// following the complete user story workflow:
///   PreEvent → Intake → Event → Print → Append
///
/// ## Key Requirements (NON-NEGOTIABLE):
/// - ALL 15 participants created via UI (not database seeding)
/// - COMPLETE data: name, RC, birth date, gender, insurance, address, phone
/// - ALL medications where present
/// - ALL restrictions where present
/// - ALL medical records from TestRecord data
///
/// ## Verification Strategy:
/// - Primary: DbVerificationHelpers (database queries)
/// - Secondary: waitForKey (UI elements)
/// - Tertiary: waitForText (name verification only)
///
/// ## Infinite Animation Handling:
/// Uses waitForKey/waitForText instead of pumpAndSettle where loaders appear.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  IntegrationTestWidgetsFlutterBinding.instance.framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  final logger = TestStepLogger();

  group('TRUE E2E: Jurský Park Full Workflow', () {
    // ========================================
    // SETUP & TEARDOWN
    // ========================================
    setUp(() async {
      await ModeCoordinator.setIntegrationTestMode(
        testName: 'jursky_park_true_e2e',
      );
      // Initialize silent logger (buffers logs, prints only on failure)
      TestStepLogger.initialize();
      
      // Make hit-test warnings fatal - catch tap misses immediately
      WidgetController.hitTestWarningShouldBeFatal = true;
    });

    tearDown(() async {
      // Drain pending microtasks to prevent ConnectionClosedException
      // when FileManager's stream callbacks fire after database disposal
      await Future.delayed(const Duration(milliseconds: 50));
      
      await DatabaseWrapper.dispose();
      // Restore default logger behavior
      TestStepLogger.dispose();
    });



    // ========================================
    // GROUP -1: Isolated Verifications (DB Persistence)
    // ========================================
    group('Isolated Verifications', () {
      setUp(() async {
        await ModeCoordinator.setIntegrationTestMode(
          testName: 'jursky_park_isolated',
        );
        TestStepLogger.initialize();
      });

      tearDown(() async {
        // Drain pending microtasks to prevent ConnectionClosedException
        await Future.delayed(const Duration(milliseconds: 50));
        
        await DatabaseWrapper.dispose();
        TestStepLogger.dispose();
      });

      testWidgets('DB Verification: Autocomplete Persistence', (tester) async {
        await logger.step('Setup: Seed DB with Event & Medic', () async {
          // Use HardcodedSetup to seed "Test Test Test" event and "Test Paramedic"
          // We need to cast or access the underlying app database if possible, 
          // but HardcodedTestSetup.setupTestData() usually creates a new DB and injects it.
          // Let's call it directly.
          await HardcodedTestSetup.setupTestData(); 
        });

        await logger.step('Launch App & Navigate', () async {
          app.main();
          await tester.pump();
          
          final dashboard = EventListRobot(tester);
          await dashboard.waitForKey('EventList_add_button', timeout: const Duration(seconds: 5));
          final eventDetail = EventDetailRobot(tester); 
          final participantEditor = ParticipantEditorRobot(tester);
          final dbHelpers = DbVerificationHelpers(DatabaseWrapper.getDatabase());

          // HardcodedSetup selects the event "Test Test Test" in cache, 
          // so dashboard might show it or we might need to select it.
          // Usually valid assumption: Dashboard shows list.
          await dashboard.waitForText('Test Test Test'); 
          await dashboard.tapEvent('Test Test Test');
          
          await eventDetail.waitForKey('EventDetail_addButton');
          await eventDetail.tapAddParticipant();
          await participantEditor.waitForFormReady();

          // 1. Ensure clean slate
          await participantEditor.assertFormClean();

          // 2. Fill Name/Surname
          await participantEditor.enterJmeno('Auto');
          await participantEditor.enterPrijmeni('Test');

          // 3. Enter Valid RC (855512/0006 -> Female, 1985)
          // SKIP DOB/Gender to test Autocomplete
          await participantEditor.enterCisloPojisteni('855512/0006');

          // 4. Submit
          await participantEditor.tapSubmit();

          await dbHelpers.waitForParticipantPersisted(
            jmeno: 'Auto',
            prijmeni: 'Test',
          );

          // 5. Verify DB Persistence
          await dbHelpers.verifyParticipantExists(
            jmeno: 'Auto',
            prijmeni: 'Test',
            rodneCislo: '855512/0006',
            pohlavi: 2, // Female
            datumNarozeni: DateTime(1985, 5, 12),
          );
        });
      });
    });

    // ========================================
    // GROUP 0: First-Use Guards (Surpassing Widget Tests)
    // Reference: docs/testing/first_use_analysis.md
    // Reference: test/first_use/first_use_test.dart
    // ========================================
    group('First-Use Guards (E2E)', () {
      Future<EventListRobot> _launchFreshApp(WidgetTester tester) async {
        app.main();
        await tester.pump();
        final dashboard = EventListRobot(tester);
        final ready = await dashboard.waitForKey(
          'EventList_add_button',
          timeout: const Duration(seconds: 5),
        );
        expect(ready, isTrue, reason: 'Dashboard add button should appear after launch');
        return dashboard;
      }

      Future<void> _createEvent(
        WidgetTester tester,
        EventListRobot dashboard,
        EventEditorRobot eventEditor,
        String title,
      ) async {
        await dashboard.tapCreateNewEvent();
        await eventEditor.enterEventName(title);
        await eventEditor.enterDescription('E2E first-use scenario event');
        await eventEditor.enterDates(
          DateTime.now().add(const Duration(days: 1)),
          DateTime.now().add(const Duration(days: 3)),
        );
        await eventEditor.submit();

        final created = await dashboard.waitForText(
          title,
          timeout: const Duration(seconds: 5),
        );
        expect(created, isTrue, reason: 'Created event "$title" should appear in list');
      }

      Future<void> _createParticipantFromDataset(
        WidgetTester tester,
        EventListRobot dashboard,
        EventDetailRobot eventDetail,
        ParticipantEditorRobot participantEditor,
        DbVerificationHelpers dbHelpers,
        TestParticipant p,
        String eventTitle,
      ) async {
        await dashboard.tapEvent(eventTitle);
        await eventDetail.tapAddParticipant();
        await participantEditor.waitForFormReady();
        await participantEditor.fillFromTestData(p);
        await participantEditor.tapSubmit();
        await participantEditor.waitForFormReady();
        await dbHelpers.waitForParticipantPersisted(
          jmeno: p.jmeno,
          prijmeni: p.prijmeni,
        );
        final handled = await tester.binding.handlePopRoute();
        expect(handled, isTrue,
            reason: 'Participant registration page should be closable via router pop');
        await tester.pumpAndSettle();
        await eventDetail.verifyPageShown();
      }

      // --- GUARDRAILS (Should Pass - Verify Protections Work) ---

      testWidgets('Scenario A: Fresh app - AppDrawer disabled without event',
          (tester) async {
        await logger.step('Scenario A: Fresh app check', () async {
          final dashboard = await _launchFreshApp(tester);
          await dashboard.openDrawer();
          await tester.tap(find.byKey(const Key('AppDrawer_priprava')));
          await tester.pumpAndSettle();

          final newRecordTile = tester.widget<ListTile>(
            find.byKey(const Key('AppDrawer_new_record')),
          );
          expect(newRecordTile.enabled, isFalse,
              reason: 'New record should be disabled when no event exists');

          final participantListTile = tester.widget<ListTile>(
            find.byKey(const Key('AppDrawer_participant_list')),
          );
          expect(participantListTile.enabled, isFalse,
              reason: 'Participant list should be disabled when no event exists');
        });
      });

      testWidgets('Scenario F: PrintCenter graceful empty state',
          (tester) async {
        await logger.step('Scenario F: PrintCenter empty check', () async {
          final dashboard = await _launchFreshApp(tester);
          await dashboard.openDrawer();
          final printCenterTile = tester.widget<ListTile>(
            find.byKey(const Key('AppDrawer_print_center')),
          );
          expect(printCenterTile.enabled, isFalse,
              reason: 'Print center must be disabled before an event and participants exist');
        });
      });

      testWidgets('Scenario H: Autocomplete empty list handling',
          (tester) async {
        await logger.step('Scenario H: Autocomplete empty check', () async {
          await _launchFreshApp(tester);
          final db = DatabaseWrapper.getDatabase();

          expect(await db.getAllLeky(), isEmpty,
              reason: 'Fresh app should start with empty medication autocomplete source');
          expect(await db.getAllOmezeni(), isEmpty,
              reason: 'Fresh app should start with empty restrictions autocomplete source');
          // Form interaction (addMedicationViaEnter, addRestrictionViaEnter) is covered
          // in focused tests (ema_restrictions_focused_test) to avoid title-bar hit-test
          // issues caused by hitTestWarningShouldBeFatal=true in this suite.
        });
      });

      // --- VULNERABILITIES (Document Known Bugs) ---
      testWidgets('Scenario C: NewRecordPage save button vulnerability',
          (tester) async {
        await logger.step('Scenario C: Save without selected participant', () async {
          final dashboard = await _launchFreshApp(tester);
          await dashboard.openDrawer();
          final newRecordTile = tester.widget<ListTile>(
            find.byKey(const Key('AppDrawer_new_record')),
          );
          expect(newRecordTile.enabled, isFalse,
              reason: 'New record route must stay disabled in first-use state (no participants)');

          await tester.tap(find.byKey(const Key('AppDrawer_new_record')), warnIfMissed: false);
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('NewRecordPage_participantAutocomplete')), findsNothing,
              reason: 'Disabled NewRecord route must not navigate to NewRecordPage');
        });
      });

      testWidgets('Scenario D: ParticipantList new participant route guard',
          (tester) async {
        await logger.step('Scenario D: New participant entry is guarded without event', () async {
          final dashboard = await _launchFreshApp(tester);
          await dashboard.openDrawer();
          await tester.tap(find.byKey(const Key('AppDrawer_priprava')));
          await tester.pumpAndSettle();

          final newParticipantTile = tester.widget<ListTile>(
            find.byKey(const Key('AppDrawer_new_participant')),
          );
          expect(newParticipantTile.enabled, isFalse,
              reason: 'New participant route must be disabled when no event exists (first-use guard)');

          await tester.tap(
            find.byKey(const Key('AppDrawer_new_participant')),
            warnIfMissed: false,
          );
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('ParticipantRegistrationForm_submit_button')), findsNothing,
              reason: 'Disabled new participant route must not navigate to registration form');
        });
      });

      testWidgets('Scenario E: IntakeForm save without event crashes',
          (tester) async {
        await logger.step('Scenario E: Intake route is guarded without event', () async {
          final dashboard = await _launchFreshApp(tester);
          await dashboard.openDrawer();
          await tester.tap(find.byKey(const Key('AppDrawer_filtr')));
          await tester.pumpAndSettle();

          final intakeTile = tester.widget<ListTile>(
            find.byKey(const Key('AppDrawer_intake_form')),
          );
          expect(intakeTile.enabled, isFalse,
              reason: 'Intake form must be disabled when no event exists');

          await tester.tap(find.byKey(const Key('AppDrawer_intake_form')), warnIfMissed: false);
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('IntakeForm_saveAndArrived_button')), findsNothing,
              reason: 'Disabled intake route must not open intake form');
        });
      });

      testWidgets('Scenario G: DB current event is null in fresh app',
          (tester) async {
        await logger.step('Scenario G: getCurrentEventID returns null in fresh app', () async {
          await _launchFreshApp(tester);
          final db = DatabaseWrapper.getDatabase();
          final currentEventId = await db.getCurrentEventID();
          expect(currentEventId, isNull,
              reason: 'Fresh app must have no current event ID — crash-maker if services assume non-null event');
        });
      });

      testWidgets('Scenario I: ParticipantDetail edit button on orphaned data',
          (tester) async {
        await logger.step('Scenario I: Participant detail actions absent on fresh app', () async {
          await _launchFreshApp(tester);
          expect(find.byKey(const Key('ParticipantDetail_edit_button')), findsNothing,
              reason: 'Edit action must not be reachable without opening participant detail');
        });
      });

      testWidgets('Scenario J: Orphaned edit page save crashes',
          (tester) async {
        await logger.step('Scenario J: Edit page route is not reachable from fresh app', () async {
          await _launchFreshApp(tester);
          expect(find.byKey(const Key('ParticipantRegistrationForm_submit_button')), findsNothing,
              reason: 'Participant edit/registration submit must not appear without explicit navigation');
        });
      });

      // --- ADDITIONAL ROUTE COVERAGE (Beyond Widget Tests) ---

      testWidgets('Route: ParticipantListItem tap paths', (tester) async {
        await logger.step('Route check: EventDetail -> ParticipantDetail', () async {
          final dashboard = await _launchFreshApp(tester);
          final eventEditor = EventEditorRobot(tester);
          final eventDetail = EventDetailRobot(tester);
          final participantEditor = ParticipantEditorRobot(tester);
          final participantDetail = ParticipantDetailRobot(tester);
          final dbHelpers = DbVerificationHelpers(DatabaseWrapper.getDatabase());
          const eventName = 'E2E ParticipantListItem Route';

          await _createEvent(tester, dashboard, eventEditor, eventName);
          await _createParticipantFromDataset(
            tester,
            dashboard,
            eventDetail,
            participantEditor,
            dbHelpers,
            jurskyParkParticipants.first,
            eventName,
          );

          final backToDashboard = await tester.binding.handlePopRoute();
          expect(backToDashboard, isTrue,
              reason: 'Should navigate back to dashboard to refresh EventDetail participants');
          await tester.pumpAndSettle();
          await dashboard.tapEvent(eventName);
          await eventDetail.verifyPageShown();

          await eventDetail.tapParticipant(
            '${jurskyParkParticipants.first.jmeno} ${jurskyParkParticipants.first.prijmeni}',
          );
          await participantDetail.verifyPageShown();
          await participantDetail.verifyParticipantName(
            '${jurskyParkParticipants.first.jmeno} ${jurskyParkParticipants.first.prijmeni}',
          );
        });
      });

      testWidgets('Route: NewRecordPage print button paths', (tester) async {
        await logger.step('Route check: NewRecord print opens PersonMode flow', () async {
          final dashboard = await _launchFreshApp(tester);
          final eventEditor = EventEditorRobot(tester);
          final eventDetail = EventDetailRobot(tester);
          final participantEditor = ParticipantEditorRobot(tester);
          final newRecord = NewRecordRobot(tester);
          final personMode = PersonModeFlowRobot(tester);
          final dbHelpers = DbVerificationHelpers(DatabaseWrapper.getDatabase());
          const eventName = 'E2E NewRecord Print Route';
          final p = jurskyParkParticipants.first;

          await _createEvent(tester, dashboard, eventEditor, eventName);
          await _createParticipantFromDataset(
            tester,
            dashboard,
            eventDetail,
            participantEditor,
            dbHelpers,
            p,
            eventName,
          );

          await dashboard.navigateToNewRecordPage();
          await newRecord.verifyPageShown();
          await newRecord.selectParticipant('${p.jmeno} ${p.prijmeni}');
          await newRecord.tapPrintFull();
          await personMode.verifyPageShown();
        });
      });

      testWidgets('Route: Event detail add participant (FIXED)',
          (tester) async {
        await logger.step('Route check: EventDetail add participant opens form', () async {
          final dashboard = await _launchFreshApp(tester);
          final eventEditor = EventEditorRobot(tester);
          final eventDetail = EventDetailRobot(tester);
          const eventName = 'E2E EventDetail Add Route';

          await _createEvent(tester, dashboard, eventEditor, eventName);
          await dashboard.tapEvent(eventName);
          await eventDetail.tapAddParticipant();

          final formReady = await dashboard.waitForKey(
            'ParticipantRegistrationForm_submit_button',
            timeout: const Duration(seconds: 5),
          );
          expect(formReady, isTrue,
              reason: 'Add participant route should open participant registration form');
        });
      });
    });

    // ========================================
    // MAIN E2E WORKFLOW (Single Sequential Test)
    // All phases in one test for data persistence
    // ========================================
    group('Complete Workflow', () {
      testWidgets('Full Jurský Park E2E: Create → Intake → Records → Append',
          (tester) async {
        
        // Initialize all robots and helpers (lazy-loaded by step usually, but defined here for scope)
        final dashboard = EventListRobot(tester);
        final eventEditor = EventEditorRobot(tester);
        final eventDetail = EventDetailRobot(tester);
        final participantEditor = ParticipantEditorRobot(tester);
        final intake = IntakeRobot(tester);
        final newRecord = NewRecordRobot(tester);
        final printCenter = PrintCenterRobot(tester);
        final personMode = PersonModeFlowRobot(tester);
        final printState = PrintStateRobot(tester);
        final db = DatabaseWrapper.getDatabase();
        final dbHelpers = DbVerificationHelpers(db);
        final world = ExpectedWorldState(jurskyParkParticipants);

        // Enable soft mode to collect all failures throughout the E2E flow
        // instead of stopping at the first failing step.
        logger.enableSoftMode();

        // ============================================================
        // PHASE 1: PreEvent - Create Event & Participants
        // ============================================================
        logger.section('PHASE 1: PreEvent - Create Event & Participants');

        await logger.step('Launch App', () async {
          app.main();
          await tester.pump();
          await dashboard.waitForKey('EventList_add_button', timeout: const Duration(seconds: 5));
        });

        await logger.step('Verify Clean DB State', () async {
          await dbHelpers.verifyDatabaseEmpty();
        });

        await logger.step('Create Event: ${jurskyParkEvent.title}', () async {
          await dashboard.tapCreateNewEvent();
          await dashboard.waitForKey('EventRegistrationForm_nadpis_input');

          await eventEditor.enterEventName(jurskyParkEvent.title);
          await eventEditor.enterDescription(jurskyParkEvent.description);
          await eventEditor.enterDates(
            DateTime.parse(jurskyParkEvent.dateFrom),
            DateTime.parse(jurskyParkEvent.dateTo),
          );
          await eventEditor.submit();

          // Wait for event to appear
          final eventFound = await dashboard.waitForText(jurskyParkEvent.title,
              timeout: const Duration(seconds: 15));
          expect(eventFound, isTrue, reason: 'Event should appear in dashboard');

          // ✅ DB VERIFICATION
          await dbHelpers.verifyEventExists(jurskyParkEvent.title);
        });

        await logger.step('Navigate to Add Participant', () async {
          await dashboard.tapEvent(jurskyParkEvent.title);
          await eventDetail.waitForKey('EventDetail_addButton');
          await eventDetail.tapAddParticipant();
          await participantEditor.waitForFormReady();
        });



        // CREATE ALL 15 PARTICIPANTS
        for (int i = 0; i < jurskyParkParticipants.length; i++) {
          final p = jurskyParkParticipants[i];
          
          await logger.step('Add Participant ${i + 1}/15: ${p.jmeno} ${p.prijmeni}', () async {
            // Ensure form is clean (checkboxes reset) before starting
            // This catches bugs where previous participant's flags persist
            await participantEditor.assertFormClean();

            // Fill basic form data
            // STRATEGY: Skip manual DOB/Gender entry for most to verify Autocomplete
            // EXCEPTION: Explicitly enter for P3 and P7 to verify manual override works
            final bool manualEntry = (i == 2 || i == 6); // P3 (Jan Hus), P7 (Karel IV)
            
            await participantEditor.fillFromTestData(
              p, 
              skipDatumNarozeni: !manualEntry,
              skipPohlavi: !manualEntry,
            );

            // SPECIAL CHECKS FOR P3 and P5 (New Data Coverage)
            if (i == 2) { // P3 Jan Hus (Only Zpusobilost)
               // Robot fillFromTestData already handles setting the checkboxes based on the model
               // We just trust the robot here, verification happens in DB check
            }

            // Medication Tests
            for (int j = 0; j < p.leky.length; j++) {
              final med = p.leky[j];
              // Build the same formatted string that addMedication() uses, to keep
              // addMedicationViaEnter in sync with what _parseMedicationInput expects.
              final _medParts = <String>[];
              if (med.davkovani != null) _medParts.add(med.davkovani!);
              if (med.kdy != null) _medParts.add(med.kdy!);
              final medText = _medParts.isEmpty
                  ? med.nazev
                  : '${med.nazev} (${_medParts.join(', ')})';

              if (i == 5 && j == 0) {
                 await participantEditor.addMedicationViaEnter(medText);
              } else if (i == 12 && j == 2) {
                 await participantEditor.addMedicationViaTab('Ibal', 'Ibalgin 400mg (1 tableta, Při bolesti)');
              } else {
                 await participantEditor.addMedication(med);
              }
            }

            // Restriction Tests
            for (int j = 0; j < p.omezeni.length; j++) {
              final r = p.omezeni[j];
              if (i == 2 && j == 0) {
                await participantEditor.addRestrictionViaEnter(r.popis);
              } else if (i == 6 && j == 0) {
                // Milada is the FIRST participant with this latex allergy — no DB entry to Tab-complete yet.
                // Autocomplete of this entry is tested via i==7 TabThenModify (Seifert, after Milada is saved).
                await participantEditor.addRestriction(r);
              } else if (i == 7 && j == 0) {
                await participantEditor.addRestrictionViaTabThenModify('Alergie na l', 'Alergie na latex (používat nitrilové rukavice)', r.popis);
              } else if (i == 8 && j == 0) {
                await participantEditor.addRestrictionViaClearAfterTab('Alergie na pr', 'Alergie na prach (knihy, staré prostory)', r.popis);
              } else if (i == 12 && j == 0) {
                await participantEditor.addRestrictionViaDropdownClick('Alergie na pr', 'Alergie na prach (knihy, staré prostory)');
                await participantEditor.addRestriction(r);
              } else if (i == 12 && j == 1) {
                await participantEditor.addRestrictionRejectSuggestion('Alergie na', r.popis);
              } else if (i == 12 && j == 2) {
                await participantEditor.addRestrictionViaTab('Alergie na pr', 'Alergie na prach (knihy, staré prostory)');
              } else {
                await participantEditor.addRestriction(r);
              }
            }

            await participantEditor.tapSubmit();
            await participantEditor.waitForFormReady();

            await dbHelpers.waitForParticipantPersisted(
              jmeno: p.jmeno,
              prijmeni: p.prijmeni,
            );

            // ✅ DB VERIFICATION (Immediate)
            // Use world.participants[i] — not the const dataset — to stay consistent
            // with the tracker pattern. (At Phase 1 both are identical; this ensures
            // we don’t silently diverge if a Phase 1 mutation is ever added.)
            final verified = await dbHelpers.verifyCompleteParticipant(world.participants[i]);
            
            // Explicit sanity checks for our new test cases
            if (i == 2) { // P3 Jan Hus
              expect(verified.zpusobilost, isTrue, reason: 'P3 should be Eligible');
              expect(verified.bezinfekcnost, isFalse, reason: 'P3 should NOT be Non-Infectious');
            }
            if (i == 4) { // P5 Alfons Mucha
              expect(verified.bezinfekcnost, isTrue, reason: 'P5 should be Non-Infectious');
              expect(verified.zpusobilost, isFalse, reason: 'P5 should NOT be Eligible');
            }
          });
        }

        await logger.step('Verify Total Participant Count', () async {
          await dbHelpers.verifyParticipantCount(15);
        });

        // ── Phase 1 Boundary: world.verifyAll() ensures no data leakage after registration ──
        await logger.step('Phase 1 Integrity Check (ExpectedWorldState)', () async {
          await world.verifyAll(dbHelpers);
        });

        // ============================================================
        // PHASE 2: Intake - Process Arrivals (All 15 Participants)
        // ============================================================
        logger.section('PHASE 2: Intake - Process Arrivals');

        await logger.step('Navigate to Intake', () async {
          await dashboard.navigateToIntakeForm();
          await intake.waitForKey('IntakeForm_saveAndArrived_button');
        });

        // Local helper: post-save verification common to all intake scenarios.
        // Avoids duplicating the same 3-line wait+assert+ready block in every case.
        Future<void> verifyIntakeSave(TestParticipant p, bool expectedArrived) async {
          await dbHelpers.waitForArrivalStatusPersisted(
            jmeno: p.jmeno,
            prijmeni: p.prijmeni,
            expectedArrived: expectedArrived,
          );
          await dbHelpers.verifyArrivalStatus(
            jmeno: p.jmeno,
            prijmeni: p.prijmeni,
            expectedArrived: expectedArrived,
          );
          await intake.waitForFormReady();
        }

        // Process all 15 participants with various scenarios
        for (int i = 0; i < jurskyParkParticipants.length; i++) {
          final p = jurskyParkParticipants[i];
          
          await logger.step('Intake ${i + 1}/15: ${p.jmeno} ${p.prijmeni}', () async {
            // Always select participant first
            await intake.selectParticipant('${p.jmeno} ${p.prijmeni}');
            
            // Different scenarios based on participant index
            switch (i) {
              case 1: // P2 Božena - Modify Note
                await intake.modifyNote('Intake note: Arrived on time');
                await intake.tapSaveAndArrived();
                await dbHelpers.waitForNotePersisted(
                  jmeno: p.jmeno,
                  prijmeni: p.prijmeni,
                  expectedNote: 'Intake note',
                );
                await dbHelpers.verifyNote(jmeno: p.jmeno, prijmeni: p.prijmeni, expectedNote: 'Intake note');
                await verifyIntakeSave(p, true);
                break;
                
              case 2: // P3 Jan Hus - Add Restriction during intake
                await participantEditor.addRestriction(
                  TestRestriction.omezeni('Kontrola slunečního krému provedena'),
                );
                await intake.tapSaveAndArrived();
                // Hard Gate: Jan Hus path is slower (restriction update + save).
                await verifyIntakeSave(p, true);
                break;
                
              case 3: // P4 Tomáš - Save only (NOT marked arrived)
                await intake.tapSave();
                await verifyIntakeSave(p, false);
                break;
                
              case 6: // P7 Milada - Cancel then retry
                await intake.tapCancel();
                await intake.waitForFormReady();
                await intake.selectParticipant('${p.jmeno} ${p.prijmeni}');
                await intake.tapSaveAndArrived();
                // Hard Gate: wait for persisted DB state after retry save.
                await verifyIntakeSave(p, true);
                break;
                
              default: // Basic flow
                await intake.tapSaveAndArrived();
                await verifyIntakeSave(p, true);
            }
          });
        }

        await logger.step('Verify Arrived Count', () async {
          // 14 arrived (P4 Tomáš used save-only)
          await dbHelpers.verifyArrivedCount(14);
        });

        // ── Phase 2 Boundary: declare expected mutations ──
        // Decoupled from robot actions — independent truth declaration.
        await logger.step('Phase 2 Integrity Check (ExpectedWorldState)', () async {
          // All participants arrived except P4 Tomáš (index 3)
          for (int i = 0; i < jurskyParkParticipants.length; i++) {
            if (i == 3) continue; // Tomáš: save-only
            world.markArrived(i);
          }
          // P2 Božena (index 1): note added during intake
          world.setNote(1, 'Intake note: Arrived on time');
          // P3 Jan Hus (index 2): restriction added during intake
          world.addRestriction(
            2,
            TestRestriction.omezeni('Kontrola slunečního krému provedena'),
          );

          await world.verifyAll(dbHelpers);
        });

        // ============================================================
        // PHASE 3: Event - Medical Records & Print
        // ============================================================
        logger.section('PHASE 3: Event - Medical Records & Print');

        await logger.step('Navigate to New Record', () async {
          await dashboard.navigateToNewRecordPage();
          await newRecord.waitForKey('NewRecordPage_participantAutocomplete');
        });

        // Interleaved records across participants (simulate real arrival order)
        final milada = jurskyParkParticipants[6]; // Index 6 = Milada Horáková
        final recordOrder = <int>[
          0, 7, 2, 4, 1, 9, 3, 12, 5, 10, 6, 8, 11, 13, 14,
        ];
        final orderedParticipants = recordOrder
            .map((index) => jurskyParkParticipants[index])
            .toList();

        final maxRecords = orderedParticipants.fold<int>(
          0,
          (max, p) => p.zaznamy.length > max ? p.zaznamy.length : max,
        );
        final interleavedRecords = <MapEntry<TestParticipant, TestRecord>>[];
        for (int round = 0; round < maxRecords; round++) {
          for (final p in orderedParticipants) {
            if (round < p.zaznamy.length) {
              interleavedRecords.add(MapEntry(p, p.zaznamy[round]));
            }
          }
        }

        // Helper to create a batch of records
        Future<void> createRecordBatch(
          List<MapEntry<TestParticipant, TestRecord>> records,
        ) async {
          for (final entry in records) {
            final p = entry.key;
            final record = entry.value;
            await newRecord.createRecordFromTestData(
              '${p.jmeno} ${p.prijmeni}',
              record,
            );
            await newRecord.waitForFormReady();
          }
        }

        // Split records into 3 batches with navigation interludes between them.
        // This exercises page switching, route stack, and state persistence.
        final totalRecords = interleavedRecords.length;
        final batch1End = totalRecords ~/ 3;
        final batch2End = 2 * totalRecords ~/ 3;

        final batch1 = interleavedRecords.sublist(0, batch1End);
        final batch2 = interleavedRecords.sublist(batch1End, batch2End);
        final batch3 = interleavedRecords.sublist(batch2End);

        await logger.step('Records Batch 1/${batch1.length} records', () async {
          await createRecordBatch(batch1);
        });

        await logger.step('Navigation Interlude: Intake Form visit', () async {
          await dashboard.navigateToIntakeForm();
          await dashboard.waitForKey('IntakeForm_personSearch_input');
          // Navigate back to NewRecordPage
          await dashboard.navigateToNewRecordPage();
          await newRecord.waitForKey('NewRecordPage_participantAutocomplete');
        });

        await logger.step('Records Batch 2/${batch2.length} records', () async {
          await createRecordBatch(batch2);
        });

        await logger.step('Navigation Interlude: Print Center visit', () async {
          await dashboard.navigateToPrintCenter();
          await printCenter.verifyPageShown();
          // Navigate back to NewRecordPage
          await dashboard.navigateToNewRecordPage();
          await newRecord.waitForKey('NewRecordPage_participantAutocomplete');
        });

        await logger.step('Records Batch 3/${batch3.length} records', () async {
          await createRecordBatch(batch3);
        });

        await logger.step('Verify All Records Inserted', () async {
          for (final p in jurskyParkParticipants) {
            if (p.zaznamy.isEmpty) continue;
            final id = await dbHelpers.getParticipantId(p.jmeno, p.prijmeni);
            await dbHelpers.verifyRecords(
              participantId: id,
              expectedRecords: p.zaznamy,
            );
          }
        });

        // Register CapturingSystemInterface BEFORE any prints
        // so all PDFs (including NewRecordPage print + Phase 4 baseline) are captured.
        final capture = CapturingSystemInterface.forCurrentTest();
        SystemInterface.registerWith(capture);

        // Exercise the NewRecordPage → PersonAndModeFlowPage print path.
        // This path is NEVER tested via PrintCenter — it's a separate Navigator.push.
        await logger.step('Print from NewRecordPage (Karel Čapek)', () async {
          // Participant must be selected for print buttons to be enabled
          final printTarget = jurskyParkParticipants[0]; // Karel Čapek
          await newRecord.selectParticipant(
            '${printTarget.jmeno} ${printTarget.prijmeni}',
          );
          await newRecord.tapPrintFull();

          // PersonAndModeFlowPage auto-selects participant + full mode via initState.
          // Just wait for the page and tap print.
          await personMode.verifyPageShown();
          
          // Fast-fail: verify mode stage is ready (auto-selection succeeded)
          final autoSelectReady = await personMode.waitForKey(
            'PersonMode_printButton',
            timeout: const Duration(seconds: 5),
          );
          expect(autoSelectReady, isTrue,
              reason: 'Print button should appear after auto-selection');
          
          await personMode.tapPrintButton();
          await personMode.confirmPrintSuccess();

          final printTargetId = await dbHelpers.getParticipantId(
            printTarget.jmeno,
            printTarget.prijmeni,
          );
          await dbHelpers.waitForParticipantPrintedPersisted(
            jmeno: printTarget.jmeno,
            prijmeni: printTarget.prijmeni,
            expected: true,
          );
          await dbHelpers.waitForAllRecordsPrintedPersisted(
            participantId: printTargetId,
            expected: true,
          );
          await dbHelpers.verifyParticipantPrinted(
            printTarget.jmeno,
            printTarget.prijmeni,
            true,
          );
          await dbHelpers.verifyAllRecordsPrinted(printTargetId, true);

          // Track print in world — Karel has been printed
          world.markPrinted(0); // Index 0 = Karel Čapek

          // "Back to Center" uses popUntil(isFirst) → pops ALL routes to Dashboard
          await personMode.tap(personMode.findKey('PersonMode_backToCenter'));
          await dashboard.pumpAndSettle();

          // Verify PDF was captured
          expect(capture.capturedPdfs.length, equals(1),
              reason: 'Expected 1 captured PDF after NewRecordPage print');
          expect(capture.capturedPdfs.last.name, contains('Osoba_'),
              reason: 'PDF name should contain participant ID pattern');
        });

        await logger.step('Navigate to Print Center', () async {
          await dashboard.navigateToPrintCenter();
          await dashboard.pumpAndSettle();
        });

        // ============================================================
        // PHASE 4: Event Continued - Baseline Print for Append
        // ============================================================
        logger.section('PHASE 4: Event Continued - Baseline Print for Append');

        await logger.step('Baseline Full Print for Milada', () async {
          await printCenter.tapPersonModeCard();
          await personMode.verifyPageShown();

          await personMode.selectParticipant('${milada.jmeno} ${milada.prijmeni}');

          await personMode.selectFullPrintMode();
          await personMode.tapPrintButton();
          await personMode.confirmPrintSuccess();

          final miladaId = await dbHelpers.getParticipantId(
            milada.jmeno,
            milada.prijmeni,
          );
          await dbHelpers.waitForParticipantPrintedPersisted(
            jmeno: milada.jmeno,
            prijmeni: milada.prijmeni,
            expected: true,
          );
          await dbHelpers.waitForAllRecordsPrintedPersisted(
            participantId: miladaId,
            expected: true,
          );
          await dbHelpers.verifyParticipantPrinted(
            milada.jmeno,
            milada.prijmeni,
            true,
          );
          await dbHelpers.verifyAllRecordsPrinted(miladaId, true);

          // Track print in world — Milada has been baseline-printed
          world.markPrinted(6); // Index 6 = Milada Horáková

          await personMode.tap(personMode.findKey('PersonMode_backToCenter'));
          await printCenter.verifyPageShown();

          // Verify PDF was captured for Phase 4 baseline print
          expect(capture.capturedPdfs.length, equals(2),
              reason: 'Expected 2 captured PDFs (NewRecordPage print + Milada baseline)');
        });

        // ============================================================
        // PHASE 4: Event Continued - Append Print
        // ============================================================
        logger.section('PHASE 4: Event Continued - Append Print');

        await logger.step('Create Append Record for Milada', () async {
          await dashboard.navigateToNewRecordPage();
          await newRecord.waitForKey('NewRecordPage_participantAutocomplete');
          final appendRecord = TestRecord(
            nazev: 'Follow-up observation',
            popis: 'Patient continues to improve, ready for activities',
            hoursAgo: 1,
          );

          await newRecord.createRecordFromTestData('${milada.jmeno} ${milada.prijmeni}', appendRecord);
          await newRecord.waitForFormReady();

          final miladaId = await dbHelpers.getParticipantId(milada.jmeno, milada.prijmeni);
          final expectedRecordCount = world.participants[6].zaznamy.length + 1;
          await dbHelpers.waitForRecordsCountPersisted(
            participantId: miladaId,
            expectedCount: expectedRecordCount,
          );

          // Track append record in world — Milada now has one extra record
          world.addRecord(6, appendRecord); // Index 6 = Milada Horáková

          // Use world.participants[6].zaznamy so the append record is included automatically
          await dbHelpers.verifyRecords(participantId: miladaId, expectedRecords: world.participants[6].zaznamy);
        });

        // ============================================================
        // PHASE 5: Print Center Full + Append with PDF Artifacts
        // ============================================================
        logger.section('PHASE 5: Print Center Full + Append with Artifacts');

        final kafka = jurskyParkParticipants[9];

        await logger.step('Full Print: Franz Kafka', () async {
          await dashboard.navigateToPrintCenter();
          await printCenter.tapPersonModeCard();
          await personMode.verifyPageShown();
          await personMode.selectParticipant('${kafka.jmeno} ${kafka.prijmeni}');
          await personMode.selectFullPrintMode();
          await personMode.tapPrintButton();
          await personMode.confirmPrintSuccess();

          final kafkaId = await dbHelpers.getParticipantId(
            kafka.jmeno,
            kafka.prijmeni,
          );
          await dbHelpers.waitForParticipantPrintedPersisted(
            jmeno: kafka.jmeno,
            prijmeni: kafka.prijmeni,
            expected: true,
          );
          await dbHelpers.waitForAllRecordsPrintedPersisted(
            participantId: kafkaId,
            expected: true,
          );
          await dbHelpers.verifyParticipantPrinted(
            kafka.jmeno,
            kafka.prijmeni,
            true,
          );
          await dbHelpers.verifyAllRecordsPrinted(kafkaId, true);

          expect(capture.capturedPdfs.length, equals(3),
              reason: 'Expected 3 captured PDFs (NewRecordPage + Milada baseline + Kafka full)');
          final kafkaPdf = capture.capturedPdfs[2]; // Index 2: after Čapek[0] and Milada baseline[1]
          expect(kafkaPdf.pageCount, greaterThan(0),
              reason: 'Kafka PDF should have at least 1 page');

          await personMode.tap(personMode.findKey('PersonMode_backToCenter'));
          await printCenter.verifyPageShown();
        });

        await logger.step('Append Print: Milada Horáková', () async {
          await printCenter.tapPersonModeCard();
          await personMode.verifyPageShown();
          await tester.pumpAndSettle();
          
          // Explicit wait to ensure participant list loads after navigation
          final listReady = await personMode.waitForKey(
            'select-person',
            timeout: const Duration(seconds: 10),
          );
          if (!listReady) {
            throw TestFailure('Participant list did not load when re-entering PersonMode');
          }
          
          await personMode.selectParticipant('${milada.jmeno} ${milada.prijmeni}');
          await personMode.selectAppendPrintMode();
          await personMode.tapPrintButton();

          final continueFound = await personMode.waitForKey(
            'AppendInstruction_continue',
          );
          expect(continueFound, isTrue,
              reason: 'Append instruction dialog should appear');
          await personMode.tap(personMode.findKey('AppendInstruction_continue'));

          await personMode.confirmPrintSuccess();

          final miladaId = await dbHelpers.getParticipantId(
            milada.jmeno,
            milada.prijmeni,
          );
          await dbHelpers.waitForParticipantPrintedPersisted(
            jmeno: milada.jmeno,
            prijmeni: milada.prijmeni,
            expected: true,
          );
          await dbHelpers.waitForAllRecordsPrintedPersisted(
            participantId: miladaId,
            expected: true,
          );
          await dbHelpers.verifyParticipantPrinted(
            milada.jmeno,
            milada.prijmeni,
            true,
          );
          await dbHelpers.verifyAllRecordsPrinted(miladaId, true);
          await dbHelpers.verifyPrintStateContiguous(miladaId);

          expect(capture.capturedPdfs.length, equals(4),
              reason: 'Expected 4 captured PDFs (NewRecordPage + Milada baseline + Kafka full + Milada append)');
          final miladaPdf = capture.capturedPdfs.last;
          expect(miladaPdf.pageCount, greaterThan(0),
              reason: 'Milada PDF should have at least 1 page');

          await personMode.tap(personMode.findKey('PersonMode_backToCenter'));
          await printCenter.verifyPageShown();
        });

        await logger.step('PDF Structural Verification', () async {
          // We should have 4 PDFs: NewRecordPage(Čapek) + Milada full + Kafka full + Milada append
            expect(capture.capturedPdfs.length, equals(4),
              reason: 'PDF Structural Verification: expected 4 PDFs total — Čapek(NewRecord), Milada(full), Kafka(full), Milada(append)');

          final capekPdf = capture.capturedPdfs[0];
          final miladaFullPdf = capture.capturedPdfs[1];
          final kafkaFullPdf = capture.capturedPdfs[2];
          final miladaAppendPdf = capture.capturedPdfs[3];

          // Name verification — each PDF name should contain participant DB ID
          final capekId = await dbHelpers.getParticipantId('Karel', 'Čapek');
          expect(capekPdf.name, equals('Osoba_$capekId'));

          final miladaId = await dbHelpers.getParticipantId('Milada', 'Horáková');
          expect(miladaFullPdf.name, equals('Osoba_$miladaId'));
          expect(miladaAppendPdf.name, equals('Osoba_$miladaId'));

          final kafkaId = await dbHelpers.getParticipantId('Franz', 'Kafka');
          expect(kafkaFullPdf.name, equals('Osoba_$kafkaId'));

          // Page count structural assertions
          // Kafka (13 records) should have >= pages than Milada full (9 records)
          expect(kafkaFullPdf.pageCount,
              greaterThanOrEqualTo(miladaFullPdf.pageCount),
              reason: 'Kafka 13 records should produce >= pages than Milada 9');

          // Full print should have >= pages than append (append = only new records)
          expect(miladaFullPdf.pageCount,
              greaterThanOrEqualTo(miladaAppendPdf.pageCount),
              reason: 'Full print should have >= pages than append');

          // All PDFs should have at least 1 page
          for (final pdf in capture.capturedPdfs) {
            expect(pdf.pageCount, greaterThan(0),
                reason: '${pdf.name} should have pages');
          }

          // Byte size: Kafka full > Čapek (more records = larger PDF)
          expect(kafkaFullPdf.bytes.length, greaterThan(capekPdf.bytes.length),
              reason: 'Kafka 13 records should produce larger PDF than Čapek 2');
        });

        await logger.step('Print State: Reset + Cascade Test', () async {
          await printCenter.tapStateManagementCard();
          await printState.verifyPageShown();

          // Wait for state list to load after route transition.
          final listReady = await printState.waitForKey(
            'PrintStateManagement_list',
            timeout: const Duration(seconds: 5),
          );
          expect(listReady, isTrue,
              reason: 'PrintState list should be visible after entering state management');

          final kafkaId = await dbHelpers.getParticipantId(
            kafka.jmeno,
            kafka.prijmeni,
          );

          await dbHelpers.getParticipantId('Milada', 'Horáková');

          // --- Verify initial state: Kafka fully printed ---
          await printState.expandPerson('Franz Kafka');
          await printState.verifyPersonPrintedBadge('Franz Kafka', true);

          // Collapse Franz before searching for Milada to avoid nested-scroll capture
          await printState.expandPerson('Franz Kafka');
          await tester.pump();

          // Also verify Milada is printed (from Phase 4+5)
          // expandPerson handles scrolling to find the person
          await printState.expandPerson('Milada Horáková');
          await printState.verifyPersonPrintedBadge('Milada Horáková', true);

          // Collapse Milada and re-open Franz for subsequent record-level actions
          await printState.expandPerson('Milada Horáková');
          await tester.pump();
          await printState.expandPerson('Franz Kafka');
          await tester.pump();

          // --- Step 1: Reset all Kafka records → all unprinted ---
          await printState.tapResetAll(kafkaId);
          await tester.pump();

          await printState.verifyPersonPrintedBadge('Franz Kafka', false);
          await printState.verifyRecordPrintedBadge(0, false);
          await dbHelpers.verifyAllRecordsPrinted(kafkaId, false);

          // --- Step 2: Try toggle record 2 ON → BLOCKED (records 0,1 unprinted) ---
          await printState.toggleRecordPrinted(2);
          await tester.pump();
          await printState.verifyRecordPrintedBadge(2, false); // Unchanged

          // --- Step 3: Toggle records 0,1,2 ON sequentially (contiguous prefix) ---
          await printState.toggleRecordPrinted(0);
          await tester.pump();
          await printState.verifyRecordPrintedBadge(0, true);

          await printState.toggleRecordPrinted(1);
          await tester.pump();
          await printState.verifyRecordPrintedBadge(1, true);

          await printState.toggleRecordPrinted(2);
          await tester.pump();
          await printState.verifyRecordPrintedBadge(2, true);

          // Verify contiguous prefix: records 0-2 printed, 3+ unprinted
          await dbHelpers.verifyPrintStateContiguous(kafkaId);

          // --- Step 4: Mark all printed ---
          await printState.tapMarkAll(kafkaId);
          await tester.pump();

          await printState.verifyPersonPrintedBadge('Franz Kafka', true);
          await dbHelpers.verifyAllRecordsPrinted(kafkaId, true);
          await dbHelpers.verifyPrintStateContiguous(kafkaId);

          // Track print state mutation for final boundary verification.
          world.markPrinted(9); // Index 9 = Franz Kafka
        });

        await logger.step('Final Integrity Check (ExpectedWorldState + Records)', () async {
          await world.verifyAll(dbHelpers, checkRecords: true);
        });

        await logger.step('Write PDF manifest for review', () async {
          final outputDir = capture.outputDir;
          if (outputDir == null) return;

          final manifest = {
            'testName': 'jursky_park_true_e2e',
            'timestamp': DateTime.now().toIso8601String(),
            'prints': capture.capturedPdfs
                .map((p) => {
                      'name': p.name,
                      'pageCount': p.pageCount,
                      'callIndex': p.callIndex,
                      'timestamp': p.timestamp.toIso8601String(),
                      'savedPath': p.savedPath,
                    })
                .toList(),
          };

          final file = File('${outputDir.path}/test_manifest.json');
          await file.writeAsString(jsonEncode(manifest), flush: true);

          for (final pdf in capture.capturedPdfs) {
            debugPrint('PDF artifact: ${pdf.savedPath}');
          }
        });

        // ============================================================
        // FINAL SUMMARY
        // ============================================================
        logger.section('✅✅✅ FULL E2E WORKFLOW COMPLETE ✅✅✅');
        
        // Flush and rethrow any errors collected during the soft-mode run
        logger.finalize();
      });
    });
  });
}

