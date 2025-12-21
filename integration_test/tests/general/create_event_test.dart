import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:denik_zza/main.dart' as app;
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:intl/intl.dart';

import '../../infrastructure/robots/dashboard_robot.dart';
import '../../infrastructure/robots/event_editor_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Sanity 2: Create Event Workflow', (tester) async {
    // 1. Setup: Use Integration mode (file-based DB in isolated folder)
    final runId = DateFormat('yyMMdd_HHmmss').format(DateTime.now());
    await ModeCoordinator.setIntegrationTestMode(
      runId: runId,
      testName: 'create_event',
    );
    AppLogger.l.d('Create Event Test: Mode set - $runId/create_event');

    // 2. Get DB and launch app
    DatabaseWrapper.getDatabase();
    app.main();
    await tester.pumpAndSettle();
    AppLogger.l.d('App Launched');

    final dashboard = DashboardRobot(tester);
    final eventEditor = EventEditorRobot(tester);

    // 3. Verify Dashboard
    await dashboard.verifyPageShown();
    AppLogger.l.d('Dashboard Verified');

    // 4. Navigate to Event Creation
    AppLogger.l.d('Tapping Add');
    await dashboard.tapCreateNewEvent();

    // 5. Fill Form
    AppLogger.l.d('Filling Form - Entering Name');
    await eventEditor.enterEventName('Test Turnus 2024');

    // Default dates (Today) by tapping input then OK
    AppLogger.l.d('Entering Dates');
    await eventEditor.enterDates(DateTime.now(), DateTime.now());
    AppLogger.l.d('Dates Entered');

    // 6. Save
    AppLogger.l.d('Submitting');
    await eventEditor.submit();

    // 7. Verify Dashboard has new event
    AppLogger.l.d('Verifying New Event');
    await dashboard.verifyPageShown();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    try {
      await dashboard.verifyEventPresent('Test Turnus 2024');
    } catch (e) {
      AppLogger.l.e('Event not found: $e');
      rethrow;
    }

    AppLogger.l.d('Test Complete');
  });
}
