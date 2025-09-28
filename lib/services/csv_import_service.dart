import 'package:denik_zza/csv/csv_definitions.dart';
import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_hold.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/input/text_tools.dart';

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
}

/// Contract used by the UI layer to obtain CSV review data.
abstract class CsvReviewService {
  /// Loads a CSV file and prepares the review session.
  Future<CsvImportSession> loadCsv(String path);

  /// Recomputes a single review row using updated field values.
  Future<CsvReviewRow> reparseRow(Map<String, String?> updatedFields);
}

/// Service coordinating CSV parsing and review DTO generation.
class CsvImportService implements CsvReviewService {
  CsvImportService({InputParser Function()? parserFactory})
      : _parserFactory = parserFactory ?? InputParser.new {
    final CsvDefinitions definitions = CsvDefinitions();
    _columnKeyToIndex = _buildColumnKeyIndex(definitions.mainCsv);
  }

  final InputParser Function() _parserFactory;
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
