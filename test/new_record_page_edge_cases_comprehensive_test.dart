import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'helpers/database_test_helper.dart';
import 'setup_templates/hardcoded_setup.dart';

/// Comprehensive edge case tests for NewRecordPage
/// 
/// Tests ALL combinations of situations including:
/// - Warning behavior: text written → expect warning, no text → no warning
/// - Proper switching without leftover text
/// - Manual timestamp preservation (not overridden by current time)
/// - Record assignment to correct participant after switching
/// - Complex scenario combinations
/// 
/// This test suite focuses on edge cases and state transitions that could
/// cause bugs in real-world usage scenarios.
void main() {
  group('NewRecordPage Edge Cases & Combinations', () {
    late AppDatabase database;
    late List<MemoryOsoba> testParticipants;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Set up test database with participants using existing setup functions
      database = await HardcodedTestSetup.setupTestData(databaseType: TestDatabaseType.memory);
      
      // Get test participants from the setup and convert to MemoryOsoba
      final participants = await database.select(database.participants).get();
      testParticipants = participants.map((p) => MemoryOsoba.named(
        id: p.id,
        jmeno: p.firstName,
        prijmeni: p.lastName,
        datumNarozeni: p.birthDate,
        adresa: p.address,
        zpusobilost: p.eligibleConfirmation,
        bezinfekcnost: p.nonInfectiousConfirmation,
        wasPrinted: p.wasPrinted,
      )).toList();
      
      // Ensure we have at least 3 participants for complex switching tests
      while (testParticipants.length < 3) {
        final participant = await _createTestParticipant(database, 
          'TestUser${testParticipants.length + 1}', 'Participant');
        testParticipants.add(participant);
      }
    });

    tearDown(() async {
      await DatabaseTestHelper.closeTestDatabase(database);
    });

    group('🚨 Warning Behavior Edge Cases', () {
      testWidgets('EDGE CASE: Text written → Warning dialog appears when switching participant', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        // Start with participant1 selected
        await _pumpNewRecordPage(tester, participant: participant1);

        // Write some text in title field
        await _enterTitle(tester, 'Some injury title');
        await tester.pump();

        // Verify unsaved changes are detected
        expect(_hasUnsavedChangesInUI(tester), isTrue, 
          reason: 'Should detect unsaved changes after typing');

        // Try to select different participant via autocomplete
        await _simulateParticipantSelection(tester, participant2);

        // Should show confirmation dialog using key-based detection
        expect(find.byKey(const Key('participant_change_dialog')), findsOneWidget);
        
        // Cancel the change using the specific dialog cancel button
        await tester.tap(find.byKey(const Key('dialog_cancel_button')));
        await tester.pumpAndSettle();

        // Should stay with original participant and keep text using state verification
        expect(_getSelectedParticipantName(tester), equals('${participant1.jmeno} ${participant1.prijmeni}'));
        expect(_getTitleText(tester), equals('Some injury title'));
      });

      testWidgets('EDGE CASE: No text → No warning when switching participant', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        // Start with participant1 selected
        await _pumpNewRecordPage(tester, participant: participant1);

        // DON'T write any text
        
        // Verify no unsaved changes
        expect(_hasUnsavedChangesInUI(tester), isFalse, 
          reason: 'Should not detect unsaved changes with empty form');

        // Try to select different participant
        await _simulateParticipantSelection(tester, participant2);

        // Should NOT show confirmation dialog - direct switch
        expect(find.byKey(const Key('participant_change_dialog')), findsNothing);
        
        // Should switch to new participant immediately using state verification
        await tester.pumpAndSettle();
        expect(_getSelectedParticipantName(tester), equals('${participant2.jmeno} ${participant2.prijmeni}'));
      });

      testWidgets('EDGE CASE: Text in description only → Warning still appears', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Write text in description field only (not title)
        await _enterDescription(tester, 'Some description text');
        await tester.pump();

        // Should still detect unsaved changes
        expect(_hasUnsavedChangesInUI(tester), isTrue, 
          reason: 'Should detect unsaved changes in description field');

        // Try to switch participant
        await _simulateParticipantSelection(tester, participant2);

        // Should show warning even for description-only changes
        expect(find.byKey(const Key('participant_change_dialog')), findsOneWidget);
      });

      testWidgets('EDGE CASE: Text written then deleted → No warning after deletion', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Write and then delete text
        await _enterTitle(tester, 'Some text');
        await tester.pump();
        expect(_hasUnsavedChangesInUI(tester), isTrue);

        await _enterTitle(tester, ''); // Clear the text
        await tester.pump();
        
        // Should no longer have unsaved changes
        expect(_hasUnsavedChangesInUI(tester), isFalse, 
          reason: 'Should not detect unsaved changes after clearing text');

        // Try to switch participant
        await _simulateParticipantSelection(tester, participant2);

        // Should NOT show warning
        expect(find.byKey(const Key('participant_change_dialog')), findsNothing);
      });
    });

    group('🔄 Participant Switching Edge Cases', () {
      testWidgets('EDGE CASE: Proper text clearing after confirmed participant switch', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Write text in both fields
        await _enterTitle(tester, 'Original title');
        await _enterDescription(tester, 'Original description');
        await tester.pump();

        // Switch participant and confirm
        await _simulateParticipantSelection(tester, participant2);
        expect(find.byKey(const Key('participant_change_dialog')), findsOneWidget);
        
        await tester.tap(find.byKey(const Key('dialog_confirm_button')));
        await tester.pumpAndSettle();

        // Should switch to new participant using state verification
        expect(_getSelectedParticipantName(tester), equals('${participant2.jmeno} ${participant2.prijmeni}'));
        
        // Text should be cleared
        expect(_getTitleText(tester), isEmpty, 
          reason: 'Title should be cleared after participant switch');
        expect(_getDescriptionText(tester), isEmpty, 
          reason: 'Description should be cleared after participant switch');
        
        // Unsaved changes should be reset
        expect(_hasUnsavedChangesInUI(tester), isFalse, 
          reason: 'Unsaved changes should be reset after participant switch');
      });

      testWidgets('EDGE CASE: Multiple rapid participant switches', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        final participant3 = testParticipants[2];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Rapidly switch between participants
        await _simulateParticipantSelection(tester, participant2);
        await tester.pumpAndSettle();
        
        await _simulateParticipantSelection(tester, participant3);
        await tester.pumpAndSettle();
        
        await _simulateParticipantSelection(tester, participant1);
        await tester.pumpAndSettle();

        // Should end up with the last selected participant using state verification
        expect(_getSelectedParticipantName(tester), equals('${participant1.jmeno} ${participant1.prijmeni}'));
        
        // Form should be in clean state
        expect(_getTitleText(tester), isEmpty);
        expect(_getDescriptionText(tester), isEmpty);
        expect(_hasUnsavedChangesInUI(tester), isFalse);
      });

      testWidgets('EDGE CASE: Participant switch from null to participant', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        
        // Start with no participant
        await _pumpNewRecordPage(tester);

        // Verify form is disabled
        expect(find.text('Nejprve vyberte účastníka'), findsOneWidget);
        expect(_isFormEnabled(tester), isFalse, 
          reason: 'Form should be disabled when no participant selected');

        // Select a participant
        await _simulateParticipantSelection(tester, participant1);
        await tester.pumpAndSettle();

        // Form should now be enabled
        expect(find.text('Nejprve vyberte účastníka'), findsNothing);
        expect(_isFormEnabled(tester), isTrue, 
          reason: 'Form should be enabled after participant selection');
        expect(_getSelectedParticipantName(tester), equals('${participant1.jmeno} ${participant1.prijmeni}'));
      });
    });

    group('⏰ Timestamp Preservation Edge Cases', () {
      testWidgets('EDGE CASE: Manual timestamp preserved through participant switches', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Set custom timestamp
        await _setCustomDateTime(tester, DateTime(2024, 6, 15, 14, 30));
        
        // Verify custom timestamp is shown using state verification
        final selectedDate = _getSelectedDate(tester);
        final selectedTime = _getSelectedTime(tester);
        expect(selectedDate?.year, equals(2024));
        expect(selectedDate?.month, equals(6));
        expect(selectedDate?.day, equals(15));
        expect(selectedTime?.hour, equals(14));
        expect(selectedTime?.minute, equals(30));

        // Switch participant (no text, so no warning)
        await _simulateParticipantSelection(tester, participant2);
        await tester.pumpAndSettle();

        // Custom timestamp should be preserved using state verification
        final preservedDate = _getSelectedDate(tester);
        final preservedTime = _getSelectedTime(tester);
        expect(preservedDate?.year, equals(2024), 
          reason: 'Custom date should be preserved after participant switch');
        expect(preservedDate?.month, equals(6), 
          reason: 'Custom date should be preserved after participant switch');
        expect(preservedDate?.day, equals(15), 
          reason: 'Custom date should be preserved after participant switch');
        expect(preservedTime?.hour, equals(14), 
          reason: 'Custom time should be preserved after participant switch');
        expect(preservedTime?.minute, equals(30), 
          reason: 'Custom time should be preserved after participant switch');
      });

      testWidgets('EDGE CASE: Timestamp preservation through warning dialog cancellation', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Set custom timestamp and write text
        await _setCustomDateTime(tester, DateTime(2024, 8, 20, 10, 15));
        await _enterTitle(tester, 'Some title');
        await tester.pump();

        // Try to switch participant
        await _simulateParticipantSelection(tester, participant2);
        expect(find.byKey(const Key('participant_change_dialog')), findsOneWidget);
        
        // Cancel the switch using the specific dialog cancel button
        await tester.tap(find.byKey(const Key('dialog_cancel_button')));
        await tester.pumpAndSettle();

        // Should preserve everything: participant, text, and timestamp using state verification
        expect(_getSelectedParticipantName(tester), equals('${participant1.jmeno} ${participant1.prijmeni}'));
        expect(_getTitleText(tester), equals('Some title'));
        final preservedDate = _getSelectedDate(tester);
        final preservedTime = _getSelectedTime(tester);
        expect(preservedDate?.year, equals(2024));
        expect(preservedDate?.month, equals(8));
        expect(preservedDate?.day, equals(20));
        expect(preservedTime?.hour, equals(10));
        expect(preservedTime?.minute, equals(15));
      });

      testWidgets('EDGE CASE: Default timestamp behavior when no custom time set', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Should show default timestamp indicator
        expect(find.text('Datum a čas (aktuální)'), findsOneWidget);
        
        // Switch participant and verify default timestamp maintained
        await _simulateParticipantSelection(tester, testParticipants[1]);
        await tester.pumpAndSettle();
        
        expect(find.text('Datum a čas (aktuální)'), findsOneWidget, 
          reason: 'Default timestamp indicator should persist');
      });
    });

    group('💾 Save Operation Edge Cases', () {
      testWidgets('EDGE CASE: Save with correct participant after multiple switches', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        final participant3 = testParticipants[2];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Switch through multiple participants
        await _simulateParticipantSelection(tester, participant2);
        await tester.pumpAndSettle();
        
        await _simulateParticipantSelection(tester, participant3);
        await tester.pumpAndSettle();

        // Fill form for participant3
        await _enterTitle(tester, 'Final participant injury');
        await _enterDescription(tester, 'Description for participant 3');
        await tester.pump();

        // Save the record
        await _saveRecord(tester);

        // Should save successfully (no validation errors)
        expect(find.text('Prosím zadejte nadpis'), findsNothing);
        expect(find.text('Nejprve vyberte účastníka'), findsNothing);
        
        // Success message should appear
        expect(find.text('Záznam úrazu byl úspěšně uložen do deníku!'), findsOneWidget);
        
        // Form should be cleared after save
        expect(_getTitleText(tester), isEmpty);
        expect(_getDescriptionText(tester), isEmpty);
      });

      testWidgets('EDGE CASE: Save attempt with no participant shows proper warning', 
        (WidgetTester tester) async {
        await _pumpNewRecordPage(tester);

        // Try to save without selecting participant
        await _saveRecord(tester);

        // Should show participant selection warning
        expect(find.text('Nejprve vyberte účastníka'), findsWidgets);
      });

      testWidgets('EDGE CASE: Validation errors with participant selected', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Try to save with empty title
        await _saveRecord(tester);

        // Should show title validation error
        expect(find.text('Prosím zadejte nadpis'), findsOneWidget);
        
        // Form should remain enabled and participant should stay selected
        expect(_getSelectedParticipantName(tester), equals('${participant1.jmeno} ${participant1.prijmeni}'));
        expect(_isFormEnabled(tester), isTrue);
      });
    });

    group('🔄 Complex Scenario Combinations', () {
      testWidgets('COMPLEX: Write text → Set timestamp → Switch participant → Cancel → Verify all preserved', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // 1. Write text
        await _enterTitle(tester, 'Complex scenario title');
        await _enterDescription(tester, 'Complex scenario description');
        await tester.pump();

        // 2. Set custom timestamp
        await _setCustomDateTime(tester, DateTime(2024, 12, 25, 16, 45));

        // 3. Try to switch participant
        await _simulateParticipantSelection(tester, participant2);
        expect(find.byKey(const Key('participant_change_dialog')), findsOneWidget);

        // 4. Cancel the switch
        await tester.tap(find.byKey(const Key('dialog_cancel_button')));
        await tester.pumpAndSettle();

        // 5. Verify everything is preserved using state verification
        expect(_getSelectedParticipantName(tester), equals('${participant1.jmeno} ${participant1.prijmeni}'), 
          reason: 'Original participant should be preserved');
        expect(_getTitleText(tester), equals('Complex scenario title'), 
          reason: 'Title text should be preserved');
        expect(_getDescriptionText(tester), equals('Complex scenario description'), 
          reason: 'Description text should be preserved');
        final preservedDate = _getSelectedDate(tester);
        final preservedTime = _getSelectedTime(tester);
        expect(preservedDate?.year, equals(2024), 
          reason: 'Custom date should be preserved');
        expect(preservedDate?.month, equals(12), 
          reason: 'Custom date should be preserved');
        expect(preservedDate?.day, equals(25), 
          reason: 'Custom date should be preserved');
        expect(preservedTime?.hour, equals(16), 
          reason: 'Custom time should be preserved');
        expect(preservedTime?.minute, equals(45), 
          reason: 'Custom time should be preserved');
      });

      testWidgets('COMPLEX: Multiple operations with successful save at the end', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // 1. Write some text
        await _enterTitle(tester, 'First attempt');
        await tester.pump();

        // 2. Switch participant (with confirmation)
        await _simulateParticipantSelection(tester, participant2);
        await tester.tap(find.byKey(const Key('dialog_confirm_button')));
        await tester.pumpAndSettle();

        // 3. Set custom timestamp
        await _setCustomDateTime(tester, DateTime(2024, 9, 10, 11, 20));

        // 4. Fill form completely
        await _enterTitle(tester, 'Final title');
        await _enterDescription(tester, 'Final description');
        await tester.pump();

        // 5. Save successfully
        await _saveRecord(tester);

        // Should complete successfully
        expect(find.text('Záznam úrazu byl úspěšně uložen do deníku!'), findsOneWidget);
        expect(_getTitleText(tester), isEmpty, reason: 'Form should be cleared after save');
        expect(_getDescriptionText(tester), isEmpty, reason: 'Form should be cleared after save');
        
        // Participant should remain selected using state verification
        expect(_getSelectedParticipantName(tester), equals('${participant2.jmeno} ${participant2.prijmeni}'));
      });

      testWidgets('COMPLEX: Form state consistency after rapid operations', 
        (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        
        await _pumpNewRecordPage(tester);

        // Start with no participant - form should be disabled
        expect(_isFormEnabled(tester), isFalse);
        expect(find.text('Nejprve vyberte účastníka'), findsOneWidget);

        // Select participant - form should enable
        await _simulateParticipantSelection(tester, participant1);
        await tester.pumpAndSettle();
        
        expect(_isFormEnabled(tester), isTrue);
        expect(find.text('Nejprve vyberte účastníka'), findsNothing);

        // Write text quickly
        await _enterTitle(tester, 'Quick text');
        await _enterDescription(tester, 'Quick description');
        await tester.pump();

        // Clear text quickly
        await _enterTitle(tester, '');
        await _enterDescription(tester, '');
        await tester.pump();

        // Form should remain enabled, no unsaved changes
        expect(_isFormEnabled(tester), isTrue);
        expect(_hasUnsavedChangesInUI(tester), isFalse);
        expect(_getSelectedParticipantName(tester), equals('${participant1.jmeno} ${participant1.prijmeni}'));
      });
    });

    group('🎯 UI State Consistency Tests', () {
      testWidgets('CONSISTENCY: All required UI elements present in all states', 
        (WidgetTester tester) async {
        // Test with no participant
        await _pumpNewRecordPage(tester);
        
        _verifyAllUIElementsPresent(tester);
        
        // Test with participant
        await _simulateParticipantSelection(tester, testParticipants[0]);
        await tester.pumpAndSettle();
        
        _verifyAllUIElementsPresent(tester);
      });

      testWidgets('CONSISTENCY: Search functionality always available', 
        (WidgetTester tester) async {
        await _pumpNewRecordPage(tester);
        
  // PersonAutocomplete should always be present by key
  expect(find.byKey(const Key('participant_autocomplete')), findsOneWidget);        // Should remain present after participant selection
        await _simulateParticipantSelection(tester, testParticipants[0]);
        await tester.pumpAndSettle();
        
        expect(find.byKey(const Key('participant_autocomplete')), findsOneWidget);
      });
    });
  });
}

