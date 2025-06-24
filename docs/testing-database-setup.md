# Database Testing Setup Guide

This guide explains how to set up and use database testing in your Flutter Drift project with flexible database selection.

## Overview

Our testing system supports **three different modes** for maximum flexibility:

1. **Per-Test-Suite Choice** - Each test file/group can choose memory OR file database
2. **Global Force Memory** - Override all tests to use memory database (fast CI/CD)
3. **Global Force File** - Override all tests to use file database (integration testing)

## Quick Start

### 1. Basic Setup Pattern

Every database test should follow this pattern:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'helpers/database_test_helper.dart';

void main() {
  late AppDatabase database;
  
  setUp(() {
    // Choose your database type here
    database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
  });
  
  tearDown(() async {
    await database.close();
  });
  
  test('your test here', () async {
    // Test database operations
  });
}
```

### 2. Database Type Selection

Choose the database type that makes sense for your tests:

```dart
// Fast unit tests - use memory database
database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);

// Integration tests - use file database  
database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);

// Shortcuts available:
database = DatabaseTestHelper.createMemoryTestDatabase();
database = DatabaseTestHelper.createFileTestDatabase();
```

## The Three Testing Modes

### Mode 1: Per-Test-Suite Choice

Each test file chooses its own database type. This is the **recommended default approach**.

```dart
// test/fast_unit_tests.dart - Uses memory for speed
void main() {
  late AppDatabase database;
  
  setUp(() {
    database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
  });
  
  // ... tests
}

// test/integration_tests.dart - Uses file for persistence testing
void main() {
  late AppDatabase database;
  
  setUp(() {
    database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
  });
  
  // ... tests
}
```

### Mode 2: Global Force All-Memory

Force **ALL** tests to use memory database (great for CI/CD speed):

```dart
void main() {
  setUpAll(() {
    // This overrides ALL test suites to use memory database
    DatabaseTestHelper.setGlobalTestDatabaseOverride(TestDatabaseType.memory);
  });
  
  tearDownAll(() {
    DatabaseTestHelper.clearGlobalTestDatabaseOverride();
  });
  
  // Now ALL test suites use memory, regardless of their individual choice
}
```

### Mode 3: Global Force All-File

Force **ALL** tests to use file database (integration test runs):

```dart
void main() {
  setUpAll(() {
    // This overrides ALL test suites to use file database
    DatabaseTestHelper.setGlobalTestDatabaseOverride(TestDatabaseType.file);
  });
  
  tearDownAll(() {
    DatabaseTestHelper.clearGlobalTestDatabaseOverride();
  });
  
  // Now ALL test suites use file database
}
```

## Helper Utilities

### Test Data Creation

Use the `TestDatabaseUtils` class for creating test data:

```dart
test('example test', () async {
  // Create test insurance company
  final company = TestDatabaseUtils.createSampleInsuranceCompany(
    name: 'Test Insurance Co'
  );
  final companyId = await database.addInsuranceCompany(company);
  
  // Create test participant
  final participant = TestDatabaseUtils.createSampleParticipant(
    firstName: 'John',
    lastName: 'Doe',
    insuranceCompanyFK: companyId,
  );
  final participantId = await database.addParticipant(participant);
  
  // Create test record
  final record = TestDatabaseUtils.createSampleRecord(
    title: 'Test Record',
    description: 'Test Description',
    participantFK: participantId,
  );
  await database.addRecord(record);
  
  // ... test assertions
});
```

### File Database Cleanup

For file databases, optionally clean up test files:

```dart
tearDown(() async {
  await DatabaseTestHelper.cleanupTestDatabaseFile(database);
});
```

## When to Use Each Database Type

### Memory Database (TestDatabaseType.memory)
- ✅ **Fast unit tests** - testing business logic
- ✅ **CI/CD pipelines** - speed is critical
- ✅ **Isolated tests** - each test gets fresh database
- ✅ **Most common use case**

**Example use cases:**
- Testing CRUD operations
- Testing business logic methods
- Testing data validation
- Testing method return values

### File Database (TestDatabaseType.file)
- ✅ **Integration tests** - testing file operations
- ✅ **Migration testing** - testing database schema changes
- ✅ **Performance testing** - realistic SQLite performance
- ✅ **Persistence testing** - data survives app restarts

**Example use cases:**
- Testing file I/O operations
- Testing database migrations
- Testing complex queries performance
- Testing transaction behavior

## Complete Example

Here's a complete test file showing both patterns:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'helpers/database_test_helper.dart';

void main() {
  group('Fast Unit Tests (Memory Database)', () {
    late AppDatabase database;
    
    setUp(() {
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
    });
    
    tearDown(() async {
      await database.close();
    });
    
    test('can create and retrieve participants', () async {
      final participant = TestDatabaseUtils.createSampleParticipant(
        firstName: 'John',
        lastName: 'Doe'
      );
      
      final id = await database.addParticipant(participant);
      final retrieved = await database.getParticipantByID(id);
      
      expect(retrieved, isNotNull);
      expect(retrieved!.firstName, equals('John'));
    });
  });
  
  group('Integration Tests (File Database)', () {
    late AppDatabase database;
    
    setUp(() {
      database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
    });
    
    tearDown(() async {
      await DatabaseTestHelper.cleanupTestDatabaseFile(database);
    });
    
    test('can handle complex database operations', () async {
      // Test more complex scenarios that might need file persistence
      // ... complex test logic
    });
  });
}
```

## Important Notes

### Required for Flutter Tests: `closeStreamsSynchronously`

All test databases automatically use `closeStreamsSynchronously: true`. This is **required** for Flutter tests to prevent timer-related test failures.

### Database Isolation

Each test gets a **fresh database instance**:
- Memory databases are completely isolated
- File databases get unique filenames with timestamps
- No test data pollution between tests

### Global Override Priority

Global overrides take **precedence** over per-test-suite choices:
- If global override is set to memory, ALL tests use memory
- If global override is set to file, ALL tests use file  
- If no global override, each test suite uses its chosen type

## Troubleshooting

### Test Failures Related to Streams

If you see errors about timers or streams not being closed:
- Ensure you're using `DatabaseTestHelper.createTestDatabase()` 
- It automatically sets `closeStreamsSynchronously: true`

### File Database Issues

If file database tests are slow or failing:
- Check that test cleanup is working properly
- Consider using memory databases for unit tests
- Use file databases only when you specifically need file behavior

### Global Override Not Working

If global override doesn't seem to work:
- Ensure you're calling `setGlobalTestDatabaseOverride()` in `setUpAll()`
- Check that it's called before any test databases are created
- Use `getGlobalTestDatabaseOverride()` to debug current setting

## Migration from Old Tests

If you have existing tests that only test memory objects:

1. **Keep the memory object tests** - they're still valuable for unit testing
2. **Add database operation tests** - use the patterns shown above
3. **Choose appropriate database type** - memory for unit tests, file for integration

Example migration:

```dart
// OLD: Only testing memory objects
test('memory object test', () {
  final person = MemoryOsoba.basic('John', 'Doe');
  expect(person.jmeno, equals('John'));
});

// NEW: Add database operation tests
test('database operation test', () async {
  final participant = TestDatabaseUtils.createSampleParticipant(
    firstName: 'John',
    lastName: 'Doe'
  );
  
  final id = await database.addParticipant(participant);
  final retrieved = await database.getParticipantByID(id);
  
  expect(retrieved!.firstName, equals('John'));
});
```

This gives you both memory object tests AND database operation tests for comprehensive coverage.
