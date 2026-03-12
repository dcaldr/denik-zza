// After-Event Contract Test
//
// Verifies the event deactivation flow (the "AfterEvent" lifecycle step):
//   AppDrawer enabled with active event
//   → tap pin icon to deselect event
//   → getCurrentEventID() returns null
//   → AppDrawer items disabled
//   → participant data still exists in DB (no silent data loss)
//
// The pin toggle on EventList is the only deactivation mechanism in the app.
// This test locks down that contract so AI refactors don't break it silently.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:denik_zza/main.dart' as app;
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';

import '../../../test/setup_templates/hardcoded_setup.dart';
import '../../infrastructure/robots/event_list_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AfterEvent Contract', () {
    setUp(() async {
      await ModeCoordinator.setIntegrationTestMode(
        testName: 'after_event_contract',
      );
      WidgetController.hitTestWarningShouldBeFatal = true;
    });

    testWidgets(
        'Pin-toggle deactivates event: drawer disabled, data intact',
        (tester) async {
      // ── 1. Seed: "Test Test Test" event + 10 Czech participants ──────
      await HardcodedTestSetup.setupTestData();
      final eventId = HardcodedTestSetup.selectedEventId;
      expect(eventId, isNotNull,
          reason: 'HardcodedSetup must produce a selected event ID');

      // ── 2. Launch app ───────────────────────────────────────────────
      app.main();
      await tester.pump();
      final dashboard = EventListRobot(tester);
      final ready = await dashboard.waitForKey(
        'EventList_add_button',
        timeout: const Duration(seconds: 5),
      );
      expect(ready, isTrue, reason: 'Dashboard must be ready after launch');

      // ── 3. Verify active-event state: print center tile is enabled ──
      final db = DatabaseWrapper.getDatabase();
      final currentIdBefore = await db.getCurrentEventID();
      expect(currentIdBefore, equals(eventId),
          reason: 'HardcodedSetup should have set current event = seeded event');

      await dashboard.openDrawer();
      final printCenterBefore = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_print_center')),
      );
      expect(printCenterBefore.enabled, isTrue,
          reason: 'PrintCenter must be enabled when a current event exists');

      // Close the drawer before tapping pin
      final drawerClosed = await tester.binding.handlePopRoute();
      expect(drawerClosed, isTrue, reason: 'Drawer pop should be handled');
      await tester.pumpAndSettle();

      // ── 4. Tap the filled pin icon to deselect the current event ───
      // Icons.push_pin = filled pin (active event)
      // Icons.push_pin_outlined = hollow pin (inactive)
      final pinFinder = find.byIcon(Icons.push_pin);
      expect(pinFinder, findsOneWidget,
          reason: 'Active event must show filled push_pin icon in EventList');
      await tester.tap(pinFinder);
      await tester.pumpAndSettle();

      // ── 5. Verify deactivation: current event is null ───────────────
      final currentIdAfter = await db.getCurrentEventID();
      expect(currentIdAfter, isNull,
          reason:
              'Tapping the filled pin on the active event must deactivate it (set current event to null)');

      // ── 6. Verify drawer is back to first-use disabled state ────────
      await dashboard.openDrawer();
      final printCenterAfter = tester.widget<ListTile>(
        find.byKey(const Key('AppDrawer_print_center')),
      );
      expect(printCenterAfter.enabled, isFalse,
          reason:
              'PrintCenter must be disabled after event deactivation — same as first-use state');

      // ── 7. Data integrity: participants still exist in DB ───────────
      final participants = await db.getParticipantsByEvent(eventId!);
      expect(participants, isNotEmpty,
          reason:
              'Deactivating an event must NOT delete participant data — data must survive pin-toggle');
    });
  });
}
