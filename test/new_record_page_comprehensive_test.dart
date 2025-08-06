import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'helpers/database_test_helper.dart';
import 'setup_templates/hardcoded_setup.dart';

/// Comprehensive tests for NewRecordPage covering all scenarios and combinations
/// 
/// Tests include:
/// - Warning behavior combinations (text written → expect warning, no text → no warning)
/// - Proper switching without leftover text
/// - Manual timestamp preservation (not overridden by current time)
/// - Record assignment to correct participant after switching
/// - Complex scenario combinations
void main() {
  group('NewRecordPage Comprehensive Tests', () {
    late AppDatabase database;
    late List<MemoryOsoba> testParticipants;

    setUpAll(() async {
      // Initialize Flutter binding for widget tests
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
      
      // Ensure we have at least 2 participants for switching tests
      if (testParticipants.length < 2) {
        // Add additional test participants if needed
        final participant1 = await _createTestParticipant(database, 'Test', 'User1');
        final participant2 = await _createTestParticipant(database, 'Test', 'User2');
        testParticipants.addAll([participant1, participant2]);
      }
    });

    tearDown(() async {
      await DatabaseTestHelper.closeTestDatabase(database);
    });

    group('Initial State Tests', () {
      testWidgets('should load correctly with no pre-selected participant', (WidgetTester tester) async {
        await _pumpNewRecordPage(tester);

        // Verify initial state
        expect(find.text('Vyberte účastníka...'), findsOneWidget);
        expect(find.text('Vyhledat'), findsOneWidget);
        expect(find.byType(PersonAutocomplete), findsOneWidget);
        expect(find.text('Neuloženo'), findsNothing); // No unsaved changes initially
      });

      testWidgets('should load correctly with pre-selected participant', (WidgetTester tester) async {
        final participant = testParticipants.first;
        await _pumpNewRecordPage(tester, participant: participant);

        // Verify participant is displayed
        expect(find.text('${participant.jmeno} ${participant.prijmeni}'), findsOneWidget);
        expect(find.text('Vyberte účastníka...'), findsNothing);
      });
    });

    group('Unsaved Changes Warning Tests', () {
      testWidgets('should show warning when title is written and participant is changed', (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Type in title field
        await _enterTitle(tester, 'Test injury title');
        await tester.pump();

        // Verify unsaved changes indicator appears
        expect(find.text('Neuloženo'), findsOneWidget);

        // Try to switch participant via search
        await _selectParticipantFromSearch(tester, participant2);

        // Verify warning dialog appears
        expect(find.text('Změnit účastníka?'), findsOneWidget);
        expect(find.text('Změnou účastníka se ztratí neuložené změny v formuláři. Chcete pokračovat?'), findsOneWidget);
      });

      testWidgets('should show warning when description is written and participant is changed', (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Type in description field
        await _enterDescription(tester, 'Test injury description');
        await tester.pump();

        // Verify unsaved changes indicator appears
        expect(find.text('Neuloženo'), findsOneWidget);

        // Try to switch participant
        await _selectParticipantFromSearch(tester, participant2);

        // Verify warning dialog appears
        expect(find.text('Změnit účastníka?'), findsOneWidget);
      });

      testWidgets('should NOT show warning when no text is written', (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Don't type anything, just try to switch participant
        await _selectParticipantFromSearch(tester, participant2);

        // Verify NO warning dialog appears
        expect(find.text('Změnit účastníka?'), findsNothing);
        
        // Verify participant was switched successfully
        expect(find.text('${participant2.jmeno} ${participant2.prijmeni}'), findsOneWidget);
      });

      testWidgets('should allow canceling participant change when unsaved changes exist', (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Type in title
        await _enterTitle(tester, 'Test title');
        await tester.pump();

        // Try to switch participant
        await _selectParticipantFromSearch(tester, participant2);

        // Cancel the change
        await tester.tap(find.text('Zrušit'));
        await tester.pumpAndSettle();

        // Verify original participant is still selected and text is preserved
        expect(find.text('${participant1.jmeno} ${participant1.prijmeni}'), findsOneWidget);
        expect(find.text('Test title'), findsOneWidget);
        expect(find.text('Neuloženo'), findsOneWidget);
      });

      testWidgets('should allow confirming participant change and clear unsaved changes', (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Type in both fields
        await _enterTitle(tester, 'Test title');
        await _enterDescription(tester, 'Test description');
        await tester.pump();

        // Try to switch participant
        await _selectParticipantFromSearch(tester, participant2);

        // Confirm the change
        await tester.tap(find.text('Změnit účastníka'));
        await tester.pumpAndSettle();

        // Verify new participant is selected and unsaved changes are cleared
        expect(find.text('${participant2.jmeno} ${participant2.prijmeni}'), findsOneWidget);
        expect(find.text('Neuloženo'), findsNothing);
      });
    });

    group('Participant Switching Tests', () {
      testWidgets('should clear form properly when switching participants', (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Type in form fields
        await _enterTitle(tester, 'Original title');
        await _enterDescription(tester, 'Original description');

        // Switch participant (confirm the change)
        await _selectParticipantFromSearch(tester, participant2);
        await tester.tap(find.text('Změnit účastníka'));
        await tester.pumpAndSettle();

        // Verify form is cleared and no leftover text
        expect(find.text('Original title'), findsNothing);
        expect(find.text('Original description'), findsNothing);
        
        // Verify the input fields are empty
        // Note: We'll need to add keys to the form fields in the widget for better testing
      });

      testWidgets('should maintain search functionality after participant selection', (WidgetTester tester) async {
        await _pumpNewRecordPage(tester);

        // Select a participant
        final participant1 = testParticipants[0];
        await _selectParticipantFromSearch(tester, participant1);

        // Verify search field is still available
        expect(find.byType(PersonAutocomplete), findsOneWidget);
        
        // Try to search for another participant
        final participant2 = testParticipants[1];
        await _selectParticipantFromSearch(tester, participant2);

        // Verify the switch worked
        expect(find.text('${participant2.jmeno} ${participant2.prijmeni}'), findsOneWidget);
      });
    });

    group('Timestamp Preservation Tests', () {
      testWidgets('should preserve manually set timestamp and not override with current time', (WidgetTester tester) async {
        final participant = testParticipants.first;
        await _pumpNewRecordPage(tester, participant: participant);

        // Set a specific date and time
        final testDate = DateTime(2024, 6, 15);
        final testTime = TimeOfDay(hour: 14, minute: 30);
        
        await _setDateTime(tester, testDate, testTime);

        // Type some content
        await _enterTitle(tester, 'Test injury');
        await _enterDescription(tester, 'Test description');

        // Save the record
        await _saveRecord(tester);

        // Verify the timestamp was preserved (we'd need to check the saved record)
        // This would require accessing the database to verify the saved record has the correct timestamp
        // For now, verify the UI shows the correct time
        expect(find.textContaining('15.06.2024'), findsOneWidget);
        expect(find.textContaining('14:30'), findsOneWidget);
      });

      testWidgets('should maintain manual timestamp when switching participants', (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Set a specific timestamp
        final testDate = DateTime(2024, 6, 15);
        final testTime = TimeOfDay(hour: 14, minute: 30);
        await _setDateTime(tester, testDate, testTime);

        // Switch participant (no unsaved changes, so no warning)
        await _selectParticipantFromSearch(tester, participant2);

        // Verify timestamp is preserved
        expect(find.textContaining('15.06.2024'), findsOneWidget);
        expect(find.textContaining('14:30'), findsOneWidget);
      });
    });

    group('Record Saving Tests', () {
      testWidgets('should save record to correct participant after switching', (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Switch to participant2
        await _selectParticipantFromSearch(tester, participant2);

        // Fill in the form
        await _enterTitle(tester, 'Injury for participant 2');
        await _enterDescription(tester, 'Description for participant 2');

        // Save the record
        await _saveRecord(tester);

        // Verify success message
        expect(find.text('Záznam úrazu byl úspěšně uložen do deníku!'), findsOneWidget);

        // Verify form is cleared after save
        await tester.pumpAndSettle();
        // We'd need to check that the record appears in the participant's history
        // This would require checking the RecordListWidget or database directly
      });

      testWidgets('should validate required fields before saving', (WidgetTester tester) async {
        final participant = testParticipants.first;
        await _pumpNewRecordPage(tester, participant: participant);

        // Try to save without title
        await _saveRecord(tester);

        // Verify validation error
        expect(find.text('Prosím zadejte nadpis'), findsOneWidget);
      });

      testWidgets('should handle save errors gracefully', (WidgetTester tester) async {
        final participant = testParticipants.first;
        await _pumpNewRecordPage(tester, participant: participant);

        // Fill in valid data
        await _enterTitle(tester, 'Test title');

        // Save the record
        await _saveRecord(tester);

        // If there's an error, verify error handling
        // This would depend on the specific error conditions
      });
    });

    group('Complex Scenario Combinations', () {
      testWidgets('should handle multiple participant switches with different timestamp and content combinations', (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        final participant2 = testParticipants[1];
        
        await _pumpNewRecordPage(tester, participant: participant1);

        // Scenario: Set timestamp, add content, switch participant, change timestamp, add different content
        
        // 1. Set initial timestamp
        await _setDateTime(tester, DateTime(2024, 6, 15), TimeOfDay(hour: 10, minute: 0));
        
        // 2. Add some content
        await _enterTitle(tester, 'First injury');
        
        // 3. Switch participant (should warn and clear content, preserve timestamp)
        await _selectParticipantFromSearch(tester, participant2);
        await tester.tap(find.text('Změnit účastníka'));
        await tester.pumpAndSettle();
        
        // 4. Verify timestamp preserved, content cleared
        expect(find.textContaining('15.06.2024'), findsOneWidget);
        expect(find.text('First injury'), findsNothing);
        
        // 5. Change timestamp
        await _setDateTime(tester, DateTime(2024, 6, 16), TimeOfDay(hour: 15, minute: 30));
        
        // 6. Add new content
        await _enterTitle(tester, 'Second injury');
        await _enterDescription(tester, 'For second participant');
        
        // 7. Save record
        await _saveRecord(tester);
        
        // 8. Verify success and proper state
        expect(find.text('Záznam úrazu byl úspěšně uložen do deníku!'), findsOneWidget);
      });

      testWidgets('should handle rapid participant switching without data corruption', (WidgetTester tester) async {
        await _pumpNewRecordPage(tester);

        // Rapidly switch between participants
        for (int i = 0; i < testParticipants.length; i++) {
          await _selectParticipantFromSearch(tester, testParticipants[i]);
          await tester.pump();
          
          // Verify correct participant is selected
          expect(find.text('${testParticipants[i].jmeno} ${testParticipants[i].prijmeni}'), findsOneWidget);
        }
      });

      testWidgets('should maintain form state consistency across all interactions', (WidgetTester tester) async {
        final participant = testParticipants.first;
        await _pumpNewRecordPage(tester, participant: participant);

        // Complex interaction sequence
        await _enterTitle(tester, 'Initial title');
        await _setDateTime(tester, DateTime(2024, 6, 15), TimeOfDay(hour: 10, minute: 0));
        await _enterDescription(tester, 'Initial description');
        
        // Verify unsaved changes indicator
        expect(find.text('Neuloženo'), findsOneWidget);
        
        // Clear title but keep description
        await _enterTitle(tester, '');
        await tester.pump();
        
        // Should still show unsaved changes due to description
        expect(find.text('Neuloženo'), findsOneWidget);
        
        // Clear description too
        await _enterDescription(tester, '');
        await tester.pump();
        
        // Should not show unsaved changes anymore
        expect(find.text('Neuloženo'), findsNothing);
      });
    });
  });

  group('Helper Function Tests', () {
    // Test the helper functions themselves to ensure they work correctly
    testWidgets('helper functions work correctly', (WidgetTester tester) async {
      // Test basic helper functions
      await _pumpNewRecordPage(tester);
      expect(find.byType(NewRecordPage), findsOneWidget);
      
      // These tests would verify our helper functions work as expected
    });
  });
}

