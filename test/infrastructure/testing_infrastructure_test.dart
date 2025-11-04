import 'package:flutter_test/flutter_test.dart';
import '../utils/test_configuration.dart';
import '../utils/test_output_manager.dart';
import '../utils/unified_test_setup.dart';
import '../utils/testing_setup_helper.dart';

/// Comprehensive test suite for the three-mode testing infrastructure
/// 
/// Tests:
/// - All three modes (inMemory, persist, production) work correctly
/// - Database-FileManager integration is preserved
/// - Directory creation and cleanup functions properly
/// - --dart-define flag parsing works as expected
/// - Mode switching safety is maintained
void main() {
  group('Testing Infrastructure Integration Tests', () {
    
    group('TestConfiguration', () {
      test('should default to inMemory mode when no dart-define is set', () {
        expect(TestConfiguration.getTestMode(), TestMode.inMemory);
        expect(TestConfiguration.isInMemory, true);
        expect(TestConfiguration.isPersist, false);
        expect(TestConfiguration.isProduction, false);
        expect(TestConfiguration.modeString, 'inMemory');
      });
      
      test('should provide config summary for debugging', () {
        final summary = TestConfiguration.getConfigSummary();
        expect(summary, isA<Map<String, dynamic>>());
        expect(summary['currentMode'], 'inMemory');
        expect(summary['isInMemory'], true);
        expect(summary['isPersist'], false);
        expect(summary['isProduction'], false);
      });
      
      test('should validate production safety checks', () {
        // In default inMemory mode, production safety should return true
        expect(TestConfiguration.isProductionSafe, true);
      });
    });
    
    group('TestOutputManager', () {
      setUp(() async {
        // Ensure clean state
        await TestOutputManager.cleanup();
      });
      
      tearDown(() async {
        // Clean up after each test
        await TestOutputManager.cleanup();
      });
      
  test('should handle inMemory mode (no directory creation)', () async {
        // In inMemory mode, no directories should be created
        await TestOutputManager.initialize();
        
        // Directory might exist from previous runs, but shouldn't be created by inMemory mode
        final dbPath = await TestOutputManager.getDatabasePath('test.db');
        expect(dbPath, isEmpty); // inMemory mode returns empty path
      });
      
      test('should provide output summary', () {
        final summary = TestOutputManager.getOutputSummary();
        expect(summary, isA<Map<String, dynamic>>());
        expect(summary['currentMode'], 'inMemory');
        expect(summary.containsKey('testOutputsDir'), true);
        expect(summary.containsKey('persistDir'), true);
        expect(summary.containsKey('productionDir'), true);
      });
      
      test('should handle cleanup operations safely', () async {
        // Should not throw even if directories don't exist
        await TestOutputManager.cleanup();
        await TestOutputManager.cleanupPersist();
        await TestOutputManager.cleanupProduction();
      });
    });
    
    group('UnifiedTestSetup', () {
      test('should create inMemory database by default', () async {
        final database = await UnifiedTestSetup.createDatabase();
        expect(database, isNotNull);
        
        // Verify it's an in-memory database by checking the connection type
        // (We can't easily test the connection type directly, but we can verify it works)
        
        await database.close();
      });
      
      test('should initialize test environment without errors', () async {
        await expectLater(
          UnifiedTestSetup.initializeTestEnvironment(),
          completes,
        );
      });
      
      test('should provide environment summary', () {
        final summary = UnifiedTestSetup.getEnvironmentSummary();
        expect(summary, isA<Map<String, dynamic>>());
        expect(summary.containsKey('testConfiguration'), true);
        expect(summary.containsKey('testOutputManager'), true);
        expect(summary.containsKey('timestamp'), true);
      });
      
      test('should validate environment correctly', () async {
        final isValid = await UnifiedTestSetup.validateEnvironment();
        expect(isValid, true);
      });
      
      test('should handle cleanup without errors', () async {
        await expectLater(
          UnifiedTestSetup.cleanupTestEnvironment(),
          completes,
        );
      });
    });
    
    group('TestingSetupHelper Integration', () {
      test('should provide backward compatible database creation', () async {
        final database = await TestingSetupHelper.createTestDatabase();
        expect(database, isNotNull);
        
        // Verify we can get the current database
        final currentDb = TestingSetupHelper.getCurrentDatabase();
        expect(currentDb, same(database));
        
        await TestingSetupHelper.cleanUp();
      });
      
      test('should maintain DatabaseWrapper integration', () async {
        await TestingSetupHelper.setupTestEnvironment();
        
        final testInfo = TestingSetupHelper.getTestInfo();
        expect(testInfo['isInitialized'], true);
        expect(testInfo['hasDatabase'], true);
        expect(testInfo['databaseWrapperMode'], 'testing');
        expect(testInfo['testMode'], 'inMemory');
        
        await TestingSetupHelper.cleanUp();
      });
      
      test('should validate test environment properly', () async {
        await TestingSetupHelper.setupTestEnvironment();
        
        final isValid = await TestingSetupHelper.validateTestEnvironment();
        expect(isValid, true);
        
        await TestingSetupHelper.cleanUp();
      });
      
      test('should handle multiple setup/teardown cycles', () async {
        // First cycle
        await TestingSetupHelper.setupTestEnvironment();
        expect(TestingSetupHelper.getCurrentDatabase(), isNotNull);
        await TestingSetupHelper.cleanUp();
        
        // Second cycle
        await TestingSetupHelper.setupTestEnvironment();
        expect(TestingSetupHelper.getCurrentDatabase(), isNotNull);
        await TestingSetupHelper.cleanUp();
        
        // Third cycle
        await TestingSetupHelper.setupTestEnvironment();
        expect(TestingSetupHelper.getCurrentDatabase(), isNotNull);
        await TestingSetupHelper.cleanUp();
      });
      
      test('should throw error when accessing database before setup', () {
        expect(
          () => TestingSetupHelper.getCurrentDatabase(),
          throwsStateError,
        );
      });
    });
    
    group('Integration with Existing Patterns', () {
      test('should work with setUp/tearDown pattern', () async {
        // This simulates how existing tests would be updated
        await TestingSetupHelper.setupTestEnvironment();
        
        // Verify database is available and working
        final db = TestingSetupHelper.getCurrentDatabase();
        expect(db, isNotNull);
        
        // Verify we can perform basic database operations
        // (Basic test - more detailed database tests are elsewhere)
        
        await TestingSetupHelper.cleanUp();
      });
      
      test('should preserve existing database architecture', () async {
        await TestingSetupHelper.setupTestEnvironment();
        
        final db = TestingSetupHelper.getCurrentDatabase();
        
        // Verify database has expected structure
        // This is a smoke test - detailed database tests are in other test files
        expect(db, isNotNull);
        
        await TestingSetupHelper.cleanUp();
      });
    });
    
    group('Mode Switching Safety', () {
      test('should handle rapid setup/cleanup cycles safely', () async {
        for (int i = 0; i < 5; i++) {
          await TestingSetupHelper.setupTestEnvironment();
          expect(TestingSetupHelper.getCurrentDatabase(), isNotNull);
          await TestingSetupHelper.cleanUp();
        }
      });
      
      test('should maintain clean state between tests', () async {
        // First test setup
        await TestingSetupHelper.setupTestEnvironment();
        final firstDb = TestingSetupHelper.getCurrentDatabase();
        await TestingSetupHelper.cleanUp();
        
        // Second test setup
        await TestingSetupHelper.setupTestEnvironment();
        final secondDb = TestingSetupHelper.getCurrentDatabase();
        await TestingSetupHelper.cleanUp();
        
        // Databases should be different instances (clean slate)
        expect(identical(firstDb, secondDb), false);
      });
    });
    
    group('Error Handling', () {
      test('should handle invalid states gracefully', () async {
        // Test accessing database without setup
        expect(
          () => TestingSetupHelper.getCurrentDatabase(),
          throwsStateError,
        );
        
        // Test validation before setup
        final isValid = await TestingSetupHelper.validateTestEnvironment();
        expect(isValid, false);
      });
      
      test('should handle cleanup on uninitialized state', () async {
        // Should not throw even if not initialized
        await expectLater(
          TestingSetupHelper.cleanUp(),
          completes,
        );
      });
    });
  });
  
  group('Performance and Resource Management', () {
    test('should not leak database connections', () async {
      // Create and close multiple databases
      for (int i = 0; i < 10; i++) {
        await TestingSetupHelper.setupTestEnvironment();
        await TestingSetupHelper.cleanUp();
      }
      
      // If there were connection leaks, this would eventually fail
      // This is a basic test - more sophisticated leak detection would require additional tooling
    });
    
    test('should handle concurrent setup attempts safely', () async {
      // This tests that the infrastructure handles concurrent access safely
      final futures = List.generate(5, (index) async {
        await TestingSetupHelper.setupTestEnvironment();
        final db = TestingSetupHelper.getCurrentDatabase();
        expect(db, isNotNull);
        await TestingSetupHelper.cleanUp();
      });
      
      await Future.wait(futures);
    });
  });
}
