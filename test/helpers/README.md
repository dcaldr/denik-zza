# Test Helpers

This directory contains helper utilities for database testing.

## Files

- **`database_test_helper.dart`** - Main test database utilities
  - `DatabaseTestHelper` class for creating test databases
  - `TestDatabaseUtils` class for creating test data
  - Support for memory and file database testing
  - Global override capabilities

## Quick Usage

```dart
import 'helpers/database_test_helper.dart';

void main() {
  late AppDatabase database;
  
  setUp(() {
    database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
  });
  
  tearDown(() async {
    await database.close();
  });
  
  test('your test', () async {
    final participant = TestDatabaseUtils.createSampleParticipant();
    final id = await database.addParticipant(participant);
    // ... test logic
  });
}
```

## Documentation

See `/docs/testing-database-setup.md` for complete documentation and examples.
