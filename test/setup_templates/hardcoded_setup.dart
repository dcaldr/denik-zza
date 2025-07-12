import 'package:drift/drift.dart';
import '../../lib/database/database_wrapper.dart';
import '../../lib/database/drift_database/database.dart';
import '../helpers/database_test_helper.dart';

/// Hardcoded setup for testing with predefined test data
/// 
/// This class prepares the app database with a test event called "Test Test Test"
/// and 10 participants with various test data configurations.
/// Automatically sets the database to test mode for safety.
/// 
/// Usage:
/// ```dart
/// setUp(() async {
///   await HardcodedTestSetup.setupTestData();
/// });
/// 
/// // OR specify database type:
/// setUp(() async {
///   await HardcodedTestSetup.setupTestData(databaseType: TestDatabaseType.file);
/// });
/// ```
class HardcodedTestSetup {
  
  /// Sets up the database with test data and returns the event ID
  /// 
  /// [databaseType] - Whether to use memory (fast) or file (persistent) database
  /// [useWrapper] - Whether to use DatabaseWrapper (app-level) or direct database (unit tests)
  static Future<int> setupTestData({
    TestDatabaseType databaseType = TestDatabaseType.memory,
    bool useWrapper = false,
  }) async {
    // Ensure we're in test mode
    DatabaseWrapper.setTestMode();
    
    late AppDatabase database;
    
    if (useWrapper) {
      // Use the wrapper system for app-level tests
      // Note: This currently requires the wrapper to return AppDatabase
      // This is a limitation that could be improved in the future
      throw UnsupportedError('Wrapper mode not yet fully supported. Use useWrapper: false for direct database access.');
    } else {
      // Use direct database creation for unit tests
      database = DatabaseTestHelper.createTestDatabase(databaseType);
    }
    
    try {
      // 1. Create insurance companies
      final int vzpId = await database.addInsuranceCompany(
        InsuranceCompaniesCompanion.insert(name: 'Všeobecná zdravotní pojišťovna')
      );
      
      final int ozkpId = await database.addInsuranceCompany(
        InsuranceCompaniesCompanion.insert(name: 'Oborová zdravotní pojišťovna')
      );
      
      // 2. Create the test event "Test Test Test"
      final now = DateTime.now();
      final eventId = await database.addZzaAction(
        ZzaActionsCompanion.insert(
          actionTitle: 'Test Test Test',
          actionDescription: const Value('Testovací akce s českými účastníky a historickými osobnostmi'),
          dateFrom: now,
          dateTo: now.add(const Duration(days: 7)),
        )
      );
      
      // 3. Create a paramedic (required for records)
      final paramedicId = await database.addParamedic(
        ParamedicsCompanion.insert(
          firstName: 'Dr. František',
          lastName: 'Zdravotník',
          address: 'Wenceslas Square 1, Praha',
          birthDate: DateTime(1985, 3, 15),
          phoneNumber: '+420 777 123 456',
          username: 'dr.zdravotnik',
        )
      );
      
      // 4. Create 10 Czech participants with cultural references
      final participants = await _createCzechParticipants(database, eventId, vzpId, ozkpId);
      
      // 5. Create some medical records with Czech cultural easter eggs
      await _createCzechMedicalRecords(database, participants, paramedicId);
      
      return eventId;
      
    } catch (e) {
      print('❌ Error setting up test data: $e');
      rethrow;
    }
  }
  
