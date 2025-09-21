import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:denik_zza/database/drift_database/database.dart';
import 'test_configuration.dart';
import 'test_output_manager.dart';

/// Test database type selection
enum TestDatabaseType { memory, file }

/// Global test database override - when set, all tests use this type
TestDatabaseType? _globalTestDatabaseOverride;

/// Cache for singleton database instances to avoid Drift warnings
final Map<String, AppDatabase> _databaseInstances = {};
// Reverse map to reliably resolve file path from an AppDatabase instance
final Map<AppDatabase, String> _pathByInstance = {};

/// Monotonic counter to strengthen uniqueness of file test DB filenames
int _fileDbCounter = 0;

/// Flag to track if drift warnings have been disabled for tests
bool _driftWarningsDisabled = false;

/// Database Test Helper for Drift Database Testing
/// 
/// 🎯 NEW PROGRAMMER NOTICE: Use this helper for ALL database tests!
/// 
/// Provides flexible test database creation with integration to unified testing infrastructure:
/// 1. Per-test-suite choice (memory or file)
/// 2. Global force all-memory 
/// 3. Global force all-file
/// 4. **NEW**: Integration with TestConfiguration for --dart-define based mode selection
/// 
/// 📖 Quick Start:
/// ```dart
/// setUp(() {
///   database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
/// });
/// tearDown(() async {
///   await DatabaseTestHelper.closeTestDatabase(database);
/// });
/// ```
/// 
/// 📖 Unified Infrastructure Integration:
/// ```dart
/// setUp(() async {
///   database = await DatabaseTestHelper.createUnifiedTestDatabase();
/// });
/// tearDown(() async {
///   await DatabaseTestHelper.closeUnifiedTestDatabase(database);
/// });
/// ```
/// 
/// This helper manages database instances as singletons to prevent
/// Drift's "multiple database instances" warnings.
class DatabaseTestHelper {
  
  /// Disable Drift warnings for test environments
  /// 
  /// Call this once at the beginning of your test suite to suppress
  /// Drift's multiple database instance warnings, which are expected
  /// in test environments where we create many isolated databases.
  static void disableDriftWarnings() {
    if (!_driftWarningsDisabled) {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      _driftWarningsDisabled = true;
    }
  }
  
  /// Creates a test database instance based on the specified type
  /// 
  /// This is the main function you'll use in your test setUp() methods.
  /// Automatically disables Drift warnings for test environments.
  /// 
  /// Example usage:
  /// ```dart
  /// late AppDatabase database;
  /// 
  /// setUp(() {
  ///   database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
  /// });
  /// 
  /// tearDown(() async {
  ///   await DatabaseTestHelper.closeTestDatabase(database);
  /// });
  /// ```
  static AppDatabase createTestDatabase(TestDatabaseType type) {
    // Automatically disable Drift warnings for tests
    disableDriftWarnings();
    
    // Check for global override first
    final effectiveType = _globalTestDatabaseOverride ?? type;
    
    switch (effectiveType) {
      case TestDatabaseType.memory:
        return _getOrCreateMemoryDatabase();
      case TestDatabaseType.file:
        return _createFileDatabase();
    }
  }
  
  /// Get or create a fresh memory database instance
  /// Note: For tests, we create a new instance each time to avoid connection reuse issues
  static AppDatabase _getOrCreateMemoryDatabase() {
  // Always create a new in-memory database following Drift testing guidance
  // Uses closeStreamsSynchronously to avoid pending timers in widget tests
  return AppDatabase.testInMemory();
  }
  
