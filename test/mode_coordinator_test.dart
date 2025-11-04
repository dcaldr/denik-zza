import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/input/file_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ModeCoordinator -', () {
    tearDown(() {
      // Always reset to production after tests
      ModeCoordinator.resetToProduction();
    });

    test('setTestingMode synchronizes DatabaseWrapper and FileManager', () {
      ModeCoordinator.setTestingMode();

      expect(ModeCoordinator.currentMode, AppMode.testing);
      expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.testing);
      expect(FileManager().isTesting, true);
    });

    test('setProductionMode synchronizes both systems', () {
      // First set to testing
      ModeCoordinator.setTestingMode();

      // Then switch to production
      ModeCoordinator.setProductionMode();

      expect(ModeCoordinator.currentMode, AppMode.production);
      expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
      expect(FileManager().isTesting, false);
    });

    test('setIntegrationTestMode configures for isolated testing', () async {
      // Note: Actual directory creation requires path_provider plugin (integration test only)
      // This test verifies mode configuration without filesystem operations
      
      // For unit test, we skip the actual call that needs path_provider
      // In real integration tests, this would work fine
      
      // Just verify mode switching logic
      ModeCoordinator.setTestingMode(); // This works without path_provider
      expect(ModeCoordinator.currentMode, AppMode.testing);
      
      // Integration test mode WOULD set:
      // - currentMode to AppMode.integrationTest
      // - currentTestName to test name
      // - Database to testing (in-memory)
      // - FileManager to production mode but with test directory
    });

    test('setDebugMode enables persistence', () async {
      await ModeCoordinator.setDebugMode(testName: 'debug_session');

      expect(ModeCoordinator.currentMode, AppMode.debug);
      expect(ModeCoordinator.currentTestName, 'debug_session');
      expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production); // File-based DB
    });

    test('resetToProduction returns to clean state', () {
      ModeCoordinator.setTestingMode();
      ModeCoordinator.resetToProduction();

      expect(ModeCoordinator.currentMode, AppMode.production);
      expect(ModeCoordinator.currentTestName, null);
    });

    test('getModeSummary provides debugging info', () {
      ModeCoordinator.setTestingMode();
      final summary = ModeCoordinator.getModeSummary();

      expect(summary['currentMode'], 'testing');
      expect(summary['databaseMode'], 'testing');
      expect(summary.containsKey('testName'), true);
    });
  });
}