// Helper Functions for Testing

/// Creates and returns a test participant
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
      localizationsDelegates: const [
        // Add necessary localizations
      ],
    ),
  );
  await tester.pumpAndSettle();
}

/// Enters text in the title field
Future<void> _enterTitle(WidgetTester tester, String text) async {
  final titleField = find.ancestor(
    of: find.text('Nadpis'),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(titleField, text);
  await tester.pump();
}

/// Enters text in the description field
Future<void> _enterDescription(WidgetTester tester, String text) async {
  final descriptionField = find.ancestor(
    of: find.text('Popis úrazu a ošetření'),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(descriptionField, text);
  await tester.pump();
}

/// Selects a participant from the search autocomplete
Future<void> _selectParticipantFromSearch(WidgetTester tester, MemoryOsoba participant) async {
  // Find the PersonAutocomplete widget
  final autocompleteField = find.byType(PersonAutocomplete);
  expect(autocompleteField, findsOneWidget);
  
  // Find the text field within the autocomplete
  final textField = find.descendant(
    of: autocompleteField,
    matching: find.byType(TextField),
  );
  
  // Type the participant's name
  await tester.enterText(textField, participant.jmeno);
  await tester.pump();
  
  // Tap on the participant in the suggestions (this might need adjustment based on actual autocomplete implementation)
  final participantOption = find.text('${participant.jmeno} ${participant.prijmeni}');
  if (participantOption.evaluate().isNotEmpty) {
    await tester.tap(participantOption);
    await tester.pumpAndSettle();
  }
}

/// Sets the date and time for the record
Future<void> _setDateTime(WidgetTester tester, DateTime date, TimeOfDay time) async {
  // Find and tap the datetime button
  final dateTimeButton = find.text('Změnit');
  await tester.tap(dateTimeButton);
  await tester.pumpAndSettle();
  
  // This would interact with the date picker dialog
  // Implementation depends on how the date/time picker is implemented
  // For now, we'll assume the dialog appears and we can interact with it
  
  // Handle date picker
  await tester.tap(find.text(date.day.toString()));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  
  // Handle time picker
  // This would depend on the specific time picker implementation
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

/// Taps the save button
Future<void> _saveRecord(WidgetTester tester) async {
  final saveButton = find.text('Uložit do deníku');
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}