// =============================================================================
// HELPER FUNCTIONS FOR TESTING
// =============================================================================

/// Creates and returns a test participant in the database
Future<MemoryOsoba> _createTestParticipant(AppDatabase db, String firstName, String lastName) async {
  final participant = await db.into(db.participants).insertReturning(ParticipantsCompanion(
    firstName: drift.Value(firstName),
    lastName: drift.Value(lastName),
    birthDate: drift.Value(DateTime(1990, 1, 1)),
    address: const drift.Value('Test Address'),
    eligibleConfirmation: const drift.Value(true),
    nonInfectiousConfirmation: const drift.Value(true),
    wasPrinted: const drift.Value(false),
  ));
  
  return MemoryOsoba.named(
    id: participant.id,
    jmeno: participant.firstName,
    prijmeni: participant.lastName,
    datumNarozeni: participant.birthDate,
    adresa: participant.address,
    zpusobilost: participant.eligibleConfirmation,
    bezinfekcnost: participant.nonInfectiousConfirmation,
    wasPrinted: participant.wasPrinted,
  );
}

/// Pumps the NewRecordPage widget with proper MaterialApp wrapper
Future<void> _pumpNewRecordPage(WidgetTester tester, {MemoryOsoba? participant}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: NewRecordPage(participant: participant),
    ),
  );
  await tester.pumpAndSettle();
}

