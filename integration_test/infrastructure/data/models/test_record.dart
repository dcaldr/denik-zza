import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';

/// Unified test medical record data structure.
///
/// Used by both database seeders and UI robots.
///
/// Time is stored as relative "hours ago" for flexibility - the actual
/// DateTime is calculated at insertion time using a base time.
class TestRecord {
  /// Record title (required), e.g. "Bolest hlavy"
  final String nazev;

  /// Record description (required), e.g. "Pacient si stěžoval na..."
  final String popis;

  /// Optional note
  final String? poznamka;

  /// Optional temperature reading
  final double? teplota;

  /// Hours before base time (for relative timing)
  /// Default 0 = "now"
  final int hoursAgo;

  const TestRecord({
    required this.nazev,
    required this.popis,
    this.poznamka,
    this.teplota,
    this.hoursAgo = 0,
  });

  /// Convert to database companion for insertion.
  ///
  /// [participantId] - The participant this record belongs to
  /// [paramedicId] - The paramedic who created the record
  /// [baseTime] - Reference time to calculate actual dateTime from hoursAgo
  RecordsCompanion toCompanion(
    int participantId,
    int paramedicId,
    DateTime baseTime,
  ) {
    return RecordsCompanion(
      title: Value(nazev),
      description: Value(popis),
      note: poznamka != null ? Value(poznamka) : const Value(''),
      temperature: teplota != null ? Value(teplota) : const Value(null),
      dateAndTime: Value(baseTime.subtract(Duration(hours: hoursAgo))),
      participantFK: Value(participantId),
      paramedicFK: Value(paramedicId),
      wasPrinted: const Value(false),
    );
  }

  @override
  String toString() => 'TestRecord($nazev, ${hoursAgo}h ago)';
}
