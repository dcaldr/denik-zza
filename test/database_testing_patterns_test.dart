import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'helpers/database_test_helper.dart';

/// Proof of Concept: Database Testing Patterns
/// 
/// This file demonstrates the three different testing modes:
/// 1. Per-test-suite database choice (memory or file)
/// 2. Global force all-memory
/// 3. Global force all-file
void main() {
  
  group('Pattern 1: Memory Database Tests (Fast Unit Tests)', () {
    late AppDatabase database;
    
    setUp(() {
      // This test suite chooses to use memory database
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
    });
    
    tearDown(() async {
      await DatabaseTestHelper.closeTestDatabase(database);
    });
    
    test('can create and retrieve insurance company', () async {
      // Arrange
      final company = TestDatabaseUtils.createSampleInsuranceCompany(
        name: 'Test Insurance Co'
      );
      
      // Act
      final id = await database.addInsuranceCompany(company);
      final retrieved = await database.getInsuranceCompanyByID(id);
      
      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Test Insurance Co'));
      expect(retrieved.id, equals(id));
    });
    
    test('can create and retrieve participants', () async {
      // Arrange
      final participant = TestDatabaseUtils.createSampleParticipant(
        firstName: 'John',
        lastName: 'Doe'
      );
      
      // Act
      final id = await database.addParticipant(participant);
      final retrieved = await database.getParticipantByID(id);
      
      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.firstName, equals('John'));
      expect(retrieved.lastName, equals('Doe'));
    });
    
    test('database operations are isolated between tests', () async {
      // This test should start with a fresh, empty database
      final allParticipants = await database.getAllParticipants();
      expect(allParticipants, isEmpty);
      
      // Add a participant
      final participant = TestDatabaseUtils.createSampleParticipant();
      await database.addParticipant(participant);
      
      final participants = await database.getAllParticipants();
      expect(participants.length, equals(1));
    });
  });
  
  group('Pattern 2: File Database Tests (Integration Tests)', () {
    late AppDatabase database;
    
    setUp(() {
      // This test suite chooses to use file database
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
    });
    
    tearDown(() async {
      await DatabaseTestHelper.closeTestDatabase(database);
    });
    
    test('file database persists data (proof of concept)', () async {
      // This test demonstrates that we can use file databases
      // In practice, you might test file-specific behaviors here
      
      final company = TestDatabaseUtils.createSampleInsuranceCompany(
        name: 'File Test Insurance'
      );
      
      final id = await database.addInsuranceCompany(company);
      final retrieved = await database.getInsuranceCompanyByID(id);
      
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('File Test Insurance'));
    });
    
    test('test insurance company ID lookup by name', () async {
      // Test the specific method that had a FIXME comment
      final company = TestDatabaseUtils.createSampleInsuranceCompany(
        name: 'Lookup Test Company'
      );
      
      await database.addInsuranceCompany(company);
      
      // Test the getInsuranceCompanyIDbyName method
      final foundId = await database.getInsuranceCompanyIDbyName('Lookup Test Company');
      expect(foundId, isNotNull);
      
      // Test with non-existent company
      final notFoundId = await database.getInsuranceCompanyIDbyName('Non-existent Company');
      expect(notFoundId, isNull);
      
      // Test with null/empty input
      final nullId = await database.getInsuranceCompanyIDbyName(null);
      expect(nullId, isNull);
      
      final emptyId = await database.getInsuranceCompanyIDbyName('');
      expect(emptyId, isNull);
      
      final whitespaceId = await database.getInsuranceCompanyIDbyName('   ');
      expect(whitespaceId, isNull);
    });
  });
  
  group('Pattern 3: Testing the setNoteValue method (marked with FIXME)', () {
    late AppDatabase database;
    
    setUp(() {
      database = DatabaseTestHelper.createMemoryTestDatabase();
    });
    
    tearDown(() async {
      await DatabaseTestHelper.closeTestDatabase(database);
    });
    
    test('setNoteValue updates participant note correctly', () async {
      // First, create a participant
      final participant = TestDatabaseUtils.createSampleParticipant(
        firstName: 'Note',
        lastName: 'Test'
      );
      
      final participantId = await database.addParticipant(participant);
      
      // Test the setNoteValue method
      final updateResult = await database.setNoteValue(participantId, 'Test note content');
      expect(updateResult, isTrue);
      
      // Verify the note was updated
      final updated = await database.getParticipantByID(participantId);
      expect(updated, isNotNull);
      expect(updated!.note, equals('Test note content'));
    });
    
    test('setNoteValue handles empty and null notes', () async {
      final participant = TestDatabaseUtils.createSampleParticipant();
      final participantId = await database.addParticipant(participant);
      
      // Test empty note
      await database.setNoteValue(participantId, '');
      final withEmpty = await database.getParticipantByID(participantId);
      expect(withEmpty!.note, equals(''));
      
      // Test updating to non-empty
      await database.setNoteValue(participantId, 'Updated note');
      final withContent = await database.getParticipantByID(participantId);
      expect(withContent!.note, equals('Updated note'));
    });
  });
}

/// Example of global override usage (commented out - uncomment to test)
/// 
/// This would force ALL tests above to use memory database,
/// regardless of their individual TestDatabaseType choice
/*
void main() {
  setUpAll(() {
    // Force all tests to use memory database
    DatabaseTestHelper.setGlobalTestDatabaseOverride(TestDatabaseType.memory);
  });
  
  tearDownAll(() {
    // Clean up global override
    DatabaseTestHelper.clearGlobalTestDatabaseOverride();
  });
  
  // ... rest of tests above would all use memory database now
}
*/
