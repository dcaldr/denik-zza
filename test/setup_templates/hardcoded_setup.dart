import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:drift/drift.dart';
import '../helpers/database_test_helper.dart';

/// Hardcoded setup for testing with predefined test data
/// 
/// This class prepares the app database with a test event called "Test Test Test"
/// and 10 participants with various test data configurations.
/// Uses the existing DatabaseTestHelper infrastructure.
/// 
/// 🎯 **Testing Approach**: Uses Drift database directly (like other tests)
/// - ✅ Events: Created using Drift database methods
/// - ✅ Participants: Created using Drift database methods  
/// - ✅ Insurance companies: Auto-created by participant addition
/// - ⚠️  Paramedics: Uses hardcoded test ID (no front-facing creation method exists)
/// - ✅ Medical records: Created using Drift database methods
/// 
/// 📖 Database Access:
/// Uses DatabaseTestHelper.createTestDatabase() for real SQLite databases.
/// 
/// Usage:
/// ```dart
/// setUp(() async {
///   database = await HardcodedTestSetup.setupTestData();
/// });
/// ```
class HardcodedTestSetup {
  
  // Static variable to track selected event
  static int? _selectedEventId;

  /// Gets the ID of the currently selected test event
  static int? get selectedEventId => _selectedEventId;

  /// Sets up the database with test data and returns the database instance
  /// 
  /// [databaseType] - Whether to use memory (fast) or file (persistent) database
  static Future<AppDatabase> setupTestData({
    TestDatabaseType databaseType = TestDatabaseType.memory,
  }) async {
    // Create test database using existing infrastructure
    final AppDatabase database = DatabaseTestHelper.createTestDatabase(databaseType);
    
    try {
  // Ensure the app uses this database instance (so UI + services see same data)
  DatabaseWrapper.setTestMode();
  DatabaseWrapper.useTestDriftDatabase(database);

      // 1. Create the test event using Drift database methods
      final now = DateTime.now();
      final eventCompanion = ZzaActionsCompanion(
        actionTitle: const Value('Test Test Test'),
        actionDescription: const Value('Testovací akce s českými účastníky a historickými osobnostmi'),
        dateFrom: Value(now),
        dateTo: Value(now.add(const Duration(days: 7))),
      );
      final eventId = await database.addZzaAction(eventCompanion);
      _selectedEventId = eventId;

      // Persist selected event into cache so production code paths using
      // getCurrentActionID/watchParticipantsByCurrentEvent work in tests/dev
      await database.updateCache(CacheCompanion(
        id: const Value(1),
        currentActionID: Value(eventId),
        pinnedActionID: const Value(null),
      ));

      // Create a test paramedic row to satisfy foreign key constraints on records
      final testParamedicId = await database.addParamedic(ParamedicsCompanion(
        firstName: const Value('Test'),
        lastName: const Value('Paramedic'),
        address: const Value('Test Address 1'),
        birthDate: Value(DateTime(1990, 1, 1)),
        phoneNumber: const Value('+420000000000'),
        username: const Value('tester1'),
      ));
      
      // 2. Create 10 Czech participants using Drift database methods
      // Insurance companies will be auto-created during participant addition
      final participants = await _createCzechParticipants(database, eventId);

      // 3. Create medical records using Drift database methods
      await _createCzechMedicalRecords(database, participants, testParamedicId);

      return database;
      
    } catch (e) {
      print('❌ Error setting up test data: $e');
      rethrow;
    }
  }

