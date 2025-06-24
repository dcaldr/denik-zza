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
    return AppDatabase(DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true, // Required for Flutter tests!
    ));
  }
  
  /// Create a file-based test database (persistent, real SQLite file)
  static AppDatabase _createFileDatabase() {
    // Create unique test database file
    final testDbFile = File('test_${DateTime.now().millisecondsSinceEpoch}.db');
    
    return AppDatabase(DatabaseConnection(
      NativeDatabase(testDbFile),
      closeStreamsSynchronously: true, // Required for Flutter tests!
    ));
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
  
  /// Utility function to clean up test database files
  /// 
  /// Call this in tearDown() if you're using file databases and want to clean up
  static Future<void> cleanupTestDatabaseFile(AppDatabase database) async {
    await database.close();
    
    // If it's a file database, try to delete the file
    if (database.executor is DatabaseConnection) {
      final connection = database.executor as DatabaseConnection;
      if (connection.executor is NativeDatabase) {
        final nativeDb = connection.executor as NativeDatabase;
        // Note: NativeDatabase doesn't expose the file path directly
        // This is a limitation, but file cleanup is optional anyway
      }
    }
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
      zzaActionFK: Value(zzaActionFK),
      insuranceCompanyFK: Value(insuranceCompanyFK),
    );
  }
  
  /// Create sample action for testing
  static ZzaActionsCompanion createSampleAction({
    String name = 'Test Action',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    final now = DateTime.now();
    return ZzaActionsCompanion.insert(
      name: name,
      dateFrom: dateFrom ?? now,
      dateTo: Value(dateTo ?? now.add(const Duration(days: 7))),
    );
  }
  
  /// Create sample record for testing
  static RecordsCompanion createSampleRecord({
    String title = 'Test Record',
    String description = 'Test Description',
    required int participantFK,
    int? paramedicFK,
  }) {
    return RecordsCompanion.insert(
      title: title,
      description: description,
      participantFK: participantFK,
      paramedicFK: Value(paramedicFK),
    );
  }
}
