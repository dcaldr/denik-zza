import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';

/// Shared test infrastructure: paramedics, insurance companies, events.
///
/// Used by all seeders to ensure consistent test data.

//==============================================================================
// PARAMEDICS (2 total)
//==============================================================================

/// Test paramedic data structure.
class TestParamedic {
  final String jmeno;
  final String prijmeni;
  final String username;
  final String adresa;
  final String datumNarozeni; // ISO string 'YYYY-MM-DD'
  final String telefon;

  const TestParamedic({
    required this.jmeno,
    required this.prijmeni,
    required this.username,
    required this.adresa,
    required this.datumNarozeni,
    required this.telefon,
  });

  DateTime get birthDateTime => DateTime.parse(datumNarozeni);

  ParamedicsCompanion toCompanion() {
    return ParamedicsCompanion(
      firstName: Value(jmeno),
      lastName: Value(prijmeni),
      username: Value(username),
      address: Value(adresa),
      birthDate: Value(birthDateTime),
      phoneNumber: Value(telefon),
    );
  }
}

/// Default test paramedics (2)
const testParamedics = [
  TestParamedic(
    jmeno: 'Jana',
    prijmeni: 'Zdravotníková',
    username: 'zdravotnik_1',
    adresa: 'Tábor Jurský park, Česká republika',
    datumNarozeni: '1985-03-15',
    telefon: '+420723456789',
  ),
  TestParamedic(
    jmeno: 'Petr',
    prijmeni: 'Doktor',
    username: 'zdravotnik_2',
    adresa: 'Zdravotnická 42, Praha',
    datumNarozeni: '1990-06-20',
    telefon: '+420724567890',
  ),
];

//==============================================================================
// INSURANCE COMPANIES (5 total, 1 fake)
//==============================================================================

/// Insurance company names (resolved to IDs at insert time)
const testInsuranceCompanies = [
  'Všeobecná zdravotní pojišťovna', // VZP - real
  'Oborová zdravotní pojišťovna', // OZP - real
  'Česká průmyslová zdravotní pojišťovna', // ČPZP - real
  'Zaměstnanecká pojišťovna Škoda', // ZPŠ - real
  'Neexistující Pojišťovna s.r.o.', // FAKE - test non-existing
];

/// Short names for convenience
const insuranceShortNames = {
  'VZP': 'Všeobecná zdravotní pojišťovna',
  'OZP': 'Oborová zdravotní pojišťovna',
  'ČPZP': 'Česká průmyslová zdravotní pojišťovna',
  'ZPŠ': 'Zaměstnanecká pojišťovna Škoda',
  'FAKE': 'Neexistující Pojišťovna s.r.o.',
};

//==============================================================================
// HELPER FUNCTIONS
//==============================================================================

/// Creates all test paramedics and returns their IDs.
Future<List<int>> createTestParamedics(AppDatabase database) async {
  final ids = <int>[];
  for (final p in testParamedics) {
    final id = await database.addParamedic(p.toCompanion());
    ids.add(id);
  }
  return ids;
}

/// Creates all test insurance companies and returns map of name → ID.
Future<Map<String, int>> createTestInsuranceCompanies(
    AppDatabase database) async {
  final map = <String, int>{};
  for (final name in testInsuranceCompanies) {
    final id = await database.addInsuranceCompany(
      InsuranceCompaniesCompanion(name: Value(name)),
    );
    map[name] = id;
  }
  // Also add short name mappings
  for (final entry in insuranceShortNames.entries) {
    if (map.containsKey(entry.value)) {
      map[entry.key] = map[entry.value]!;
    }
  }
  return map;
}

/// Creates a test event and returns its ID.
Future<int> createTestEvent(
  AppDatabase database, {
  required String title,
  String? description,
  required DateTime dateFrom,
  required DateTime dateTo,
  String? homeDirectory,
}) async {
  return await database.addZzaAction(
    ZzaActionsCompanion(
      actionTitle: Value(title),
      actionDescription:
          description != null ? Value(description) : const Value(null),
      dateFrom: Value(dateFrom),
      dateTo: Value(dateTo),
      homeDirectory:
          homeDirectory != null ? Value(homeDirectory) : const Value(null),
    ),
  );
}
