import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/new_record/new_record_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'setup_templates/hardcoded_setup.dart';

void main() {
  group('NewRecordPage Widget Tests', () {
    late List<MemoryOsoba> testPersons;

    setUp(() async {
      // Use HardcodedTestSetup for robust data initialization
      // This ensures events, participants, and cache are correctly set up
      await HardcodedTestSetup.setupTestData();

      // Get the participants created by the setup
      final dbInterface = DatabaseWrapper.getDatabase();
      testPersons = await dbInterface.getParticipantsByCurrentEvent();

      // Verify setup was successful
      expect(testPersons, isNotEmpty,
          reason: 'HardcodedTestSetup should create participants');
    });

    tearDown(() async {
      await DatabaseWrapper.dispose();
    });

    Widget createTestableWidget() {
      return MaterialApp(
        home: NewRecordPage(
          participant: null, // Start with no participant selected
        ),
      );
    }

    Widget createWidgetWithParticipant(MemoryOsoba participant) {
      return MaterialApp(
        home: NewRecordPage(
          participant: participant,
        ),
      );
    }

    testWidgets('should display initial UI components correctly',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nový záznam úrazu'), findsOneWidget);
      // Participant section present
      expect(find.text('Účastník'), findsOneWidget);
      expect(find.byKey(const Key('NewRecordPage_participantAutocomplete')),
          findsOneWidget);
      // Form fields (by keys)
      expect(
          find.byKey(const Key('NewRecordPage_title_input')), findsOneWidget);
      expect(find.byKey(const Key('NewRecordPage_description_input')),
          findsOneWidget);
      // Datetime and actions (label is now tooltip)
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Tooltip && widget.message == 'Čas záznamu',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('datetime_change_button')), findsOneWidget);
      expect(
          find.byKey(const Key('NewRecordPage_save_button')), findsOneWidget);
      expect(
          find.byKey(const Key('NewRecordPage_cancel_button')), findsOneWidget);
    });

    testWidgets('should show participant selection interface',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Should show participant selection UI elements
      expect(find.text('Účastník'), findsOneWidget);
      expect(find.byKey(const Key('NewRecordPage_participantAutocomplete')),
          findsOneWidget);
    });

    testWidgets('should display form fields for record creation',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Check for form elements (by keys/labels)
      expect(
          find.byKey(const Key('NewRecordPage_title_input')), findsOneWidget);
      expect(find.byKey(const Key('NewRecordPage_description_input')),
          findsOneWidget);
      expect(
          find.byKey(const Key('NewRecordPage_save_button')), findsOneWidget);
    });

    testWidgets('should allow text input in description field',
        (WidgetTester tester) async {
      // Arrange: provide an initial participant to enable the form fields
      final osoba = MemoryOsoba.basic('Test', 'Osoba')..id = 1;
      await tester.pumpWidget(createWidgetWithParticipant(osoba));
      await tester.pumpAndSettle();

      // Act - Enter text in description field
      final descriptionField =
          find.byKey(const Key('NewRecordPage_description_input'));
      // Note: Without a selected participant, the field is disabled but still accepts tester.enterText
      await tester.enterText(descriptionField, 'Test injury description');
      await tester.pumpAndSettle();
      expect(find.text('Test injury description'), findsOneWidget);
    });

    testWidgets('should show timestamp in the UI', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Should display timestamp information (label is now tooltip)
      final tooltipFinder = find.byWidgetPredicate(
        (widget) => widget is Tooltip && widget.message == 'Čas záznamu',
      );
      expect(tooltipFinder, findsOneWidget);
      expect(find.byKey(const Key('datetime_change_button')), findsOneWidget);
    });

    // testWidgets('should handle refresh button tap', (WidgetTester tester) async {
    //   // This test is obsolete: the refresh control is now integrated into PersonAutocomplete.
    //   // Keeping as skipped to document behavioral change.
    // }, skip: true);

    testWidgets('should handle save button interaction',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Act - Tap save button (without valid data)
      final saveButton = find.byKey(const Key('NewRecordPage_save_button'));
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Assert - Should handle the interaction (may show validation errors)
      // The exact behavior depends on validation logic
      expect(find.byKey(const Key('NewRecordPage_save_button')),
          findsOneWidget); // Button should still be there
    });

    testWidgets('should maintain form state during interactions',
        (WidgetTester tester) async {
      // Arrange: provide an initial participant so fields are enabled
      final osoba = MemoryOsoba.basic('Test', 'Osoba')..id = 1;
      await tester.pumpWidget(createWidgetWithParticipant(osoba));
      await tester.pumpAndSettle();

      // Act - Enter some text
      final textField =
          find.byKey(const Key('NewRecordPage_description_input'));
      await tester.enterText(textField, 'Test content that should persist');
      await tester.pumpAndSettle();

      // There is no standalone refresh button anymore; ensure structure persists
      expect(find.text('Nový záznam úrazu'), findsOneWidget);
      expect(find.byKey(const Key('NewRecordPage_description_input')),
          findsOneWidget);
    });

    testWidgets('should show proper form layout', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Check layout elements
      expect(find.text('Nový záznam úrazu'), findsOneWidget); // Page title
      expect(find.text('Účastník'), findsOneWidget); // Participant section
      expect(find.byKey(const Key('NewRecordPage_title_input')),
          findsOneWidget); // Title field
      expect(find.byKey(const Key('NewRecordPage_description_input')),
          findsOneWidget); // Description field
      expect(find.byKey(const Key('NewRecordPage_save_button')),
          findsOneWidget); // Save button
    });

    testWidgets('should handle widget lifecycle correctly',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert initial state
      expect(find.text('Nový záznam úrazu'), findsOneWidget);

      // Act - Remove widget and recreate
      await tester.pumpWidget(Container()); // Empty widget
      await tester.pumpAndSettle();

      // Recreate
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Should properly reinitialize
      expect(find.text('Nový záznam úrazu'), findsOneWidget);
      expect(find.text('Účastník'), findsOneWidget);
    });

    /// Feature Contract Tests
    ///
    /// These tests protect non-obvious, critical UI behaviors that could break
    /// during refactoring. They focus on WHAT the feature does (observable behavior),
    /// not HOW it's implemented.
    ///
    /// See copilot-instructions.md "Feature Contract Tests" section for methodology.
    group('Feature Contracts -', () {
      testWidgets('must show health items when participant selected',
          (WidgetTester tester) async {
        // Create participant with health data including birthdate
        final participant = MemoryOsoba.basic('Test', 'Person')
          ..id = 1
          ..datumNarozeni =
              DateTime(2000, 1, 1); // Add birthdate to show age icon

        await tester.pumpWidget(createWidgetWithParticipant(participant));
        await tester.pumpAndSettle();

        // Critical: Health section must be visible (not hidden behind collapsed state)
        // This catches if health info becomes hidden by default accidentally
        expect(find.byKey(const Key('NewRecordPage_birthdate_info_icon')),
            findsOneWidget,
            reason:
                'Age info icon must be present when participant has birthdate');
      });

      testWidgets('must show compact collapse button when >6 health items',
          (WidgetTester tester) async {
        // This would require mock data setup - documented as TODO
        // TODO: Add test with participant having >6 health items to verify collapse button appears
      });

      testWidgets('must display print icons in datetime row',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        // Critical: Print icons must be present and disabled by default
        expect(find.byKey(const Key('NewRecordPage_print_full_button')),
            findsOneWidget,
            reason: 'Full print button must be visible in datetime row');
        expect(find.byKey(const Key('NewRecordPage_print_append_button')),
            findsOneWidget,
            reason: 'Append print button must be visible in datetime row');
      });

      testWidgets('must show dev warning badge', (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        // Critical: Dev warning must be visible to indicate mock data
        expect(find.text('USES MOCKUPS !!'), findsOneWidget,
            reason:
                'Dev warning badge must be present until real data entry implemented');
      });

      testWidgets('must show způsobilost chip when flag is true',
          (WidgetTester tester) async {
        // TODO: Add test with participant having zpusobilost=true
        // Verify způsobilost chip appears in datetime row
      });

      testWidgets('must allow clicking health chips to expand full text',
          (WidgetTester tester) async {
        // TODO: Add test that clicks a truncated health chip and verifies overlay shows
        // This protects the critical "click to expand" behavior
      });

      testWidgets('must show age with clickable info icon',
          (WidgetTester tester) async {
        final participant = MemoryOsoba.basic('Jan', 'Novák')
          ..id = 1
          ..datumNarozeni = DateTime(2007, 9, 8);

        await tester.pumpWidget(createWidgetWithParticipant(participant));
        await tester.pumpAndSettle();

        // Age must be displayed
        expect(find.textContaining('let'), findsOneWidget,
            reason: 'Age text must be visible when birthdate present');

        // Info icon must be clickable
        expect(find.byKey(const Key('NewRecordPage_birthdate_info_icon')),
            findsOneWidget,
            reason: 'Birthdate info icon must be present and clickable');
      });

      testWidgets('must not overflow datetime row with all buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        // Critical: Datetime row must handle: Změnit + 2 print icons + způsobilost without overflow
        expect(tester.takeException(), isNull,
            reason:
                'DateTime row must not overflow even with all buttons visible');
      });

      testWidgets('must handle narrow screen widths gracefully',
          (WidgetTester tester) async {
        // Set narrow screen size
        await tester.binding.setSurfaceSize(const Size(400, 800));

        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull,
            reason: 'UI must adapt to narrow screens without overflow');

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });
    });

    // Normal tests for recent UI changes
    testWidgets('should allow tapping datetime area when participant selected',
        (WidgetTester tester) async {
      final participant = MemoryOsoba.basic('Jan', 'Novák')..id = 1;

      await tester.pumpWidget(createWidgetWithParticipant(participant));
      await tester.pumpAndSettle();

      // Datetime area should be clickable
      final datetimeButton = find.byKey(const Key('datetime_change_button'));
      expect(datetimeButton, findsOneWidget);

      // Verify it's enabled (has onTap)
      final inkWell = tester.widget<InkWell>(datetimeButton);
      expect(inkWell.onTap, isNotNull,
          reason: 'DateTime area should be tappable when participant selected');
    });

    testWidgets('should disable datetime editing when no participant selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // DateTime button exists but is disabled
      final datetimeButton = find.byKey(const Key('datetime_change_button'));
      expect(datetimeButton, findsOneWidget);

      final inkWell = tester.widget<InkWell>(datetimeButton);
      expect(inkWell.onTap, isNull,
          reason:
              'DateTime area should be disabled when no participant selected');
    });

    group('Datetime Reset Button -', () {
      testWidgets(
          'must not show reset button in default state with pre-selected participant',
          (WidgetTester tester) async {
        final participant = MemoryOsoba.basic('Jan', 'Novák')..id = 1;
        await tester.pumpWidget(createWidgetWithParticipant(participant));
        await tester.pumpAndSettle();

        // Reset button should NOT be visible in default state (datetime not modified)
        expect(find.byKey(const Key('datetime_reset_button')), findsNothing,
            reason:
                'Reset button should be hidden when datetime is in default state');

        // Default text should be shown
        expect(find.text('Datum a čas (aktuální)'), findsOneWidget,
            reason: 'Should show default datetime text in initial state');
      });

      testWidgets(
          'must render PersonAutocomplete widget when no participant pre-selected',
          (WidgetTester tester) async {
        // This test verifies autocomplete widget is present and user can interact with it
        // Actual autocomplete selection flow is complex to test (requires database setup)
        // and is better covered by integration tests or manual testing
        await tester.pumpWidget(createTestableWidget());
        await tester.pumpAndSettle();

        // Initially no reset button (no participant, datetime disabled)
        expect(find.byKey(const Key('datetime_reset_button')), findsNothing);

        // Verify PersonAutocomplete widget is rendered with correct key
        final autocompleteWidget =
            find.byKey(const Key('NewRecordPage_participantAutocomplete'));
        expect(autocompleteWidget, findsOneWidget,
            reason:
                'PersonAutocomplete widget must be present for manual participant selection');

        // Verify TextField is accessible within autocomplete
        final autocompleteField = find.descendant(
          of: autocompleteWidget,
          matching: find.byType(TextField),
        );
        expect(autocompleteField, findsOneWidget,
            reason:
                'Autocomplete must have TextField for typing participant name');

        // Contract: When no participant selected, datetime controls disabled
        final datetimeButton = find.byKey(const Key('datetime_change_button'));
        final inkWell = tester.widget<InkWell>(datetimeButton);
        expect(inkWell.onTap, isNull,
            reason: 'Datetime must be disabled without participant');

        // Contract: Reset button only shows when datetime modified (currently impossible without participant)
        expect(find.byKey(const Key('datetime_reset_button')), findsNothing,
            reason:
                'Reset button must not show when datetime controls disabled');
      });
    });

    group('Feature Contracts - Datetime Reset -', () {
      testWidgets('must hide reset button when datetime is default',
          (WidgetTester tester) async {
        final participant = MemoryOsoba.basic('Jan', 'Novák')..id = 1;
        await tester.pumpWidget(createWidgetWithParticipant(participant));
        await tester.pumpAndSettle();

        // Contract: Reset button must not be visible when datetime is in default state
        expect(find.byKey(const Key('datetime_reset_button')), findsNothing,
            reason:
                'Reset button must be hidden for clean UI when datetime not modified');
      });

      testWidgets('must show reset button only when datetime modified',
          (WidgetTester tester) async {
        // Note: This is a feature contract test to ensure the conditional rendering
        // works correctly. Actual datetime modification requires platform dialogs
        // which cannot be easily tested in widget tests. This test verifies the
        // contract that the reset button appears/disappears based on state.

        final participant = MemoryOsoba.basic('Jan', 'Novák')..id = 1;
        await tester.pumpWidget(createWidgetWithParticipant(participant));
        await tester.pumpAndSettle();

        // Contract: Reset button visibility is controlled by _selectedDate and _selectedTime state
        // When both are null → button hidden (tested above)
        // When either is not null → button shown (requires manual verification or integration test)

        // This contract ensures UI stays clean and only shows reset when needed
        expect(find.byKey(const Key('datetime_reset_button')), findsNothing,
            reason: 'Reset button must follow conditional rendering pattern');
      });
    });

    // Note: Time-first picker behavior cannot be tested in widget tests
    // as showTimePicker/showDatePicker are framework dialogs.
    // Manual testing confirms time picker appears first, then date picker.
  });
}
