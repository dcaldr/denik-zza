import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import '../../lib/database/drift_database/database.dart';

/// Test database type selection
enum TestDatabaseType { memory, file }

/// Global test database override - when set, all tests use this type
TestDatabaseType? _globalTestDatabaseOverride;

/// Cache for singleton database instances to avoid Drift warnings
final Map<String, AppDatabase> _databaseInstances = {};

/// Flag to track if drift warnings have been disabled for tests
bool _driftWarningsDisabled = false;

/// Database Test Helper for Drift Database Testing
/// 
/// 🎯 NEW PROGRAMMER NOTICE: Use this helper for ALL database tests!
/// 
/// Provides flexible test database creation with three modes:
/// 1. Per-test-suite choice (memory or file)
/// 2. Global force all-memory 
/// 3. Global force all-file
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
    // Always create a new memory database for tests to avoid connection reuse
    return AppDatabase(':memory:');
  }
  
  /// Create a file-based test database (persistent, real SQLite file)
  /// Each test gets a unique file to ensure isolation
  static AppDatabase _createFileDatabase() {
    // Create unique test database file with human-readable timestamp + counter
    final timestamp = DateTime.now();
    final formattedDate = '${timestamp.year.toString().substring(2)}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
    final uniqueId = timestamp.millisecondsSinceEpoch % 100000; // Anti-collision number
    
    // Create test database in dedicated directory
    final testDbDir = Directory('./test/test_dbs');
    if (!testDbDir.existsSync()) {
      testDbDir.createSync(recursive: true);
    }
    
    final testDbPath = '${testDbDir.path}/test_${formattedDate}_testDB_$uniqueId.db';
    
    // Check if we already have this instance cached
    if (_databaseInstances.containsKey(testDbPath)) {
      return _databaseInstances[testDbPath]!;
    }
    
    final database = AppDatabase(testDbPath);
    _databaseInstances[testDbPath] = database;
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
    
    for (final database in databases) {
      try {
        await database.close();
      } catch (e) {
        // Ignore close errors
      }
    }
  }
  
  /// Optional: Clean up test database files with specific patterns
  /// 
  /// Use this sparingly - only when you specifically need to clean up test files.
  /// By default, test databases are preserved for debugging and analysis.
  static Future<void> cleanupTestDatabaseDirectory({String? filePattern}) async {
    final testDbDir = Directory('./test/test_dbs');
    if (testDbDir.existsSync()) {
      try {
        final files = testDbDir.listSync().whereType<File>();
        for (final file in files) {
          final fileName = file.path.split(Platform.pathSeparator).last;
          if (filePattern != null && fileName.contains(filePattern)) {
            try {
              await file.delete();
            } catch (e) {
              // Ignore individual file deletion errors
            }
          }
        }
      } catch (e) {
        // Ignore directory access errors
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
