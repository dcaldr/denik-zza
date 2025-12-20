# Implementation Plan - Phase 1: SystemInterface Facade

# Goal Description
To enable automated integration testing, we must abstract the native OS interactions ("Leaky Dependencies") that currently block the test runner. Specifically, `FilePicker` and `Printing` trigger system dialogs that cannot be controlled by Flutter code.

We will introduce a `SystemInterface` facade that allows us to swap the "Real" implementation (production) with a "Test" implementation (mock logic) at runtime.

## User Review Required
> [!IMPORTANT]
> This refactor introduces a new singleton `SystemInterface.instance`. While generally discouraged, it is the most pragmatic solution for this codebase (Provider-based) to avoid rewriting the entire dependency injection tree immediately.
>
> **Affected Files:**
> *   `lib/screens2/csv/import_screen.dart` (Will now use `SystemInterface` instead of `FilePicker.platform`)
> *   `lib/print_ops2/print_center.dart` (Will now use `SystemInterface` instead of `Printing.layoutPdf`)
> *   `lib/services/system/system_interface.dart` (**NEW**)
> *   `lib/utils/mode_coordinator.dart` (Will manage the mock injection)

## Proposed Changes

### System Service Layer
#### [NEW] [system_interface.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/lib/services/system/system_interface.dart)
A new abstract class defining the contract for OS interactions:
```dart
abstract class SystemInterface {
  static SystemInterface _instance = RealSystemInterface();
  static SystemInterface get instance => _instance;

  // Injection for testing
  static void registerWith(SystemInterface implementation) { ... }

  Future<FilePickerResult?> pickFiles({...});
  Future<void> printPdf({required Future<Uint8List> Function(PdfPageFormat) onLayout, ...});
}
```
Implementation of `RealSystemInterface` (wraps actual packages) and `TestSystemInterface` (mocks).

### Screen Refactoring
#### [MODIFY] [import_screen.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/lib/screens2/csv/import_screen.dart)
*   Replace `FilePicker.platform.pickFiles(...)` with `SystemInterface.instance.pickFiles(...)`.

#### [MODIFY] [print_center.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/lib/print_ops2/print_center.dart)
*   Replace `Printing.layoutPdf(...)` with `SystemInterface.instance.printPdf(...)`.

### Configuration
#### [MODIFY] [mode_coordinator.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/lib/utils/mode_coordinator.dart)
*   Update `setTestingMode()` to inject `TestSystemInterface`.

## Verification Plan

### Automated Tests
*   **Verification:** Run `flutter test test/system_interface_test.dart` (Mock verification logic).
*   *Note:* Since we are creating the infrastructure *for* integration tests, we verify this primarily by ensuring the app still runs in Dev Mode.

### Manual Verification
1.  **Dev Mode Check:** Run `lib/main_UI_dev.dart` (or standard main).
2.  **Import:** Click "Import CSV". Verify the native file picker STILL opens (Real implementation active).
3.  **Print:** Click "Print". Verify the native print preview STILL opens.
4.  **Test Mode Check:** (Later) Verify that running in test mode does *not* open these dialogs.
