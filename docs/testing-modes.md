# Test Modes Quick Reference

## Two Modes

| Mode | Database | Files | Use Case |
|------|----------|-------|----------|
| `setTestingMode()` | In-memory | None | Unit/widget tests |
| `setIntegrationTestMode()` | **Disk file** | Isolated folder | Integration tests |

## Usage

### Unit/Widget Tests (`test/` folder)

```dart
// Automatic! flutter_test_config.dart calls setTestingMode() globally.
// Just write your test - no setup needed.
```

### Integration Tests (`integration_test/` folder)

```dart
testWidgets('my test', (tester) async {
  await ModeCoordinator.setIntegrationTestMode(testName: 'my_test');
  // DB file: Documents/DenikZZA/test_outputs/integration/run_YYMMDD_HHMMSS/my_test/db.sqlite
  // Files: Documents/DenikZZA/test_outputs/integration/run_YYMMDD_HHMMSS/my_test/
  
  app.main();
  await tester.pumpAndSettle();
  // ... test code ...
});
```

## Deprecated Modes

These modes still work but are deprecated:

| Mode | Replacement |
|------|-------------|
| `setCanaryTestMode()` | Use `setIntegrationTestMode()` |
| `setDebugMode()` | Use `setIntegrationTestMode()` |

## File Locations

| Mode | test/` Output | `integration_test/` Output |
|------|---------------|---------------------------|
| Testing | No files | N/A |
| IntegrationTest | N/A | `Documents/DenikZZA/test_outputs/integration/run_{runId}/{testName}/` |

## DatabaseMode Enum

```dart
enum DatabaseMode {
  production,       // Real singleton (production app)
  testing,          // In-memory (unit/widget tests)
  integrationTest,  // File-based in isolated folder (integration tests)
}
```
