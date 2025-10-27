# FIXME: CSV Review Flow Gaps

- Only dev utilities (see `lib/dev/dev_csv_review_picker.dart`) provide a CSV picker. The production `screens2` flow launches review screens directly, so a first-class "Vyberte soubor" upload step is missing.
- Finalization happens inside `CsvReviewScreen` using `FinalizeCard` dialogs. There is no dedicated confirmation/summary page once import decisions are applied.
- Follow-up: decide where these screens should live in the main navigation, design UX for them, and hook them into the existing `CsvReviewPrototypeController` flow.
