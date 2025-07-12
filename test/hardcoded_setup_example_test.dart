import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'setup_templates/hardcoded_setup.dart';

/// Example test demonstrating the usage of HardcodedTestSetup
/// This creates a test environment with pre-populated data for testing.
/// 
/// 📖 HardcodedTestSetup Options:
///   - setupTestData() - Uses memory database (default)
///   - setupTestData(databaseType: TestDatabaseType.file) - Uses persistent test files
///   - Files are saved in test/test_dbs/ directory for manual inspection
void main() {
  group('Hardcoded Setup Example Tests', () {
    late AppDatabase database;
    
    setUp(() async {
      // Setup test data and get the database instance
      database = await HardcodedTestSetup.setupTestData();
    });
    
    tearDown(() async {
      // Close the database after each test
      await database.close();
    });
    
    test('should have created test event "Test Test Test"', () async {
      final events = await database.select(database.zzaActions).get();
      
      expect(events.length, greaterThan(0));
      
      final testEvent = events.firstWhere((event) => event.actionTitle == 'Test Test Test');
      expect(testEvent.actionTitle, equals('Test Test Test'));
      expect(testEvent.actionDescription, contains('českými účastníky'));
    });
    
    test('should have created 10 Czech participants with cultural references', () async {
      final participants = await database.select(database.participants).get();
      
      expect(participants.length, equals(10));
      
      // Check for some Czech cultural figures
      final vaclavHavlik = participants.firstWhere((p) => p.firstName == 'Václav' && p.lastName == 'Havlík');
      expect(vaclavHavlik.note, contains('divadlo'));
      
      final karelCapkova = participants.firstWhere((p) => p.firstName == 'Karel' && p.lastName == 'Čapková');
      expect(karelCapkova.note, contains('roboty'));
      
      final bedrichSmetana = participants.firstWhere((p) => p.firstName == 'Bedřich' && p.lastName == 'Smetana');
      expect(bedrichSmetana.note, contains('Vltavu'));
    });
    
    test('should have created Czech medical records with cultural easter eggs', () async {
      final participants = await database.select(database.participants).get();
      
      // Get records for first participant (Václav Havlík)
      final firstParticipant = participants.first;
      final records = await (database.select(database.records)
        ..where((tbl) => tbl.participantFK.equals(firstParticipant.id))).get();
      
      expect(records.length, greaterThan(0));
      
      // Should contain the requested easter egg
      final recordWithEasterEgg = records.firstWhere(
        (record) => record.description.contains('má velrybí stoličku a hodně ho bolí')
      );
      expect(recordWithEasterEgg, isNotNull);
    });
    
    test('should have insurance companies set up', () async {
      final participants = await database.select(database.participants).get();
      
      // All participants should have insurance companies
      for (final participant in participants) {
        expect(participant.insuranceCompanyFK, isNotNull);
        expect(participant.insuranceCompanyFK, greaterThan(0));
      }
    });
    
    test('should be ready for further testing', () async {
      // This test demonstrates that the setup is complete and ready for use
      
      // We have events
      final events = await database.select(database.zzaActions).get();
      expect(events, isNotEmpty);
      
      // We have participants
      final participants = await database.select(database.participants).get();
      expect(participants, isNotEmpty);
      
      // We have records
      bool hasRecords = false;
      for (final participant in participants) {
        final records = await (database.select(database.records)
          ..where((tbl) => tbl.participantFK.equals(participant.id))).get();
        if (records.isNotEmpty) {
          hasRecords = true;
          break;
        }
      }
      expect(hasRecords, isTrue);
    });
  });
}
