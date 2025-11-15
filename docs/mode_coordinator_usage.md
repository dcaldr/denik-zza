# ModeCoordinator Usage Guide

## Overview

`ModeCoordinator` provides centralized control for switching application modes. It synchronizes `DatabaseWrapper` and `FileManager` to ensure they always use compatible modes.

**File**: `lib/utils/mode_coordinator.dart`  
**Lines**: ~150 (lightweight!)

---

## Available Modes

| Mode | Database | File Operations | Use Case |
|------|----------|-----------------|----------|
| **testing** | In-memory | None (in-memory) | Fast unit/widget tests |
| **integrationTest** | In-memory | Real files in isolated dir | Integration tests needing file verification |
| **debug** | File-based | Real files in test_outputs/ | Debugging with persistence |
| **production** | File-based | Real files in Documents/DenikZZA/ | Real app |

---

## Usage Examples

### Unit Tests (Fast, In-Memory)

```dart
import 'package:denik_zza/utils/mode_coordinator.dart';

void main() {
  group('MyService Tests', () {
    setUp(() {
      ModeCoordinator.setTestingMode(); // In-memory everything
    });
    
    tearDown(() {
      ModeCoordinator.resetToProduction();
    });
    
    test('service works', () {
      // Test runs fast with in-memory database
      final service = MyService();
      // ...
    });
  });
}
```

### Integration Tests (With Real Files)

**When to use**: Testing PDF generation, file uploads, or any feature that needs real file system operations.

```dart
// integration_test/file_operations_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('File Operations', () {
    setUp(() async {
      // Each test gets isolated directory:
      // Documents/DenikZZA/integration_test_output/pdf_generation_test/
      await ModeCoordinator.setIntegrationTestMode(
        testName: 'pdf_generation_test',
      );
    });
    
    tearDown(() {
      ModeCoordinator.resetToProduction();
    });
    
    testWidgets('generates PDF successfully', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // Trigger PDF generation - writes to isolated test directory
      await tester.tap(find.text('Generate PDF'));
      await tester.pumpAndSettle();
      
      // Verify PDF exists in test directory
      // (not in production directory!)
    });
  });
}
```

### Debug Mode (Persistent Test Data)

**When to use**: Debugging tests where you want to inspect the database and files afterward.

```dart
void main() {
  setUp(() async {
    await ModeCoordinator.setDebugMode(testName: 'debug_session');
    // Creates: test_outputs/debug_session/
    // Database and files persist after test completes
  });
  
  tearDown(() {
    // DON'T reset to production - keep files for inspection
    // ModeCoordinator.resetToProduction(); // Skip this!
  });
  
  test('debug this behavior', () {
    // After test runs, check test_outputs/debug_session/ for data
  });
}
```

### Production App

```dart
// lib/main.dart
void main() {
  ModeCoordinator.setProductionMode(); // Ensure production mode
  runApp(MyApp());
}
```

---

## Integration Test Directory Structure

When using `setIntegrationTestMode`, files are organized:

```
Documents/
  DenikZZA/                           # Production data (untouched)
    backup/
    zpusobilosti/
    vysetreni/
  
  DenikZZA/integration_test_output/   # Test data (isolated)
    test_name_1/                       # Each test gets own folder
      backup/
      zpusobilosti/
      vysetreni/
    test_name_2/
      backup/
      ...
```

### Cleanup (Optional, for CI/CD)

```dart
// Clean up all integration test outputs
await ModeCoordinator.cleanupIntegrationTestOutputs();
```

---

## Benefits

✅ **Single Point of Control**: One call switches everything  
✅ **Guaranteed Synchronization**: Database and FileManager always match  
✅ **Clear Intent**: Mode name indicates purpose  
✅ **Test Isolation**: Integration tests don't corrupt production data  
✅ **Future-Proof**: Integration test mode ready for when you need it  

---

## Comparison: Old vs New

### Before (Multiple Systems)

```dart
// Had to remember to sync manually:
DatabaseWrapper.setTestMode();
FileManager().setTestMode();
// Easy to forget one!
```

### After (Centralized)

```dart
// One call, guaranteed sync:
ModeCoordinator.setTestingMode();
```

---

## Migration from Old Code

If you have existing tests using DatabaseWrapper/FileManager directly:

**Old Code**:
```dart
setUp(() {
  DatabaseWrapper.setTestMode();
  FileManager().setTestMode();
});
```

**New Code**:
```dart
setUp(() {
  ModeCoordinator.setTestingMode();
});
```

**Benefits**: Shorter, clearer, and guaranteed to stay synchronized.

---

## Debugging

Get current mode summary:

```dart
final summary = ModeCoordinator.getModeSummary();
print(summary);
// {
//   'currentMode': 'testing',
//   'testName': 'my_test',
//   'databaseMode': 'testing',
//   'fileManagerMode': 'testing'
// }
```

---

## Notes

- **In-memory database** is used for `testing` and `integrationTest` modes for speed
- **Integration test mode** uses in-memory DB but REAL file operations in isolated directory
- **Debug mode** uses file-based database for persistence
- **Production mode** is the default - always explicitly set test modes in tests
- **Test isolation**: Each integration test should use unique testName for isolation
