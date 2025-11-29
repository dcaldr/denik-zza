# The Universal Test Automation Strategy

> **Core Philosophy**: "Zero-Config" Safety & "Happy Path" Developer Experience.
> **Objective**: Eliminate test pollution automatically so developers can focus on writing tests, not boilerplate.

## 1. The "Zero-Config" Promise
Developers should **never** have to manually set up or tear down the database in a standard test.
-   **Bad**: Manually calling `DatabaseWrapper.setTestMode()` and `tearDown(() => DatabaseWrapper.dispose())`.
-   **Good**: The test infrastructure handles this automatically.

## 2. Architecture: The "Smart Singleton" & Global Safety
We solve the "Immortal Singleton" and "Zombie Database" anti-patterns with a two-layer defense:

### Layer 1: Self-Cleaning Wrapper (`DatabaseWrapper`)
The `DatabaseWrapper` is refactored to be "smart":
-   **Implicit Tracking**: It tracks *every* database instance it creates, even the implicit ones created by `getDatabase()` in test mode.
-   **Safe Disposal**: It exposes a `dispose()` method that closes all tracked connections and resets the state to production.

### Layer 2: Global Automation (`flutter_test_config.dart`)
We use Flutter's global test configuration to enforce hygiene:
-   **Global Teardown**: A system-wide `tearDown` hook calls `DatabaseWrapper.dispose()` after *every single test*.
-   **Result**: Even if a developer forgets `tearDown`, the system cleans up after them.

## 3. Developer Experience: `BaseTestWidget`
For Widget Tests, we provide a "Happy Path" mixin/base class:
-   **`BaseTestWidget`**: Standardizes the setup of providers, screen size, and database injection.
-   **Usage**:
    ```dart
    class MyWidgetTest extends BaseTestWidget {
      // ... standard setup is already done ...
    }
    ```

## 4. How to Write Tests (The New Standard)

### Unit Tests (Logic/Services)
Just write the test. The global teardown handles the DB.
```dart
test('my service test', () async {
  // DatabaseWrapper automatically gives you an isolated in-memory DB
  final db = DatabaseWrapper.getDatabase();
  // ... test logic ...
  // No tearDown needed!
});
```

### Widget Tests (UI)
Use the helper to pump widgets with the correct environment.
```dart
testWidgets('my widget test', (tester) async {
  await tester.pumpWidget(
    // Use the standard helper to wrap your widget
    createTestApp(child: MyWidget())
  );
  // ... assertions ...
});
```

## 5. Migration Guide for Refactoring
When refactoring old tests:
1.  **Remove** manual `tearDown(() => DatabaseWrapper.dispose())`.
2.  **Remove** direct usage of `DatabaseTestHelper` if it conflicts with the global strategy.
3.  **Ensure** `DatabaseWrapper.getDatabase()` is used instead of instantiating `AppDatabase` directly, unless you are specifically testing the database class itself.
