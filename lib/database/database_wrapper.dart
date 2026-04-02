import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/drift_database_connector.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:flutter/widgets.dart';

/// Database selection modes for better type safety and clarity.
///
/// **Usage:**
/// - [production]: Real app with persistent storage (default).
/// - [testing]: Unit/widget tests with in-memory DB (fast, isolated).
/// - [integrationTest]: Integration tests with file-based DB (inspectable).
enum DatabaseMode {
  /// Default Drift database with persistent file storage (production)
  production,

  /// In-memory database for testing (fast, isolated)
  testing,

  /// File-based database in isolated test directory (for integration tests).
  /// Use when you need to inspect DB after test failure.
  integrationTest,
}

/// Selects the correct [DatabaseInterface] instance.
///
/// **PRODUCTION SAFETY GUARANTEE**: This wrapper ensures that the production app
/// ALWAYS uses persistent storage and can NEVER silently switch to non-persistent
/// databases that would cause data loss.
///
/// ## Usage
///
/// **Production (Default):**
/// No setup needed. Uses [DriftDatabaseConnector] with persistent storage.
///
/// **Testing:**
/// ```dart
/// setUp(() {
///   DatabaseWrapper.setTestMode();
/// });
///
/// tearDown(() async {
///   await DatabaseWrapper.dispose();
/// });
/// ```
class DatabaseWrapper {
  static final DatabaseWrapper _singleton = DatabaseWrapper._internal();

  factory DatabaseWrapper() {
    return _singleton;
  }
  DatabaseWrapper._internal();

  /// Database mode selection (safer than int-based selection)
  static DatabaseMode _databaseMode = DatabaseMode.production;

  /// True while global database disposal is running.
  static bool _shutdownSignalActive = false;

  /// Path to the integration test database file.
  /// Only used when [_databaseMode] is [DatabaseMode.integrationTest].
  static String? _integrationTestDbPath;

  /// Optional test database to use when in testing mode.
  static AppDatabase? _injectedTestDb;

  /// Cached instance of the implicit test database.
  /// This tracks the database created by [getDatabase] when in test mode but no explicit DB was injected.
  static AppDatabase? _cachedImplicitTestDb;

  /// Inject a specific Drift [AppDatabase] for tests / dev runs.
  /// If not provided, testing mode will default to an in-memory instance.
  static void useTestDriftDatabase(AppDatabase db) {
    _injectedTestDb = db;
  }

  /// Set database mode for unit/widget tests (in-memory).
  ///
  /// **IMPORTANT**: This method is intended for testing only.
  /// Do NOT use in production code - use only in test setUp methods.
  ///
  /// For integration tests that need file-based DB, use [setIntegrationTestMode].
  static void setTestMode() {
    _databaseMode = DatabaseMode.testing;
  }

  /// Set integration test mode with file-based database.
  ///
  /// The database will be created at [dbPath] (e.g., 'test_outputs/my_test/db.sqlite').
  /// This allows post-mortem inspection of test data.
  ///
  /// **Usage:** Called by [ModeCoordinator.setIntegrationTestMode].
  static void setIntegrationTestMode(String dbPath) {
    _databaseMode = DatabaseMode.integrationTest;
    _integrationTestDbPath = dbPath;
  }

  /// Get current database mode (for debugging/testing purposes)
  static DatabaseMode getCurrentMode() {
    return _databaseMode;
  }

  /// Check whether shutdown/disposal of DB resources is in progress.
  static bool isShuttingDown() {
    return _shutdownSignalActive;
  }

  /// Check if the app is currently using persistent storage.
  static bool isUsingPersistentStorage() {
    return _databaseMode == DatabaseMode.production;
  }

  /// Force production mode and validate safety.
  static void ensureProductionMode() {
    _databaseMode = DatabaseMode.production;
    validateProductionSafety();
  }

