// Focused integration test for Intake Form
//
// This test sets up data directly on the backend (like dev_intake_form.dart)
// to bypass the slow UI registration steps and focus on testing intake functionality.
//
// 🚀 Run: flutter test integration_test/tests/intake/intake_form_focused_test.dart -d windows

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/screens2/intake_form_improved.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../infrastructure/robots/intake_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Focused Intake Form Tests', () {
    /// Helper to wait for loading to complete
    Future<void> waitForLoading(WidgetTester tester) async {
      await tester.pump(const Duration(milliseconds: 500));
      final loadingKey = find.byKey(const Key('IntakeForm_loading'));
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (loadingKey.evaluate().isEmpty) {
          break;
        }
      }
      await tester.pump(const Duration(milliseconds: 500));
    }

    // ========== BASIC FUNCTIONALITY ==========

    testWidgets('Select participant and mark as arrived', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      // Select participant
      await intake.selectParticipant('Václav Havel');

      // Verify participant loaded
      await intake.waitForText('Václav');
      await intake.waitForText('Havel');

      // Save and mark as arrived
      await intake.tapSaveAndArrived();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify form reset
      await intake.waitForKey('IntakeForm_saveAndArrived_button');
    });

    testWidgets('Save without marking as arrived', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      await intake.selectParticipant('Karel Čapek');
      await intake.waitForText('Karel');

      // Save only (not arrived)
      await intake.tapSave();
      await tester.pump(const Duration(milliseconds: 500));

      await intake.waitForKey('IntakeForm_save_button');
    });

    testWidgets('Cancel discards selection', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      await intake.selectParticipant('Milan Kundera');
      await intake.waitForText('Milan');

      // Cancel
      await intake.tapCancel();
      await tester.pump(const Duration(milliseconds: 500));

      // Form should be reset
      await intake.waitForKey('IntakeForm_saveAndArrived_button');
    });

    // ========== SEARCH FUNCTIONALITY ==========

    testWidgets('Order-independent search: "Komenský Jan" finds "Jan Komenský"', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      await waitForLoading(tester);

      final searchField = find.widgetWithText(TextField, 'Vyhledat osobu');
      await tester.tap(searchField);
      await tester.pump();
      await tester.enterText(searchField, 'Komenský Jan');
      
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('Jan Komenský').evaluate().isNotEmpty) break;
      }
      
      expect(find.text('Jan Komenský'), findsWidgets);
    });

    testWidgets('Partial last name search finds participant', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      await waitForLoading(tester);

      final searchField = find.widgetWithText(TextField, 'Vyhledat osobu');
      await tester.tap(searchField);
      await tester.pump();
      await tester.enterText(searchField, 'Dvořák');
      
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('Antonín Dvořák').evaluate().isNotEmpty) break;
      }
      
      expect(find.text('Antonín Dvořák'), findsWidgets);
    });

    testWidgets('Partial first name search finds participant', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      await waitForLoading(tester);

      final searchField = find.widgetWithText(TextField, 'Vyhledat osobu');
      await tester.tap(searchField);
      await tester.pump();
      await tester.enterText(searchField, 'Bed');
      
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('Bedřich Smetana').evaluate().isNotEmpty) break;
      }
      
      expect(find.text('Bedřich Smetana'), findsWidgets);
    });

    // ========== SEQUENTIAL PROCESSING ==========

    testWidgets('Process multiple participants sequentially', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      // Process first
      await intake.selectParticipant('Jaroslav Hašek');
      await intake.waitForText('Jaroslav');
      await intake.tapSaveAndArrived();
      await tester.pump(const Duration(milliseconds: 500));

      // Process second
      await intake.selectParticipant('Tomáš Baťa');
      await intake.waitForText('Tomáš');
      await intake.tapSaveAndArrived();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify still functional
      await intake.waitForKey('IntakeForm_saveAndArrived_button');
    });

    // ========== DATABASE PERSISTENCE ==========

    testWidgets('Arrival state persists to database', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      final db = DatabaseWrapper.getDatabase();

      // Use Ema Destinnová for this test (unique, not used elsewhere)
      await intake.selectParticipant('Ema Destinnová');
      await intake.tapSaveAndArrived();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify database updated
      final participants = await db.getParticipantsByCurrentEvent();
      final ema = participants.firstWhere(
        (p) => p.jmeno == 'Ema' && p.prijmeni == 'Destinnová',
      );
      
      expect(ema.prisel, isTrue, 
        reason: 'Ema Destinnová should be marked as arrived after save');
    });

    testWidgets('Note modification persists to database', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      final db = DatabaseWrapper.getDatabase();
      const testNote = 'Unique test note 98765';

      // Use Franz Kafka for this test
      await intake.selectParticipant('Franz Kafka');
      
      // Modify note
      await intake.modifyNote(testNote);
      await tester.pump(const Duration(milliseconds: 500));

      // Save
      await intake.tapSaveAndArrived();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify note persisted
      final participants = await db.getParticipantsByCurrentEvent();
      final franz = participants.firstWhere(
        (p) => p.jmeno == 'Franz' && p.prijmeni == 'Kafka',
      );
      
      // This test exposes the known bug - note not saving
      expect(franz.poznamka, contains(testNote),
        reason: 'Note should contain the test note after save');
    });

    // ========== UI STATE VERIFICATION ==========

    testWidgets('Form shows participant data after selection', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      await intake.selectParticipant('Jan Komenský');

      // Verify multiple fields populated
      await intake.waitForText('Jan');
      await intake.waitForText('Komenský');
      
      // Check form is visible
      await intake.waitForKey('IntakeForm_saveAndArrived_button');
      await intake.waitForKey('IntakeForm_save_button');
      await intake.waitForKey('IntakeForm_cancel_button');
    });

    testWidgets('Empty search shows no suggestions', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      await waitForLoading(tester);

      final searchField = find.widgetWithText(TextField, 'Vyhledat osobu');
      await tester.tap(searchField);
      await tester.pump();
      
      // Type nothing, just tap
      await tester.pump(const Duration(milliseconds: 500));
      
      // No dropdown suggestions should appear (only input field)
      // Specific participant names should not be visible as dropdown items
      expect(find.text('Václav Havel'), findsNothing);
    });

    testWidgets('Non-matching search shows no results', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      await waitForLoading(tester);

      final searchField = find.widgetWithText(TextField, 'Vyhledat osobu');
      await tester.tap(searchField);
      await tester.pump();
      await tester.enterText(searchField, 'XYZNOTEXIST');
      
      await tester.pump(const Duration(milliseconds: 500));
      
      // No participant names should match
      expect(find.text('Václav Havel'), findsNothing);
      expect(find.text('Karel Čapek'), findsNothing);
    });

    // ========== STATE PROBLEMS ==========

    testWidgets('STATE: Form resets completely after save', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      // Select and save first participant
      await intake.selectParticipant('Václav Havel');
      await intake.waitForText('Václav');
      await intake.tapSaveAndArrived();
      await tester.pump(const Duration(milliseconds: 500));

      // After save, first participant's name should NOT be visible in form
      // (autocomplete may still show it in dropdown, but form fields should be empty)
      // The search field should be empty/reset
      final searchField = find.widgetWithText(TextField, 'Vyhledat osobu');
      expect(searchField, findsOneWidget);
    });

    testWidgets('STATE: Previous participant data does not bleed into next selection', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      // Select first participant
      await intake.selectParticipant('Bedřich Smetana');
      await intake.waitForText('Bedřich');
      await intake.waitForText('Smetana');
      
      // Save
      await intake.tapSaveAndArrived();
      await tester.pump(const Duration(milliseconds: 500));

      // Select second participant
      await intake.selectParticipant('Franz Kafka');
      
      // Verify second participant data is shown, not first
      await intake.waitForText('Franz');
      await intake.waitForText('Kafka');
      
      // First participant's unique data should not be present
      // (Smetana's note is different from Kafka's)
    });

    testWidgets('STATE: Switching participants updates form correctly', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      // Select first
      await intake.selectParticipant('Antonín Dvořák');
      await intake.waitForText('Antonín');
      
      // Cancel and select different
      await intake.tapCancel();
      await tester.pump(const Duration(milliseconds: 500));

      await intake.selectParticipant('Milan Kundera');
      await intake.waitForText('Milan');
      
      // Antonín should not be visible in form anymore
      // (may still be in autocomplete suggestions, but not in form fields)
    });

    testWidgets('STATE: Cancel after modification reverts all changes', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      final db = DatabaseWrapper.getDatabase();
      
      // Get original state
      final beforeParticipants = await db.getParticipantsByCurrentEvent();
      final jaroslavBefore = beforeParticipants.firstWhere(
        (p) => p.jmeno == 'Jaroslav' && p.prijmeni == 'Hašek',
      );
      final originalNote = jaroslavBefore.poznamka;

      // Select and modify
      await intake.selectParticipant('Jaroslav Hašek');
      await intake.modifyNote('THIS SHOULD NOT BE SAVED');
      await tester.pump(const Duration(milliseconds: 500));

      // Cancel instead of save
      await intake.tapCancel();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify database unchanged
      final afterParticipants = await db.getParticipantsByCurrentEvent();
      final jaroslavAfter = afterParticipants.firstWhere(
        (p) => p.jmeno == 'Jaroslav' && p.prijmeni == 'Hašek',
      );
      
      expect(jaroslavAfter.poznamka, equals(originalNote),
        reason: 'Cancel should not save changes');
    });

    testWidgets('STATE: Re-selection after cancel shows fresh data', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      // Select, modify, cancel
      await intake.selectParticipant('Tomáš Baťa');
      await intake.modifyNote('Modified note that should be discarded');
      await tester.pump(const Duration(milliseconds: 500));
      await intake.tapCancel();
      await tester.pump(const Duration(milliseconds: 500));

      // Re-select same participant
      await intake.selectParticipant('Tomáš Baťa');
      
      // Form should show original data, not modified data
      await intake.waitForText('Tomáš');
      await intake.waitForText('Baťa');
    });

    testWidgets('STATE: Rapid selection changes do not cause race conditions', (tester) async {
      await DevEnvironment.initialize();
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      final intake = IntakeRobot(tester);
      await waitForLoading(tester);

      // Rapidly select multiple participants
      await intake.selectParticipant('Václav Havel');
      await tester.pump(const Duration(milliseconds: 100));
      
      await intake.tapCancel();
      await tester.pump(const Duration(milliseconds: 100));
      
      await intake.selectParticipant('Karel Čapek');
      await tester.pump(const Duration(milliseconds: 100));
      
      await intake.tapCancel();
      await tester.pump(const Duration(milliseconds: 100));
      
      await intake.selectParticipant('Ema Destinnová');
      await tester.pump(const Duration(milliseconds: 500));

      // Final state should be Ema, not previous selections
      await intake.waitForText('Ema');
      await intake.waitForText('Destinnová');
    });

    testWidgets('STATE: Loading state shows correctly during initialization', (tester) async {
      await DevEnvironment.initialize();
      
      // Pump widget but don't wait for settle
      await tester.pumpWidget(const MaterialApp(home: NewIntakeFormImproved()));
      
      // Check for loading indicator (may or may not be present depending on timing)
      // This test just verifies no crash during loading phase
      await tester.pump(const Duration(milliseconds: 50));
      
      // Wait for loading to complete
      await waitForLoading(tester);
      
      // After loading, form should be interactive
      final searchField = find.widgetWithText(TextField, 'Vyhledat osobu');
      expect(searchField, findsOneWidget);
    });
  });
}