  /// Create a file-based test database (persistent, real SQLite file)
  /// Each test gets a unique file to ensure isolation
  static AppDatabase _createFileDatabase() {
    // Create unique test database file with human-readable date + high-entropy numeric id
    // Ensure the chosen filename doesn't already exist on disk to make tests deterministic.
    final testDbDir = Directory('./test/test_dbs').absolute;
    if (!testDbDir.existsSync()) {
      testDbDir.createSync(recursive: true);
    }

    String buildPath() {
      final now = DateTime.now();
      final formattedDate = '${now.year.toString().substring(2)}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      // Use microseconds for greater entropy and add a counter suffix to avoid same-microsecond collisions.
      final counter = (_fileDbCounter++ % 1000);
      final numericId = (now.microsecondsSinceEpoch % 100000000) * 1000 + counter; // digits only
  return p.join(testDbDir.path, 'test_${formattedDate}_testDB_$numericId.db');
    }

    // Find a non-existing path (defensive against collisions across the whole run)
    String testDbPath = buildPath();
    int attempts = 0;
    while (File(testDbPath).existsSync() && attempts < 10) {
      // Small sleep isn't possible here (sync function), so regenerate id using a bumped counter
      testDbPath = buildPath();
      attempts++;
    }

    // If we somehow generated an existing path that's already cached, regenerate as well
    while (_databaseInstances.containsKey(testDbPath) && attempts < 20) {
      testDbPath = buildPath();
      attempts++;
    }

    final database = AppDatabase(testDbPath);
    _databaseInstances[testDbPath] = database;
    _pathByInstance[database] = testDbPath;
    return database;
  }
  
  /// Set global override - forces ALL tests to use specified database type
  /// 
  /// Use this when you want to run all tests with the same database type.
  /// Useful for CI/CD or specific test scenarios.
  /// 
  /// Example:
  /// ```dart
  /// void main() {
  ///   setUpAll(() {
  ///     DatabaseTestHelper.setGlobalTestDatabaseOverride(TestDatabaseType.memory);
  ///   });
  ///   
  ///   // Now ALL test suites use memory database, regardless of their individual choice
  /// }
  /// ```
  static void setGlobalTestDatabaseOverride(TestDatabaseType? type) {
    _globalTestDatabaseOverride = type;
  }
  
  /// Clear global override - return to per-test-suite choice
  static void clearGlobalTestDatabaseOverride() {
    _globalTestDatabaseOverride = null;
  }
  
  /// Get current global override setting (for debugging/testing)
  static TestDatabaseType? getGlobalTestDatabaseOverride() {
    return _globalTestDatabaseOverride;
  }
  
  /// Close and optionally clean up a test database file
  /// 
  /// Call this in tearDown() when you're done with a database.
  /// This properly manages the singleton cache and prevents memory leaks.
  /// 
  /// Note: For memory databases, we only remove from cache but don't actually
  /// close the database if it might be reused by other tests. For file databases,
  /// we always close since each test gets its own file.
  static Future<void> closeTestDatabase(AppDatabase database, {bool cleanup = false}) async {
    // Find the key for this database instance
    String? keyToRemove;
    for (final entry in _databaseInstances.entries) {
      if (identical(entry.value, database)) {
        keyToRemove = entry.key;
        break;
      }
    }
    
    if (keyToRemove != null) {
      if (keyToRemove == 'memory') {
        // For memory database, we don't close it as it's shared across tests
        // Just clear any data instead
        try {
          // Clear all tables to reset state for next test
          await _clearDatabaseTables(database);
        } catch (e) {
          // If clearing fails, remove from cache and close
          _databaseInstances.remove(keyToRemove);
          await database.close();
        }
      } else {
  // For file databases, always close and remove from cache
  _databaseInstances.remove(keyToRemove);
  _pathByInstance.remove(database);
        await database.close();
        
        // Cleanup is optional and disabled by default to preserve test data
        if (cleanup) {
          try {
            final file = File(keyToRemove);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            // Ignore file deletion errors
          }
        }
      }
    } else {
      // If not found in cache, just close it
      _pathByInstance.remove(database);
      await database.close();
    }
  }
  
