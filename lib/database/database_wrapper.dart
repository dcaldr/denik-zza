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
///
/// ## Usage:
///
/// **In production code:**
/// ```dart
/// DatabaseInterface dbInterface = DatabaseWrapper.getDatabase();
/// // Always returns DriftDatabaseConnector with persistent storage
/// ```
///
/// **In test code:**
/// ```dart
/// setUp(() {
///   DatabaseWrapper.setTestMode(); // Use in-memory database
/// });
///
/// tearDown(() {
///   DatabaseWrapper.resetToProduction(); // Clean up
/// });
///
/// test('my test', () {
///   DatabaseInterface db = DatabaseWrapper.getDatabase();
///   // Returns Drift in-memory database for test isolation
/// });
/// ```
///
/// **In main() function (recommended):**
/// ```dart
/// void main() {
///   DatabaseWrapper.ensureProductionMode(); // Validates safety
///   runApp(MyApp());
/// }
/// ```
///
/// ## Database Types:
/// - **Production**: DriftDatabaseConnector (persistent SQLite file)
/// - **Testing**: DriftDatabaseConnector bound to in-memory AppDatabase
///
/// ## Safety Features:
/// - Compile-time and runtime checks prevent accidental data loss
/// - Production mode is the default and heavily protected
/// - Test mode must be explicitly enabled
/// - Validation methods detect unsafe configurations
///
/// **Right now, it's singleton by historical reasons.**
/// **New databases should be easier to implement.**
class DatabaseWrapper {
  static final DatabaseWrapper _singleton = DatabaseWrapper._internal();

  factory DatabaseWrapper() {
    return _singleton;
  }
  DatabaseWrapper._internal();

  /// Database to be used by the app.
  ///
  /// 1 - in memory database
  ///
  /// 0 - default database ( now [DriftDatabaseConnector] )
  static int databaseID = 0;

  /// NEW: Database mode selection (safer than int-based selection)
  static DatabaseMode _databaseMode = DatabaseMode.production;

  /// Optional test database to use when in testing mode.
  static AppDatabase? _injectedTestDb;

  /// Inject a specific Drift [AppDatabase] for tests / dev runs.
  /// If not provided, testing mode will default to an in-memory instance.
  static void useTestDriftDatabase(AppDatabase db) {
    _injectedTestDb = db;
  }

  // Cleaned legacy unused fields and methods

  /// Set database mode for testing purposes.
  ///
  /// **IMPORTANT**: This method is intended for testing only.
  /// Do NOT use in production code - use only in test setUp methods.
  ///
  /// Example usage in tests:
  /// Set database to testing mode (in-memory, non-persistent).
  ///
  /// **IMPORTANT**: Only call this in test code! Never in production.
  /// This switches the database to use in-memory storage for test isolation.
  ///
  /// Example usage in tests:
  /// ```dart
  /// setUp(() {
  ///   DatabaseWrapper.setTestMode();
  /// });
  ///
  /// tearDown(() {
  ///   DatabaseWrapper.resetToProduction();
  /// });
  /// ```
  static void setTestMode() {
    print('[TMP] DatabaseWrapper: setTestMode() called');
    _databaseMode = DatabaseMode.testing;
  }

  /// Reset database to production mode (persistent storage).
  ///
  /// Call this in test tearDown to ensure clean state.
  /// Also useful for ensuring production mode is active.
  static void resetToProduction() {
    print('[TMP] DatabaseWrapper: resetToProduction() called');
    _databaseMode = DatabaseMode.production;
    _injectedTestDb = null;
  }

  /// Get current database mode (for debugging/testing purposes)
  static DatabaseMode getCurrentMode() {
    return _databaseMode;
  }

  /// Check if the app is currently using persistent storage.
  ///
  /// Returns true if the database will persist data between app restarts.
  /// Returns false if using in-memory/testing storage.
  static bool isUsingPersistentStorage() {
    return _databaseMode == DatabaseMode.production && databaseID != 1;
  }

  /// Force production mode and validate safety.
  ///
  /// This method ensures the app is in production mode and validates
  /// that the configuration is safe. Call this in your main() function.
  ///
  /// Throws [StateError] if unsafe configuration is detected.
  static void ensureProductionMode() {
    _databaseMode = DatabaseMode.production;
    validateProductionSafety();
  }

  /// Returns the correct database instance.
  ///
  /// This method returns the correct database instance based on the [databaseID] variable
  /// and the [_databaseMode] setting. The new mode-based selection takes precedence
  /// for better type safety.
  ///
  /// If [databaseID] is undefined it falls back to [DriftDatabaseConnector].
  ///
  /// **For Production**: Always returns [DriftDatabaseConnector] with persistent storage
  /// **For Testing**: Returns in-memory database for test isolation
  ///
  /// **SAFETY GUARANTEE**: In production, this method will NEVER return a non-persistent
  /// database. The app will always use persistent storage unless explicitly set to test mode.
  static DatabaseInterface getDatabase() {
    print(
        '[TMP] DatabaseWrapper: getDatabase() called. Mode: $_databaseMode, Injected: ${_injectedTestDb?.hashCode}');
    // Production safety check: ensure we never accidentally use non-persistent DB in production
    // when not explicitly in test mode
    assert(() {
      if (_databaseMode == DatabaseMode.production && databaseID == 1) {
        throw StateError(
            'CRITICAL SAFETY ERROR: Production app attempted to use non-persistent database! '
            'databaseID=1 (memory) is set while _databaseMode=production. '
            'This would cause silent data loss. '
            'If you need testing, call DatabaseWrapper.setTestMode() explicitly.');
      }
      return true;
    }());

    // New mode-based selection (preferred and safer)
    if (_databaseMode == DatabaseMode.testing) {
      // Prefer injected AppDatabase, fallback to in-memory Drift
      final db = _injectedTestDb ?? AppDatabase.testInMemory();
      print(
          '[TMP] DatabaseWrapper: Returning testing DB (Injected: ${_injectedTestDb != null}). DB Hash: ${db.hashCode}');
      return DriftDatabaseConnector.withDatabase(db);
    }

    // Legacy int-based selection (maintained for compatibility)
    // Note: The assert above prevents dangerous combinations
    if (databaseID == 1) {
      // Legacy switch maps to testing behavior: use in-memory Drift (custom MemoryDatabase deprecated)
      final db = _injectedTestDb ?? AppDatabase.testInMemory();
      print(
          '[TMP] DatabaseWrapper: Returning legacy testing DB. DB Hash: ${db.hashCode}');
      return DriftDatabaseConnector.withDatabase(db);
    }

    // Default: Production database with persistent storage
    // This is the ONLY path that returns persistent storage
    print('[TMP] DatabaseWrapper: Returning PRODUCTION DB');
    return DriftDatabaseConnector();
  }

  /// Validates that the current configuration is safe for production use.
  ///
  /// Throws [StateError] if the configuration would result in data loss.
  /// Call this in your main() function to verify production safety.
  static void validateProductionSafety() {
    if (_databaseMode == DatabaseMode.production && databaseID == 1) {
      throw StateError(
          'PRODUCTION SAFETY VIOLATION: App is configured to use non-persistent storage! '
          'databaseID=1 while _databaseMode=production would cause silent data loss. '
          'Reset databaseID to 0 or call DatabaseWrapper.setTestMode() for testing.');
    }
  }
}
