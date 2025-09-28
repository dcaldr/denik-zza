import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ensures the dev CSV fixture for problematic rows exercises all severity
/// buckets (OK/INFO/WARN/REJECT) to support the CSV review demo mains.
void main() {
  test('dev_bad_import_fixture.csv surfaces mixed severities', () async {
  final InputParser parser = InputParser()..filePath = 'test/data/dev_bad_import_fixture.csv';

    await parser.getFile();
    final CsvImportReview? review = parser.review;
    final PersonResult? result = parser.result;

    expect(review, isNotNull, reason: 'Review payload should be generated');
    expect(result, isNotNull, reason: 'PersonResult should be generated');

  final List<CsvReviewRow> rows = review!.rows;
  expect(rows.length, 10, reason: 'Fixture should include 10 rows');

    final Map<CsvRowReviewStatus, int> counts = <CsvRowReviewStatus, int>{
      for (final CsvRowReviewStatus status in CsvRowReviewStatus.values) status: 0,
    };
    for (final CsvReviewRow row in rows) {
      counts[row.status] = counts[row.status]! + 1;
    }

    final List<String> rowSummaries = rows
        .map(
          (CsvReviewRow row) =>
              '#${row.originalIndex} ${row.status} -> ${row.messages.map((CsvReviewMessage message) => message.code ?? message.message).join('|')}',
        )
        .toList(growable: false);
    final String summary = 'Row statuses: ${rowSummaries.join('; ')}';

    expect(
      counts[CsvRowReviewStatus.ok],
      1,
      reason: 'Row status distribution: $counts. $summary',
    );
    expect(
      counts[CsvRowReviewStatus.info],
      1,
      reason: 'Row status distribution: $counts. $summary',
    );
    expect(
      counts[CsvRowReviewStatus.warn],
      6,
      reason: 'Row status distribution: $counts. $summary',
    );
    expect(
      counts[CsvRowReviewStatus.rejected],
      2,
      reason: 'Row status distribution: $counts. $summary',
    );

    expect(result!.passingPersons.length, 8, reason: 'Only rejected rows should be excluded from passingPersons');
  });
}
