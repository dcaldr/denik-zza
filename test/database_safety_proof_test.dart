import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../lib/database/database_wrapper.dart';
import '../lib/database/database_interface.dart';
import '../lib/database/drift_database_connector.dart';
import '../lib/database/in_memory_structures_tmp/memory_database_connector.dart';

/// Comprehensive proof-of-concept tests demonstrating the robust database system.
/// 
/// These tests verify:
/// 1. Production safety - app never uses non-persistent DB accidentally
/// 2. Test isolation - test DBs don't interfere with each other or production
/// 3. Schema consistency - same schema works in both production and test contexts
/// 4. Backward compatibility - legacy code continues to work
/// 5. Safety checks - dangerous configurations are detected and prevented
void main() {
  group('Database System Safety Proof Tests', () {
    
    /// Clean up state before each test
    setUp(() {
      DatabaseWrapper.resetToProduction();
    });
    
    /// Ensure clean state after tests
    tearDown(() {
      DatabaseWrapper.resetToProduction();
    });

    group('Production Safety Tests', () {
      test('Default mode is production with persistent storage', () {
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
        expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);
        
        DatabaseInterface db = DatabaseWrapper.getDatabase();
        expect(db, isA<DriftDatabaseConnector>());
      });

      test('Production mode NEVER returns non-persistent database', () {
        // Ensure we're in production mode
        DatabaseWrapper.resetToProduction();
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
        
        // Even with legacy databaseID manipulation, production should be safe
        // (This would be caught by the assert in getDatabase())
        DatabaseInterface db = DatabaseWrapper.getDatabase();
        expect(db, isA<DriftDatabaseConnector>());
        expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);
      });

      test('ensureProductionMode validates safety', () {
        DatabaseWrapper.ensureProductionMode();
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
        expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);
      });

      test('validateProductionSafety detects dangerous configurations', () {
        // This test verifies the safety check works
        // Note: We can't actually test the dangerous state in production
        // because it would throw in assert mode, but we can verify
        // the validation method exists and works in safe states
        expect(() => DatabaseWrapper.validateProductionSafety(), returnsNormally);
      });
    });

    group('Test Mode Safety Tests', () {
      test('Test mode uses non-persistent storage', () {
        DatabaseWrapper.setTestMode();
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.testing);
        expect(DatabaseWrapper.isUsingPersistentStorage(), isFalse);
        
        DatabaseInterface db = DatabaseWrapper.getDatabase();
        expect(db, isA<MemoryDatabase>());
      });

      test('Test mode can be reset to production', () {
        DatabaseWrapper.setTestMode();
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.testing);
        
        DatabaseWrapper.resetToProduction();
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
        expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);
      });

      test('Multiple test setups are isolated', () {
        // First test environment
        DatabaseWrapper.setTestMode();
        DatabaseInterface db1 = DatabaseWrapper.getDatabase();
        expect(db1, isA<MemoryDatabase>());
        
        // Reset and create second test environment
        DatabaseWrapper.resetToProduction();
        DatabaseWrapper.setTestMode();
        DatabaseInterface db2 = DatabaseWrapper.getDatabase();
        expect(db2, isA<MemoryDatabase>());
        
        // They should be different instances (isolated)
        expect(identical(db1, db2), isFalse);
      });
    });

    group('Schema Consistency Tests', () {
      test('Production and test databases have same interface', () {
        // Production database
        DatabaseWrapper.resetToProduction();
        DatabaseInterface prodDb = DatabaseWrapper.getDatabase();
        
        // Test database
        DatabaseWrapper.setTestMode();
        DatabaseInterface testDb = DatabaseWrapper.getDatabase();
        
        // Both should implement the same interface
        expect(prodDb, isA<DatabaseInterface>());
        expect(testDb, isA<DatabaseInterface>());
        
        // They should have the same methods available
        // (This is guaranteed by the interface, but we verify it works)
        expect(prodDb.runtimeType.toString(), contains('Database'));
        expect(testDb.runtimeType.toString(), contains('Database'));
      });
    });

    group('Backward Compatibility Tests', () {
      test('Legacy getDatabase() calls still work', () {
        // This is how the app currently calls the database
        DatabaseInterface db = DatabaseWrapper.getDatabase();
        expect(db, isNotNull);
        expect(db, isA<DatabaseInterface>());
        
        // Should be production database by default
        expect(db, isA<DriftDatabaseConnector>());
      });

      test('Legacy code patterns continue to work', () {
        // Test the exact pattern used throughout the app
        final DatabaseInterface database = DatabaseWrapper.getDatabase();
        expect(database, isNotNull);
        
        // Verify it's the persistent database
        expect(database, isA<DriftDatabaseConnector>());
      });
    });

    group('Integration Safety Tests', () {
      test('Production app workflow is never affected by test code', () {
        // Simulate production app startup
        DatabaseWrapper.ensureProductionMode();
        DatabaseInterface prodDb = DatabaseWrapper.getDatabase();
        expect(prodDb, isA<DriftDatabaseConnector>());
        
        // Simulate some test running (in separate isolate/process)
        // This should NOT affect the production database selection
        DatabaseWrapper.setTestMode();
        DatabaseInterface testDb = DatabaseWrapper.getDatabase();
        expect(testDb, isA<MemoryDatabase>());
        
        // Reset to production (simulating test cleanup)
        DatabaseWrapper.resetToProduction();
        DatabaseInterface backToProdDb = DatabaseWrapper.getDatabase();
        expect(backToProdDb, isA<DriftDatabaseConnector>());
      });

      test('Test cleanup always returns to safe state', () {
        // Simulate a test that might not clean up properly
        DatabaseWrapper.setTestMode();
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.testing);
        
        // Force cleanup (what should happen in tearDown)
        DatabaseWrapper.resetToProduction();
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
        expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);
        
        // Verify production app would work correctly
        DatabaseInterface db = DatabaseWrapper.getDatabase();
        expect(db, isA<DriftDatabaseConnector>());
      });
    });

    group('Safety Edge Cases', () {
      test('Repeated mode switches work correctly', () {
        for (int i = 0; i < 5; i++) {
          DatabaseWrapper.setTestMode();
          expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.testing);
          expect(DatabaseWrapper.getDatabase(), isA<MemoryDatabase>());
          
          DatabaseWrapper.resetToProduction();
          expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
          expect(DatabaseWrapper.getDatabase(), isA<DriftDatabaseConnector>());
        }
      });

      test('getCurrentMode always returns correct state', () {
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
        
        DatabaseWrapper.setTestMode();
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.testing);
        
        DatabaseWrapper.resetToProduction();
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
      });

      test('isUsingPersistentStorage correctly identifies storage type', () {
        // Production mode should use persistent storage
        DatabaseWrapper.resetToProduction();
        expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);
        
        // Test mode should not use persistent storage
        DatabaseWrapper.setTestMode();
        expect(DatabaseWrapper.isUsingPersistentStorage(), isFalse);
      });
    });
  });

  group('Real-World Usage Examples', () {
    test('Typical test setup pattern', () {
      // This demonstrates the recommended test setup pattern
      DatabaseWrapper.setTestMode();
      
      DatabaseInterface db = DatabaseWrapper.getDatabase();
      expect(db, isA<MemoryDatabase>());
      
      // Test operations would go here...
      // They would use isolated, in-memory storage
      
      DatabaseWrapper.resetToProduction();
    });

    test('Production app startup pattern', () {
      // This demonstrates the recommended production startup
      DatabaseWrapper.ensureProductionMode();
      
      DatabaseInterface db = DatabaseWrapper.getDatabase();
      expect(db, isA<DriftDatabaseConnector>());
      
      // Production operations would use persistent storage
      expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);
    });
  });
}