  /// Creates 10 Czech participants with cultural references
  static Future<List<int>> _createCzechParticipants(AppDatabase database, int eventId, int vzpId, int ozkpId) async {
    final participantIds = <int>[];
    
    // Czech historical and cultural figures with subtle references
    final czechParticipants = [
      {
        'firstName': 'Václav',
        'lastName': 'Havlík', // Reference to Václav Havel
        'birthDate': DateTime(2010, 10, 5),
        'address': 'Hradčanské náměstí 1, Praha',
        'note': 'Rád hraje divadlo a píše básně',
        'insurance': vzpId,
      },
      {
        'firstName': 'Karel',
        'lastName': 'Čapková', // Reference to Karel Čapek
        'birthDate': DateTime(2009, 1, 9),
        'address': 'Vinohrady 42, Praha',
        'note': 'Miluje roboty a sci-fi příběhy',
        'insurance': ozkpId,
      },
      {
        'firstName': 'Bedřich',
        'lastName': 'Smetana', // Bedřich Smetana - composer
        'birthDate': DateTime(2008, 3, 2),
        'address': 'Kampa Island 5, Praha',
        'note': 'Hraje na klavír Vltavu',
        'insurance': vzpId,
      },
      {
        'firstName': 'Antonín',
        'lastName': 'Dvořák', // Antonín Dvořák - composer
        'birthDate': DateTime(2007, 9, 8),
        'address': 'Nelahozeves 123',
        'note': 'Komponuje melodie z Nového světa',
        'insurance': vzpId,
      },
      {
        'firstName': 'Milan',
        'lastName': 'Kundera', // Milan Kundera - writer
        'birthDate': DateTime(2006, 4, 1),
        'address': 'Brno, Moravské náměstí 1',
        'note': 'Píše o nesnesitelné lehkosti bytí',
        'insurance': ozkpId,
      },
      {
        'firstName': 'Jaroslav',
        'lastName': 'Hašek', // Jaroslav Hašek - author of Švejk
        'birthDate': DateTime(2011, 4, 30),
        'address': 'U Fleku 11, Praha',
        'note': 'Vyprávě historky o dobrém vojákovi',
        'insurance': vzpId,
      },
      {
        'firstName': 'Tomáš',
        'lastName': 'Baťa', // Tomáš Baťa - shoe entrepreneur  
        'birthDate': DateTime(2005, 4, 3),
        'address': 'Zlín, náměstí Míru 12',
        'note': 'Sbírá staré boty a opravuje je',
        'insurance': ozkpId,
      },
      {
        'firstName': 'Ema',
        'lastName': 'Destinnová', // Ema Destinnová - opera singer
        'birthDate': DateTime(2004, 2, 26),
        'address': 'Vinohrady, Korunní 15, Praha',
        'note': 'Zpívá árie z Prodané nevěsty',
        'insurance': vzpId,
      },
      {
        'firstName': 'Jan',
        'lastName': 'Komenský', // Jan Amos Komenský
        'birthDate': DateTime(2003, 3, 28),
        'address': 'Nivnice 456, Zlínský kraj',
        'note': 'Zajímá se o vzdělávání a učí ostatní',
        'insurance': ozkpId,
      },
      {
        'firstName': 'Franz',
        'lastName': 'Kafka', // Franz Kafka
        'birthDate': DateTime(2002, 7, 3),
        'address': 'Staroměstské náměstí 27, Praha',
        'note': 'Píše podivné příběhy o proměnách',
        'insurance': vzpId,
      },
    ];
    
    for (final participant in czechParticipants) {
      final id = await database.addParticipant(
        ParticipantsCompanion.insert(
          firstName: participant['firstName'] as String,
          lastName: participant['lastName'] as String,
          zzaActionFK: eventId,
          birthDate: Value(participant['birthDate'] as DateTime),
          address: Value(participant['address'] as String),
          note: Value(participant['note'] as String),
          insuranceCompanyFK: Value(participant['insurance'] as int),
          eligibleConfirmation: const Value(true),
          nonInfectiousConfirmation: const Value(true),
          arrivedConfirmation: const Value(true),
        )
      );
      participantIds.add(id);
    }
    
    return participantIds;
  }
  
  /// Creates medical records with Czech cultural easter eggs
  static Future<void> _createCzechMedicalRecords(AppDatabase database, List<int> participantIds, int paramedicId) async {
    final czechRecords = [
      {
        'title': 'Kontrola zdraví',
        'description': 'má velrybí stoličku a hodně ho bolí', // The requested easter egg
        'participantIndex': 0, // Václav Havlík
      },
      {
        'title': 'Preventivní prohlídka',
        'description': 'stěžuje si na roboty v břiše, možná sci-fi alergie',
        'participantIndex': 1, // Karel Čapková
      },
      {
        'title': 'Hudební terapie',
        'description': 'Vltava mu teče v uších, doporučujeme méně klavíru',
        'participantIndex': 2, // Bedřich Smetana
      },
      {
        'title': 'Bolest hlavy',
        'description': 'hlava bolí z příliš mnoha symfonií, potřebuje klid',
        'participantIndex': 3, // Antonín Dvořák
      },
      {
        'title': 'Existenciální krize',
        'description': 'trpí nesnesitelnou lehkostí bytí, doporučen filozofický klid',
        'participantIndex': 4, // Milan Kundera
      },
      {
        'title': 'Vojenské vyšetření',
        'description': 'simuluje nemoc jako dobrý voják Švejk, ale je zdravý',
        'participantIndex': 5, // Jaroslav Hašek
      },
      {
        'title': 'Pracovní úraz',
        'description': 'poranil si nohu při výrobě bot, rychlé hojení',
        'participantIndex': 6, // Tomáš Baťa
      },
      {
        'title': 'Hlasové problémy',
        'description': 'přepěla se při áriích, doporučen hlasový klid',
        'participantIndex': 7, // Ema Destinnová
      },
      {
        'title': 'Únava z učení',
        'description': 'vyčerpání z příliš mnoho vzdělávání, potřebuje pauzu',
        'participantIndex': 8, // Jan Komenský
      },
      {
        'title': 'Kafka-esque situace',
        'description': 'proměnil se v brouka během spánku, ale ráno byl zase normální',
        'participantIndex': 9, // Franz Kafka
      },
    ];
    
    final baseTime = DateTime.now().subtract(const Duration(days: 3));
    
    for (int i = 0; i < czechRecords.length; i++) {
      final record = czechRecords[i];
      await database.addRecord(
        RecordsCompanion.insert(
          title: record['title'] as String,
          description: record['description'] as String,
          participantFK: participantIds[record['participantIndex'] as int],
          paramedicFK: paramedicId,
          dateAndTime: baseTime.add(Duration(hours: i * 2)), // Spread records over time
          note: const Value('Záznam s českým kulturním odkazem'),
        )
      );
    }
  }
  
  /// Quick setup method that can be called in test setUp()
  static Future<void> quickSetup() async {
    await setupTestData();
  }
  
  /// Reset database to clean state
  static Future<void> cleanup() async {
    DatabaseWrapper.resetToProduction();
  }
}