/// Enters text in the title field
Future<void> _enterTitle(WidgetTester tester, String text) async {
  final titleField = find.byKey(const Key('title_field'));
  await tester.enterText(titleField, text);
}

/// Enters text in the description field
Future<void> _enterDescription(WidgetTester tester, String text) async {
  final descriptionField = find.byKey(const Key('description_field'));
  await tester.enterText(descriptionField, text);
}

/// Gets the current text in the title field
String _getTitleText(WidgetTester tester) {
  final titleField = find.byKey(const Key('title_field'));
  final widget = tester.widget<TextFormField>(titleField);
  return widget.controller?.text ?? '';
}

/// Gets the current text in the description field  
String _getDescriptionText(WidgetTester tester) {
  final descriptionField = find.byKey(const Key('description_field'));
  final widget = tester.widget<TextFormField>(descriptionField);
  return widget.controller?.text ?? '';
}

/// Simulates participant selection through the autocomplete widget
Future<void> _simulateParticipantSelection(WidgetTester tester, MemoryOsoba participant) async {
  // Find the PersonAutocomplete widget by key
  final autocompleteWidget = tester.widget<PersonAutocomplete>(find.byKey(const Key('participant_autocomplete')));
  
  // Simulate the selection by calling the callback directly
  autocompleteWidget.onPersonSelected(participant);
  await tester.pump();
}

