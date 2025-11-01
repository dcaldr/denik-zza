import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/database_test_helper.dart';

/// Widget tests for AppDrawer menu
/// Tests state-based enabling/disabling and menu structure
void main() {
  group('AppDrawer Widget Tests', () {
    setUp(() async {
      DatabaseWrapper.setTestMode();
    });

    testWidgets('Menu shows all sections', (tester) async {
      DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(),
          ),
        ),
      );

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pump(); // Start drawer animation
      await tester.pumpAndSettle(); // Wait for drawer and FutureBuilder
      
      // Debug: print what we actually found
      print('CircularProgressIndicator found: ${find.byType(CircularProgressIndicator).evaluate().length}');
      print('Drawer found: ${find.byType(Drawer).evaluate().length}');
      print('ListTile found: ${find.byType(ListTile).evaluate().length}');

      // Check section headers
      expect(find.text('UDÁLOSTI'), findsOneWidget);
      expect(find.text('ÚČASTNÍCI'), findsOneWidget);
      expect(find.text('ZÁZNAMY'), findsOneWidget);
      expect(find.text('NÁSTROJE'), findsOneWidget);
    });

    testWidgets('Menu shows header', (tester) async {
      DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Deník ZZA'), findsOneWidget);
    });

    testWidgets('Event operations always enabled', (tester) async {
      DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
      // No event created

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Event operations should be enabled
      final eventListTile = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_event_list')),
      );
      expect(eventListTile.enabled, true);

      final addEventTile = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_add_event')),
      );
      expect(addEventTile.enabled, true);
    });

    testWidgets('Participant operations disabled without event', (tester) async {
      DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
      // No event created

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Participant operations should be disabled
      final newParticipantTile = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_new_participant')),
      );
      expect(newParticipantTile.enabled, false);

      final csvImportTile = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_csv_import')),
      );
      expect(csvImportTile.enabled, false);
    });

    testWidgets('Record operations disabled without event and participants', (tester) async {
      DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
      // No event or participants

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Record operations should be disabled
      final newRecordTile = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_new_record')),
      );
      expect(newRecordTile.enabled, false);

      final intakeFormTile = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_intake_form')),
      );
      expect(intakeFormTile.enabled, false);
    });

    testWidgets('All menu items have keys', (tester) async {
      DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Check all keys exist
      expect(find.byKey(const Key('AppDrawer_event_list')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_add_event')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_participant_list')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_new_participant')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_csv_import')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_new_record')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_intake_form')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_print_center')), findsOneWidget);
    });

    testWidgets('Participant list placeholder is always disabled', (tester) async {
      DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Participant list should be disabled (screen doesn't exist)
      final participantListTile = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_participant_list')),
      );
      expect(participantListTile.enabled, false);
      
      // Should show "Připravujeme"
      expect(find.text('Připravujeme'), findsOneWidget);
    });
  });
}
