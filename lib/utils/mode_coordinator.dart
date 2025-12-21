import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/services/system/system_interface.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:path_provider/path_provider.dart';
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

  /// Available application modes
  static AppMode get currentMode => _currentMode;
  static String? get currentTestName => _currentTestName;
  static String? get currentRunId => _currentRunId;

  /// Switch to testing mode: in-memory database, no file operations, MOCKED SystemInterface.
  /// Fastest mode for unit and widget tests.
  static void setTestingMode() {
    _currentMode = AppMode.testing;
    _currentTestName = null;

    DatabaseWrapper.setTestMode();
    FileManager().setTestMode();
    SystemInterface.registerWith(TestSystemInterface());

    _logger.d(
        'ModeCoordinator: Switched to testing mode (in-memory, mock system)');
  }

  /// Switch to integration test mode: in-memory database, real file operations
  /// in isolated directory, MOCKED SystemInterface (no OS dialogs).
  ///
  /// Folder structure: Documents/DenikZZA/test_outputs/integration/run_{runId}/{testName}/
  ///
  /// **When to use:** Integration tests that need to verify file operations
  /// (PDF generation, file uploads, etc.) while keeping data separate from production.
  static Future<void> setIntegrationTestMode({
    required String runId,
    required String testName,
  }) async {
    _currentMode = AppMode.integrationTest;
    _currentTestName = testName;
    _currentRunId = runId;

    // Use in-memory database for speed and isolation
    DatabaseWrapper.setTestMode();

    // Use real file system in isolated per-test directory
    final testDir = await _getTestDirectory('integration', runId, testName);
    FileManager().setMode(FileManagerMode.production); // Real file operations
    FileManager().homeDir = testDir; // But in test directory

    // Use Mock System Interface (No OS Dialogs)
    SystemInterface.registerWith(TestSystemInterface());

    _logger.i('ModeCoordinator: Integration test mode - $runId/$testName');
    _logger.d('Integration test directory: ${testDir.path}');
  }

  /// Canary test mode: File-based DB for inspection + mocked OS dialogs.
  ///
  /// Use for critical path tests that need persistent DB for debugging.
  /// Folder: Documents/DenikZZA/test_outputs/canary/run_{runId}/{testName}/
  static Future<void> setCanaryTestMode({
    required String runId,
    required String testName,
  }) async {
    _currentMode = AppMode.canary;
    _currentTestName = testName;
    _currentRunId = runId;

    // Use file-based database (like debug mode)
    await DatabaseWrapper.dispose();

    final testDir = await _getTestDirectory('canary', runId, testName);
    FileManager().setPersistentTestMode(testDir.path);

    // Mock OS dialogs (unlike debug mode)
    SystemInterface.registerWith(TestSystemInterface());

    _logger.i('ModeCoordinator: Canary test mode - $runId/$testName');
    _logger.d('Canary test directory: ${testDir.path}');
  }

  /// Switch to debug mode: persistent database and file operations in test_outputs/.
  /// Useful for debugging tests with real data persistence.
  static Future<void> setDebugMode({required String testName}) async {
    _currentMode = AppMode.debug;
    _currentTestName = testName;

    await DatabaseWrapper.dispose(); // Uses file-based database
    // Use unique path per run to avoid Windows file locking issues
    // on previous run's database file.
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    FileManager().setPersistentTestMode('test_outputs/${testName}_$timestamp');

    // Debug Mode uses REAL system interfaces (unless we want to test mocks explicitly)
    // For now, keep it real to debug interactions.
    SystemInterface.registerWith(RealSystemInterface());

    _logger.d('ModeCoordinator: Debug mode - $testName');
  }

  /// Switch to production mode: real database, real file operations, REAL system interface.
  static Future<void> setProductionMode() async {
    _currentMode = AppMode.production;
    _currentTestName = null;
    _currentRunId = null;

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
      '${docs.path}/DenikZZA/test_outputs/$category/run_$runId/$testName',
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
          Directory('${docs.path}/DenikZZA/integration_test_output');

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
  /// Deletes run folders from both 'integration/' and 'canary/'.
  static Future<void> cleanupOldRuns({int keepLast = 5}) async {
    try {
      final docs = await getApplicationDocumentsDirectory();

      for (final category in ['integration', 'canary']) {
        final categoryDir = Directory(
          '${docs.path}/DenikZZA/test_outputs/$category',
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
      'fileManagerMode': FileManager().isTesting ? 'testing' : 'production',
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

  /// File-based database + mocked OS dialogs (for canary/critical path tests)
  canary,

  /// Persistent database and files in test_outputs/ (for debugging)
  debug,

  /// Real database and file operations (production)
  production,
}
