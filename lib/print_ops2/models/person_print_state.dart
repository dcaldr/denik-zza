import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:collection/collection.dart'; // For list equality

/// Holds the print state for a single participant and their records.
///
/// Used by [PrintStateController] to provide a complete view of
/// a person's print status for the state management UI.
class PersonPrintState {
  final MemoryOsoba person;
  final List<MemoryZaznam> records;

  /// Whether append mode is possible for this person.
  final bool appendPossible;

  /// Whether the record sequence has issues (broken contiguous prefix).
  final bool hasSequenceIssue;

  const PersonPrintState({
    required this.person,
    required this.records,
    required this.appendPossible,
    required this.hasSequenceIssue,
  });

  /// Number of records with isPrinted == true.
  int get printedRecordCount => records.where((r) => r.isPrinted).length;

  /// Total number of records.
  int get totalRecordCount => records.length;

  /// Whether the person header has been printed.
  bool get personPrinted => person.wasPrinted ?? false;

  /// Display name for the person.
  String get displayName => '${person.jmeno} ${person.prijmeni}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is PersonPrintState &&
        other.person == person &&
        listEquals(other.records, records) &&
        other.appendPossible == appendPossible &&
        other.hasSequenceIssue == hasSequenceIssue;
  }

  @override
  int get hashCode =>
      person.hashCode ^
      const DeepCollectionEquality().hash(records) ^
      appendPossible.hashCode ^
      hasSequenceIssue.hashCode;
}