/// Sets a custom date and time
Future<void> _setCustomDateTime(WidgetTester tester, DateTime dateTime) async {
  // Find the NewRecordPage widget and call the test method directly
  final newRecordPageState = tester.state<NewRecordPageState>(find.byType(NewRecordPage));
  newRecordPageState.setCustomDateTimeForTesting(dateTime);
  await tester.pump(); // Rebuild the widget to show the new date/time
}

/// Checks if the form currently has unsaved changes
bool _hasUnsavedChangesInUI(WidgetTester tester) {
  // Look for unsaved changes indicators
  return find.text('Neuloženo').evaluate().isNotEmpty ||
         (_getTitleText(tester).trim().isNotEmpty || _getDescriptionText(tester).trim().isNotEmpty);
}

/// Checks if the form is currently enabled (participant selected)
bool _isFormEnabled(WidgetTester tester) {
  try {
    final titleField = find.byKey(const Key('title_field'));
    final widget = tester.widget<TextFormField>(titleField);
    return widget.enabled;
  } catch (e) {
    return false;
  }
}

/// Taps the save button
Future<void> _saveRecord(WidgetTester tester) async {
  final saveButton = find.byKey(const Key('save_button'));
  
  // Ensure the button is visible and ready for tap
  await tester.ensureVisible(saveButton);
  await tester.pumpAndSettle();
  
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
  // Add extra pump to ensure validation errors appear
  await tester.pump();
}

