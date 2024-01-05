// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: lines_longer_than_80_chars
//@formatter:off
import 'in_memory_structures_tmp/memory_osoba.dart';
/// Class holding dummy data for testing purposes.
///
/// This class holds testing data for development purposes.
/// None of the data are real and are not meant to be used in production.
class DummyData{
List<MemoryOsoba> osobnostiBard = [
  MemoryOsoba.dummyData("Jan", "Hus", DateTime(1369, 7, 6), "Husinec", "+420123456789", "Česká Pojišťovna", "123456789", 1),
  MemoryOsoba.dummyData("Jan", "Žižka", DateTime(1360, 5, 26), "Tábor", "+420678954321", "Generali", "432156789", 1),
  MemoryOsoba.dummyData("Božena", "Němcová", DateTime(1820, 2, 4), "Náměšť nad Oslavou", "+420789654321", "Všeobecná zdravotní pojišťovna", "654321789", 2),
  MemoryOsoba.dummyData("Alfons", "Mucha", DateTime(1860, 7, 24), "U žofíny", "+420987654321", "Zdravotní pojišťovna VZP", "321789654", 1),
  MemoryOsoba.dummyData("Antonín", "Dvořák", DateTime(1841, 9, 8), "Praha", "+420897654321", "Česká Pojišťovna", "543217896", 1),
  MemoryOsoba.dummyData("Klement", "Gottwald", DateTime(1896, 11, 23), "Holešov", "+420234567890", "Slavia pojišťovna", "908765432", 1),
  MemoryOsoba.dummyData("Václav", "Havel", DateTime(1936, 5, 5), "Praha", "+420345678901", "Česká Pojišťovna", "012345678", 1),
  MemoryOsoba.dummyData("Edvard", "Beneš", DateTime(1884, 5, 28), "Kolín", "+420456789012", "Generali", "123456789", 1),
  MemoryOsoba.dummyData("Miloš", "Zeman", DateTime(1944, 9, 28), "Zruč nad Sázavou", "+420567890123", "Česká Pojišťovna", "234567890", 1),
  MemoryOsoba.dummyData("Tomáš", "Garrigue Masaryk", DateTime(1850, 3, 7), "Hodonín", "+420678901234", "Všeobecná zdravotní pojišťovna", "345678901", 1),
  MemoryOsoba.dummyData("Jiří", "Třanovský", DateTime(1535, 2, 24), "Uherské Hradiště", "+420789012345", "Zdravotní pojišťovna VZP", "456789012", 1),
  MemoryOsoba.dummyData("Kryštof", "Harant z Polžic a Bezdružic", DateTime(1564, 6, 29), "Mladá Boleslav", "+420890123456", "Česká Pojišťovna", "567890123", 1),
  MemoryOsoba.dummyData("Karel", "IV. Jagellonský", DateTime(1471, 2, 14), "Königstein nad Nisou", "+420901234567", "Generali", "678901234", 1),
  MemoryOsoba.dummyData("František", "Palacký", DateTime(1798, 6, 14), "Hrabůvka", "+420912345678", "Česká Pojišťovna", "789012345", 1),
  MemoryOsoba.dummyData("Jan", "Ámos Komenský", DateTime(1592, 2, 28), "Nivnice", "+420923456789", "Generali", "890123456", 1),
  MemoryOsoba.dummyData("Eduard", "Hoffmann", DateTime(1822, 2, 29), "Mladá Boleslav", "+420934567890", "Všeobecná zdravotní pojišťovna", "901234567", 1),
  MemoryOsoba.dummyData("František", "Křižík", DateTime(1847, 7, 8), "Praha", "+420945678901", "Zdravotní pojišťovna VZP", "012345678", 1),
  MemoryOsoba.dummyData("Václav", "Havlíček", DateTime(1834, 12, 3), "Býškovice", "+420956789012", "Slavia pojišťovna", "123456789", 1),
  MemoryOsoba.dummyData("Jaroslav", "Heyrovský", DateTime(1850, 12, 20), "Praha", "+420967890123", "Česká Pojišťovna", "234567890", 1),
//  MemoryOsoba.dummyData("Edvard", "Beneš", DateTime(1884, 5, 28), "Kolín", "+420978901234", "Generali", "345678901", 1),
  // MemoryOsoba.dummyData("Miloš", "Zeman", DateTime(1944, 9, 28), "Zruč nad Sázavou", "+420990123456", "Česká Pojišťovna", "567890123", 1),

];

List<MemoryOsoba> osobnostiGpt = [
  MemoryOsoba.dummyData("Jan", "Hus", DateTime(1369, 7, 6), "Praha", "+420123456789", "VZP", "123456789", 1),
  MemoryOsoba.dummyData("Alfons", "Mucha", DateTime(1860, 7, 24), "Ivančice","+420987654321", "ČPZP", "987654321", 1),
  MemoryOsoba.dummyData("Emil", "Zátopek", DateTime(1922, 9, 19), "Kopřivnice", "+420111223344", "VoZP", "111223344", 1),
  MemoryOsoba.dummyData("Tomáš", "Bata", DateTime(1876, 4, 3), "Zlín", "+420555666777", "Uniqa", "555666777", 1),
  MemoryOsoba.dummyData("Božena", "Němcová", DateTime(1820, 2, 4), "Višňová", "+420999888777", "Generali", "999888777", 2),
  MemoryOsoba.dummyData("Karel", "Čapek", DateTime(1890, 1, 9), "Malé Svatoňovice", "+420333444555", "Kooperativa", "333444555", 1),
  MemoryOsoba.dummyData("Antonín", "Dvořák", DateTime(1841, 9, 8), "Nelahozeves", "+420666777888", "UNIQA", "666777888", 1),
  MemoryOsoba.dummyData("Bedřich", "Smetana", DateTime(1824, 3, 2), "Litomyšl", "+420777888999", "Pojišťovna České spořitelny", "777888999", 1),
  MemoryOsoba.dummyData("Jaroslav", "Hašek", DateTime(1883, 4, 30), "Prague", "+420222333444", "Kooperativa", "222333444", 1),
  MemoryOsoba.dummyData("Ema", "Destinnová", DateTime(1878, 2, 26), "Praha", "+420888999000", "VZP", "888999000", 2),
  MemoryOsoba.dummyData("Václav", "Havel", DateTime(1936, 10, 5), "Praha", "+420123123123", "ZPŠ", "123123123", 1),
  MemoryOsoba.dummyData("Milada", "Horáková", DateTime(1901, 12, 12), "Prague", "+420456456456", "Uniqa", "456456456", 2),
  MemoryOsoba.dummyData("Josef", "Mikoláš", DateTime(1785, 6, 30), "Brno", "+420789789789", "Kooperativa", "789789789", 1),
  MemoryOsoba.dummyData("Magdalena", "Dobromila Rettigová", DateTime(1785, 6, 20), "Německý Brod", "+420012012012", "Pojišťovna České spořitelny", "012012012", 2), // Další osobnosti...
  MemoryOsoba.dummyData("František", "Palacký", DateTime(1798, 6, 14), "Pacov", "+420234567890", "UNIQA", "234567890", 1),
//  MemoryOsoba.dummyData("Božena", "Němcová", DateTime(1820, 2, 4), "Višňová", "+420345678901", "Generali", "345678901", 2),
//  MemoryOsoba.dummyData("Antonín", "Dvořák", DateTime(1841, 9, 8), "Nelahozeves", "+420456789012", "UNIQA", "456789012", 1),
//  MemoryOsoba.dummyData("Bedřich", "Smetana", DateTime(1824, 3, 2), "Litomyšl","+420567890123", "Pojišťovna České spořitelny", "567890123", 1),
//  MemoryOsoba.dummyData("Jaroslav", "Hašek", DateTime(1883, 4, 30), "Prague","+420678901234", "Kooperativa", "678901234", 1),
//  MemoryOsoba.dummyData("Ema", "Destinnová", DateTime(1878, 2, 26), "Praha","+420789012345", "VZP", "789012345", 2),
//  MemoryOsoba.dummyData("Václav", "Havel", DateTime(1936, 10, 5), "Praha","+420890123456", "ZPŠ", "890123456", 1),
//  MemoryOsoba.dummyData("Milada", "Horáková", DateTime(1901, 12, 12), "Prague", "+420901234567", "Uniqa", "901234567", 2),
// MemoryOsoba.dummyData("Josef", "Mikoláš", DateTime(1785, 6, 30), "Brno", "+420123456789", "Kooperativa", "123456789", 1),
//  MemoryOsoba.dummyData("Magdalena", "Dobromila Rettigová", DateTime(1785, 6, 20), "Německý Brod", "+420234567890", "Pojišťovna České spořitelny", "234567890", 2),
  MemoryOsoba.dummyData("František", "Xaver Šalda", DateTime(1867, 5, 30), "Prague", "+420345678901", "VZP", "345678901", 1),
// MemoryOsoba.dummyData("Božena", "Vorlová", DateTime(1865, 4, 13), "Humpolec", "+420456789012", "Generali", "456789012", 2),
  MemoryOsoba.dummyData("Josef", "Jiří Kolár", DateTime(1914, 12, 24), "Protivín", "+420567890123", "UNIQA", "567890123", 1),
  MemoryOsoba.dummyData("Věra", "Chytilová", DateTime(1929, 2, 2), "Ostrava", "+420678901234", "Kooperativa", "678901234", 2),
  MemoryOsoba.dummyData("Jiří", "Menzel", DateTime(1938, 2, 23), "Prague", "+420789012345", "VZP", "789012345", 1),
  MemoryOsoba.dummyData("Věra", "Čáslavská", DateTime(1942, 5, 3), "Prague", "+420890123456", "ZPŠ", "890123456", 2),
  MemoryOsoba.dummyData("Václav", "Klaus", DateTime(1941, 6, 19), "Prague", "+420901234567", "Uniqa", "901234567", 1),
  MemoryOsoba.dummyData("Martina", "Navrátilová", DateTime(1956, 10, 18), "Prague", "+420123456789", "Kooperativa", "123456789", 2),
  MemoryOsoba.dummyData("Karel", "Gott", DateTime(1939, 7, 14), "Pilsen", "+420234567890", "VZP", "234567890", 1),
  MemoryOsoba.dummyData("Dana", "Zátopková", DateTime(1922, 9, 19), "Prague", "+420345678901", "Generali", "345678901", 2),
  MemoryOsoba.dummyData("Tomáš", "Rosický", DateTime(1980, 10, 4), "Prague", "+420456789012", "UNIQA", "456789012", 1),
  MemoryOsoba.dummyData("Karolína", "Plíšková", DateTime(1992, 3, 21), "Louny", "+420567890123", "Pojišťovna České spořitelny", "567890123", 2),
  MemoryOsoba.dummyData("Petr", "Čech", DateTime(1982, 5, 20), "Pilsen", "+420678901234", "Kooperativa", "678901234", 1),
  MemoryOsoba.dummyData("Eva", "Samková", DateTime(1993, 6, 28), "Vrchlabí", "+420789012345", "VZP", "789012345", 2),
  MemoryOsoba.dummyData("Jaromír", "Jágr", DateTime(1972, 2, 15), "Kladno", "+420890123456", "ZPŠ", "890123456", 1),
  MemoryOsoba.dummyData("Lucie", "Bílá", DateTime(1966, 4, 7), "Otrokovice", "+420901234567", "Uniqa", "901234567", 2),
  MemoryOsoba.dummyData("Pavel", "Nedvěd", DateTime(1972, 8, 30), "Prague", "+420123456789", "Kooperativa", "123456789", 1),
  MemoryOsoba.dummyData("Ester", "Ledecká", DateTime(1995, 7, 23), "Prague", "+420234567890", "VZP", "234567890", 2),
  MemoryOsoba.dummyData("Tomáš", "Halík", DateTime(1948, 6, 1), "Prague", "+420345678901", "Generali", "345678901", 1),
  MemoryOsoba.dummyData("Karolína", "Kurková", DateTime(1984, 2, 28), "Děčín", "+420456789012", "UNIQA", "456789012", 2),
  MemoryOsoba.dummyData("Dominik", "Hašek", DateTime(1965, 1, 29), "Pardubice", "+420567890123", "Pojišťovna České spořitelny", "567890123", 1),
];

//@formatter:on
List<MemoryOsoba> mergeAndRemoveDuplicates([List<List<MemoryOsoba>> lists = const []]) {
  // If no lists are provided, use osobnostiGpt and osobnostiBard as default
  if (lists.isEmpty) {
    lists = [osobnostiGpt, osobnostiBard];
  }

  print('Number of lists: ${lists.length}');

  var allOsobnosti = <MemoryOsoba>[];
  for (var list in lists) {
    allOsobnosti.addAll(list);
  }

  var uniqueOsobnosti = <MemoryOsoba>{};
  print ('Length of allOsobnosti: ${allOsobnosti.length}');

  for (var osoba in allOsobnosti) {
    var duplicate = uniqueOsobnosti.firstWhere(
      (uniqueOsoba) => uniqueOsoba.jmeno == osoba.jmeno && uniqueOsoba.prijmeni == osoba.prijmeni,
      orElse: () => MemoryOsoba.basic('', ''),
    );

    if (duplicate.jmeno.isEmpty && duplicate.prijmeni.isEmpty) {
      uniqueOsobnosti.add(osoba);
    }
  }

  print('Length of resulting list: ${uniqueOsobnosti.length}');

  return uniqueOsobnosti.toList();
}

  void detectDuplicates(List<MemoryOsoba> list) {
    var uniqueNames = <String>{};
    for (var osoba in list) {
      var fullName = '${osoba.jmeno} ${osoba.prijmeni}';
      if (!uniqueNames.add(fullName)) {
        print('Duplicate detected: $fullName');
      }
    }
  }

}