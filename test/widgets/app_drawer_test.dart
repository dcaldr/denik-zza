import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../utils/base_test_widget.dart';

/// Widget tests for AppDrawer menu
/// Tests state-based enabling/disabling and menu structure
void main() {
  group('AppDrawer Widget Tests', () {
    // Note: setUp() is optional now because BaseTestWidget handles it.

    testWidgets('Menu shows all sections', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          isDrawer: true,
          child: AppDrawer(),
        ),
      );

      // Open drawer
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pump(); // Start drawer animation
      await tester.pumpAndSettle(); // Wait for drawer and FutureBuilder

      // Check section headers (current UI structure)
      expect(find.text('HLAVNÍ: BĚHEM AKCE'), findsOneWidget);
      expect(find.text('PŘÍPRAVA AKCE'), findsOneWidget);
      expect(find.text('ZDRAVOTNICKÝ FILTR'), findsOneWidget);
    });

    testWidgets('Menu shows header', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          isDrawer: true,
          child: AppDrawer(),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Deník ZZA'), findsOneWidget);
    });

    testWidgets('Event operations always enabled', (tester) async {
      // No event created

      await tester.pumpWidget(
        const BaseTestWidget(
          isDrawer: true,
          child: AppDrawer(),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Expand PŘÍPRAVA AKCE section to access event items
      await tester.tap(find.byKey(const Key('AppDrawer_priprava')));
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

    testWidgets('Participant operations disabled without event',
        (tester) async {
      // No event created

      await tester.pumpWidget(
        const BaseTestWidget(
          isDrawer: true,
          child: AppDrawer(),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Expand PŘÍPRAVA AKCE section to access participant items
      await tester.tap(find.byKey(const Key('AppDrawer_priprava')));
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

    testWidgets('Record operations disabled without event and participants',
        (tester) async {
      // No event or participants

      await tester.pumpWidget(
        const BaseTestWidget(
          isDrawer: true,
          child: AppDrawer(),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // New record is in main section (always visible)
      final newRecordTile = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_new_record')),
      );
      expect(newRecordTile.enabled, false);

      // Expand ZDRAVOTNICKÝ FILTR section to access intake form
      await tester.tap(find.text('ZDRAVOTNICKÝ FILTR'));
      await tester.pumpAndSettle();

      final intakeFormTile = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_intake_form')),
      );
      expect(intakeFormTile.enabled, false);
    });

    testWidgets('All menu items have keys', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          isDrawer: true,
          child: AppDrawer(),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Expand PŘÍPRAVA AKCE section to access event items
      await tester.tap(find.byKey(const Key('AppDrawer_priprava')));
      await tester.pumpAndSettle();

      // Scroll to make ZDRAVOTNICKÝ FILTR visible and tap it
      await tester.dragUntilVisible(
        find.byKey(const Key('AppDrawer_filtr')),
        find.byType(ListView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('AppDrawer_filtr')),
          warnIfMissed: false);
      await tester.pumpAndSettle();

      // Check all keys exist
      expect(find.byKey(const Key('AppDrawer_event_list')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_add_event')), findsOneWidget);
      expect(
          find.byKey(const Key('AppDrawer_participant_list')), findsOneWidget);
      expect(
          find.byKey(const Key('AppDrawer_new_participant')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_csv_import')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_new_record')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_intake_form')), findsOneWidget);
      expect(find.byKey(const Key('AppDrawer_print_center')), findsOneWidget);
    });

    testWidgets('Participant list placeholder is always disabled',
        (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          isDrawer: true,
          child: AppDrawer(),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Participant list should be disabled (no event created)
      final participantListTile = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_participant_list')),
      );
      expect(participantListTile.enabled, false);

      // Should show warning message within participant list tile
      final participantListFinder =
          find.byKey(const Key('AppDrawer_participant_list'));
      expect(
        find.descendant(
          of: participantListFinder,
          matching: find.text('Vytvořte akci nejdříve'),
        ),
        findsOneWidget,
      );
    });
  });
}
