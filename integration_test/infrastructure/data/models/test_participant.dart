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
  });

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
      arrivedConfirmation: const Value(true),
      wasPrinted: const Value(false),
    );
  }

  /// Full name for display
  String get fullName => '$jmeno $prijmeni';

  @override
  String toString() => 'TestParticipant($fullName, $rodneCislo)';
}
