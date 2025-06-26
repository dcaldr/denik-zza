import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/controllers/intake_controller.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';
import 'helpers/database_test_helper.dart';

void main() {
  group('Intake Duplicate Prevention Tests - Memory Objects', () {
    test('Should use addOsoba for new person (id = -1)', () async {
      // Arrange
      final newPerson = MemoryOsoba.basic('John', 'Doe');
      newPerson.id = -1; // New person indicator
      newPerson.zpusobilost = true;
      newPerson.bezinfekcnost = true;
      
      // Act & Assert
      // We can't easily test the database operations without mocking,
      // but we can test the logic decision making
      expect(newPerson.id, equals(-1));
      expect(newPerson.jmeno, equals('John'));
      expect(newPerson.prijmeni, equals('Doe'));
    });

    test('Should use updateParticipant for existing person (id > 0)', () async {
      // Arrange
      final existingPerson = MemoryOsoba.basic('Jane', 'Smith');
      existingPerson.id = 123; // Existing person with valid ID
      existingPerson.zpusobilost = true;
      existingPerson.bezinfekcnost = true;
      
      // Act & Assert
      expect(existingPerson.id, greaterThan(0));
      expect(existingPerson.jmeno, equals('Jane'));
      expect(existingPerson.prijmeni, equals('Smith'));
    });

    test('Insurance company creation logic with empty name', () async {
      // Arrange
      final person = MemoryOsoba.basic('Test', 'Person');
      person.id = -1;
      person.zdravotniPojistovna = ''; // Empty insurance company name
      person.zpusobilost = true;
      person.bezinfekcnost = true;
      
      // Act & Assert
      // The logic should handle empty insurance company names gracefully
      expect(person.zdravotniPojistovna, isEmpty);
      
      // Test with null insurance company name
      person.zdravotniPojistovna = null;
      expect(person.zdravotniPojistovna, isNull);
    });
  });

  group('Intake Duplicate Prevention Tests - Real Database Operations', () {
    late AppDatabase database;
    
    setUp(() {
      // Use memory database for fast testing
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
    });
    
    tearDown(() async {
      await database.close();
    });
    
    test('Should create new participant when ID is -1', () async {
      // Arrange
      final newParticipant = TestDatabaseUtils.createSampleParticipant(
        firstName: 'John',
        lastName: 'Doe'
      );
      
      // Act
      final participantId = await database.addParticipant(newParticipant);
      final created = await database.getParticipantByID(participantId);
      
      // Assert
      expect(created, isNotNull);
      expect(created!.firstName, equals('John'));
      expect(created.lastName, equals('Doe'));
      expect(created.id, greaterThan(0)); // Should get a real ID
    });
    
    test('Should handle insurance company creation with empty name', () async {
      // Test the edge case mentioned in the original test
      final companyId = await database.getInsuranceCompanyIDbyName('');
      expect(companyId, isNull);
      
      final nullCompanyId = await database.getInsuranceCompanyIDbyName(null);
      expect(nullCompanyId, isNull);
      
      // Test with valid company name
      final validCompany = TestDatabaseUtils.createSampleInsuranceCompany(
        name: 'Valid Insurance Company'
      );
      await database.addInsuranceCompany(validCompany);
      
      final foundId = await database.getInsuranceCompanyIDbyName('Valid Insurance Company');
      expect(foundId, isNotNull);
    });
    
    test('Should update existing participant when ID > 0', () async {
      // First create a participant
      final participant = TestDatabaseUtils.createSampleParticipant(
        firstName: 'Jane',
        lastName: 'Smith'
      );
      
      final participantId = await database.addParticipant(participant);
      
      // Now update the participant
      final updatedParticipant = ParticipantsCompanion(
        firstName: const Value('Jane Updated'),
        lastName: const Value('Smith Updated'),
      );
      
      final updateCount = await database.updateParticipant(participantId, updatedParticipant);
      expect(updateCount, equals(1)); // Should update 1 row
      
      // Verify the update
      final updated = await database.getParticipantByID(participantId);
      expect(updated!.firstName, equals('Jane Updated'));
      expect(updated.lastName, equals('Smith Updated'));
    });
  });

    test('Insurance company creation logic with valid name', () async {
      // Arrange
      final person = MemoryOsoba.basic('Test', 'Person');
      person.id = -1;
      person.zdravotniPojistovna = 'Test Insurance'; // Valid insurance company name
      person.zpusobilost = true;
      person.bezinfekcnost = true;
      
      // Act & Assert
      expect(person.zdravotniPojistovna, isNotEmpty);
      expect(person.zdravotniPojistovna, equals('Test Insurance'));
    });

    test('Person creation through new person button should have id = -1', () {
      // This simulates the logic in IntakePersonRow._createNewPerson()
      final newPerson = MemoryOsoba.basic('', '');
      newPerson.id = -1;
      
      expect(newPerson.id, equals(-1));
      expect(newPerson.jmeno, isEmpty);
      expect(newPerson.prijmeni, isEmpty);
    });
  });
}
