import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';

/// Manual Dependency Injection container for the app.
///
/// Centralizes service creation and configuration for:
/// - Production: `initialize()` - real database, file system
/// - Testing: `initializeForTest()` - in-memory database, no file system
/// - Dev Mode: Uses existing DevEnvironment pattern
///
/// Usage in main.dart:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await AppDependencies.initialize();
///   runApp(const MyApp());
/// }
/// ```
class AppDependencies {
  static AppDependencies? _instance;

  final DatabaseInterface database;
  final FileManager fileManager;
  final AppMode mode;

  AppDependencies._({
    required this.database,
    required this.fileManager,
    required this.mode,
  });

  /// Get the singleton instance.
  /// Throws if not initialized.
  static AppDependencies get instance {
    if (_instance == null) {
      throw StateError(
          'AppDependencies not initialized. Call initialize() or initializeForTest() first.');
    }
    return _instance!;
  }

  /// Check if dependencies are initialized.
  static bool get isInitialized => _instance != null;

  /// Initialize for production mode.
  ///
  /// Sets up real database with file persistence.
  static Future<void> initialize() async {
    if (_instance != null) return; // Already initialized

    await ModeCoordinator.setProductionMode();

    _instance = AppDependencies._(
      database: DatabaseWrapper.getDatabase(),
      fileManager: FileManager(),
      mode: AppMode.production,
    );
  }

  /// Initialize for testing mode (in-memory database).
  ///
  /// Used by flutter_test_config.dart for unit/widget tests.
  static Future<void> initializeForTest({AppDatabase? database}) async {
    ModeCoordinator.setTestingMode();

    if (database != null) {
      DatabaseWrapper.useTestDriftDatabase(database);
    }

    _instance = AppDependencies._(
      database: DatabaseWrapper.getDatabase(),
      fileManager: FileManager(isTesting: true),
      mode: AppMode.testing,
    );
  }

  /// Initialize for integration test mode (file-based isolated database).
  ///
  /// Each test gets its own isolated directory.
  static Future<void> initializeForIntegrationTest({
    required String testName,
  }) async {
    await ModeCoordinator.setIntegrationTestMode(testName: testName);

    _instance = AppDependencies._(
      database: DatabaseWrapper.getDatabase(),
      fileManager: FileManager(),
      mode: AppMode.integrationTest,
    );
  }

  /// Reset dependencies (for test isolation).
  static Future<void> reset() async {
    if (_instance != null) {
      await DatabaseWrapper.dispose();
      _instance = null;
    }
  }
}
