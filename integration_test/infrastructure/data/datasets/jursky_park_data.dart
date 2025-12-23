import '../models/test_medication.dart';
import '../models/test_participant.dart';
import '../models/test_record.dart';
import '../models/test_restriction.dart';

/// Jurský Park dataset - 15 Czech participants.
///
/// This is the standard/canary dataset used for most integration tests.
/// All data is fully hardcoded with valid rodné číslo values.
///
/// ## Participants Summary:
/// - 15 total (11 male, 4 female)
/// - Ages 10-16 (birthdates 2009-2015)
/// - Medical records: 0-13 per participant (64 total)
/// - Parent contacts: 8/15 (53%)
///
/// ## Usage:
/// ```dart
/// for (final p in jurskyParkParticipants) {
///   // Seeder: await db.addParticipant(p.toCompanion(eventId, insuranceId));
///   // Robot:  await robot.fillParticipantForm(p);
/// }
/// ```

const jurskyParkParticipants = [
  // 1. Karel Čapek - 16, Male, 2 records
  TestParticipant(
    jmeno: 'Karel',
    prijmeni: 'Čapek',
    pohlavi: 1,
    datumNarozeni: '2009-01-09',
    rodneCislo: '090109/0804',
    adresa: 'Vinohrady 42, Praha',
    telefonRodice: '+420601234567',
    pojistovna: 'VZP',
    zaznamy: [
      TestRecord(
        nazev: 'Noční můry',
        popis: 'Sní o robotech, které ovládly tábor. Doporučen klid.',
        hoursAgo: 48,
      ),
      TestRecord(
        nazev: 'Nespavost',
        popis: 'Potíže s usínáním kvůli obavám z budoucnosti technologie.',
        hoursAgo: 24,
      ),
    ],
  ),

  // 2. Božena Němcová - 15, Female, 2 records, bee allergy
  TestParticipant(
    jmeno: 'Božena',
    prijmeni: 'Němcová',
    pohlavi: 2,
    datumNarozeni: '2010-05-15',
    rodneCislo: '105515/9634',
    adresa: 'Ratibořice 1, Červený Kostelec',
    telefonRodice: '+420602345678',
    pojistovna: 'VZP',
    omezeni: [
      TestRestriction.alergie(
          'Včelí štípnutí (epipen není nutný, ale opatrnost vyžadována)'),
    ],
    zaznamy: [
      TestRecord(
        nazev: 'Stesk po babičce',
        popis: 'Stesk po domově. Doporučen telefonát s rodičem.',
        hoursAgo: 60,
      ),
      TestRecord(
        nazev: 'Odřenina z lezení po stromech',
        popis: 'Drobné odřeniny na kolen a loktech. Ošetřeno.',
        hoursAgo: 36,
      ),
    ],
  ),

  // 3. Jan Hus - 14, Male, 5 records, SPF requirement
  TestParticipant(
    jmeno: 'Jan',
    prijmeni: 'Hus',
    pohlavi: 1,
    datumNarozeni: '2011-07-06',
    rodneCislo: '110706/6792',
    adresa: 'Husova 15, Praha 1',
    pojistovna: 'VZP',
    leky: [
      TestMedication(nazev: 'Panthenol', kdy: 'Po spálení'),
    ],
    omezeni: [
      TestRestriction.omezeni(
          'Nutné používat opalovací krém SPF 50+ (citlivá kůže)'),
    ],
    zaznamy: [
      TestRecord(
        nazev: 'Spálení sluncem',
        popis: 'Odmítl použít opalovací krém. Výrazné zarudnutí.',
        hoursAgo: 72,
      ),
      TestRecord(
        nazev: 'Spálení sluncem - pokrač.',
        popis: 'Pokračující problémy s kůží. Panthenol aplikován.',
        hoursAgo: 48,
      ),
      TestRecord(
        nazev: 'Přehřátí',
        popis: 'Příznaky slunečního úpalu. Doporučen stín a tekutiny.',
        hoursAgo: 40,
      ),
      TestRecord(
        nazev: 'Puchýř na patě',
        popis: 'Puchýř z turistiky. Ošetřen náplastí.',
        hoursAgo: 30,
      ),
      TestRecord(
        nazev: 'Drobné popáleniny z ohně',
        popis: 'Lehké popálení při stavbě ohně.',
        hoursAgo: 12,
      ),
    ],
  ),

  // 4. Tomáš Masaryk - 14, Male, 0 records (stoic)
  TestParticipant(
    jmeno: 'Tomáš',
    prijmeni: 'Masaryk',
    pohlavi: 1,
    datumNarozeni: '2011-03-07',
    rodneCislo: '110307/4713',
    adresa: 'Hradčany 7, Praha',
    telefonRodice: '+420603456789',
    pojistovna: 'OZP',
  ),

  // 5. Alfons Mucha - 13, Male, 0 records but has allergies
  TestParticipant(
    jmeno: 'Alfons',
    prijmeni: 'Mucha',
    pohlavi: 1,
    datumNarozeni: '2012-07-24',
    rodneCislo: '120724/0177',
    adresa: 'Ivančice 28, Brno',
    pojistovna: 'OZP',
    omezeni: [
      TestRestriction.alergie('Alergie na malířské látky (barvy, ředidla)'),
      TestRestriction.omezeni('Vyhnout se výtvarným aktivitám s barvami'),
    ],
  ),

  // 6. Emil Zátopek - 13, Male, 1 record, running limitation
  TestParticipant(
    jmeno: 'Emil',
    prijmeni: 'Zátopek',
    pohlavi: 1,
    datumNarozeni: '2012-09-19',
    rodneCislo: '120919/4350',
    adresa: 'Kopřivnice 192, Zlín',
    telefonRodice: '+420604567890',
    pojistovna: 'VZP',
    omezeni: [
      TestRestriction.omezeni(
          'Běh omezen na max. 30 minut denně (prevence přetížení svalů)'),
    ],
    zaznamy: [
      TestRecord(
        nazev: 'Křeč svalů',
        popis: 'Křeč v lýtku po nadměrném běhání. Doporučeno omezení.',
        hoursAgo: 50,
      ),
    ],
  ),

  // 7. Milada Horáková - 12, Female, 9 records, latex allergy
  TestParticipant(
    jmeno: 'Milada',
    prijmeni: 'Horáková',
    pohlavi: 2,
    datumNarozeni: '2013-12-25',
    rodneCislo: '136225/3663',
    adresa: 'Staroměstské nám. 8, Praha',
    telefonRodice: '+420605678901',
    pojistovna: 'OZP',
    leky: [
      TestMedication(
          nazev: 'Ibalgin 400mg', davkovani: '1 tableta', kdy: 'Při bolesti'),
    ],
    omezeni: [
      TestRestriction.alergie('Alergie na latex (používat nitrilové rukavice)'),
    ],
    zaznamy: [
      TestRecord(
          nazev: 'Modřina z obrany kamaráda',
          popis: 'Zasáhla při šikaně. Modřina na paži.',
          hoursAgo: 80),
      TestRecord(
          nazev: 'Odřeniny z intervence',
          popis: 'Odřené koleno při pomoci mladšímu účastníkovi.',
          hoursAgo: 70),
      TestRecord(
          nazev: 'Natažený sval',
          popis: 'Natažení při zastavení konfliktu.',
          hoursAgo: 65),
      TestRecord(
          nazev: 'Modřina na zádech',
          popis: 'Další modřina z obhajoby druhých.',
          hoursAgo: 55),
      TestRecord(
          nazev: 'Malá tržná rána',
          popis: 'Tržná rána na ruce. Sešita.',
          hoursAgo: 45),
      TestRecord(
          nazev: 'Oděrky',
          popis: 'Četné oděrky po pádu během zásahu.',
          hoursAgo: 38),
      TestRecord(
          nazev: 'Pohmoždění',
          popis: 'Pohmoždění žeber. Doporučen klid.',
          hoursAgo: 28),
      TestRecord(
          nazev: 'Bolest hlavy',
          popis: 'Bolest hlavy ze stresu. Ibalgin podán.',
          hoursAgo: 15),
      TestRecord(
          nazev: 'Únava',
          popis: 'Vyčerpání z nadbytečné aktivity. Doporučen odpočinek.',
          hoursAgo: 6),
    ],
  ),

  // 8. Jaroslav Seifert - 12, Male, 3 records, dust allergy
  TestParticipant(
    jmeno: 'Jaroslav',
    prijmeni: 'Seifert',
    pohlavi: 1,
    datumNarozeni: '2013-09-23',
    rodneCislo: '130923/9104',
    adresa: 'Žižkov 34, Praha 3',
    telefonRodice: '+420606789012',
    pojistovna: 'VZP',
    omezeni: [
      TestRestriction.alergie('Alergie na prach (knihy, staré prostory)'),
    ],
    zaznamy: [
      TestRecord(
          nazev: 'Říznutí papírem',
          popis: 'Papírové říznutí při psaní básní.',
          hoursAgo: 55),
      TestRecord(
          nazev: 'Únava očí',
          popis: 'Únava z četby při svitu baterky.',
          hoursAgo: 40),
      TestRecord(
          nazev: 'Bolest hlavy',
          popis: 'Tenze hlavy z dlouhého psaní.',
          hoursAgo: 20),
    ],
  ),

  // 9. Věra Čáslavská - 11, Female, 4 records, gymnastics limitation
  TestParticipant(
    jmeno: 'Věra',
    prijmeni: 'Čáslavská',
    pohlavi: 2,
    datumNarozeni: '2014-10-18',
    rodneCislo: '146018/5746',
    adresa: 'Roudnice n. L. 56',
    pojistovna: 'OZP',
    leky: [
      TestMedication(
          nazev: 'Voltaren gel',
          davkovani: 'Aplikovat na zápěstí',
          kdy: '2x denně'),
    ],
    omezeni: [
      TestRestriction.omezeni(
          'Gymnastika omezena na 2 týdny (zranění zápěstí)'),
    ],
    zaznamy: [
      TestRecord(
          nazev: 'Vykloubený zápěstí',
          popis: 'Lehké vykloubení při gymnastice. Voltaren aplikován.',
          hoursAgo: 60),
      TestRecord(
          nazev: 'Kroucení kotníku',
          popis: 'Natažení kotníku při cvičení.',
          hoursAgo: 45),
      TestRecord(
          nazev: 'Natažení svalů',
          popis: 'Natažení svalů stehna.',
          hoursAgo: 30),
      TestRecord(
          nazev: 'Dehydratace',
          popis: 'Nedostatek tekutin po intenzivním cvičení.',
          hoursAgo: 15),
    ],
  ),

  // 10. Franz Kafka - 11, Male, 13 records (existential)
  TestParticipant(
    jmeno: 'Franz',
    prijmeni: 'Kafka',
    pohlavi: 1,
    datumNarozeni: '2014-07-03',
    rodneCislo: '140703/9140',
    adresa: 'Dlouhá třída 39, Praha 1',
    telefonRodice: '+420607890123',
    pojistovna: 'VZP',
    leky: [
      TestMedication(
          nazev: 'Melatonin 3mg', davkovani: '1 tableta', kdy: 'Před spaním'),
      TestMedication(
          nazev: 'Rescue Remedy kapky',
          davkovani: '4 kapky pod jazyk',
          kdy: 'Při úzkosti'),
    ],
    zaznamy: [
      TestRecord(
          nazev: 'Existenciální úzkost',
          popis: 'Úzkost z táborové stravy. Doporučena konzultace.',
          hoursAgo: 100),
      TestRecord(
          nazev: 'Existenciální úzkost 2',
          popis: 'Pokračující úzkostné stavy.',
          hoursAgo: 92),
      TestRecord(
          nazev: 'Existenciální úzkost 3',
          popis: 'Další vlna úzkosti. Rescue Remedy podána.',
          hoursAgo: 85),
      TestRecord(
          nazev: 'Existenciální úzkost 4',
          popis: 'Obavy z absurdity života v táboře.',
          hoursAgo: 78),
      TestRecord(
          nazev: 'Nespavost',
          popis: 'Potíže se spánkem. Melatonin doporučen.',
          hoursAgo: 70),
      TestRecord(
          nazev: 'Nespavost 2',
          popis: 'Pokračující problémy s usínáním.',
          hoursAgo: 62),
      TestRecord(
          nazev: 'Nespavost 3',
          popis: 'Třetí noc špatného spánku.',
          hoursAgo: 54),
      TestRecord(
          nazev: 'Psychosomatická bolest břicha',
          popis: 'Bolest bez fyzické příčiny.',
          hoursAgo: 46),
      TestRecord(
          nazev: 'Psychosomatická bolest břicha 2',
          popis: 'Opakující se bolesti.',
          hoursAgo: 38),
      TestRecord(
          nazev: 'Bolest hlavy', popis: 'Tenze bolest hlavy.', hoursAgo: 30),
      TestRecord(
          nazev: 'Bolest hlavy 2',
          popis: 'Další den bolesti hlavy.',
          hoursAgo: 22),
      TestRecord(
          nazev: 'Obecná nevolnost',
          popis: 'Celková nevolnost bez jasné diagnózy.',
          hoursAgo: 14),
      TestRecord(
          nazev: 'Strach z jídla',
          popis: 'Strach z konzumace táborové stravy.',
          hoursAgo: 6),
    ],
  ),

  // 11. Antonín Dvořák - 10, Male, 8 records
  TestParticipant(
    jmeno: 'Antonín',
    prijmeni: 'Dvořák',
    pohlavi: 1,
    datumNarozeni: '2015-09-08',
    rodneCislo: '150908/7426',
    adresa: 'Nelahozeves 12, Mělník',
    pojistovna: 'VZP',
    leky: [
      TestMedication(
          nazev: 'Multivitamin', davkovani: '1 tableta', kdy: 'Ráno'),
      TestMedication(nazev: 'Omega-3', davkovani: '1 kapsle', kdy: 'S jídlem'),
    ],
    zaznamy: [
      TestRecord(
          nazev: 'Stesk po Novém světě',
          popis: 'Stesk po domově. Doporučena hudební terapie.',
          hoursAgo: 88),
      TestRecord(
          nazev: 'Stesk 2',
          popis: 'Pokračující stesk po domově.',
          hoursAgo: 75),
      TestRecord(
          nazev: 'Nedostatek spánku',
          popis: 'Komponoval v noci. Únava.',
          hoursAgo: 68),
      TestRecord(
          nazev: 'Nedostatek spánku 2',
          popis: 'Další noc málo spánku kvůli hudbě.',
          hoursAgo: 58),
      TestRecord(
          nazev: 'Podvýživa',
          popis: 'Zapomíná jíst kvůli skládání. Multivitamin doporučen.',
          hoursAgo: 48),
      TestRecord(
          nazev: 'Bolest hlavy', popis: 'Bolest z přepracování.', hoursAgo: 35),
      TestRecord(
          nazev: 'Bolest zad',
          popis: 'Špatné držení těla při psaní not.',
          hoursAgo: 25),
      TestRecord(
          nazev: 'Úzkost z vystoupení',
          popis: 'Nervozita z táborového koncertu.',
          hoursAgo: 10),
    ],
  ),

  // 12. Václav Havel - 10, Male, 1 record
  TestParticipant(
    jmeno: 'Václav',
    prijmeni: 'Havel',
    pohlavi: 1,
    datumNarozeni: '2015-10-05',
    rodneCislo: '151005/6427',
    adresa: 'Hrádek 1, Trutnov',
    telefonRodice: '+420608901234',
    pojistovna: 'VZP',
    zaznamy: [
      TestRecord(
        nazev: 'Pohmoždění kolena',
        popis: 'Pád z improvizovaného jeviště při divadelní improvizaci.',
        hoursAgo: 42,
      ),
    ],
  ),

  // 13. Ema Destinnová - 10, Female, 12 records, pollen allergy
  TestParticipant(
    jmeno: 'Ema',
    prijmeni: 'Destinnová',
    pohlavi: 2,
    datumNarozeni: '2015-02-26',
    rodneCislo: '155226/9939',
    adresa: 'Schwarzova 13, České Budějovice',
    pojistovna: 'OZP',
    leky: [
      TestMedication(
          nazev: 'Cetirizin 10mg', davkovani: '1 tableta', kdy: 'Večer'),
      TestMedication(
          nazev: 'Hlasové pastilky',
          davkovani: 'Každé 3 hodiny',
          kdy: 'Dle potřeby'),
    ],
    omezeni: [
      TestRestriction.alergie('Alergie na pyl (trávy, stromy)'),
      TestRestriction.omezeni('Hlasový klid nutný (laryngitida)'),
    ],
    zaznamy: [
      TestRecord(
          nazev: 'Bolest v krku',
          popis: 'Přetížení hlasivek z nadměrného zpěvu.',
          hoursAgo: 95),
      TestRecord(
          nazev: 'Bolest v krku 2',
          popis: 'Pokračující problémy s hlasem.',
          hoursAgo: 87),
      TestRecord(
          nazev: 'Bolest v krku 3',
          popis: 'Třetí den bolesti v krku.',
          hoursAgo: 79),
      TestRecord(
          nazev: 'Laryngitida',
          popis: 'Zánět hrtanu. Hlasový klid nařízen.',
          hoursAgo: 71),
      TestRecord(
          nazev: 'Laryngitida 2',
          popis: 'Pokračující laryngitida.',
          hoursAgo: 63),
      TestRecord(
          nazev: 'Alergická reakce na pyl',
          popis: 'Kýchání a slzení. Cetirizin podán.',
          hoursAgo: 55),
      TestRecord(
          nazev: 'Alergická reakce 2',
          popis: 'Další alergická reakce.',
          hoursAgo: 47),
      TestRecord(
          nazev: 'Dehydratace',
          popis: 'Nedostatek tekutin. Doporučeno zvýšení příjmu vody.',
          hoursAgo: 39),
      TestRecord(
          nazev: 'Hlasový klid',
          popis: 'Kontrola dodržování hlasového klidu.',
          hoursAgo: 31),
      TestRecord(
          nazev: 'Úzkost',
          popis: 'Nervozita z možného poškození hlasu.',
          hoursAgo: 23),
      TestRecord(
          nazev: 'Dušnost',
          popis: 'Dramatické potíže s dýcháním (psychosomatické).',
          hoursAgo: 15),
      TestRecord(
          nazev: 'Porucha spánku',
          popis: 'Potíže se spánkem z obav o hlas.',
          hoursAgo: 7),
    ],
  ),

  // 14. Jan Amos Komenský - 11, Male, 4 records
  TestParticipant(
    jmeno: 'Jan Amos',
    prijmeni: 'Komenský',
    pohlavi: 1,
    datumNarozeni: '2014-03-28',
    rodneCislo: '140328/4564',
    adresa: 'Přerov 78, Olomouc',
    pojistovna: 'OZP',
    zaznamy: [
      TestRecord(
          nazev: 'Stres z organizace',
          popis: 'Přílišná snaha organizovat vzdělávací akce.',
          hoursAgo: 65),
      TestRecord(
          nazev: 'Únava očí',
          popis: 'Únava z tvorby vzdělávacích plánů.',
          hoursAgo: 50),
      TestRecord(
          nazev: 'Opakované zatížení',
          popis: 'RSI z nadměrného psaní.',
          hoursAgo: 35),
      TestRecord(
          nazev: 'Stres 2',
          popis: 'Pokračující stres z výuky druhých.',
          hoursAgo: 18),
    ],
  ),

  // 15. Bedřich Smetana - 12, Male, 6 records, ear issues
  TestParticipant(
    jmeno: 'Bedřich',
    prijmeni: 'Smetana',
    pohlavi: 1,
    datumNarozeni: '2013-03-02',
    rodneCislo: '130302/3304',
    adresa: 'Litomyšl 9, Pardubice',
    telefonRodice: '+420609012345',
    pojistovna: 'VZP',
    leky: [
      TestMedication(
          nazev: 'Otipax kapky do uší',
          davkovani: '3 kapky do každého ucha',
          kdy: '2x denně'),
    ],
    zaznamy: [
      TestRecord(
          nazev: 'Infekce ucha',
          popis: 'Zánět středního ucha. Otipax kapky předepsány.',
          hoursAgo: 75),
      TestRecord(
          nazev: 'Infekce ucha 2',
          popis: 'Pokračující problémy.',
          hoursAgo: 65),
      TestRecord(
          nazev: 'Tinnitus',
          popis: 'Pískání v uších. Kontrola doporučena.',
          hoursAgo: 55),
      TestRecord(
          nazev: 'Test sluchu',
          popis: 'Preventivní kontrola sluchu.',
          hoursAgo: 45),
      TestRecord(
          nazev: 'Úzkost', popis: 'Strach z plynoucí řeky.', hoursAgo: 30),
      TestRecord(
          nazev: 'Pískání v uších',
          popis: 'Stížnost na pískání. Monitorováno.',
          hoursAgo: 15),
    ],
  ),
];

/// Jurský Park event definition
const jurskyParkEvent = (
  title: 'Jurský park',
  description: 'Dinosauří dobrodružství čeká! 🦖',
  dateFrom: '2025-07-10',
  dateTo: '2025-07-24',
  homeDirectory: 'jursky_park_2025',
);