/// Verifies if the participant change dialog is visible
bool _isParticipantChangeDialogVisible(WidgetTester tester) {
  return find.byKey(const Key('participant_change_dialog')).evaluate().isNotEmpty;
}

/// Gets the currently selected participant name from the UI state
String? _getSelectedParticipantName(WidgetTester tester) {
  try {
    final newRecordPageState = tester.state<NewRecordPageState>(find.byType(NewRecordPage));
    final participant = newRecordPageState.selectedParticipant;
    return participant != null ? '${participant.jmeno} ${participant.prijmeni}' : null;
  } catch (e) {
    return null;
  }
}

/// Checks if a participant is currently selected
bool _isParticipantSelected(WidgetTester tester) {
  return _getSelectedParticipantName(tester) != null;
}

/// Gets the currently selected date from the UI state
DateTime? _getSelectedDate(WidgetTester tester) {
  try {
    final newRecordPageState = tester.state<NewRecordPageState>(find.byType(NewRecordPage));
    return newRecordPageState.selectedDate;
  } catch (e) {
    return null;
  }
}

/// Gets the currently selected time from the UI state
TimeOfDay? _getSelectedTime(WidgetTester tester) {
  try {
    final newRecordPageState = tester.state<NewRecordPageState>(find.byType(NewRecordPage));
    return newRecordPageState.selectedTime;
  } catch (e) {
    return null;
  }
}

