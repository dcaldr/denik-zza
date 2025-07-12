import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import '../lib/database/drift_database/database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'helpers/database_test_helper.dart';

/// Integration Logic Test - Mixed memory objects and database operations
/// 
/// This test demonstrates both:
/// 1. Memory object unit testing (no database needed)
/// 2. Database integration testing (uses proper test database setup)
/// 
/// 📖 Available Database Types:
///   - TestDatabaseType.memory: Fast in-memory testing (used here for unit tests)
///   - TestDatabaseType.file: Persistent test files in test/test_dbs/ (for integration tests)
void main() {
  group('Integration Logic Test - Memory Objects', () {
    test('Verify MemoryOsoba constructor behavior', () {
      // Test basic constructor
      final basicPerson = MemoryOsoba.basic('John', 'Doe');
      basicPerson.id = -1;
      
      expect(basicPerson.jmeno, equals('John'));
      expect(basicPerson.prijmeni, equals('Doe'));
      expect(basicPerson.id, equals(-1));
      
      // Test with existing person ID
      final existingPerson = MemoryOsoba.basic('Jane', 'Smith');
      existingPerson.id = 123;
      
      expect(existingPerson.id, equals(123));
      expect(existingPerson.jmeno, equals('Jane'));
      expect(existingPerson.prijmeni, equals('Smith'));
    });

    test('Test insurance company logic scenarios', () {
      final person = MemoryOsoba.basic('Test', 'User');
      
      // Test empty string
      person.zdravotniPojistovna = '';
      expect(person.zdravotniPojistovna, isEmpty);
      
      // Test null
      person.zdravotniPojistovna = null;
      expect(person.zdravotniPojistovna, isNull);
      
      // Test whitespace only
      person.zdravotniPojistovna = '   ';
      expect(person.zdravotniPojistovna!.trim(), isEmpty);
      
      // Test valid insurance company
      person.zdravotniPojistovna = 'Test Insurance Company';
      expect(person.zdravotniPojistovna, isNotNull);
      expect(person.zdravotniPojistovna!.trim(), isNotEmpty);
    });
  });

  group('Integration Logic Test - Database Operations', () {
    late AppDatabase database;
    
    setUp(() {
      // Use proper test database helper for consistent, isolated testing
      // Memory database chosen for fast unit testing of integration logic
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
    });
    
    tearDown(() async {
      await DatabaseTestHelper.closeTestDatabase(database);
    });
    
    test('End-to-end participant creation with insurance company', () async {
      // Create insurance company first
      final insuranceCompany = TestDatabaseUtils.createSampleInsuranceCompany(
        name: 'Integration Test Insurance'
      );
      final insuranceId = await database.addInsuranceCompany(insuranceCompany);
      
      // Create participant with insurance company
      final participant = TestDatabaseUtils.createSampleParticipant(
        firstName: 'Integration',
        lastName: 'Test',
        insuranceCompanyFK: insuranceId,
      );
      final participantId = await database.addParticipant(participant);
      
      // Verify the relationship
      final retrievedParticipant = await database.getParticipantByID(participantId);
      expect(retrievedParticipant, isNotNull);
      expect(retrievedParticipant!.insuranceCompanyFK, equals(insuranceId));
      
      // Test the insurance company lookup by name
      final foundInsuranceId = await database.getInsuranceCompanyIDbyName('Integration Test Insurance');
      expect(foundInsuranceId, equals(insuranceId));
    });
    
    test('Integration test for records and participants relationship', () async {
      // Create a participant
      final participant = TestDatabaseUtils.createSampleParticipant(
        firstName: 'Record',
        lastName: 'Owner',
      );
      final participantId = await database.addParticipant(participant);
      
      // Create multiple records for the participant
      final record1 = TestDatabaseUtils.createSampleRecord(
        title: 'First Record',
        description: 'First medical record',
        participantFK: participantId,
        paramedicFK: 1, // Add required paramedicFK
      );
      final record2 = TestDatabaseUtils.createSampleRecord(
        title: 'Second Record', 
        description: 'Second medical record',
        participantFK: participantId,
        paramedicFK: 1, // Add required paramedicFK
      );
      
      await database.addRecord(record1);
      await database.addRecord(record2);
      
      // Test retrieving records by participant ID
      final records = await database.getRecordsByParticipantID(participantId);
      expect(records.length, equals(2));
      expect(records.map((r) => r.title), containsAll(['First Record', 'Second Record']));
    });
    
    test('Test cache operations integration', () async {
      // Test cache update and retrieval
      final cacheUpdate = CacheCompanion(
        id: const Value(1),
        pinnedActionID: const Value(123),
        currentActionID: const Value(456),
      );
      
      final updateResult = await database.updateCache(cacheUpdate);
      expect(updateResult, greaterThan(0));
      
      // Test retrieval
      final pinnedId = await database.getPinnedActionID();
      expect(pinnedId, equals(123));
      
      final currentId = await database.getCurrentActionID();
      expect(currentId, equals(456));
    });
  });
}