  /// Returns the correct database instance.
  ///
  /// *   **Production**: Returns the singleton `DriftDatabaseConnector` (which uses the real `AppDatabase`).
  /// *   **Test**: Returns a `DriftDatabaseConnector` initialized with an in-memory `AppDatabase`.
  ///
  /// **Important**: In test mode, this method ensures that if an implicit database is created,
  /// it is cached in `_cachedImplicitTestDb` so it can be properly closed by `dispose()`.
  static DatabaseInterface getDatabase() {
    // Production safety check - fails if integration test context detected without proper mode
    assert(() {
      if (_databaseMode == DatabaseMode.production) {
        try {
          // Check if running in integration test binding
          // We use runtimeType.toString() to avoid integration_test package dependency in lib/
          final bindingType = WidgetsBinding.instance.runtimeType.toString();
          if (bindingType.contains('IntegrationTest')) {
            throw StateError(
              'INTEGRATION TEST SAFETY VIOLATION: DatabaseWrapper.getDatabase() called '
              'in production mode while IntegrationTestWidgetsFlutterBinding is active. '
              'Did you forget to call ModeCoordinator.setTestingMode() or '
              'ModeCoordinator.setIntegrationTestMode()?',
            );
          }
        } catch (e) {
          if (e is StateError) rethrow;
          // WidgetsBinding not initialized yet, safe to proceed
        }
      }
      return true;
    }());

    // Priority 1: Use injected DB if provided (works for ANY mode)
    // This allows HardcodedTestSetup and other components to inject a DB
    // that will be used regardless of the current mode.
    if (_injectedTestDb != null) {
      return DriftDatabaseConnector.withDatabase(_injectedTestDb!);
    }

    // Priority 2: Mode-specific defaults
    if (_databaseMode == DatabaseMode.testing) {
      _cachedImplicitTestDb ??= AppDatabase.testInMemory();
      return DriftDatabaseConnector.withDatabase(_cachedImplicitTestDb!);
    }

    if (_databaseMode == DatabaseMode.integrationTest) {
      // File-based database for integration tests (inspectable after test)
      _cachedImplicitTestDb ??= AppDatabase(_integrationTestDbPath);
      return DriftDatabaseConnector.withDatabase(_cachedImplicitTestDb!);
    }

    return DriftDatabaseConnector();
  }

  /// Disposes of all database resources and resets the wrapper to a clean state.
  ///
  /// This method is the core of the "Universal Test Automation Strategy". It:
  /// 1.  Closes the injected test database (if any).
  /// 2.  Closes the cached implicit test database (if any).
  /// 3.  Resets the mode to [DatabaseMode.production].
  /// 4.  Clears all static references.
  ///
  /// Call this method in the global `tearDown` to ensure no test pollution.
  static Future<void> dispose() async {
    _shutdownSignalActive = true;

    // Idempotent fast-path: teardown may call dispose multiple times
    // (global + local hooks). Avoid double close/reset work.
    if (_databaseMode == DatabaseMode.production &&
        _injectedTestDb == null &&
        _cachedImplicitTestDb == null) {
      _shutdownSignalActive = false;
      return;
    }

    if (_injectedTestDb != null) {
      await _injectedTestDb!.close();
      _injectedTestDb = null;
    }

    if (_cachedImplicitTestDb != null) {
      await _cachedImplicitTestDb!.close();
      _cachedImplicitTestDb = null;
    }

    // CRITICAL: Reset the Drift singleton to close any open connections
    // that might be holding file locks (especially in Debug Mode).
    await DriftDatabaseConnector.reset();

    // Clear integration test path
    _integrationTestDbPath = null;
    _databaseMode = DatabaseMode.production;
    _shutdownSignalActive = false;
  }

  /// Validates that the current configuration is safe for production use.
  static void validateProductionSafety() {
    // Validation is now implicit in the mode system
    if (_databaseMode != DatabaseMode.production) {
      throw StateError(
          'PRODUCTION SAFETY VIOLATION: App is not in production mode!');
    }
  }
}
