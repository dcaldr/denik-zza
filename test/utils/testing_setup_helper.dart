import 'package:denik_zza/database/database_wrapper.dart';
import '../../lib/database/drift_database/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_configuration.dart';
import 'unified_test_setup.dart';

/// Enhanced test setup helper that provides backward compatibility
/// while enabling new three-mode testing infrastructure
/// 
/// Usage:
/// ```dart
/// setUp(() async {
///   await TestingSetupHelper.setupTestEnvironment();
/// });
/// 
/// tearDown(() async {
///   await TestingSetupHelper.tearDown();
/// });
/// ```
class TestingSetupHelper {
  static AppDatabase? _currentDatabase;
  static bool _isInitialized = false;
  
  /// Setup test environment with backward compatibility
  /// 
  /// This method:
  /// 1. Maintains existing DatabaseWrapper.setTestMode() behavior
  /// 2. Initializes new three-mode infrastructure 
  /// 3. Creates appropriate database for current test mode
  static Future<AppDatabase> setupTestEnvironment() async {
    // Maintain backward compatibility with existing DatabaseWrapper pattern
    DatabaseWrapper.setTestMode();
    
    // Initialize new three-mode infrastructure
    await UnifiedTestSetup.initializeTestEnvironment();
    
    // Create database using unified setup
    _currentDatabase = await UnifiedTestSetup.createDatabase();
    _isInitialized = true;
    
    return _currentDatabase!;
  }
  
  /// Get the current test database
  /// 
  /// Returns the database created by setupTestEnvironment()
  /// Throws if setupTestEnvironment() hasn't been called
  static AppDatabase getCurrentDatabase() {
    if (!_isInitialized || _currentDatabase == null) {
      throw StateError('TestingSetupHelper not initialized. Call setupTestEnvironment() first.');
    }
    return _currentDatabase!;
  }
  
  /// Backward compatible database creation (legacy pattern)
  /// 
  /// This maintains the existing pattern used in many tests:
  /// ```dart
  /// final db = await TestingSetupHelper.createTestDatabase();
  /// ```
  static Future<AppDatabase> createTestDatabase() async {
    return setupTestEnvironment();
  }
  
  /// Clean teardown following best practices
  /// 
  /// This method:
  /// 1. Closes database connections properly
  /// 2. Cleans up test outputs based on mode
  /// 3. Resets state for next test
  static Future<void> cleanUp() async {
    if (_currentDatabase != null) {
      await _currentDatabase!.close();
      _currentDatabase = null;
    }
    
    // Clean up test environment
    await UnifiedTestSetup.cleanupTestEnvironment();
    
    // Reset DatabaseWrapper to production mode
    DatabaseWrapper.resetToProduction();
    
    _isInitialized = false;
  }
  
  /// Get current test mode information for debugging
  static Map<String, dynamic> getTestInfo() {
    return {
      'isInitialized': _isInitialized,
      'hasDatabase': _currentDatabase != null,
      'testMode': TestConfiguration.modeString,
      'databaseWrapperMode': DatabaseWrapper.getCurrentMode().name,
      'environment': UnifiedTestSetup.getEnvironmentSummary(),
    };
  }
  
  /// Validate test environment is properly configured
  static Future<bool> validateTestEnvironment() async {
    try {
      // Check if unified setup is valid
      final isValid = await UnifiedTestSetup.validateEnvironment();
      if (!isValid) return false;
      
      // Check DatabaseWrapper is in test mode
      if (DatabaseWrapper.getCurrentMode() != DatabaseMode.testing) return false;
      
      // Check database is available
      if (_currentDatabase == null) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Shorthand for common test pattern
  /// 
  /// Usage in group tests:
  /// ```dart
  /// group('My Feature Tests', () {
  ///   TestingSetupHelper.setupGroup();
  ///   
  ///   test('should do something', () async {
  ///     final db = TestingSetupHelper.getCurrentDatabase();
  ///     // ... test code
  ///   });
  /// });
  /// ```
  static void setupGroup() {
    setUp(() async {
      await setupTestEnvironment();
    });
    
    tearDown(() async {
      await TestingSetupHelper.cleanUp();
    });
  }
  
  /// Enhanced setup for widget tests
  /// 
  /// Provides additional initialization needed for widget testing
  static Future<AppDatabase> setupWidgetTestEnvironment() async {
    // Standard test setup
    final database = await setupTestEnvironment();
    
    // Additional widget test specific setup can go here
    // (e.g., service registration, provider setup, etc.)
    
    return database;
  }
}
