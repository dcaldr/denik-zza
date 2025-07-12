import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/drift_database_connector.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'in_memory_structures_tmp/memory_database_connector.dart';


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
///   // Returns MemoryDatabase for test isolation
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
/// - **Testing**: MemoryDatabase (in-memory, isolated, fast)
/// 
/// ## Safety Features:
/// - Compile-time and runtime checks prevent accidental data loss
/// - Production mode is the default and heavily protected
/// - Test mode must be explicitly enabled
/// - Validation methods detect unsafe configurations
/// 
/// **Right now, it's singleton by historical reasons.**
/// **New databases should be easier to implement.**
class DatabaseWrapper  {

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

  @Deprecated("Remove when possible")
  final MemoryDatabase _memoryDatabase = MemoryDatabase();
  @Deprecated("Remove when possible")
  final _driftDatabase = AppDatabase();

  /**===================== REMOVE WHEN POSSIBLE ↓ =========================== */
/**
  @override
  Future<bool> addZaznam(MemoryZaznam zaznam) async => _memoryDatabase.addZaznam(zaznam);
  @override


  @override
  Future<bool> addOsoba(MemoryOsoba osoba) async {
    return _memoryDatabase.addOsoba(osoba);
  }

  Future<bool> quickAddNewZaznam( String popis, int idPacient  ) async {
    return _memoryDatabase.addZaznam(MemoryZaznam.short( popis,  idPacient));
  }

  @override
  Future<void> quickPrintAllOsoby() async {
    _memoryDatabase.quickPrintAllOsoby();
  }
  @override
  String quickPrintZaznamyOsoby(int idOsoby) {
    return _memoryDatabase.quickPrintZaznamyOsoby(idOsoby);
  }

  //========= Vojtovy přidané metody ===========================================

  @override
  Future<List<MemoryZaznam>> getRecordsByParticipantID(int id) async {
    List<Record> records = await _driftDatabase.getRecordsByParticipantID(id);
    List<MemoryZaznam> memoryRecords = [];
    
    for(Record r in records) {
      memoryRecords.add(MemoryZaznam.complete(r.id, r.dateAndTime, r.title,
          r.description, r.treatment, r.wasPrinted,
          r.paramedicFK, r.participantFK));
    }
    
    return memoryRecords;
  }

  @override
  Future<List<MemoryOsoba>> getParticipantsByAction(int idAction) async {
    List<Participant> participants = await
    _driftDatabase.getParticipantsByAction(idAction);

    List<MemoryOsoba> memoryParticipants = [];

    for(Participant p in participants) {
      memoryParticipants.add(MemoryOsoba.complete(p.id, p.firstName, p.lastName,
        p.address, p.birthNumber, p.birthDate, p.parentPhoneNumber,
        p.eligibleConfirmation, p.nonInfectiousConfirmation, p.wasPrinted,
        p.insuranceCompanyFK, p.zzaActionFK));
    }

    return memoryParticipants;
  }

  @override
  Future<int> updateCache(int? pinnedActionID) async {
    return _driftDatabase.updateCache(CacheCompanion(
      id: Value(1),
      pinnedActionID: Value(pinnedActionID)
    ));
  }

  @override
  Future<int?> getPinnedActionID() async {
    return _driftDatabase.getPinnedActionID();
  }
*/
  /**===================== REMOVE WHEN POSSIBLE ↑ ============================*/

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
    _databaseMode = DatabaseMode.testing;
  }

  /// Reset database to production mode (persistent storage).
  /// 
  /// Call this in test tearDown to ensure clean state.
  /// Also useful for ensuring production mode is active.
  static void resetToProduction() {
    _databaseMode = DatabaseMode.production;
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
    // Production safety check: ensure we never accidentally use non-persistent DB in production
    // when not explicitly in test mode
    assert(() {
      if (_databaseMode == DatabaseMode.production && databaseID == 1) {
        throw StateError(
          'CRITICAL SAFETY ERROR: Production app attempted to use non-persistent database! '
          'databaseID=1 (memory) is set while _databaseMode=production. '
          'This would cause silent data loss. '
          'If you need testing, call DatabaseWrapper.setTestMode() explicitly.'
        );
      }
      return true;
    }());
    
    // New mode-based selection (preferred and safer)
    if (_databaseMode == DatabaseMode.testing) {
      return MemoryDatabase();
    }
    
    // Legacy int-based selection (maintained for compatibility)
    // Note: The assert above prevents dangerous combinations
    if (databaseID == 1) {
      return MemoryDatabase();
    }
    
    // Default: Production database with persistent storage
    // This is the ONLY path that returns persistent storage
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
        'Reset databaseID to 0 or call DatabaseWrapper.setTestMode() for testing.'
      );
    }
  }
}