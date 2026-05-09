import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/services/system/system_interface.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'dart:io';

/// Centralized coordinator for application mode switching.
///
/// Synchronizes DatabaseWrapper, FileManager, and SystemInterface to ensure
/// they always use compatible modes. Provides single point of control for
/// switching between testing, debugging, and production modes.
///
/// ## Usage Examples:
///
/// **Unit/Widget Tests (in-memory, fast):**
/// ```dart
/// setUp(() {
///   ModeCoordinator.setTestingMode();
/// });
///
/// tearDown(() async {
///   await ModeCoordinator.setProductionMode();
/// });
/// ```
///
/// **Integration Tests (with real file operations):**
/// ```dart
/// setUp(() async {
///   await ModeCoordinator.setIntegrationTestMode(testName: 'user_flow_test');
/// });
///
/// tearDown(() async {
///   await ModeCoordinator.setProductionMode();
/// });
/// ```
///
/// **Debug Mode (persist test outputs):**
/// ```dart
/// setUp(() async {
///   await ModeCoordinator.setDebugMode(testName: 'debug_session');
/// });
/// ```
class ModeCoordinator {
  static final Logger _logger = AppLogger.l;
  static AppMode _currentMode = AppMode.production;
  static String? _currentTestName;
  static String? _currentRunId;
  static Directory? _currentTestDirectory;

  /// Available application modes
  static AppMode get currentMode => _currentMode;
  static String? get currentTestName => _currentTestName;
  static Directory? get currentTestDirectory => _currentTestDirectory;

  /// Get or generate the current run ID.
  /// Generated once per process (Dart VM session) on first access.
  /// Format: yyMMdd_HHmmss (e.g., 241221_220800)
  static String get currentRunId {
    _currentRunId ??= DateFormat('yyMMdd_HHmmss').format(DateTime.now());
    return _currentRunId!;
  }

  /// Initialize run ID from flutter_test_config.dart.
  /// Call this ONCE at the start of a test suite to ensure all tests share
  /// the same run ID. If not called, [currentRunId] auto-generates on first access.
  static void initializeRunId(String runId) {
    _currentRunId = runId;
  }

  /// Switch to testing mode: in-memory database, no file operations, MOCKED SystemInterface.
  /// Fastest mode for unit and widget tests.
  static void setTestingMode() {
    _currentMode = AppMode.testing;
    _currentTestName = null;
    _currentTestDirectory = null;

    DatabaseWrapper.setTestMode();
    FileManager().setTestMode();
    SystemInterface.registerWith(TestSystemInterface());

    _logger.d(
        'ModeCoordinator: Switched to testing mode (in-memory, mock system)');
  }

  /// Switch to integration test mode: **FILE-BASED database**, real file operations
  /// in isolated directory, MOCKED SystemInterface (no OS dialogs).
  ///
  /// This is the **default mode for integration tests**. Uses a persistent SQLite database
  /// file that can be inspected after test runs for debugging.
  ///
  /// Folder structure: Documents/DenikZZA/test_outputs/integration/run_{runId}/{testName}/
  /// Database file: {testDir}/db.sqlite
  ///
  /// **When to use:** Most integration tests. The file-based DB allows inspection of
  /// test data after a run completes or fails, making debugging easier.
  ///
  /// **For in-memory (faster) tests:** Use [setTestingMode] instead.
  static Future<void> setIntegrationTestMode({required String testName}) async {
    _currentMode = AppMode.integrationTest;
    _currentTestName = testName;

    // Dispose any existing database first
    await DatabaseWrapper.dispose();

    // Get isolated test directory
    final testDir =
      await _getTestDirectory('integration', currentRunId, testName);
    _currentTestDirectory = testDir;

    // Set file-based database for inspection and debugging
    final dbPath = path.join(testDir.path, 'db.sqlite');
    DatabaseWrapper.setIntegrationTestMode(dbPath);

    // Use real file system in isolated per-test directory
    FileManager().setPersistentTestMode(testDir.path);

    // Use Mock System Interface (No OS Dialogs)
    SystemInterface.registerWith(TestSystemInterface());

    _logger
        .i('ModeCoordinator: Integration test mode - $currentRunId/$testName');
    _logger.d('DB path: $dbPath');
  }



  /// Switch to production mode: real database, real file operations, REAL system interface.
  static Future<void> setProductionMode() async {
    _currentMode = AppMode.production;
    _currentTestName = null;
    _currentRunId = null;
    _currentTestDirectory = null;

    await DatabaseWrapper.dispose();
    FileManager().setProductionMode();
    SystemInterface.registerWith(RealSystemInterface());

    _logger.d('ModeCoordinator: Switched to production mode');
  }

  /// Get test directory for a specific test.
  /// Creates: Documents/DenikZZA/test_outputs/{category}/run_{runId}/{testName}/
  static Future<Directory> _getTestDirectory(
    String category,
    String runId,
    String testName,
  ) async {
    final docs = await getApplicationDocumentsDirectory();
    final testDir = Directory(
      path.join(docs.path, 'DenikZZA', 'test_outputs', category, 'run_$runId', testName),
    );

    if (!await testDir.exists()) {
      await testDir.create(recursive: true);
      _logger.d('Created test directory: ${testDir.path}');
    }

    return testDir;
  }

  /// Clean up integration test outputs (optional, for CI/CD cleanup)
  static Future<void> cleanupIntegrationTestOutputs() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
        final integrationDir =
          Directory(path.join(docs.path, 'DenikZZA', 'integration_test_output'));

      if (await integrationDir.exists()) {
        await integrationDir.delete(recursive: true);
        _logger.i('Cleaned up integration test outputs');
      }
    } catch (e) {
      _logger.w('Failed to cleanup integration test outputs: $e');
    }
  }

  /// Clean up old test runs, keeping the most recent N.
  ///
  /// Deletes run folders from 'integration/'.
  static Future<void> cleanupOldRuns({int keepLast = 5}) async {
    try {
      final docs = await getApplicationDocumentsDirectory();

      for (final category in ['integration']) {
        final categoryDir = Directory(
          path.join(docs.path, 'DenikZZA', 'test_outputs', category),
        );

        if (!await categoryDir.exists()) continue;

        final runs = <Directory>[];
        await for (final entity in categoryDir.list()) {
          if (entity is Directory && entity.path.contains('run_')) {
            runs.add(entity);
          }
        }

        // Sort by name (timestamp in name = chronological order)
        runs.sort((a, b) => b.path.compareTo(a.path)); // Newest first

        // Delete oldest runs beyond keepLast
        for (var i = keepLast; i < runs.length; i++) {
          await runs[i].delete(recursive: true);
          _logger.d('Cleaned up old test run: ${runs[i].path}');
        }
      }

      _logger.i('Cleanup complete (kept last $keepLast runs per category)');
    } catch (e) {
      _logger.w('Cleanup failed: $e');
    }
  }

  /// Get summary of current mode configuration (for debugging)
  static Map<String, dynamic> getModeSummary() {
    return {
      'currentMode': _currentMode.name,
      'testName': _currentTestName ?? 'none',
      'databaseMode': DatabaseWrapper.getCurrentMode().name,
      'fileManagerMode': FileManager().currentMode.name,
    };
  }
}

/// Application modes for centralized control
enum AppMode {
  /// In-memory database, no file operations (fastest, for unit/widget tests)
  testing,

  /// In-memory database, real file operations in isolated directory
  /// (for integration tests that need to verify file operations)
  integrationTest,

  /// Real database and file operations (production)
  production,
}