  /// Clear all data from database tables (used for memory database reset)
  static Future<void> _clearDatabaseTables(AppDatabase database) async {
    await database.transaction(() async {
      // Clear tables in reverse dependency order to avoid foreign key constraints
      await database.delete(database.records).go();
      await database.delete(database.participants).go();
      await database.delete(database.insuranceCompanies).go();
      await database.delete(database.zzaActions).go();
    });
  }
  
  /// Clear all cached database instances
  /// 
  /// Use this sparingly - typically only in test cleanup or when you need
  /// to completely reset the database state between test suites.
  static Future<void> clearAllDatabaseInstances() async {
    final databases = List.from(_databaseInstances.values);
    _databaseInstances.clear();
    _pathByInstance.clear();
    
    for (final database in databases) {
      try {
        await database.close();
      } catch (e) {
        // Ignore close errors
      }
    }
  }

  /// Get the on-disk file path for a given AppDatabase created by this helper.
  ///
  /// Returns null for memory databases or if the database wasn't created
  /// by this helper. Useful in tests to assert file existence deterministically
  /// without relying on directory diffs under parallel test execution.
  static String? getDatabaseFilePath(AppDatabase database) {
    // Fast path: direct instance->path mapping
    final direct = _pathByInstance[database];
    if (direct != null) return direct;

    // Fallback: scan the old map by identity
    for (final entry in _databaseInstances.entries) {
      if (identical(entry.value, database)) {
        final key = entry.key;
        if (key.contains(Platform.pathSeparator) && key.toLowerCase().endsWith('.db')) {
          return key;
        }
        return null;
      }
    }
    return null;
  }
  
  /// Optional: Clean up test database files with specific patterns
  /// 
  /// Use this sparingly - only when you specifically need to clean up test files.
  /// By default, test databases are preserved for debugging and analysis.
  static Future<void> cleanupTestDatabaseDirectory({String? filePattern}) async {
    final testDbDir = Directory('./test/test_dbs');
    if (!testDbDir.existsSync()) return;

    // 1) Proactively close any cached DB instances pointing into this directory to release file locks (esp. on Windows)
    final toClose = <String, AppDatabase>{};
    _databaseInstances.forEach((path, db) {
      // Skip non-file keys (like potential 'memory')
      if (!path.contains(Platform.pathSeparator)) return;
      if (!File(path).path.startsWith(testDbDir.path)) return;
      if (filePattern != null) {
        final name = path.split(Platform.pathSeparator).last;
        if (!name.contains(filePattern)) return;
      }
      toClose[path] = db;
    });
    for (final entry in toClose.entries) {
      try {
        await entry.value.close();
      } catch (_) {
        // ignore
      } finally {
        _databaseInstances.remove(entry.key);
        _pathByInstance.remove(entry.value);
      }
    }

    // Helper to delete a file with retries and also its SQLite sidecars
    Future<void> deleteWithRetries(File f) async {
      // Delete SQLite sidecar files first to avoid locks (-wal, -shm, -journal)
      final basePath = f.path;
      for (final suffix in const ['-wal', '-shm', '-journal']) {
        final sidecar = File('$basePath$suffix');
        if (await sidecar.exists()) {
          try { await sidecar.delete(); } catch (_) {}
        }
      }

      const maxAttempts = 8;
      const delayMs = 150;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        try {
          if (await f.exists()) {
            await f.delete();
          }
          // Verify gone
          if (!await f.exists()) {
            return;
          }
        } catch (_) {
          // swallow and retry
        }
        await Future.delayed(const Duration(milliseconds: delayMs));
      }
    }

