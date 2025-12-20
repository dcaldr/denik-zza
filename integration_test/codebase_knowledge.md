# Deep Codebase Knowledge Base (Integration Test Context)

This document captures low-level implementation details and "Knowledge Items" (KIs) discovered during the forensic audit of the codebase. These insights are critical for writing robust integration tests and avoiding "surprise" blockers.

## 1. Database & State Management
*   **KI-DB-1 (Resettable Singleton):** `DriftDatabaseConnector` is a "Resettable Lazy Singleton". It has a static `reset()` method (line 47) that closes the database connection.
    *   *Implication:* Integration tests **MUST** call `await DriftDatabaseConnector.reset()` in their `tearDown` phase to release the file lock on the SQLite file, ensuring the next test starts clean.
*   **KI-DB-2 (Side-Effect Creation):** The `addOsoba` method is not atomic. It attempts to resolve or create an `InsuranceCompany` before adding the participant.
    *   *Implication:* Tests validating "Add Participant" should also verify that the corresponding Insurance Company was correctly created/linked in the DB.

## 2. CSV Import Service
*   **KI-CSV-1 (Bytes vs. Files):** `DefaultCsvImportService` handles in-memory CSVs by writing them to a temporary file using `FileManager.writeTempCsvBytes` (line 140).
    *   *Implication:* Our `SystemInterface` mock must assume that the service *will* try to write to a temp file. We need to ensure the test environment allows this or that `FileManager` is properly mocked/redirected to a test-safe directory (handled by `ModeCoordinator`).
*   **KI-CSV-2 (Duplicate Detection):** Duplicate detection (line 294) is "strict". It flags a duplicate if:
    *   Birth Numbers match (exact).
    *   Name + Surname match (normalized).
    *   Name + BirthDate match.
    *   Name + Parent Phone match.
    *   *Implication:* Test scenarios should specifically target these 4 distinct duplicate conditions.

## 3. Intake Form Logic
*   **KI-INTAKE-1 (Active Widget):** The active Intake Form is `NewIntakeFormImproved` (`lib/screens2/intake_form_improved.dart`), not `OldIntakeForm`.
*   **KI-INTAKE-2 (Rebuild Strategy):** The form uses a `UniqueKey` (`_personAutocompleteKey`) to forcibly destroy and recreate the `IntakePersonRow` widget when clearing the form (line 83).
    *   *Implication:* You cannot rely on holding a reference to a `Finder` for the search field across a "Clear/Reset" action. You must re-find the widget after the tap.
*   **KI-INTAKE-3 (Controller Separation):** Logic is moved to `IntakeController`. Integration tests primarily test the *binding* between the UI and this controller, rather than the raw logic (which should be unit tested).

## 4. Printing Logic (The Complex Beast)
*   **KI-PRINT-1 (Three-Pass Append):** The "Append" (Dostisk) mode is computationally expensive. It generates the PDF **three times** (`analyzeAndBuildAppend` in `generate_pdf_template.dart`):
    1.  **Baseline:** Generates only printed records.
    2.  **Probe:** Adds one unprinted record to see if it causes a page break.
    3.  **Final:** Generates the masked document.
    *   *Implication:* Integration tests for "Append" mode will be slower. Set longer timeouts. The `TestSystemInterface` mock for `printing` is crucial here to avoid 3x native dialog summons.
*   **KI-PRINT-2 (Keys Exist):** The `PrintCenter` UI components have robust keys:
    *   `ValueKey('select-person')` - Personal list.
    *   `ValueKey('mode-preview')` - The main preview area.
    *   `ValueKey('post-confirm')` - The success state.
    *   *Implication:* Use `find.byKey()` for these screens instead of fragile text matching.

## 5. UI & Widget Properties
*   **KI-UI-KEY-GAP:** Use of `Key` is inconsistent.
    *   *Good:* `PrintCenter` uses specific ValueKeys.
    *   *Bad:* `ParticipantRegistrationForm` text fields rely on implied order or text labels.
    *   *Recommendation:* Future refactoring should add `Key('field_jmeno')` etc. For now, we will find by `LabelText`.
*   **KI-FOCUS-BUG:** Confirmed via `FIXME.md`. Widget tests miss focus loss.
    *   *Action:* Always use `await tester.tap(finder); await tester.enterText(finder, text);` pattern.

## 6. Permissions & Environment
*   **KI-ENV-1 (No Assets):** `pubspec.yaml` has no bundled CSV assets.
    *   *Action:* Tests must generate their own CSV content strings and write them to the mock file system.
*   **KI-ENV-2 (Clean Manifests):** No dangerous permissions (Camera/Location) are declared in `AndroidManifest.xml` or `Info.plist`, simplifying the "System Dialog" threat model to just FilePicker and Printing.

## 7. Localization & Strings (Micro-Friction)
*   **KI-L10N-1 (Inconsistent Case):** Button labels vary between "uložit" (lowercase) and "Uložit" (capitalized).
    *   *Action:* Do not rely on case-sensitive exact matches. Use `find.textContaining('ložit')` or verify the specific screen's implementation before writing the test.
*   **KI-L10N-2 (Locale Requirement):** `main.dart` forces `Locale('cs', 'CZ')`.
    *   *Action:* The test runner's `pumpWidget` must wrap the app in a `MaterialApp` with `GlobalMaterialLocalizations.delegate` and `supportedLocales: [Locale('cs', 'CZ')]`. Without this, date pickers and standard dialogs will default to English, potentially breaking logic that parses localized date strings.

## 8. Navigation Logic
*   **KI-NAV-1 (Standard Navigator):** The app uses standard `Navigator.push` (Stack-based), not GoRouter.
    *   *Implication:* `await tester.pumpAndSettle()` is effective for waiting for transitions. There are no complex deep-linking parsing delays.

## 9. Date & Text Parsing
*   **KI-DATE-1 (Robust Parsing):** `TextTools.myParseDate` supports `yyyy.mm.dd` and `dd.mm.yyyy` logic, and handles separators `[-/.\s]`.
    *   *Confidence:* We can safely use "12.05.2023" or "2023-05-12" in our CSV test data.

