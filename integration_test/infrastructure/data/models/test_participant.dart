import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';

import 'test_medication.dart';
import 'test_record.dart';
import 'test_restriction.dart';

/// Unified test participant data structure.
///
/// Used by both database seeders and UI robots. All datasets (Jurský Park,
/// Medium, Generated) use this same format for consistency.
///
/// Supports `copyWith()` for creating mutated copies in [ExpectedWorldState].
///
/// ## Usage:
/// ```dart
/// // Hardcoded data
/// const participant = TestParticipant(
///   jmeno: 'Karel',
///   prijmeni: 'Čapek',
///   pohlavi: 1,
///   datumNarozeni: '2009-01-09',
///   rodneCislo: '090109/0804',
///   pojistovna: 'VZP',
/// );
///
/// // Seeder usage
/// await database.addParticipant(participant.toCompanion(eventId, insuranceId));
///
/// // Robot usage
/// await robot.fillParticipantForm(participant);
///
/// // Mutated copy for ExpectedWorldState
/// final arrived = participant.copyWith(prisel: true);
/// ```
class TestParticipant {
  /// First name (required)
  final String jmeno;

  /// Last name (required)
  final String prijmeni;

  /// Gender: 1=male, 2=female
  final int pohlavi;

  /// Birthdate as ISO string 'YYYY-MM-DD' for const constructor compatibility
  final String datumNarozeni;

  /// Rodné číslo (Czech national ID) - must be valid format
  final String rodneCislo;

  /// Address (optional)
  final String? adresa;

  /// Parent phone number (optional, ~35% coverage)
  final String? telefonRodice;

  /// Parent email (optional)
  final String? emailRodice;

  /// Parent name (optional)
  final String? jmenoRodice;

  /// Insurance company name (resolved to ID at insert time)
  final String pojistovna;

  /// Medications list
  final List<TestMedication> leky;

  /// Restrictions (allergies type=2, limitations type=1)
  final List<TestRestriction> omezeni;

  /// Medical records
  final List<TestRecord> zaznamy;

  /// Infection-free certificate (bezinfekčnost)
  final bool bezinfekcnost;

  /// Fitness certificate (způsobilost)
  final bool zpusobilost;

  /// Arrival confirmation — set during intake phase
  final bool prisel;

  /// Note (poznámka) — set/modified during intake phase
  final String? poznamka;

  /// Print status — set after printing
  final bool wasPrinted;

  const TestParticipant({
    required this.jmeno,
    required this.prijmeni,
    required this.pohlavi,
    required this.datumNarozeni,
    required this.rodneCislo,
    this.adresa,
    this.telefonRodice,
    this.emailRodice,
    this.jmenoRodice,
    required this.pojistovna,
    this.leky = const [],
    this.omezeni = const [],
    this.zaznamy = const [],
    this.bezinfekcnost = false,
    this.zpusobilost = false,
    this.prisel = false,
    this.poznamka,
    this.wasPrinted = false,
  });

  /// Creates a copy with selected fields overridden.
  ///
  /// Used by [ExpectedWorldState] to evolve test data across phases.
  /// Nullable fields use `?? this.field` — we never need to reset to `null`
  /// in the E2E flow.
  TestParticipant copyWith({
    String? jmeno,
    String? prijmeni,
    int? pohlavi,
    String? datumNarozeni,
    String? rodneCislo,
    String? adresa,
    String? telefonRodice,
    String? emailRodice,
    String? jmenoRodice,
    String? pojistovna,
    List<TestMedication>? leky,
    List<TestRestriction>? omezeni,
    List<TestRecord>? zaznamy,
    bool? bezinfekcnost,
    bool? zpusobilost,
    bool? prisel,
    String? poznamka,
    bool? wasPrinted,
  }) {
    return TestParticipant(
      jmeno: jmeno ?? this.jmeno,
      prijmeni: prijmeni ?? this.prijmeni,
      pohlavi: pohlavi ?? this.pohlavi,
      datumNarozeni: datumNarozeni ?? this.datumNarozeni,
      rodneCislo: rodneCislo ?? this.rodneCislo,
      adresa: adresa ?? this.adresa,
      telefonRodice: telefonRodice ?? this.telefonRodice,
      emailRodice: emailRodice ?? this.emailRodice,
      jmenoRodice: jmenoRodice ?? this.jmenoRodice,
      pojistovna: pojistovna ?? this.pojistovna,
      leky: leky ?? this.leky,
      omezeni: omezeni ?? this.omezeni,
      zaznamy: zaznamy ?? this.zaznamy,
      bezinfekcnost: bezinfekcnost ?? this.bezinfekcnost,
      zpusobilost: zpusobilost ?? this.zpusobilost,
      prisel: prisel ?? this.prisel,
      poznamka: poznamka ?? this.poznamka,
      wasPrinted: wasPrinted ?? this.wasPrinted,
    );
  }

  /// Parse birthdate string to DateTime
  DateTime get birthDateTime => DateTime.parse(datumNarozeni);

  /// Convert to database companion for insertion.
  ///
  /// [eventId] - The event to assign this participant to
  /// [insuranceId] - The resolved insurance company ID (can be null)
  ParticipantsCompanion toCompanion(int eventId, int? insuranceId) {
    return ParticipantsCompanion(
      firstName: Value(jmeno),
      lastName: Value(prijmeni),
      gender: Value(pohlavi),
      birthDate: Value(birthDateTime),
      birthNumber: Value(rodneCislo),
      address: adresa != null ? Value(adresa) : const Value(null),
      parentPhoneNumber:
          telefonRodice != null ? Value(telefonRodice) : const Value(null),
      parentEmail: emailRodice != null ? Value(emailRodice) : const Value(null),
      parentName: jmenoRodice != null ? Value(jmenoRodice) : const Value(null),
      insuranceCompanyFK:
          insuranceId != null ? Value(insuranceId) : const Value(null),
      zzaActionFK: Value(eventId),
      eligibleConfirmation: Value(zpusobilost),
      nonInfectiousConfirmation: Value(bezinfekcnost),
      arrivedConfirmation: Value(prisel),
      wasPrinted: Value(wasPrinted),
      note: poznamka != null ? Value(poznamka) : const Value(null),
    );
  }

  /// Full name for display
  String get fullName => '$jmeno $prijmeni';

  @override
  String toString() => 'TestParticipant($fullName, $rodneCislo)';
}