/// Verifies the current date/time state matches expected values
bool _verifyDateTime(WidgetTester tester, DateTime expectedDateTime) {
  try {
    final newRecordPageState = tester.state<NewRecordPageState>(find.byType(NewRecordPage));
    final selectedDate = newRecordPageState.selectedDate;
    final selectedTime = newRecordPageState.selectedTime;
    
    if (selectedDate == null || selectedTime == null) return false;
    
    return selectedDate.year == expectedDateTime.year &&
           selectedDate.month == expectedDateTime.month &&
           selectedDate.day == expectedDateTime.day &&
           selectedTime.hour == expectedDateTime.hour &&
           selectedTime.minute == expectedDateTime.minute;
  } catch (e) {
    return false;
  }
}

/// Verifies that all required UI elements are present using keys
void _verifyAllUIElementsPresent(WidgetTester tester) {
  // Form elements using keys for reliability
  expect(find.byKey(const Key('title_field')), findsOneWidget, reason: 'Title field should be present');
  expect(find.byKey(const Key('description_field')), findsOneWidget, reason: 'Description field should be present');
  expect(find.byKey(const Key('save_button')), findsOneWidget, reason: 'Save button should be present');
  
  // Controls using keys
  expect(find.byKey(const Key('participant_autocomplete')), findsOneWidget, reason: 'Participant search should be present');
  expect(find.byKey(const Key('datetime_change_button')), findsOneWidget, reason: 'DateTime change button should be present');
}
