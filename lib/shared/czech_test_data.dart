import 'package:drift/drift.dart';
import 'package:denik_zza/database/drift_database/database.dart';

/// Shared Czech test data for development and testing.
///
/// Used by:
/// - [HardcodedTestSetup] (test/)
/// - [DevEnvironment] (lib/dev/)
///
/// Contains 10 Czech cultural figures as participants with matching medical records.
class CzechTestData {
  /// 10 Czech historical and cultural figures with subtle cultural references.
  static const List<Map<String, dynamic>> participants = [
    {
      'firstName': 'Václav',
      'lastName': 'Havlík', // Reference to Václav Havel
      'birthDate': '2010-10-05',
      'address': 'Hradčanské náměstí 1, Praha',
      'note': 'Rád hraje divadlo a píše básně',
      'insurance': 'Všeobecná zdravotní pojišťovna',
    },
    {
      'firstName': 'Karel',
      'lastName': 'Čapková', // Reference to Karel Čapek
      'birthDate': '2009-01-09',
      'address': 'Vinohrady 42, Praha',
      'note': 'Miluje roboty a sci-fi příběhy',
      'insurance': 'Oborová zdravotní pojišťovna',
    },
    {
      'firstName': 'Bedřich',
      'lastName': 'Smetana', // Composer
      'birthDate': '2008-03-02',
      'address': 'Kampa Island 5, Praha',
      'note': 'Hraje na klavír Vltavu',
      'insurance': 'Všeobecná zdravotní pojišťovna',
    },
    {
      'firstName': 'Antonín',
      'lastName': 'Dvořák', // Composer
      'birthDate': '2007-09-08',
      'address': 'Nelahozeves 123',
      'note': 'Komponuje melodie z Nového světa',
      'insurance': 'Všeobecná zdravotní pojišťovna',
    },
    {
      'firstName': 'Milan',
      'lastName': 'Kundera', // Writer
      'birthDate': '2006-04-01',
      'address': 'Brno, Moravské náměstí 1',
      'note': 'Píše o nesnesitelné lehkosti bytí',
      'insurance': 'Oborová zdravotní pojišťovna',
    },
    {
      'firstName': 'Jaroslav',
      'lastName': 'Hašek', // Author of Švejk
      'birthDate': '2011-04-30',
      'address': 'U Fleku 11, Praha',
      'note': 'Vyprávě historky o dobrém vojákovi',
      'insurance': 'Všeobecná zdravotní pojišťovna',
    },
    {
      'firstName': 'Tomáš',
      'lastName': 'Baťa', // Shoe entrepreneur
      'birthDate': '2005-04-03',
      'address': 'Zlín, náměstí Míru 12',
      'note': 'Sbírá staré boty a opravuje je',
      'insurance': 'Oborová zdravotní pojišťovna',
    },
    {
      'firstName': 'Ema',
      'lastName': 'Destinnová', // Opera singer
      'birthDate': '2004-02-26',
      'address': 'Vinohrady, Korunní 15, Praha',
      'note': 'Zpívá árie z Prodané nevěsty',
      'insurance': 'Všeobecná zdravotní pojišťovna',
    },
    {
      'firstName': 'Jan',
      'lastName': 'Komenský', // Jan Amos Komenský
      'birthDate': '2003-03-28',
      'address': 'Nivnice 456, Zlínský kraj',
      'note': 'Zajímá se o vzdělávání a učí ostatní',
      'insurance': 'Oborová zdravotní pojišťovna',
    },
    {
      'firstName': 'Franz',
      'lastName': 'Kafka', // Franz Kafka
      'birthDate': '2002-07-03',
      'address': 'Staroměstské náměstí 27, Praha',
      'note': 'Píše podivné příběhy o proměnách',
      'insurance': 'Všeobecná zdravotní pojišťovna',
    },
  ];

  /// 10 Czech-themed medical records with cultural easter eggs.
  static const List<Map<String, dynamic>> records = [
    {
      'title': 'Kontrola zdraví',
      'description': 'má velrybí stoličku a hodně ho bolí', // Easter egg
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
      'description':
          'trpí nesnesitelnou lehkostí bytí, doporučen filozofický klid',
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
      'description':
          'proměnil se v brouka během spánku, ale ráno byl zase normální',
      'participantIndex': 9, // Franz Kafka
    },
  ];

  /// Creates 10 Czech participants in the database.
  ///
  /// Returns a list of participant IDs in the same order as [participants].
  static Future<List<int>> createParticipants(
    AppDatabase database,
    int eventId,
  ) async {
    final participantIds = <int>[];

    for (final p in participants) {
      // Create insurance company if it doesn't exist
      final insuranceName = p['insurance'] as String;
      int? insuranceId =
          await database.getInsuranceCompanyIDbyName(insuranceName);
      insuranceId ??= await database.addInsuranceCompany(
          InsuranceCompaniesCompanion(name: Value(insuranceName)));

      final birthDate = DateTime.parse(p['birthDate'] as String);
      final companion = ParticipantsCompanion(
        firstName: Value(p['firstName'] as String),
        lastName: Value(p['lastName'] as String),
        birthDate: Value(birthDate),
        address: Value(p['address'] as String),
        note: Value(p['note'] as String),
        insuranceCompanyFK: Value(insuranceId),
        zzaActionFK: Value(eventId),
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

  /// Creates 10 medical records for the given participants.
  static Future<void> createMedicalRecords(
    AppDatabase database,
    List<int> participantIds,
    int paramedicId,
  ) async {
    for (int i = 0; i < records.length; i++) {
      final record = records[i];
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
}
