# Integration Test Readiness Report & Bridging Plan

## 1. Executive Summary
The codebase requires specific architectural refactoring to enable the proposed Integration Testing Strategy. While the general strategy is sound, the current implementation of system-level interactions (File Picking, Printing) prevents automated testing because these actions trigger native OS dialogs that the test runner cannot control.

**Action Required:** Execute the Bridging Plan (Section 5) to introduce "Test Seams" before writing the first test.

## 2. Codebase Gap Analysis

| Feature | Current Implementation | Testing Blocker | Strategy Alignment |
| :--- | :--- | :--- | :--- |
| **File Import** | `CsvImportScreen` calls `FilePicker.platform.pickFiles()` directly. | Opens native file explorer. Test runner hangs. | **fail** (Requires Mocking) |
| **Printing** | `PrintCenterController` invokes `Printing.layoutPdf()` via UI flow. | Opens native print preview. Test runner hangs. | **fail** (Requires Mocking) |
| **Data Setup** | `DevEnvironment` (in `lib/dev/`) exists for manual dev apps. | `DevEnvironment` is "quick and dirty" and not suitable for rigorous integration tests. | **fail** (Need dedicated Seeders) |
| **Infrastructure** | No `integration_test/infrastructure` folder. | No distinct separation between test logic and app code. | **fail** (Missing Robots) |

## 3. The "Mocking Gap" (Detailed)

### 3.1. File Picker
*   **Location:** `lib/screens2/csv/import_screen.dart` (Line 181).
*   **Issue:** Direct static call to `FilePicker.platform`.
*   **Constraint:** Integration tests cannot interact with the window named "Open File" that Windows/OS launches.

### 3.2. Printing
*   **Location:** `lib/print_ops2/print_center.dart` (invokes `Printing.layoutPdf`).
*   **Issue:** Triggers the native print dialog/preview overlay.
*   **Constraint:** Integration tests cannot tap "Print" or "Cancel" on this native overlay.

### 3.3. Deep Codebase Audit Findings (8-Pass Analysis)
A dedicated, multi-pass forensic audit was conducted to ensure no surprises during testing:

*   **Pass 1-3 (Blockers & Concurrency):**
    *   **Native OS Calls:** Confirmed direct calls to `FilePicker.platform.pickFiles` (Import Screen) and `Printing.layoutPdf` (Print Center). These are hard blockers.
    *   **State Persistence:** `ModeCoordinator` correctly isolates Database and FileManager modes.
    *   **Async Safety:** No unclosed `Timer.periodic` or dangerous `Stream` listeners found.

*   **Pass 4-6 (Forensic & Scope):**
    *   **Code Evidence:** `lib/services/csv_import_service.dart` explicitly contains a `TODO: cover bytes-to-temp flow`, validating our mocking plan.
    *   **State Leakage:** `CsvReviewPrototypeController` is **safe** (ephemeral, not singleton). `ModeCoordinator` does not track it, but the widget lifecycle handles disposal correctly.
    *   **Critical Warning (KI-1):** `FIXME.md` warns that `tester.enterText()` bypasses focus logic.

*   **Pass 7-8 (Environment):**
    *   **Permissions:** `AndroidManifest.xml` and `Info.plist` are clean. No hidden system dialogs.
    *   **Assets:** No CSV test assets in `pubspec.yaml`. **Decision:** We will dynamically generate test CSVs in code instead of relying on fragile asset paths.
    *   **Dependencies:** `integration_test` dependency is assumed but must be explicitly verified in the test runner context.

## 4. Key Insights (KIs) & Recommendations

*   **KI-1 (Focus Logic):** Unit tests currently miss focus bugs. Integration tests **MUST** use `tester.tap()` before `enterText`, or `simulateKeyEvent`, to accurately reproduce user input flow.
*   **KI-2 (State Reset):** `ModeCoordinator` manages backend state, but UI state relies on navigation. Tests should always start from a fresh "Home" state to ensure clean UI controllers.
*   **KI-3 (Data Generation):** Do not rely on "bundled" assets. Generate dynamic test data (CSVs) into the isolated test directory managed by `ModeCoordinator`.

## 5. Bridging Plan (The Prerequisite Tasks)

This plan must be executed **before** implementing the strategy's "Protected Flow".

### Phase 1: The `SystemInterface` Facade (Code Refactor)
We will wrap the "leaky" libraries behind a facade that we can swap out during tests.

1.  **Create `SystemInterface` abstract class:**
    *   `Future<FilePickerResult?> pickFiles(...)`
    *   `Future<void> printPdf(...)`
2.  **Implement `RealSystemInterface`:** Calls the actual `FilePicker` and `Printing` packages.
3.  **Implement `TestSystemInterface`:**
    *   `pickFiles`: Returns a pre-configured in-memory CSV file immediately.
    *   `printPdf`: Awaits for 100ms and returns success (simulating a print job sent).
4.  **Inject the Interface:**
    *   Since the app uses `Provider` (not Riverpod), we will use a **Singleton approach** for `SystemInterface.instance` initially to minimize refactoring impact.
    *   Update `CsvImportScreen` and `PrintCenter` to use `SystemInterface.instance` instead of static calls.

### Phase 2: Dedicated Test Data (Infrastructure)
*   **Ignore `DevEnvironment`:** Do not refactor or depend on `lib/dev/dev_environment.dart`. It serves a different purpose (manual dev tools).
*   **Create `SimulationProfile`:**
    *   Build `integration_test/infrastructure/data/simulation_profiles.dart`.
    *   Implement **pure** seeders that populate the `Drift` database cleanly using `DriftDatabaseConnector` or direct DB access.
    *   **Goal:** `await seed(SimulationProfile.minimal)` should result in a predictable DB state in <50ms.

### Phase 3: Directory Setup
Create the physical structure to match the strategy:
```text
integration_test/
├── infrastructure/
│   ├── data/ (Seeders, TestVectors)
│   ├── robots/ (BaseRobot, PageObjects)
│   └── scenarios/ (Reused logic)
└── tests/
    └── protected_flow/
```

## 6. Next Steps recommendation
1.  **Approve Phase 1:** Authorize the creation of `SystemInterface` and the refactoring of `import_screen.dart` and `print_center.dart`.
2.  **Verify:** Once refactored, run the app in "Dev Mode" to ensure the new interface works manually.
3.  **Proceed to Testing:** Only after this seam is established, begin writing `protected_flow`.
