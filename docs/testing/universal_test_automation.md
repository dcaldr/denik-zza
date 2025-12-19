# Universal Test Automation Strategy

> **Goal**: "Zero-Config" Safety & "Happy Path" Developer Experience.

This project uses a **Universal Test Automation Strategy** to eliminate test pollution (flaky tests caused by shared state) and reduce boilerplate.

## 1. The "Zero-Config" Safety Net

You do **NOT** need to manually close databases or clean up files in your tests.

*   **Global Teardown**: `test/flutter_test_config.dart` automatically runs `DatabaseWrapper.dispose()` after **EVERY** test.
*   **Safe Cleanup**: The cleanup is safe even if your test never touched the database.
*   **Isolation**: Every test gets a fresh, isolated in-memory database (or a unique file if explicitly requested).

## 2. Writing Widget Tests (The "Happy Path")

Use `BaseTestWidget` to wrap your widgets. It handles:
1.  `MaterialApp` and `Scaffold` wrapping.
2.  Database initialization (sets Test Mode automatically).

### Example
```dart
import '../utils/base_test_widget.dart';

testWidgets('My Widget Test', (tester) async {
  await tester.pumpWidget(
    const BaseTestWidget(
      child: MyWidget(),
    ),
  );
  
  // ... your assertions ...
});
```

## 3. Writing Unit Tests

Just call `setupTestEnvironment()` (or `DatabaseWrapper.setTestMode()`) in your `setUp()`.

### Example
```dart
import '../utils/base_test_widget.dart'; // or directly import database_wrapper

setUp(() {
  setupTestEnvironment();
});

test('My Unit Test', () {
  // ... use database ...
});
// No tearDown needed! It's automatic.
```

## 4. Architecture Details

*   **`DatabaseWrapper`**: The "Smart Singleton" that manages database instances. It tracks implicitly created test databases and exposes a `dispose()` method.
*   **`flutter_test_config.dart`**: The global test configuration file that registers the universal `tearDown`.
*   **`AppDatabase.testInMemory()`**: Creates Drift databases with `closeStreamsSynchronously: true` to prevent stream leaks in widget tests.

## 5. Troubleshooting
*   **"Database already open"**: Should not happen with this strategy. If it does, ensure you aren't manually creating `AppDatabase` instances outside of `DatabaseWrapper`.
*   **"Stream not closed"**: Ensure you are using `DatabaseWrapper` (which uses `testInMemory`) and not creating raw `NativeDatabase` instances.

### Windows-Specific Issues
*   **"FileSystemException: The process cannot access the file..."**:
    *   **Cause**: Windows holds file locks on SQLite databases even after the test process tries to delete them.
    *   **Solution**: The `ModeCoordinator` automatically generates **Unique Timestamped Paths** for every debug run to bypass this. If you are manually managing files, ensure you adopt this strategy.

### Legacy Code
*   **"Unique constraint failed"**:
    *   **Cause**: The "Zombie Singleton" bug. A static `DriftDatabaseConnector` from a previous test is still alive and writing to an old database.
    *   **Solution**: Ensure you are calling `DatabaseWrapper.dispose()` in `tearDown`. This now triggers a hard `reset()` of the Drift singleton.
