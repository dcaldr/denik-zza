import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:denik_zza/main.dart' as app;
import 'package:denik_zza/database/database_wrapper.dart';
import 'dart:io';

import '../../infrastructure/robots/dashboard_robot.dart';
import '../../infrastructure/robots/event_editor_robot.dart';

void log(String message) {
  final file = File('debug_trace_create_event.txt');
  file.writeAsStringSync('$message\n', mode: FileMode.append);
  print(message);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Sanity 2: Create Event Workflow', (tester) async {
    File('debug_trace_create_event.txt')
        .writeAsStringSync('Starting Create Event Test\n');
    log('DEBUG: Test Starting');

    // 1. Setup - Ensure Clean(-ish) DB
    // We don't wipe for now, just append. Ideally we start fresh.
    // Assuming Sanity check didn't corrupt anything.
    DatabaseWrapper.getDatabase();
    app.main();
    await tester.pumpAndSettle();
    log('DEBUG: App Launched');

    final dashboard = DashboardRobot(tester);
    final eventEditor = EventEditorRobot(tester);

    // 2. Verify Dashboard
    await dashboard.verifyPageShown();
    log('DEBUG: Dashboard Verified');

    // 3. Navigate to Event Creation
    log('DEBUG: Tapping Add');
    await dashboard.tapCreateNewEvent();

    // 4. Fill Form
    log('DEBUG: Filling Form');
    log('DEBUG: Entering Name');
    await eventEditor.enterEventName('Test Turnus 2024');

    // Default dates (Today) by tapping input then OK
    log('DEBUG: Entering Dates');
    await eventEditor.enterDates(DateTime.now(), DateTime.now());
    log('DEBUG: Dates Entered');

    // 5. Save
    log('DEBUG: Submitting');
    await eventEditor.submit();

    // 6. Verify Dashboard has new event
    log('DEBUG: Verifying New Event');
    await dashboard.verifyPageShown();
    // Use PumpAndSettle with longer timeout/loop if needed, but for now ensure we wait.
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    try {
      await dashboard.verifyEventPresent('Test Turnus 2024');
    } catch (e) {
      log('ERROR: Event not found. Dumping widget tree text...');
      // Simplified dump or just fail
      rethrow;
    }

    log('DEBUG: Test Complete');
  });
}
