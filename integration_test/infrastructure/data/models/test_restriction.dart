import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';

/// Unified test restriction data structure (covers both allergies and limitations).
///
/// Used by both database seeders and UI robots.
///
/// Type values:
/// - `1` = Omezení (limitation)
/// - `2` = Alergie (allergy)
class TestRestriction {
  /// Restriction description (required), e.g. "Alergie na latex"
  final String popis;

  /// Type: 1=omezení, 2=alergie
  final int typ;

  const TestRestriction({
    required this.popis,
    required this.typ,
  });

  /// Convenience constructor for limitations (typ=1)
  const TestRestriction.omezeni(this.popis) : typ = 1;

  /// Convenience constructor for allergies (typ=2)
  const TestRestriction.alergie(this.popis) : typ = 2;

  /// Whether this is an allergy (typ=2)
  bool get isAlergie => typ == 2;

  /// Whether this is a limitation (typ=1)
  bool get isOmezeni => typ == 1;

  /// Convert to database companion for insertion.
  AllergiesLimitationsCompanion toCompanion(int participantId) {
    return AllergiesLimitationsCompanion(
      description: Value(popis),
      type: Value(typ),
      participantFK: Value(participantId),
      wasPrinted: const Value(false),
    );
  }

  @override
  String toString() =>
      'TestRestriction(${isAlergie ? "alergie" : "omezení"}: $popis)';
}
