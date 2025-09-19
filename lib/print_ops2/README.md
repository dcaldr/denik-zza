# print_ops2 — Multi-page append printing

This module implements the three-pass multi-page append algorithm used by the Deník ZZA printing system.

Overview
- Three-pass algorithm (implemented in `GeneratePdfTemplate.analyzeAndBuildAppend`):
  1. Baseline pass — render only printed content to determine existing page count.
  2. Probe pass — add the first unprinted record to detect whether it fits on the last page.
  3. Final pass — render all content with header/footer adjustments and produce final PDF bytes.

Key files
- `generate_pdf_template.dart` — core algorithm and PDF generation helpers.
- `print_pdf_records.dart` — renders record sections. Note: `buildRecordsList(..., forMultiPage: true)` avoids `pw.Expanded` so it is safe inside `pw.MultiPage`.
- `print_center_controller.dart` — exposes `analyzeAppendScenario()` to UI and holds analysis state.
- `print_center_service.dart` — service-layer wrappers for updating printed flags in the DB.
- `widgets/append_analysis_widget.dart` — UI component for displaying analysis results with user-friendly Czech descriptions.

Tests
- Comprehensive test coverage for the append analysis and multi-page printing is located under `test/`:
  - `test/multipage_append_test.dart` — unit tests for `AppendAnalysis` behavior and descriptions.
  - `test/multipage_integration_test.dart` — integration tests that exercise controller analysis and DB persistence.
  - `test/multipage_persistence_ext_test.dart` — extended persistence and edge-case tests (first-print behavior, canAppend checks, empty multi-update).
  - `test/multipage_comprehensive_edge_cases_test.dart` — comprehensive edge cases including:
    - Complex printing workflows (partial print → append scenarios)
    - Record size and page boundary testing  
    - Error handling and recovery scenarios
    - Concurrent operations and state consistency
    - Real-world camp medical officer workflow simulations

Total test coverage: 22 tests covering unit, integration, persistence, and edge-case scenarios.

Notes
- Widgets must not access the database directly. Use `PrintCenterService` from widgets via `PrintCenterController` (see project rules).
- The module uses `Logger` instead of `print()` for diagnostics.

How to run the tests (developer machine)
- From project root, run the standard Flutter/Dart test runner used by the project. Tests use the same helpers as other DB tests (`HardcodedTestSetup`).

If you add or refactor the PDF layout, remember to keep `buildRecordsList(..., forMultiPage: true)` free of `pw.Expanded`.
