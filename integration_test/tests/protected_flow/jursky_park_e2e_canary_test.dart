import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:denik_zza/main.dart' as app;
import 'package:denik_zza/database/database_wrapper.dart';

import '../../infrastructure/data/simulation_profiles.dart';
import '../../infrastructure/robots/dashboard_robot.dart';
import '../../infrastructure/robots/event_detail_robot.dart';
import '../../infrastructure/data/hardcoded_test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Strict analysis check: 0 issues.
  group('E2E Tier 1: Canary Test (Jurský Park)', () {
    testWidgets('Verify Core Flow: Seed -> Dashboard -> Event -> Intake',
        (tester) async {
      // 1. Setup & Logging
      print('DEBUG: Starting Canary Test Setup');
      HardcodedTestSetup.setup();

      // 2. Database & Seeding
      print('DEBUG: Seeding Database');
      final appDatabase = DatabaseWrapper.getDatabase();
      // Cast to AppDatabase if necessary, or ensure seedDatabase accepts DatabaseInterface.
      // Looking at simulation_profiles.dart, seedDatabase takes AppDatabase.
      // DatabaseWrapper.getDatabase() returns DatabaseInterface.
      // We need to cast it or change seedDatabase signature.
      // Since seedDatabase is in infrastructure, let's fix the call site by casting if safe, or assume the real impl is AppDatabase.
      // Actually, DatabaseWrapper.getDatabase() returns DatabaseInterface which is abstract.
      // Depending on imports, 'db' might be inferred as the interface.
      // Let's try casting to dynamic or AppDatabase if imported.
      // Better yet, let's look at seedDatabase signature. It takes `AppDatabase database`.
      // So we need:
      await seedDatabase(appDatabase as dynamic, SimulationProfile.standard());

      // 3. Launch App
      print('DEBUG: Launching App');
      app.main();
      await tester.pumpAndSettle();

      // 4. Robot Initialization
      final dashboard = DashboardRobot(tester);
      final eventDetail = EventDetailRobot(tester);

      // 5. Verify Dashboard
      print('DEBUG: Verifying Dashboard Page');
      await dashboard.verifyPageShown();
      print('DEBUG: Verifying Jurský Park event');
      await dashboard.verifyEventPresent('Jurský Park');

      // 6. Navigate to Event
      print('DEBUG: Tapping Jurský Park');
      await dashboard.tapEvent('Jurský Park');

      // 7. Verify Event Detail
      print('DEBUG: Verifying Event Detail Page');
      await eventDetail.verifyPageShown();
      print('DEBUG: Verifying Participant Karel Čapek');
      await eventDetail.verifyParticipantPresent('Karel Čapek');

      // 8. Navigate to Participant Detail
      // Tapping by text 'Karel Čapek' might be tricky if it's inside a complex widget.
      // But verifyParticipantPresent passed, so text is there.
      print('DEBUG: Tapping Karel Čapek');
      await eventDetail.tapParticipant('Karel Čapek');

      // 9. Verify Participant Detail (Basic check)
      // We don't have a specific ParticipantRobot yet, but we can check for common elements.
      print('DEBUG: Verifying Participant Detail Page');
      await tester.pumpAndSettle();
      expect(find.text('Karel Čapek'), findsOneWidget); // Header
      expect(find.text('Informace o účastníkovi'), findsOneWidget);
    });
  });
}
