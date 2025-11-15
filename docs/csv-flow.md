# CSV Import Flow

This document describes the current single-file CSV import experience, the developer entry points, and the supporting test coverage.

## Overview

1. **Import screen** (`CsvImportScreen`)
   - Uses `file_picker` to select a single CSV file.
   - Validates the extension and prepares a `CsvImportPayload` that carries both the display name and data source (path or bytes).
   - Navigates to the review table once a payload is ready.
2. **Table overview** (`CsvReviewTableOverviewScreen`)
   - Reuses the existing review controller with the new payload support.
   - Shows the chosen filename in the header and exposes the finalize action.
3. **Summary screen** (`CsvImportSummaryScreen`)
   - Displays counts for approved, rejected, saved, and failed rows.
   - Lists individual failures when present and provides a shortcut back to the import screen.

## Developer entry points

Use the dev mains under `lib/dev/` with an in-memory database so production data stays untouched.

```
flutter run -t lib/dev/dev_csv_import_flow.dart
```
> Runs the full import-first flow starting with `CsvImportScreen`.

```
flutter run -t lib/dev/dev_csv_review_table_extra_columns.dart
```
> Opens the table overview directly with the extra-columns fixture for layout checks.

Both launchers default to `test/data/multi_person_with_extra_columns.csv`. Provide your own CSV by adjusting the path or using the picker.

## Testing

Targeted widget tests cover the import and summary screens, and a service test exercises the payload-to-temp-file logic:

- `test/csv_review_variants/csv_import_screen_widget_test.dart`
- `test/csv_review_variants/csv_import_summary_widget_test.dart`
- `test/services/csv_import_service_payload_test.dart`

Run all suites with:

```
flutter test test/csv_review_variants/csv_import_screen_widget_test.dart \
  test/csv_review_variants/csv_import_summary_widget_test.dart \
  test/services/csv_import_service_payload_test.dart
```

## Known follow-ups

- Drag-and-drop CSV selection on desktop/web remains a TODO (see `CsvImportScreen`).
- Coverage for finalize navigation back into main app will be revisited once post-summary routing is finalized.
