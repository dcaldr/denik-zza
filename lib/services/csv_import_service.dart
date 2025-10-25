import 'dart:typed_data';

import 'package:denik_zza/csv/csv_definitions.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_hold.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/input/text_tools.dart';
import 'package:denik_zza/services/models/csv_import_payload.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:denik_zza/utils/temp_csv_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Result bundle returned after loading a CSV file.
class CsvImportSession {
  CsvImportSession({
    required this.review,
    required this.personResult,
  });

  /// Structured data contract for the review UI.
  final CsvImportReview review;

  /// Original parser outcome with MemoryOsoba lists.
  final PersonResult personResult;

  /// Convenience view of rows that are eligible to pass (OK or WARN).
  List<PassingPersonEntry> get passingPersons => personResult.passingPersons;

  /// Count of rows considered passing (OK or WARN).
  int get passingCount => personResult.passingCount;
}

/// Aggregated outcome of a finalize operation.
class CsvFinalizeResult {
  CsvFinalizeResult({
    required this.approvedCount,
    required this.rejectedCount,
    required List<int> savedRowIndices,
    required List<CsvFinalizeFailure> failures,
  })  : savedRowIndices = List<int>.unmodifiable(savedRowIndices),
        failures = List<CsvFinalizeFailure>.unmodifiable(failures);

  /// Total number of rows that were marked as approved by the user.
  final int approvedCount;

  /// Total number of rows explicitly rejected by the user.
  final int rejectedCount;

  /// Indices of rows that were successfully persisted.
  final List<int> savedRowIndices;

  /// Information about rows that could not be persisted.
  final List<CsvFinalizeFailure> failures;

  /// Convenience getter for the number of saved rows.
  int get savedCount => savedRowIndices.length;

  /// Convenience getter for the number of failed rows.
  int get failedCount => failures.length;
}

/// Describes a single row that failed during finalize.
class CsvFinalizeFailure {
  CsvFinalizeFailure({
    required this.originalIndex,
    required this.message,
  });

  /// Row index from the original CSV (1-based).
  final int originalIndex;

  /// User-friendly error message in Czech.
  final String message;
}

/// Contract used by the UI layer to obtain CSV review data.
abstract class CsvReviewService {
  /// Loads a CSV file and prepares the review session.
  Future<CsvImportSession> loadCsv(String path);

  /// Loads CSV data using a platform-aware payload abstraction.
  Future<CsvImportSession> loadCsvFromPayload(CsvImportPayload payload);

  /// Recomputes a single review row using updated field values.
  Future<CsvReviewRow> reparseRow(Map<String, String?> updatedFields);

  /// Persists approved rows and reports failures while respecting user decisions.
  Future<CsvFinalizeResult> finalizeImport({
    required CsvImportSession session,
    required Map<int, CsvRowDecision> decisions,
  });

  /// Finds participants that appear to duplicate rows within the current review session.
  Future<Map<int, List<CsvDuplicateCandidate>>> findPotentialDuplicates({
    required CsvImportSession session,
  });
}

/// Service coordinating CSV parsing and review DTO generation.
class CsvImportService implements CsvReviewService {
  CsvImportService({InputParser Function()? parserFactory})
      : _parserFactory = parserFactory ?? InputParser.new,
        _logger = AppLogger.l {
    final CsvDefinitions definitions = CsvDefinitions();
    _columnKeyToIndex = _buildColumnKeyIndex(definitions.mainCsv);
  }

  final InputParser Function() _parserFactory;
  final Logger _logger;
  late final Map<String, int> _columnKeyToIndex;

  /// Loads a CSV file and returns both the structured review data and
  /// the legacy person result aggregation.
  @override
  Future<CsvImportSession> loadCsv(String path) async {
    final InputParser parser = _parserFactory();
    parser.filePath = path;
    await parser.getFile();
    final CsvImportReview? review = parser.review;
    final PersonResult? result = parser.result;
    if (review == null || result == null) {
      throw StateError('CSV parsing did not produce review data.');
    }
    return CsvImportSession(review: review, personResult: result);
  }

