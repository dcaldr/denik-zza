import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'setup_templates/hardcoded_setup.dart';

/// Example test demonstrating the usage of HardcodedTestSetup
/// This creates a Czech test environment with cultural references
void main() {
  group('Hardcoded Setup Example Tests', () {
    
    setUp(() async {
      // Setup test data (automatically sets test mode)
      await HardcodedTestSetup.setupTestData();
    });
    
    tearDown(() async {
      // Clean up after tests
      await HardcodedTestSetup.cleanup();
    });
    
    test('should have created test event "Test Test Test"', () async {
      final db = DatabaseWrapper.getDatabase();
      final events = await db.getAllZzaActions();
      
      expect(events.length, greaterThan(0));
      
      final testEvent = events.firstWhere((event) => event.nadpis == 'Test Test Test');
      expect(testEvent.nadpis, equals('Test Test Test'));
      expect(testEvent.popis, contains('českými účastníky'));
    });
    
    test('should have created 10 Czech participants with cultural references', () async {
      final db = DatabaseWrapper.getDatabase();
      final participants = await db.getParticipantsByCurrentEvent();
      
      expect(participants.length, equals(10));
      
      // Check for some Czech cultural figures
      final vaclavHavlik = participants.firstWhere((p) => p.jmeno == 'Václav' && p.prijmeni == 'Havlík');
      expect(vaclavHavlik.poznamka, contains('divadlo'));
      
      final karelCapkova = participants.firstWhere((p) => p.jmeno == 'Karel' && p.prijmeni == 'Čapková');
      expect(karelCapkova.poznamka, contains('roboty'));
      
      final bedrichSmetana = participants.firstWhere((p) => p.jmeno == 'Bedřich' && p.prijmeni == 'Smetana');
      expect(bedrichSmetana.poznamka, contains('Vltavu'));
    });
    
    test('should have created Czech medical records with cultural easter eggs', () async {
      final db = DatabaseWrapper.getDatabase();
      final participants = await db.getParticipantsByCurrentEvent();
      
      // Get records for first participant (Václav Havlík)
      final firstParticipant = participants.first;
      final records = await db.getRecordsByParticipantID(firstParticipant.id);
      
      expect(records.length, greaterThan(0));
      
      // Should contain the requested easter egg
      final recordWithEasterEgg = records.firstWhere(
        (record) => record.popis!.contains('má velrybí stoličku a hodně ho bolí')
      );
      expect(recordWithEasterEgg, isNotNull);
    });
    
    test('should have insurance companies set up', () async {
      final db = DatabaseWrapper.getDatabase();
      final participants = await db.getParticipantsByCurrentEvent();
      
      // All participants should have insurance companies
      for (final participant in participants) {
        expect(participant.zdravotniPojistovna, isNotNull);
        expect(participant.zdravotniPojistovna, isNotEmpty);
      }
    });
    
    test('should be ready for further testing', () async {
      // This test demonstrates that the setup is complete and ready for use
      final db = DatabaseWrapper.getDatabase();
      
      // We have events
      final events = await db.getAllZzaActions();
      expect(events, isNotEmpty);
      
      // We have participants
      final participants = await db.getParticipantsByCurrentEvent();
      expect(participants, isNotEmpty);
      
      // We have records
      bool hasRecords = false;
      for (final participant in participants) {
        final records = await db.getRecordsByParticipantID(participant.id);
        if (records.isNotEmpty) {
          hasRecords = true;
          break;
        }
      }
      expect(hasRecords, isTrue);
    });
  });
}
