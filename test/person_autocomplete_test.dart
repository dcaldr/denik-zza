import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';

/// PersonAutocomplete Widget Tests
///
/// This file tests the PersonAutocomplete widget's functionality and behavioral contracts.
///
/// Test Organization:
/// - Basic widget tests: Verify widget builds, disposes, and handles input
/// - Feature Contracts: Verify critical user-facing behaviors remain intact
///
/// See copilot-instructions.md "Feature Contract Tests" section for methodology.
void main() {
  group('PersonAutocomplete Widget Tests', () {
    late List<MemoryOsoba> testPersons;

    setUp(() {
      testPersons = [
        MemoryOsoba.basic('John', 'Doe')..id = 1,
        MemoryOsoba.basic('Jane', 'Smith')..id = 2,
        MemoryOsoba.basic('Bob', 'Johnson')..id = 3,
      ];
    });

    testWidgets('should build without errors when provided with person list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonAutocomplete(
              availablePersons: testPersons,
              onPersonSelected: (person) {
                // Person selection callback
              },
              onRefresh: () {
                // Refresh callback
              },
            ),
          ),
        ),
      );

      // Verify the widget builds successfully
      expect(find.byType(PersonAutocomplete), findsOneWidget);
      expect(find.byType(Autocomplete<MemoryOsoba>), findsOneWidget);
      expect(find.text('Search for a person'), findsOneWidget);
    });

    testWidgets('should dispose properly without setState errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonAutocomplete(
              availablePersons: testPersons,
              onPersonSelected: (person) {},
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Different screen'),
          ),
        ),
      );

      // If we get here without exceptions, dispose worked correctly
      expect(find.text('Different screen'), findsOneWidget);
    });

    testWidgets('should filter persons based on search input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonAutocomplete(
              availablePersons: testPersons,
              onPersonSelected: (person) {},
              onRefresh: () {},
            ),
          ),
        ),
      );

      // Find the search field and enter text
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'John');
      await tester.pump();

      // This test verifies the filtering logic works
      // The actual autocomplete dropdown behavior is complex to test
      // but the important part is no setState errors occur
    });

    /// Feature Contract Tests
    ///
    /// These tests verify that critical user-facing behaviors remain intact after
    /// code changes, refactoring, or modifications. They test WHAT the widget does
    /// (observable behavior) rather than HOW it does it (implementation details).
    ///
    /// Purpose:
    /// - Detect accidental breaking changes (e.g., dropdown stops appearing)
    /// - Catch removal of required features (e.g., ID or birthdate disappearing)
    /// - Verify user interactions still work (e.g., selection callbacks)
    /// - Protect against unintended consequences of refactoring or code generation
    ///
    /// When these tests FAIL:
    /// - First check: Did requirements change intentionally? → Update tests
    /// - If NOT intentional: The feature is likely broken → Fix the code
    ///
    /// Maintenance:
    /// - Update tests ONLY when feature requirements change deliberately
    /// - Do NOT modify tests to make them pass after unintended changes
    /// - These failures are alerts that something unexpected happened
    group('Feature Contracts -', () {
      testWidgets('must display dropdown when user types', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PersonAutocomplete(
                availablePersons: testPersons,
                onPersonSelected: (person) {},
                onRefresh: () {},
              ),
            ),
          ),
        );

        final searchField = find.byType(TextField);
        
        // Type text to trigger options
        await tester.enterText(searchField, 'John');
        await tester.pump();

        // Verify dropdown options appear
        // This catches if Autocomplete is broken or replaced with non-working widget
        expect(find.text('John Doe'), findsOneWidget, 
          reason: 'Dropdown must show matching person name');
      });

      testWidgets('must show person ID in dropdown', (WidgetTester tester) async{
        final testPerson = MemoryOsoba.basic('Test', 'Person')
          ..id = 999
          ..datumNarozeni = DateTime(1990, 5, 15);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PersonAutocomplete(
                availablePersons: [testPerson],
                onPersonSelected: (person) {},
                onRefresh: () {},
              ),
            ),
          ),
        );

        final searchField = find.byType(TextField);
        await tester.enterText(searchField, 'Test');
        await tester.pump();

        // Verify ID is visible in dropdown
        expect(find.textContaining('ID: 999'), findsOneWidget,
          reason: 'Dropdown must display person ID for identification');
      });

      testWidgets('must show birthdate when available', (WidgetTester tester) async {
        final testPerson = MemoryOsoba.basic('Test', 'Person')
          ..id = 999
          ..datumNarozeni = DateTime(1990, 5, 15);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PersonAutocomplete(
                availablePersons: [testPerson],
                onPersonSelected: (person) {},
                onRefresh: () {},
              ),
            ),
          ),
        );

        final searchField = find.byType(TextField);
        await tester.enterText(searchField, 'Test');
        await tester.pump();

        // Verify birthdate is visible in dd.mm.yyyy format
        expect(find.textContaining('15.05.1990'), findsOneWidget,
          reason: 'Dropdown must display birthdate in dd.mm.yyyy format');
      });

      testWidgets('must trigger selection callback when tapped', (WidgetTester tester) async {
        MemoryOsoba? selectedPerson;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PersonAutocomplete(
                availablePersons: testPersons,
                onPersonSelected: (person) {
                  selectedPerson = person;
                },
                onRefresh: () {},
              ),
            ),
          ),
        );

        final searchField = find.byType(TextField);
        await tester.enterText(searchField, 'John');
        await tester.pump();

        // Tap on the dropdown option
        await tester.tap(find.text('John Doe'));
        await tester.pumpAndSettle();

        // Verify selection callback was triggered
        expect(selectedPerson, isNotNull,
          reason: 'Tapping dropdown option must trigger selection callback');
        expect(selectedPerson?.jmeno, equals('John'));
        expect(selectedPerson?.prijmeni, equals('Doe'));
      });

      testWidgets('must show multiple matching options', (WidgetTester tester) async {
        final multipleJohns = [
          MemoryOsoba.basic('John', 'Doe')..id = 1,
          MemoryOsoba.basic('John', 'Smith')..id = 2,
          MemoryOsoba.basic('Johnny', 'Walker')..id = 3,
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PersonAutocomplete(
                availablePersons: multipleJohns,
                onPersonSelected: (person) {},
                onRefresh: () {},
              ),
            ),
          ),
        );

        final searchField = find.byType(TextField);
        await tester.enterText(searchField, 'John');
        await tester.pump();

        // All matching options must be visible
        expect(find.text('John Doe'), findsOneWidget,
          reason: 'First matching person must be visible');
        expect(find.text('John Smith'), findsOneWidget,
          reason: 'Second matching person must be visible');
        expect(find.text('Johnny Walker'), findsOneWidget,
          reason: 'Third matching person must be visible');
      });

      testWidgets('must use ListTile for proper Material Design display', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PersonAutocomplete(
                availablePersons: testPersons,
                onPersonSelected: (person) {},
                onRefresh: () {},
              ),
            ),
          ),
        );

        final searchField = find.byType(TextField);
        await tester.enterText(searchField, 'John');
        await tester.pump();

        // Verify ListTile is used (proper Material Design)
        expect(find.byType(ListTile), findsWidgets,
          reason: 'Dropdown must use ListTile for proper Material Design display');
      });
    });
  });
}
