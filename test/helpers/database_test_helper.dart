import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import '../../lib/database/drift_database/database.dart';

/// Test database type selection
enum TestDatabaseType { memory, file }

/// Global test database override - when set, all tests use this type
TestDatabaseType? _globalTestDatabaseOverride;

/// Database Test Helper for Drift Database Testing
/// 
/// Provides flexible test database creation with three modes:
/// 1. Per-test-suite choice (memory or file)
/// 2. Global force all-memory 
/// 3. Global force all-file
class DatabaseTestHelper {
  
  /// Creates a test database instance based on the specified type
  /// 
  /// This is the main function you'll use in your test setUp() methods.
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
  ///   await database.close();
  ///   // For file databases, optionally clean up test files
  ///   if (database.executor is NativeDatabase) {
  ///     // Clean up logic here if needed
  ///   }
  /// });
  /// ```
  static AppDatabase createTestDatabase(TestDatabaseType type) {
    // Check for global override first
    final effectiveType = _globalTestDatabaseOverride ?? type;
    
    switch (effectiveType) {
      case TestDatabaseType.memory:
        return _createMemoryDatabase();
      case TestDatabaseType.file:
        return _createFileDatabase();
    }
  }
  
  /// Create an in-memory test database (fast, isolated)
  static AppDatabase _createMemoryDatabase() {
    return AppDatabase(':memory:');
  }
  
  /// Create a file-based test database (persistent, real SQLite file)
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
    
    return AppDatabase(testDbPath);
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
  /// Call this in tearDown() when you're done with a file database.
  /// The cleanup parameter is optional - set to true only if you want to delete the file.
  static Future<void> closeTestDatabase(AppDatabase database, {bool cleanup = false}) async {
    await database.close();
    
    // Cleanup is optional and disabled by default to preserve test data
    if (cleanup) {
      // Note: Individual file cleanup would require storing the path,
      // which is not easily accessible from the database instance.
      // If cleanup is needed, consider using cleanupTestDatabaseDirectory() 
      // with specific file patterns.
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
  /// Use this as a shortcut when you know you want memory database
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
