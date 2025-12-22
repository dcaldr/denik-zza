# Test Modes Quick Reference

## Zero-Config for Unit Tests

```dart
// flutter_test_config.dart calls setTestingMode() globally.
// NO setup needed in individual test files!
```

---

## Mode Overview

| Mode | Database | Files | Use Case |
|------|----------|-------|----------|
| `testing` | In-memory | None | Unit/widget tests |
| `integrationTest` | Disk file | Isolated folder | Integration tests |
| `canary` | Disk file | Isolated folder | Same as integrationTest |
| `debug` | Disk file | Persistent folder | Dev environment |
| `production` | Disk file | App documents | Real app |

---

## Unit/Widget Tests (`test/` folder)

```dart
// Automatic! Just write your test - no setup needed.
void main() {
  test('my test', () {
    // Mode already set by flutter_test_config.dart
    final db = DatabaseWrapper.getDatabase();  // In-memory DB
  });
}
```

---

## Integration Tests (`integration_test/` folder)

```dart
testWidgets('my test', (tester) async {
  await ModeCoordinator.setIntegrationTestMode(testName: 'my_test');
  // DB: Documents/DenikZZA/test_outputs/integration/run_{runId}/{testName}/db.sqlite
  
  app.main();
  await tester.pumpAndSettle();
  // ... test code ...
});
```

---

## File Locations

| Mode | Output Location |
|------|-----------------|
| testing | No files (in-memory) |
| integrationTest | `Documents/DenikZZA/test_outputs/integration/run_{runId}/{testName}/` |
| canary | Same as integrationTest |
| debug | `Documents/DenikZZA/debug/` |
| production | `Documents/DenikZZA/` |

---

## DatabaseMode Enum

```dart
enum DatabaseMode {
  production,       // Real singleton (production app)
  testing,          // In-memory (unit/widget tests)
  integrationTest,  // File-based in isolated folder
}
```
