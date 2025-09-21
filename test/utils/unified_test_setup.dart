import '../../lib/database/drift_database/database.dart';
import 'package:drift/drift.dart';
import '../../lib/input/file_manager.dart';
import 'test_configuration.dart';
import 'test_output_manager.dart';

/// Unified test setup coordinating all testing infrastructure components
class UnifiedTestSetup {
  /// Create a test database with proper mode configuration
  static Future<AppDatabase> createDatabase({bool useFileManagerPersist = false, bool useRunDir = true}) async {
    final testMode = TestConfiguration.getTestMode();
    
    switch (testMode) {
      case TestMode.inMemory:
        return AppDatabase.testInMemory();
      case TestMode.persist:
        await TestOutputManager.initialize();
        // Persist mode: provide a concrete .db file path; AppDatabase will treat
        // paths ending with .db as file paths and open them directly.
        if (useFileManagerPersist) {
          // Optionally configure FileManager to point to the per-run directory
          final runDir = await TestOutputManager.getOrCreatePersistRunDirectory();
          FileManager().setPersistentTestMode(runDir);
        }
        final dbPath = await TestOutputManager.getDatabasePath('test_database.db', useRunDir: useRunDir);
        return AppDatabase(dbPath);
      case TestMode.production:
        if (!TestConfiguration.isProductionSafe) {
          throw Exception('Production testing requires CONFIRM_PRODUCTION_TESTING=yes');
        }
        await TestOutputManager.initialize();
        final dbPath = await TestOutputManager.getDatabasePath('production_test_database.db', useRunDir: useRunDir);
        return AppDatabase(dbPath);
    }
  }
  
  /// Initialize test environment for all modes
  static Future<void> initializeTestEnvironment() async {
    // Suppress noisy drift warning about multiple AppDatabase instances in tests.
    // We intentionally create isolated DBs per test for reliability.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await TestOutputManager.initialize();
  }
  
  /// Clean up test environment
  static Future<void> cleanupTestEnvironment() async {
    final testMode = TestConfiguration.getTestMode();
    
    switch (testMode) {
      case TestMode.inMemory:
        // No cleanup needed for in-memory
        break;
      case TestMode.persist:
        await TestOutputManager.cleanupPersist();
        break;
      case TestMode.production:
        // Don't auto-cleanup production outputs - they might be needed for analysis
        break;
    }
  }
  
  /// Get complete test environment summary
  static Map<String, dynamic> getEnvironmentSummary() {
    return {
      'testConfiguration': TestConfiguration.getConfigSummary(),
      'testOutputManager': TestOutputManager.getOutputSummary(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
  
  /// Validate test environment is properly configured
  static Future<bool> validateEnvironment() async {
    try {
      final testMode = TestConfiguration.getTestMode();
      
      // Check production safety
      if (testMode == TestMode.production && !TestConfiguration.isProductionSafe) {
        return false;
      }
      
      // Try to initialize test environment
      await initializeTestEnvironment();
      
      // Try to create a test database
      final db = await createDatabase();
      await db.close();
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
