import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Centralized coordinator for application mode switching.
///
/// Synchronizes DatabaseWrapper and FileManager to ensure they always use
/// compatible modes. Provides single point of control for switching between
/// testing, debugging, and production modes.
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

  /// Available application modes
  static AppMode get currentMode => _currentMode;
  static String? get currentTestName => _currentTestName;

  /// Switch to testing mode: in-memory database, no file operations.
  /// Fastest mode for unit and widget tests.
  static void setTestingMode() {
    _currentMode = AppMode.testing;
    _currentTestName = null;

    DatabaseWrapper.setTestMode();
    FileManager().setTestMode();

    _logger.d('ModeCoordinator: Switched to testing mode (in-memory)');
  }

  /// Switch to integration test mode: in-memory database, real file operations
  /// in isolated directory.
  ///
  /// Each test gets its own subfolder: Documents/DenikZZA/integration_test_output/<testName>/
  ///
  /// **When to use:** Integration tests that need to verify file operations
  /// (PDF generation, file uploads, etc.) while keeping data separate from production.
  static Future<void> setIntegrationTestMode({required String testName}) async {
    _currentMode = AppMode.integrationTest;
    _currentTestName = testName;

    // Use in-memory database for speed and isolation
    DatabaseWrapper.setTestMode();

    // Use real file system in isolated directory
    final integrationTestDir = await _getIntegrationTestDirectory(testName);
    FileManager().setMode(FileManagerMode.production); // Real file operations
    FileManager().homeDir = integrationTestDir; // But in test directory

    _logger.i('ModeCoordinator: Integration test mode - $testName');
    _logger.d('Integration test directory: ${integrationTestDir.path}');
  }

  /// Switch to debug mode: persistent database and file operations in test_outputs/.
  /// Useful for debugging tests with real data persistence.
  static Future<void> setDebugMode({required String testName}) async {
    _currentMode = AppMode.debug;
    _currentTestName = testName;

    await DatabaseWrapper.dispose(); // Uses file-based database
    FileManager().setPersistentTestMode('test_outputs/$testName');

    _logger.d('ModeCoordinator: Debug mode - $testName');
  }

  /// Switch to production mode: real database, real file operations.
  static Future<void> setProductionMode() async {
    _currentMode = AppMode.production;
    _currentTestName = null;

    await DatabaseWrapper.dispose();
    FileManager().resetToProduction();

    _logger.d('ModeCoordinator: Switched to production mode');
  }

  /// Reset to production mode (alias for clarity in tearDown)
  @deprecated
  static Future<void> resetToProduction() => setProductionMode();

  /// Get integration test directory for a specific test.
  /// Creates: Documents/DenikZZA/integration_test_output/<testName>/
  static Future<Directory> _getIntegrationTestDirectory(String testName) async {
    final docs = await getApplicationDocumentsDirectory();
    final integrationDir =
        Directory('${docs.path}/DenikZZA/integration_test_output/$testName');

    if (!await integrationDir.exists()) {
      await integrationDir.create(recursive: true);
      _logger.d('Created integration test directory: ${integrationDir.path}');
    }

    return integrationDir;
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

  /// Persistent database and files in test_outputs/ (for debugging)
  debug,

  /// Real database and file operations (production)
  production,
}
