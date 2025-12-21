import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';

/// Unified test medication data structure.
///
/// Used by both database seeders and UI robots.
class TestMedication {
  /// Medication name (required), e.g. "Ibalgin 400mg"
  final String nazev;

  /// Dosage description (optional), e.g. "1 tableta"
  final String? davkovani;

  /// When to take (optional), e.g. "Při bolesti", "Ráno", "Večer"
  final String? kdy;

  const TestMedication({
    required this.nazev,
    this.davkovani,
    this.kdy,
  });

  /// Convert to database companion for insertion.
  MedicationsCompanion toCompanion(int participantId) {
    return MedicationsCompanion(
      name: Value(nazev),
      dosage: davkovani != null ? Value(davkovani) : const Value(null),
      dosageTiming: kdy != null ? Value(kdy) : const Value(null),
      participantFK: Value(participantId),
      wasPrinted: const Value(false),
    );
  }

  @override
  String toString() => 'TestMedication($nazev)';
}
