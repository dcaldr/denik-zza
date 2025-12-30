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
    testWidgets('Select participant and mark as arrived', (tester) async {
      // 1. Setup: Initialize DevEnvironment (creates in-memory DB with participants)
      await DevEnvironment.initialize();

      // 2. Launch: Just the intake form
      await tester.pumpWidget(
        const MaterialApp(
          home: NewIntakeFormImproved(),
        ),
      );

      // 3. Create robot
      final intake = IntakeRobot(tester);

      // 4. Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Debug: Print what's on screen
      debugPrint('=== DEBUG: Current widget tree ===');
      debugPrint('Loading indicator: ${find.byKey(const Key('IntakeForm_loading')).evaluate().length}');
      debugPrint('Autocomplete input: ${find.widgetWithText(TextField, 'Vyhledat osobu').evaluate().length}');
      
      // Wait for loading to complete (uses pump loop for CircularProgressIndicator)
      final loadingKey = find.byKey(const Key('IntakeForm_loading'));
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (loadingKey.evaluate().isEmpty) {
          debugPrint('Loading complete after ${i * 100}ms');
          break;
        }
      }
      await tester.pumpAndSettle();
      
      // Debug: Check available persons via database
      final db = DatabaseWrapper.getDatabase();
      final participants = await db.getParticipantsByCurrentEvent();
      debugPrint('Available participants in DB: ${participants.length}');
      for (var p in participants.take(3)) {
        debugPrint('  - ${p.jmeno} ${p.prijmeni}');
      }

      // 5. Test: Select a participant (uses first Czech participant from DevEnvironment)
      // DevEnvironment creates: Jan Novák, Jana Nováková, Petr Svoboda, Antonín Dvořák, etc.
      await intake.selectParticipant('Jan Novák');

      // 6. Verify: Participant data loaded into form
      expect(find.text('Jan'), findsWidgets);
      expect(find.text('Novák'), findsWidgets);

      // 7. Test: Save and mark as arrived
      await intake.tapSaveAndArrived();
      await tester.pumpAndSettle();

      // 8. Verify: Form reset, ready for next participant
      await intake.waitForKey('IntakeForm_saveAndArrived_button');
    });

    testWidgets('Debug availablePersons loading', (tester) async {
      // 1. Setup
      await DevEnvironment.initialize();

      // 2. Launch
      await tester.pumpWidget(
        const MaterialApp(
          home: NewIntakeFormImproved(),
        ),
      );

      // 3. Wait and debug
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        
        final loading = find.byKey(const Key('IntakeForm_loading'));
        final autocomplete = find.widgetWithText(TextField, 'Vyhledat osobu');
        
        if (i % 10 == 0) {
          debugPrint('[${i * 50}ms] loading: ${loading.evaluate().isNotEmpty}, autocomplete: ${autocomplete.evaluate().isNotEmpty}');
        }
        
        if (loading.evaluate().isEmpty && autocomplete.evaluate().isNotEmpty) {
          debugPrint('✅ Ready to interact at ${i * 50}ms');
          break;
        }
      }

      // 4. Try typing in autocomplete
      final autocomplete = find.widgetWithText(TextField, 'Vyhledat osobu');
      expect(autocomplete, findsOneWidget, reason: 'Autocomplete should be visible');
      
      await tester.tap(autocomplete);
      await tester.pump();
      
      await tester.enterText(autocomplete, 'Jan');
      await tester.pump(const Duration(milliseconds: 200));
      
      // Debug: Check if dropdown appeared
      final dropdown = find.text('Jan Novák');
      debugPrint('Dropdown "Jan Novák" found: ${dropdown.evaluate().length} widgets');
      
      // More pumps to trigger autocomplete
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        debugPrint('After pump ${i + 1}: "Jan Novák" = ${find.text('Jan Novák').evaluate().length}');
      }
    });
  });
}
