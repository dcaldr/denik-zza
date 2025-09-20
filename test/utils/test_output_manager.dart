import 'dart:io';
import 'package:path/path.dart' as path;
import 'test_configuration.dart';

/// Manages test output directories and file paths for different testing modes
/// TestOutputManager
///
/// Purpose:
/// - Centralizes creation and management of test output directories for different
///   testing modes (inMemory, persist, production).
/// - Provides stable, predictable locations for artifacts (e.g., SQLite files) so
///   developers can inspect results after a test run.
///
/// IMPORTANT (Persistence Policy):
/// - Do NOT auto-clean persist outputs after each test. The entire point of
///   persist mode is to preserve artifacts (database files, logs) across tests
///   within a run for debugging and post-run inspection.
/// - The cleanup() helpers provided here are intended for:
///   1) CI environments before or after a full test run, and
///   2) Occasional manual maintenance.
/// - Avoid calling cleanup() or cleanupPersist() in per-test tearDown().
///   Doing so defeats the purpose of persist mode.
///
/// Concurrency note:
/// - This manager only creates directories on demand. It does not toggle any
///   global app state. It is safe to use in concurrent tests as long as the
///   same directory paths aren’t deleted mid-run.
class TestOutputManager {
  static const String _testOutputsDir = 'test_outputs';
  static const String _persistDir = 'persist';
  static const String _productionDir = 'production';
  static String? _persistRunId;
  static String? _productionRunId;
  
  /// Initialize test output directories based on current test mode.
  ///
  /// inMemory: no directories are created.
  /// persist: ensures `test_outputs/persist` exists (but does not clean it).
  /// production: ensures `test_outputs/production` exists if `isProductionSafe`.
  static Future<void> initialize() async {
    final testMode = TestConfiguration.getTestMode();
    
    switch (testMode) {
      case TestMode.inMemory:
        // No directory initialization needed for in-memory mode
        break;
      case TestMode.persist:
        await _ensureDirectoryExists(_getPersistDir());
        break;
      case TestMode.production:
        if (TestConfiguration.isProductionSafe) {
          await _ensureDirectoryExists(_getProductionDir());
        } else {
          throw Exception('Production testing requires CONFIRM_PRODUCTION_TESTING=yes');
        }
        break;
    }
  }
  
  /// Get the base test outputs directory path (absolute).
  static String getTestOutputsDir() {
    return path.absolute(_testOutputsDir);
  }
  
  /// Get base directory for persist mode (absolute path).
  static String _getPersistDir() {
    return path.join(getTestOutputsDir(), _persistDir);
  }

  /// Generate a run id: test_YYYYMMDD_HHMMSS_rand5
  static String _generateRunId() {
    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final time = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final rand = (now.microsecondsSinceEpoch % 100000).toString().padLeft(5, '0');
    return 'test_${date}_${time}_$rand';
  }

  /// Get or create a per-run directory for persist mode.
  ///
  /// WARNING: Do not delete this directory in per-test tearDown. Persist mode
  /// is designed to preserve artifacts for the entire run.
  static Future<String> getOrCreatePersistRunDirectory() async {
    _persistRunId ??= _generateRunId();
    final dir = path.join(_getPersistDir(), _persistRunId!);
    await _ensureDirectoryExists(dir);
    return dir;
  }
  
  /// Get base directory for production mode (absolute path).
  static String _getProductionDir() {
    return path.join(getTestOutputsDir(), _productionDir);
  }

  /// Get or create a per-run directory for production mode (guarded elsewhere).
  static Future<String> getOrCreateProductionRunDirectory() async {
    _productionRunId ??= _generateRunId();
    final dir = path.join(_getProductionDir(), _productionRunId!);
    await _ensureDirectoryExists(dir);
    return dir;
  }
  
  /// Get database file path for current test mode.
  ///
  /// - inMemory: returns an empty string (no file path).
  /// - persist: returns `<test_outputs>/persist/<filename>`.
  /// - production: returns `<test_outputs>/production/<filename>`.
  ///
  /// Consumers like UnifiedTestSetup can pass the returned path to
  /// AppDatabase(). Paths ending with `.db` are treated as file paths by
  /// AppDatabase; directory paths will have `db.sqlite` appended internally.
  ///
  /// Optional: Set [useRunDir] to true to place the DB file under a per-run
  /// directory (e.g., `test_outputs/persist/test_YYYY.../<filename>`).
  static Future<String> getDatabasePath(String filename, {bool useRunDir = false}) async {
    final testMode = TestConfiguration.getTestMode();
    
    switch (testMode) {
      case TestMode.inMemory:
        // Return empty string for in-memory databases
        return '';
      case TestMode.persist:
        if (useRunDir) {
          final runDir = await getOrCreatePersistRunDirectory();
          return path.join(runDir, filename);
        }
        return path.join(_getPersistDir(), filename);
      case TestMode.production:
        if (useRunDir) {
          final runDir = await getOrCreateProductionRunDirectory();
          return path.join(runDir, filename);
        }
        return path.join(_getProductionDir(), filename);
    }
  }
  
  /// Clean up test outputs (use judiciously).
  ///
  /// WARNING: Do NOT call this from per-test tearDown. This is intended for
  /// full-run cleanup in CI or occasional manual resets. Persist mode is meant
  /// to keep artifacts for inspection.
  static Future<void> cleanup() async {
    final testOutputsDir = Directory(getTestOutputsDir());
    if (await testOutputsDir.exists()) {
      await testOutputsDir.delete(recursive: true);
    }
  }
  
  /// Clean up only persist mode outputs (use sparingly).
  ///
  /// WARNING: Avoid calling from per-test tearDown. Intended for CI or manual
  /// maintenance when you explicitly want to remove persisted artifacts.
  static Future<void> cleanupPersist() async {
    final persistDir = Directory(_getPersistDir());
    if (await persistDir.exists()) {
      await persistDir.delete(recursive: true);
    }
    _persistRunId = null; // reset for next run if desired
  }
  
  /// Clean up only production mode outputs (guarded by production checks elsewhere).
  static Future<void> cleanupProduction() async {
    final productionDir = Directory(_getProductionDir());
    if (await productionDir.exists()) {
      await productionDir.delete(recursive: true);
    }
    _productionRunId = null;
  }
  
  /// Get output summary for debugging (paths and basic existence flags).
  static Map<String, dynamic> getOutputSummary() {
    return {
      'testOutputsDir': getTestOutputsDir(),
      'persistDir': _getPersistDir(),
      'productionDir': _getProductionDir(),
      'currentMode': TestConfiguration.modeString,
      'outputsExist': Directory(getTestOutputsDir()).existsSync(),
    };
  }
  
  /// Ensure directory exists, create if needed.
  ///
  /// This helper is idempotent and safe to call concurrently. It never deletes
  /// existing content and only creates missing folders.
  static Future<void> _ensureDirectoryExists(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }
}
