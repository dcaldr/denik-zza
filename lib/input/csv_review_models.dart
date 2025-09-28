/// Severity levels for row and field messages shown in the CSV review UI.
class CsvReviewMessage {
  CsvReviewMessage({
    required this.severity,
    required this.message,
    this.code,
  });

  final CsvReviewMessageSeverity severity;
  final String message;
  final String? code;
}

/// Categorises a message for aggregation and UI styling.
enum CsvReviewMessageSeverity { info, warn, error }

/// Row status is the highest severity across all row and field messages.
///
/// Precedence: `rejected` > `warn` > `info` > `ok`.
enum CsvRowReviewStatus { ok, info, warn, rejected }

/// Field-level status derived from the original parser holds.
enum CsvFieldReviewStatus { ok, warn, bad, empty }

/// User's decision made during CSV review for a particular row.
enum CsvRowDecision { none, approved, rejected }

/// Represents a single field within the CSV review table.
class CsvFieldReview {
  CsvFieldReview({
    required this.columnKey,
    required this.columnName,
    required this.status,
    required this.originalValue,
    required this.normalizedValue,
    required this.inferred,
    this.messages = const <CsvReviewMessage>[],
  });

  final String columnKey;
  final String columnName;
  final CsvFieldReviewStatus status;
  final String? originalValue;
  final String? normalizedValue;
  final bool inferred;
  final List<CsvReviewMessage> messages;
}

/// Captures data derived from other fields (e.g. rodné číslo inference).
class CsvDerivedValue {
  CsvDerivedValue({
    required this.key,
    required this.value,
    required this.applied,
  });

  final String key;
  final String value;
  final bool applied;
}

/// A single CSV row prepared for review UI consumption.
class CsvReviewRow {
  CsvReviewRow({
    required this.originalIndex,
    required this.status,
    required this.messages,
    required this.fields,
    required this.derived,
  });

  final int originalIndex;
  final CsvRowReviewStatus status;
  final List<CsvReviewMessage> messages;
  final Map<String, CsvFieldReview> fields;
  final Map<String, CsvDerivedValue> derived;
}

/// Data contract consumed by the review/confirmation UI.
class CsvImportReview {
  CsvImportReview({
    required List<String> unparsedColumns,
    required List<CsvReviewRow> rows,
  })  : unparsedColumns = List.unmodifiable(unparsedColumns),
        rows = List.unmodifiable(rows);

  /// Columns present in CSV but ignored by the parser (for summary display).
  final List<String> unparsedColumns;

  /// Rows prepared for UI display with statuses, messages, and field metadata.
  final List<CsvReviewRow> rows;
}
