# Implementation Plan - Phase 1: SystemInterface Facade

# Goal Description
To enable automated integration testing, we must abstract the native OS interactions ("Leaky Dependencies") that currently block the test runner. We will introduce a `SystemInterface` facade to swap the "Real" implementation (production) with a "Test" implementation (mock logic) at runtime.

**Strict Constraints:**
1.  **No Behavior Change:** The `RealSystemInterface` MUST strictly call the exact same underlying methods as the original code.
2.  **Unit Test Sanctity:** DO NOT Modify any files in `test/`. If a change breaks an existing test, the change is wrong. Revert and report.
3.  **Continuous Validation:** Run `flutter analyze` and `flutter test` after EACH step.

## User Review Required
> [!IMPORTANT]
> This refactor introduces a `SystemInterface` singleton.
>
> **Affected Files:**
> *   `lib/services/system/system_interface.dart` (**NEW**)
> *   `lib/screens2/csv/import_screen.dart`
> *   `lib/print_ops2/print_center.dart`
> *   `lib/utils/mode_coordinator.dart`

## Proposed Changes

### 1. System Service Layer
#### [NEW] [system_interface.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/lib/services/system/system_interface.dart)
Define the abstract contract and the production implementation.
*   **Validation:** Run `flutter analyze`.

```dart
abstract class SystemInterface {
  static SystemInterface _instance = RealSystemInterface();
  static SystemInterface get instance => _instance;

  // Injection for testing (Managed by ModeCoordinator)
  static void registerWith(SystemInterface implementation) {
    _instance = implementation;
  }

  Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
  });

  Future<void> printPdf({
    required String name,
    required Future<Uint8List> Function(PdfPageFormat) onLayout,
  });
}

class RealSystemInterface implements SystemInterface {
  @override
  Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
  }) {
    return FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
      withData: withData,
      withReadStream: withReadStream,
    );
  }

  @override
  Future<void> printPdf({
    required String name,
    required Future<Uint8List> Function(PdfPageFormat) onLayout,
  }) {
    return Printing.layoutPdf(onLayout: onLayout, name: name);
  }
}

class TestSystemInterface implements SystemInterface {
   // ... implementation of mocks (returning null or success)
}
```

### 2. Screen Refactoring (Surgical Replacement)
#### [MODIFY] [import_screen.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/lib/screens2/csv/import_screen.dart)
*   **Change:** `FilePicker.platform.pickFiles(...)` -> `SystemInterface.instance.pickFiles(...)`.
*   **Verify behavior:** Ensure ALL parameters (`type`, `allowedExtensions`, `withData`) are passed correctly.
*   **Validation:** `flutter analyze` (Must be clean) -> `flutter test` (Must pass).

#### [MODIFY] [print_center.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/lib/print_ops2/print_center.dart)
*   **Change:** `Printing.layoutPdf(...)` -> `SystemInterface.instance.printPdf(...)`.
*   **Validation:** `flutter analyze` (Must be clean) -> `flutter test` (Must pass).

### 3. Configuration
#### [MODIFY] [mode_coordinator.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/lib/utils/mode_coordinator.dart)
*   **Change:** `setTestingMode()` -> calls `SystemInterface.registerWith(TestSystemInterface())`.
*   **Validation:** `flutter analyze`.

## Verification Protocol
1.  **Analyze:** `dart run flutter_tools:analyze_code` (or strict `flutter analyze`).
2.  **Test:** `flutter test`.
    *   **IF FAIL:** Do **NOT** edit the test. Revert the code change. Analysis of the failure is required before proceeding.
3.  **Manual:** Run `lib/main.dart` -> Verify clicking Import/Print still opens system dialogs (since default is `RealSystemInterface`).
