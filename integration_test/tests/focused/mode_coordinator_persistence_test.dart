import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:denik_zza/database/database_wrapper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ModeCoordinator Integration -', () {
    tearDown(() async {
      // Always reset back to production state
      await ModeCoordinator.setProductionMode();
    });

    testWidgets('setIntegrationTestMode enables persistence natively', (tester) async {
      // This requires the path_provider plugin, which works in integration tests
      await ModeCoordinator.setIntegrationTestMode(testName: 'persistence_check');

      expect(ModeCoordinator.currentMode, AppMode.integrationTest);
      expect(ModeCoordinator.currentTestName, 'persistence_check');
      expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.integrationTest); // Verifies file-based DB mode
    });
  });
}