  /// Creates 10 Czech participants with cultural references using Drift database methods
  static Future<List<int>> _createCzechParticipants(AppDatabase database, int eventId) async {
    final participantIds = <int>[];
    
    // Czech historical and cultural figures with subtle references
    final czechParticipants = [
      {
        'firstName': 'Václav',
        'lastName': 'Havlík', // Reference to Václav Havel
        'birthDate': DateTime(2010, 10, 5),
        'address': 'Hradčanské náměstí 1, Praha',
        'note': 'Rád hraje divadlo a píše básně',
        'insurance': 'Všeobecná zdravotní pojišťovna', // Will be auto-created
      },
      {
        'firstName': 'Karel',
        'lastName': 'Čapková', // Reference to Karel Čapek
        'birthDate': DateTime(2009, 1, 9),
        'address': 'Vinohrady 42, Praha',
        'note': 'Miluje roboty a sci-fi příběhy',
        'insurance': 'Oborová zdravotní pojišťovna', // Will be auto-created
      },
      {
        'firstName': 'Bedřich',
        'lastName': 'Smetana', // Bedřich Smetana - composer
        'birthDate': DateTime(2008, 3, 2),
        'address': 'Kampa Island 5, Praha',
        'note': 'Hraje na klavír Vltavu',
        'insurance': 'Všeobecná zdravotní pojišťovna',
      },
      {
        'firstName': 'Antonín',
        'lastName': 'Dvořák', // Antonín Dvořák - composer
        'birthDate': DateTime(2007, 9, 8),
        'address': 'Nelahozeves 123',
        'note': 'Komponuje melodie z Nového světa',
        'insurance': 'Všeobecná zdravotní pojišťovna',
      },
      {
        'firstName': 'Milan',
        'lastName': 'Kundera', // Milan Kundera - writer
        'birthDate': DateTime(2006, 4, 1),
        'address': 'Brno, Moravské náměstí 1',
        'note': 'Píše o nesnesitelné lehkosti bytí',
        'insurance': 'Oborová zdravotní pojišťovna',
      },
      {
        'firstName': 'Jaroslav',
        'lastName': 'Hašek', // Jaroslav Hašek - author of Švejk
        'birthDate': DateTime(2011, 4, 30),
        'address': 'U Fleku 11, Praha',
        'note': 'Vyprávě historky o dobrém vojákovi',
        'insurance': 'Všeobecná zdravotní pojišťovna',
      },
      {
        'firstName': 'Tomáš',
        'lastName': 'Baťa', // Tomáš Baťa - shoe entrepreneur  
        'birthDate': DateTime(2005, 4, 3),
        'address': 'Zlín, náměstí Míru 12',
        'note': 'Sbírá staré boty a opravuje je',
        'insurance': 'Oborová zdravotní pojišťovna',
      },
      {
        'firstName': 'Ema',
        'lastName': 'Destinnová', // Ema Destinnová - opera singer
        'birthDate': DateTime(2004, 2, 26),
        'address': 'Vinohrady, Korunní 15, Praha',
        'note': 'Zpívá árie z Prodané nevěsty',
        'insurance': 'Všeobecná zdravotní pojišťovna',
      },
      {
        'firstName': 'Jan',
        'lastName': 'Komenský', // Jan Amos Komenský
        'birthDate': DateTime(2003, 3, 28),
        'address': 'Nivnice 456, Zlínský kraj',
        'note': 'Zajímá se o vzdělávání a učí ostatní',
        'insurance': 'Oborová zdravotní pojišťovna',
      },
      {
        'firstName': 'Franz',
        'lastName': 'Kafka', // Franz Kafka
        'birthDate': DateTime(2002, 7, 3),
        'address': 'Staroměstské náměstí 27, Praha',
        'note': 'Píše podivné příběhy o proměnách',
        'insurance': 'Všeobecná zdravotní pojišťovna',
      },
    ];
    
    for (final participant in czechParticipants) {
      // Create insurance company if it doesn't exist
      final insuranceName = participant['insurance'] as String;
      int? insuranceId = await database.getInsuranceCompanyIDbyName(insuranceName);
      if (insuranceId == null) {
        insuranceId = await database.addInsuranceCompany(
          InsuranceCompaniesCompanion(name: Value(insuranceName))
        );
      }
      
      final companion = ParticipantsCompanion(
        firstName: Value(participant['firstName'] as String),
        lastName: Value(participant['lastName'] as String),
        birthDate: Value(participant['birthDate'] as DateTime),
        address: Value(participant['address'] as String),
        insuranceCompanyFK: Value(insuranceId),
        zzaActionFK: Value(eventId), // Link participant to the event
        eligibleConfirmation: const Value(true),
        nonInfectiousConfirmation: const Value(true),
        arrivedConfirmation: const Value(true),
        wasPrinted: const Value(false),
      );
      
      final id = await database.addParticipant(companion);
      participantIds.add(id);
    }
    return participantIds;
  }

  /// Creates medical records with Czech cultural easter eggs using Drift database methods
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
    
    for (int i = 0; i < czechRecords.length; i++) {
      final record = czechRecords[i];
      final companion = RecordsCompanion(
        title: Value(record['title'] as String),
        description: Value(record['description'] as String),
        note: const Value('Záznam s českým kulturním odkazem'),
        participantFK: Value(participantIds[record['participantIndex'] as int]),
        paramedicFK: Value(paramedicId),
        dateAndTime: Value(DateTime.now().subtract(Duration(hours: i * 2))),
        wasPrinted: const Value(false),
      );
      await database.addRecord(companion);
    }
  }
  
  /// Quick setup method that can be called in test setUp()
  static Future<AppDatabase> quickSetup({
    TestDatabaseType databaseType = TestDatabaseType.memory,
  }) async {
    return await setupTestData(databaseType: databaseType);
  }
  
  /// Close and clean up the database
  static Future<void> cleanup(AppDatabase database) async {
    await DatabaseTestHelper.closeTestDatabase(database);
  }
}
