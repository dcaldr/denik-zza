# CSV Review Dev Launchers

Use the dev mains to try CSV review variants without touching production data. All entry points boot an in-memory database via `configureCsvReviewDevDatabase()`.

## Available entry points

- `lib/dev/dev_csv_import_flow.dart`
  - Launches the import-first flow with `CsvImportScreen`. Pick any CSV (e.g. `test/data/multi_person_with_extra_columns.csv`) to navigate into the review table and continue through finalize summary.
- `lib/dev/dev_csv_review_table_extra_columns.dart`
  - Opens the tabular overview directly using the sample CSV containing extra columns to stress column ordering and width handling.

## Running

```
flutter run -t lib/dev/dev_csv_import_flow.dart
```

```
flutter run -t lib/dev/dev_csv_review_table_extra_columns.dart
```

## Notes

- These launchers rely on local fixtures under `test/data/`; adjust the path or provide your own CSV if needed.
- Widgets expose stable keys so widget tests can target them directly.
- Drag-and-drop support for CSV selection remains marked as TODO on the import screen.
