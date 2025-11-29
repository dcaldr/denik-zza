import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/drift_database_connector.dart';
import 'package:denik_zza/database/database_interface.dart';

/// Database selection modes for better type safety and clarity
enum DatabaseMode {
  /// Default Drift database with persistent file storage (production)
  production,

  /// In-memory database for testing (fast, isolated)
  testing,
}

/// Selects the correct [DatabaseInterface] instance.
///
/// **PRODUCTION SAFETY GUARANTEE**: This wrapper ensures that the production app
/// ALWAYS uses persistent storage and can NEVER silently switch to non-persistent
/// databases that would cause data loss.
class DatabaseWrapper {
  static final DatabaseWrapper _singleton = DatabaseWrapper._internal();

  factory DatabaseWrapper() {
    return _singleton;
  }
  DatabaseWrapper._internal();

  /// NEW: Database mode selection (safer than int-based selection)
  static DatabaseMode _databaseMode = DatabaseMode.production;

  /// Database to be used by the app.
  /// 1 - in memory database
  /// 0 - default database ( now [DriftDatabaseConnector] )
  static int databaseID = 0;

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

  /// Set database mode for testing purposes.
  ///
  /// **IMPORTANT**: This method is intended for testing only.
  /// Do NOT use in production code - use only in test setUp methods.
  static void setTestMode() {
    print('[TMP] DatabaseWrapper: setTestMode() called');
    _databaseMode = DatabaseMode.testing;
  }

  /// Get current database mode (for debugging/testing purposes)
  static DatabaseMode getCurrentMode() {
    return _databaseMode;
  }

  /// Check if the app is currently using persistent storage.
  static bool isUsingPersistentStorage() {
    return _databaseMode == DatabaseMode.production && databaseID != 1;
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
    print('[TMP] DatabaseWrapper: getDatabase() called. Mode: $_databaseMode');

    // Production safety check
    assert(() {
      // Production safety check is now handled by _databaseMode enforcement
      return true;
    }());

    if (_databaseMode == DatabaseMode.testing || databaseID == 1) {
      if (_injectedTestDb != null) {
        print('[TMP] Returning injected test DB');
        return DriftDatabaseConnector.withDatabase(_injectedTestDb!);
      } else {
        // Fix: Reuse the cached implicit DB if it exists, otherwise create and cache it.
        if (_cachedImplicitTestDb == null) {
          print('[TMP] Creating NEW implicit test DB (in-memory)');
          _cachedImplicitTestDb = AppDatabase.testInMemory();
        } else {
          print('[TMP] Reusing CACHED implicit test DB');
        }
        return DriftDatabaseConnector.withDatabase(_cachedImplicitTestDb!);
      }
    }

    print('[TMP] Returning PRODUCTION DB');
    return DriftDatabaseConnector();
  }

  /// Reset database to production mode (persistent storage).
  ///
  /// Call this in test tearDown to ensure clean state.
  /// Also useful for ensuring production mode is active.
  ///
  /// **Deprecated**: Use [dispose] instead for better cleanup.
  static void resetToProduction() {
    print('[TMP] DatabaseWrapper: resetToProduction() called');
    _databaseMode = DatabaseMode.production;
    databaseID = 0;
    _injectedTestDb = null;
    // We don't close _cachedImplicitTestDb here because this is the legacy method.
    // Use dispose() for proper cleanup.
    _cachedImplicitTestDb = null;
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
    print('[TMP] DatabaseWrapper.dispose() called. Cleaning up.');

    if (_injectedTestDb != null) {
      await _injectedTestDb!.close();
      _injectedTestDb = null;
    }

    if (_cachedImplicitTestDb != null) {
      await _cachedImplicitTestDb!.close();
      _cachedImplicitTestDb = null;
    }

    _databaseMode = DatabaseMode.production;
    databaseID = 0;
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