    // 2) Delete matching files (with retries)
    try {
      final files = testDbDir.listSync().whereType<File>();
      for (final file in files) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        if (filePattern != null && !fileName.contains(filePattern)) {
          continue;
        }
        await deleteWithRetries(file);
      }
    } catch (_) {
      // Ignore directory access errors
    }
  }

  /// Targeted cleanup: Delete only the specific database files provided.
  ///
  /// This avoids cross-test interference when tests run in parallel by cleaning
  /// up exactly the files a test created instead of globbing a whole directory.
  static Future<void> cleanupSpecificTestFiles(List<String> absolutePaths) async {
    // Close any cached instances first to release file locks
    final toClose = <String, AppDatabase>{};
    for (final path in absolutePaths) {
      final db = _databaseInstances[path];
      if (db != null) toClose[path] = db;
    }
    for (final entry in toClose.entries) {
      try { await entry.value.close(); } catch (_) {} finally { _databaseInstances.remove(entry.key); _pathByInstance.remove(entry.value); }
    }

    // Local helper to delete a file with retries and sidecars
    Future<void> deleteWithRetries(File f) async {
      final basePath = f.path;
      for (final suffix in const ['-wal', '-shm', '-journal']) {
        final sidecar = File('$basePath$suffix');
        if (await sidecar.exists()) {
          try { await sidecar.delete(); } catch (_) {}
        }
      }

      const maxAttempts = 8;
      const delayMs = 150;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        try {
          if (await f.exists()) {
            await f.delete();
          }
          if (!await f.exists()) {
            return;
          }
        } catch (_) {
          // swallow and retry
        }
        await Future.delayed(const Duration(milliseconds: delayMs));
      }
    }

    // Delete provided files
    for (final path in absolutePaths) {
      try {
        final file = File(path);
        await deleteWithRetries(file);
      } catch (_) {
        // ignore individual file deletion issues
      }
    }
  }
  
  /// Get the path to the test databases directory
  static String getTestDatabaseDirectory() {
    return './test/test_dbs';
  }
  
  /// Quick setup helper for memory database tests
  /// 
  /// Use this as a shortcut when you know you want memory database.
  /// Returns the singleton memory database instance.
  static AppDatabase createMemoryTestDatabase() {
    return createTestDatabase(TestDatabaseType.memory);
  }
  
  /// Quick setup helper for file database tests
  /// 
  /// Use this as a shortcut when you know you want file database
  static AppDatabase createFileTestDatabase() {
    return createTestDatabase(TestDatabaseType.file);
  }

  // UNIFIED TESTING INFRASTRUCTURE INTEGRATION
  
  /// Create test database using TestConfiguration mode
  /// 
  /// This method integrates with the unified testing infrastructure and
  /// automatically selects the database type based on TestConfiguration mode:
  /// - inMemory mode: Uses in-memory database
  /// - persist mode: Uses file database in test/test_outputs directory
  /// - production mode: Throws error (should not be used in tests)
  /// 
  /// Usage with --dart-define:
  /// - flutter test (default inMemory)
  /// - flutter test --dart-define=TEST_MODE=persist
  /// 
  /// Example:
  /// ```dart
  /// setUp(() async {
  ///   database = await DatabaseTestHelper.createUnifiedTestDatabase();
  /// });
  /// tearDown(() async {
  ///   await DatabaseTestHelper.closeUnifiedTestDatabase(database);
  /// });
  /// ```
  static Future<AppDatabase> createUnifiedTestDatabase() async {
    // Automatically disable Drift warnings for tests
    disableDriftWarnings();
    
    final testMode = TestConfiguration.getTestMode();
    
    switch (testMode) {
      case TestMode.inMemory:
        return _getOrCreateMemoryDatabase();
        
      case TestMode.persist:
        // Initialize TestOutputManager for persistent testing
        await TestOutputManager.initialize();
        return _createPersistentTestDatabase();
        
      case TestMode.production:
        throw StateError(
          'Cannot create test database in production mode. '
          'Use --dart-define=TEST_MODE=inMemory or --dart-define=TEST_MODE=persist'
        );
    }
  }
  
  /// Create a persistent test database in test/test_outputs directory
  static Future<AppDatabase> _createPersistentTestDatabase() async {
    // Get database path from TestOutputManager (per-run by default)
    final dbPath = await TestOutputManager.getDatabasePath('test_database.db', useRunDir: true);
    
    // Check if we already have this instance cached
    if (_databaseInstances.containsKey(dbPath)) {
      return _databaseInstances[dbPath]!;
    }
    
    final database = AppDatabase(dbPath);
    _databaseInstances[dbPath] = database;
    return database;
  }
  
  /// Close test database created with createUnifiedTestDatabase
  /// 
  /// Handles cleanup based on the current TestConfiguration mode.
  /// - inMemory: Clears data but keeps database alive
  /// - persist: Keeps database file for debugging (controlled by TestOutputManager)
  /// - production: Not applicable (would throw in createUnifiedTestDatabase)
  static Future<void> closeUnifiedTestDatabase(AppDatabase database) async {
    final testMode = TestConfiguration.getTestMode();
    
    switch (testMode) {
      case TestMode.inMemory:
        // Use existing memory database cleanup logic
        await closeTestDatabase(database, cleanup: false);
        break;
        
      case TestMode.persist:
        // For persistent testing, don't cleanup files (keep for debugging)
        // Just close the database connection
        String? keyToRemove;
        for (final entry in _databaseInstances.entries) {
          if (identical(entry.value, database)) {
            keyToRemove = entry.key;
            break;
          }
        }
        
        if (keyToRemove != null) {
          _databaseInstances.remove(keyToRemove);
        }
        await database.close();
        break;
        
      case TestMode.production:
        // This should never happen as createUnifiedTestDatabase would throw
        throw StateError('closeUnifiedTestDatabase called in production mode');
    }
  }
  
  /// Get configuration summary for debugging unified test setup
  static Map<String, dynamic> getUnifiedTestingSummary() {
    return {
      'testConfiguration': TestConfiguration.getConfigSummary(),
      'testOutputManager': TestOutputManager.getOutputSummary(),
      'databaseInstances': _databaseInstances.keys.toList(),
      'globalOverride': _globalTestDatabaseOverride?.toString(),
      'driftWarningsDisabled': _driftWarningsDisabled,
    };
  }
}