  @override
  Future<CsvImportSession> loadCsvFromPayload(CsvImportPayload payload) async {
    if (payload.hasPath) {
      return loadCsv(payload.path!);
    }

    final Uint8List? inMemoryBytes = payload.bytes;
    if (inMemoryBytes != null) {
      if (kIsWeb) {
        _logger.w(
          'CSV import via bytes is not supported on web yet. Display name: ${payload.displayName}',
        );
        throw UnsupportedError(
          'Načtení CSV souboru z paměti není ve webové verzi zatím podporováno.',
        );
      }

      String? tempPath;
      try {
        tempPath = await TempCsvStorage.writeBytes(
          inMemoryBytes,
          suggestedName: payload.displayName,
        );
        // TODO: cover bytes-to-temp flow in service tests (TASK-5.3).
        return await loadCsv(tempPath);
      } catch (error, stackTrace) {
        _logger.e(
          'Failed to load CSV from payload.',
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      } finally {
        if (tempPath != null) {
          try {
            await TempCsvStorage.deleteFile(tempPath);
          } catch (cleanupError, cleanupStack) {
            _logger.w(
              'Failed to delete temporary CSV file.',
              error: cleanupError,
              stackTrace: cleanupStack,
            );
          }
        }
      }
    }

    _logger.w(
      'CsvImportPayload missing both path and bytes. Display name: ${payload.displayName}',
    );
    throw ArgumentError('Nebyl poskytnut platný CSV soubor.');
  }

  /// Recomputes a single row using updated values supplied by the UI.
  /// Field keys must be normalized (lowercase, diacritics removed, spaces -> _).
  @override
  Future<CsvReviewRow> reparseRow(Map<String, String?> updatedFields) async {
    final InputParser parser = _parserFactory();
    final Map<int, String> sparseData = <int, String>{};
    updatedFields.forEach((String key, String? value) {
      final int? index = _columnKeyToIndex[key];
      if (index == null) {
        throw ArgumentError('Unknown column key: $key');
      }
      sparseData[index] = value?.trim() ?? '';
    });

    final Answer answer = await parser.parseLine(sparseData);
    final CsvImportReviewBuilder builder = CsvImportReviewBuilder(
      definition: parser.definition,
      missingColumnIndices: const <int>{},
      unparsedColumns: const <String>[],
    );
    final CsvImportReview review = builder.build(<Answer>[answer]);
    return review.rows.single;
  }

  @override
  Future<CsvFinalizeResult> finalizeImport({
    required CsvImportSession session,
    required Map<int, CsvRowDecision> decisions,
  }) async {
    final List<int> approvedIndices = decisions.entries
        .where((MapEntry<int, CsvRowDecision> entry) => entry.value == CsvRowDecision.approved)
        .map((MapEntry<int, CsvRowDecision> entry) => entry.key)
        .toList();
    final int rejectedCount = decisions.values
        .where((CsvRowDecision decision) => decision == CsvRowDecision.rejected)
        .length;

    if (approvedIndices.isEmpty) {
      return CsvFinalizeResult(
        approvedCount: 0,
        rejectedCount: rejectedCount,
        savedRowIndices: const <int>[],
        failures: const <CsvFinalizeFailure>[],
      );
    }

    final DatabaseInterface database = DatabaseWrapper.getDatabase();
    final InputParser parser = _parserFactory();
    final Map<int, CsvReviewRow> rowsByIndex = <int, CsvReviewRow>{
      for (final CsvReviewRow row in session.review.rows) row.originalIndex: row,
    };

    final List<int> savedRows = <int>[];
    final List<CsvFinalizeFailure> failures = <CsvFinalizeFailure>[];

    for (final int rowIndex in approvedIndices) {
      final CsvReviewRow? row = rowsByIndex[rowIndex];
      if (row == null) {
        failures.add(
          CsvFinalizeFailure(
            originalIndex: rowIndex,
            message: 'Řádek $rowIndex nebyl nalezen a nebyl uložen.',
          ),
        );
        continue;
      }

      try {
        final MemoryOsoba person = await _buildPersonFromRow(parser, row);
        final bool saved = await database.addOsoba(person);
        if (saved) {
          savedRows.add(rowIndex);
        } else {
          failures.add(
            CsvFinalizeFailure(
              originalIndex: rowIndex,
              message: 'Řádek $rowIndex se nepodařilo uložit do databáze.',
            ),
          );
        }
      } catch (error, stackTrace) {
        _logger.e(
          'Finalize import failed for row $rowIndex',
          error: error,
          stackTrace: stackTrace,
        );
        failures.add(
          CsvFinalizeFailure(
            originalIndex: rowIndex,
            message: 'Uložení řádku $rowIndex selhalo: ${error.toString()}',
          ),
        );
      }
    }

    return CsvFinalizeResult(
      approvedCount: approvedIndices.length,
      rejectedCount: rejectedCount,
      savedRowIndices: savedRows,
      failures: failures,
    );
  }

  @override
  Future<Map<int, List<CsvDuplicateCandidate>>> findPotentialDuplicates({
    required CsvImportSession session,
  }) async {
    if (session.review.rows.isEmpty) {
      return const <int, List<CsvDuplicateCandidate>>{};
    }

    final DatabaseInterface database = DatabaseWrapper.getDatabase();
    List<MemoryOsoba> existingParticipants = <MemoryOsoba>[];
    try {
      existingParticipants = await database.getParticipantsByCurrentEvent();
    } catch (error, stackTrace) {
      _logger.w(
        'Duplicate detection skipped because current event participants could not be loaded.',
        error: error,
        stackTrace: stackTrace,
      );
      return const <int, List<CsvDuplicateCandidate>>{};
    }

    if (existingParticipants.isEmpty) {
      return const <int, List<CsvDuplicateCandidate>>{};
    }

    final InputParser parser = _parserFactory();
    final Map<int, List<CsvDuplicateCandidate>> result = <int, List<CsvDuplicateCandidate>>{};

    for (final CsvReviewRow row in session.review.rows) {
      try {
        final MemoryOsoba candidate = await _buildPersonFromRow(parser, row);
        final List<CsvDuplicateCandidate> matches = <CsvDuplicateCandidate>[];
        for (final MemoryOsoba existing in existingParticipants) {
          // TODO: replace with DatabaseInterface-level comparator once available.
          final String? reason = _duplicateReason(candidate, existing);
          if (reason == null) {
            continue;
          }
          matches.add(
            CsvDuplicateCandidate(
              participantId: existing.id,
              displayName: _formatParticipantName(existing),
              reason: reason,
            ),
          );
        }
        if (matches.isNotEmpty) {
          result[row.originalIndex] = matches;
        }
      } catch (error, stackTrace) {
        _logger.w(
          'Skipping duplicate detection for row ${row.originalIndex} due to parse failure.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return result;
  }

  Future<MemoryOsoba> _buildPersonFromRow(InputParser parser, CsvReviewRow row) async {
    final Map<int, String> sparseData = <int, String>{};

    row.fields.forEach((String key, CsvFieldReview field) {
      final int? columnIndex = _columnKeyToIndex[key];
      if (columnIndex == null) {
        return;
      }
      final String? rawValue = field.originalValue?.trim();
      final String? formattedValue = field.normalizedValue?.trim();
      final String value =
          (rawValue != null && rawValue.isNotEmpty) ? rawValue : (formattedValue ?? '');
      sparseData[columnIndex] = value;
    });

    for (final CsvDerivedValue derived in row.derived.values) {
      final int? columnIndex = _columnKeyToIndex[derived.key];
      if (columnIndex == null) {
        continue;
      }
      final String existing = sparseData[columnIndex] ?? '';
      if (existing.isEmpty) {
        sparseData[columnIndex] = derived.value;
      }
    }

    final Answer answer = await parser.parseLine(sparseData);
    answer.originalIndex = row.originalIndex;
    final MemoryOsoba person = answer.toPerson();
    person.zpusobilost ??= false;
    person.bezinfekcnost ??= false;
    person.wasPrinted ??= false;
    return person;
  }

  String _formatParticipantName(MemoryOsoba person) {
    final String firstName = person.jmeno.trim();
    final String lastName = person.prijmeni.trim();
    final String base = '$firstName $lastName'.trim();
    final DateTime? birthDate = person.datumNarozeni;
    if (birthDate == null) {
      return base;
    }
    return '$base (${_formatDate(birthDate)})';
  }

  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}.${twoDigits(date.month)}.${date.year}';
  }

  String? _duplicateReason(MemoryOsoba imported, MemoryOsoba existing) {
    final String? importedRc = _normalized(imported.cisloPojisteni);
    final String? existingRc = _normalized(existing.cisloPojisteni);

    if (importedRc != null && importedRc.isNotEmpty && importedRc == existingRc) {
      return 'Stejné rodné číslo';
    }

    final bool sameNames = _normalized(imported.jmeno) == _normalized(existing.jmeno) &&
        _normalized(imported.prijmeni) == _normalized(existing.prijmeni);
    if (!sameNames) {
      return null;
    }

    final DateTime? importedBirth = imported.datumNarozeni;
    final DateTime? existingBirth = existing.datumNarozeni;
    if (importedBirth != null && existingBirth != null) {
      if (_isSameDate(importedBirth, existingBirth)) {
        return 'Stejné jméno a datum narození';
      }
    }

    if (_normalized(imported.telefonRodice) != null &&
        _normalized(imported.telefonRodice) == _normalized(existing.telefonRodice)) {
      return 'Stejné jméno a telefon zákonného zástupce';
    }

    return 'Stejné jméno a příjmení';
  }

  String? _normalized(String? value) {
    if (value == null) {
      return null;
    }
    return value.trim().toLowerCase();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static Map<String, int> _buildColumnKeyIndex(List<InputHold> columns) {
    final Map<String, int> map = <String, int>{};
    for (int i = 0; i < columns.length; i++) {
      final String key = _columnKey(columns[i].columnName);
      map[key] = i;
    }
    return map;
  }

  static String _columnKey(String columnName) {
    final String normalized = TextTools.normText(columnName);
    return normalized.replaceAll(RegExp(r'\s+'), '_');
  }
}
