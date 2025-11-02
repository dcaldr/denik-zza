/// Focus Management Tests
/// 
/// Tests for the focus management fix that ensures TextField focus is maintained
/// during typing across different screens.
/// 
/// **Root Issue Fixed**: TextField inside FutureBuilder caused widget recreation
/// on setState, breaking focus even with stable FocusNode.
/// 
/// **Solution**: Load data in initState(), remove FutureBuilder from interactive
/// widgets, ensure TextField in stable widget tree position.
/// 
/// Tests cover:
/// - ActionDetail: Raw TextField with stable controllers
/// - ParticipantListScreen: PersonAutocomplete widget
/// - NewRecordPage: PersonAutocomplete widget
/// - IntakePersonRow: PersonAutocomplete widget

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/event_detail.dart';
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/screens2/participant_list_screen.dart';
import 'package:denik_zza/screens2/widgets/intake_person_row.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'setup_templates/hardcoded_setup.dart';
import 'utils/database_test_helper.dart';

void main() {
  group('Focus Management - ActionDetail (Raw TextField)', () {
    late MemoryAction testAction;

    setUp(() async {
      DatabaseWrapper.setTestMode();
      await HardcodedTestSetup.setupTestData(
        databaseType: TestDatabaseType.memory,
      );
      
      // Get the current action using DatabaseWrapper
      final dbInterface = DatabaseWrapper.getDatabase();
      testAction = (await dbInterface.getCurrentAction())!;
    });

    testWidgets('Focus maintained during typing in search field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActionDetail(action: testAction),
        ),
      );

      // Wait for data to load
      await tester.pumpAndSettle();

      // Find the search field
      final searchField = find.byKey(const Key('EventDetail_searchField'));
      expect(searchField, findsOneWidget);

      // Tap to focus
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      // Get the TextField widget
      final textField = tester.widget<TextField>(searchField);
      final focusNode = textField.focusNode!;

      // Verify initial focus
      expect(focusNode.hasFocus, isTrue, reason: 'TextField should be focused after tap');

      // Type multiple characters - each triggers setState
      await tester.enterText(searchField, 'A');
      await tester.pump();
      expect(focusNode.hasFocus, isTrue, reason: 'Focus lost after typing "A"');

      await tester.enterText(searchField, 'An');
      await tester.pump();
      expect(focusNode.hasFocus, isTrue, reason: 'Focus lost after typing "An"');

      await tester.enterText(searchField, 'Ant');
      await tester.pump();
      expect(focusNode.hasFocus, isTrue, reason: 'Focus lost after typing "Ant"');

      // Verify text was actually entered
      expect(textField.controller!.text, 'Ant');
    });

    testWidgets('TextField widget not recreated on typing (stable instance)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActionDetail(action: testAction),
        ),
      );

      await tester.pumpAndSettle();

      final searchField = find.byKey(const Key('EventDetail_searchField'));
      
      // Get initial widget instance
      final initialWidget = tester.widget<TextField>(searchField);
      final initialController = initialWidget.controller;
      final initialFocusNode = initialWidget.focusNode;

      // Type to trigger setState
      await tester.enterText(searchField, 'Test');
      await tester.pump();

      // Get widget instance after typing
      final afterWidget = tester.widget<TextField>(searchField);
      
      // Verify same controller and focus node (not recreated)
      expect(afterWidget.controller, same(initialController), 
        reason: 'TextEditingController should not be recreated');
      expect(afterWidget.focusNode, same(initialFocusNode),
        reason: 'FocusNode should not be recreated');
    });

    testWidgets('Focus maintained during rapid typing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActionDetail(action: testAction),
        ),
      );

      await tester.pumpAndSettle();

      final searchField = find.byKey(const Key('EventDetail_searchField'));
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(searchField);
      final focusNode = textField.focusNode!;

      // Rapid typing without pumpAndSettle (simulates real typing)
      final testStrings = ['A', 'An', 'Ant', 'Anto', 'Anton'];
      
      for (final text in testStrings) {
        await tester.enterText(searchField, text);
        await tester.pump(const Duration(milliseconds: 50));
        expect(focusNode.hasFocus, isTrue, 
          reason: 'Focus lost after typing "$text"');
      }

      expect(textField.controller!.text, 'Anton');
    });

    testWidgets('Focus maintained when filtering results (setState calls)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActionDetail(action: testAction),
        ),
      );

      await tester.pumpAndSettle();

      final searchField = find.byKey(const Key('EventDetail_searchField'));
      await tester.tap(searchField);
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(searchField);
      final focusNode = textField.focusNode!;

      // Type to filter - triggers setState which rebuilds filtered list
      await tester.enterText(searchField, 'Dvo');
      await tester.pumpAndSettle();

      // Focus should still be maintained
      expect(focusNode.hasFocus, isTrue);
      
      // Verify filtering worked (list updated)
      // Note: We're testing that setState rebuilt the list WITHOUT breaking focus
      expect(textField.controller!.text, 'Dvo');
    });
  });

  group('Focus Management - ParticipantListScreen (PersonAutocomplete)', () {
    setUp(() async {
      DatabaseWrapper.setTestMode();
      await HardcodedTestSetup.setupTestData(
        databaseType: TestDatabaseType.memory,
      );
    });

    testWidgets('PersonAutocomplete maintains focus during typing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ParticipantListScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find TextField directly by its textFieldKey (not as descendant)
      final textFieldKey = const Key('ParticipantList_searchField');
      final textFieldFinder = find.byKey(textFieldKey);
      expect(textFieldFinder, findsOneWidget, reason: 'TextField with key not found');

      // Tap to focus
      await tester.tap(textFieldFinder);
      await tester.pumpAndSettle();

      // Get FocusNode from TextField
      final textField = tester.widget<TextField>(textFieldFinder);
      final focusNode = textField.focusNode!;

      expect(focusNode.hasFocus, isTrue);

      // Type characters - PersonAutocomplete should maintain focus
      await tester.enterText(textFieldFinder, 'D');
      await tester.pump();
      expect(focusNode.hasFocus, isTrue, reason: 'Focus lost after typing "D"');

      await tester.enterText(textFieldFinder, 'Dv');
      await tester.pump();
      expect(focusNode.hasFocus, isTrue, reason: 'Focus lost after typing "Dv"');

      await tester.enterText(textFieldFinder, 'Dvo');
      await tester.pump();
      expect(focusNode.hasFocus, isTrue, reason: 'Focus lost after typing "Dvo"');
    });

    testWidgets('PersonAutocomplete controllers stable (not recreated)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ParticipantListScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find TextField directly by key
      final textFieldFinder = find.byKey(const Key('ParticipantList_searchField'));
      expect(textFieldFinder, findsOneWidget);

      // Get initial controllers
      final initialTextField = tester.widget<TextField>(textFieldFinder);
      final initialController = initialTextField.controller;
      final initialFocusNode = initialTextField.focusNode;

      // Type to trigger updates
      await tester.enterText(textFieldFinder, 'Test');
      await tester.pump();

      // Get controllers after typing
      final afterTextField = tester.widget<TextField>(textFieldFinder);

      // Verify same instances (stable, not recreated)
      expect(afterTextField.controller, same(initialController));
      expect(afterTextField.focusNode, same(initialFocusNode));
    });
  });

  group('Focus Management - NewRecordPage (PersonAutocomplete)', () {
    late MemoryOsoba testPerson;

    setUp(() async {
      DatabaseWrapper.setTestMode();
      await HardcodedTestSetup.setupTestData(
        databaseType: TestDatabaseType.memory,
      );
      
      final dbInterface = DatabaseWrapper.getDatabase();
      final participants = await dbInterface.getParticipantsByCurrentEvent();
      testPerson = participants.first;
    });

    testWidgets('PersonAutocomplete in NewRecordPage maintains focus', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NewRecordPage(participant: testPerson),
        ),
      );

      await tester.pumpAndSettle();

      // Find TextField directly by textFieldKey (updated key)
      final textFieldKey = const Key('NewRecordPage_participantSearchField');
      final textFieldFinder = find.byKey(textFieldKey);
      expect(textFieldFinder, findsOneWidget, reason: 'TextField with new key not found');

      await tester.tap(textFieldFinder);
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(textFieldFinder);
      final focusNode = textField.focusNode!;

      expect(focusNode.hasFocus, isTrue);

      // Type and verify focus maintained
      await tester.enterText(textFieldFinder, 'J');
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.enterText(textFieldFinder, 'Ja');
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
    });
  });

  group('Focus Management - IntakePersonRow (PersonAutocomplete)', () {
    setUp(() async {
      DatabaseWrapper.setTestMode();
      await HardcodedTestSetup.setupTestData(
        databaseType: TestDatabaseType.memory,
      );
    });

    testWidgets('PersonAutocomplete in IntakePersonRow maintains focus', (tester) async {
      final dbInterface = DatabaseWrapper.getDatabase();
      final participants = await dbInterface.getParticipantsByCurrentEvent();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IntakePersonRow(
              onPersonSelected: (person) {},
              onRefresh: () async {},
              availablePersons: participants,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find PersonAutocomplete in the row
      final autocompleteFinder = find.byType(PersonAutocomplete);
      expect(autocompleteFinder, findsOneWidget);

      final textFieldFinder = find.descendant(
        of: autocompleteFinder,
        matching: find.byType(TextField),
      );

      await tester.tap(textFieldFinder);
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(textFieldFinder);
      final focusNode = textField.focusNode!;

      expect(focusNode.hasFocus, isTrue);

      // Type and verify focus maintained
      await tester.enterText(textFieldFinder, 'K');
      await tester.pump();
      expect(focusNode.hasFocus, isTrue, reason: 'Focus lost in IntakePersonRow after typing');
    });
  });

  group('Focus Management - Architectural Patterns', () {
    testWidgets('Demonstrates stable FocusNode pattern (recommended)', (tester) async {
      // This test demonstrates the correct pattern: stable controllers in StatefulWidget
      await tester.pumpWidget(
        const MaterialApp(
          home: _ArchitecturalDemoWidget(),
        ),
      );

      await tester.pumpAndSettle();

      final textFieldKey = const Key('demo_textField');
      final textField = find.byKey(textFieldKey);
      expect(textField, findsOneWidget);

      await tester.tap(textField);
      await tester.pumpAndSettle();

      final textFieldWidget = tester.widget<TextField>(textField);
      final focusNode = textFieldWidget.focusNode!;

      expect(focusNode.hasFocus, isTrue);

      // Type multiple times - focus maintained with stable controllers
      for (int i = 0; i < 5; i++) {
        await tester.enterText(textField, 'Test$i');
        await tester.pump();
        expect(focusNode.hasFocus, isTrue, 
          reason: 'Focus maintained on iteration $i with stable FocusNode pattern');
      }
    });

    testWidgets('Demonstrates RawAutocomplete pattern (PersonAutocomplete)', (tester) async {
      final testPersons = <MemoryOsoba>[
        MemoryOsoba.basic('Jan', 'Novák'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonAutocomplete(
              availablePersons: testPersons,
              onPersonSelected: (_) {},
              onRefresh: () async {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // PersonAutocomplete creates stable controllers in initState
      // Find TextField directly by its textFieldKey
      final textFieldFinder = find.byKey(const Key('test_autocomplete'));
      expect(textFieldFinder, findsOneWidget);

      await tester.tap(textFieldFinder);
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(textFieldFinder);
      final focusNode = textField.focusNode!;

      // Focus maintained through autocomplete operations
      expect(focusNode.hasFocus, isTrue);

      await tester.enterText(textFieldFinder, 'J');
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
    });
  });
}

/// Demo widget showing correct stable FocusNode pattern
class _ArchitecturalDemoWidget extends StatefulWidget {
  const _ArchitecturalDemoWidget();

  @override
  State<_ArchitecturalDemoWidget> createState() => _ArchitecturalDemoWidgetState();
}

class _ArchitecturalDemoWidgetState extends State<_ArchitecturalDemoWidget> {
  // Stable controllers created in State, survive rebuilds
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _text = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            key: const Key('demo_textField'),
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (value) {
              setState(() {
                _text = value; // setState triggers rebuild, but TextField stable
              });
            },
          ),
          Text('Current text: $_text'), // Shows setState working
        ],
      ),
    );
  }
}