/// Utility functions for common test scenarios
class TestDatabaseUtils {
  
  /// Create sample insurance company for testing
  static InsuranceCompaniesCompanion createSampleInsuranceCompany({
    String name = 'Test Insurance Company',
  }) {
    return InsuranceCompaniesCompanion.insert(name: name);
  }
  
  /// Create sample participant for testing
  static ParticipantsCompanion createSampleParticipant({
    String firstName = 'Test',
    String lastName = 'Person', 
    int? zzaActionFK,
    int? insuranceCompanyFK,
  }) {
    return ParticipantsCompanion.insert(
      firstName: firstName,
      lastName: lastName,
      zzaActionFK: zzaActionFK ?? 1, // Default to action ID 1 if not specified
      insuranceCompanyFK: insuranceCompanyFK != null ? Value(insuranceCompanyFK) : const Value.absent(),
    );
  }
  
  /// Create sample action for testing
  static ZzaActionsCompanion createSampleAction({
    String actionTitle = 'Test Action',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    final now = DateTime.now();
    return ZzaActionsCompanion.insert(
      actionTitle: actionTitle,
      dateFrom: dateFrom ?? now,
      dateTo: dateTo ?? now.add(const Duration(days: 7)),
    );
  }
  
  /// Create sample record for testing
  static RecordsCompanion createSampleRecord({
    String title = 'Test Record',
    String description = 'Test Description',
    required int participantFK,
    required int paramedicFK,
    DateTime? dateAndTime,
  }) {
    return RecordsCompanion.insert(
      title: title,
      description: description,
      participantFK: participantFK,
      paramedicFK: paramedicFK,
      dateAndTime: dateAndTime ?? DateTime.now(),
    );
  }
}
