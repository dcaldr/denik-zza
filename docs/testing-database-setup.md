# Database Testing Setup Guide

This guide explains the robust, non-breaking database system for both production and testing contexts in your Flutter Drift project.

## 🛡️ Safety-First Design

**CORE PRINCIPLE**: The production app ALWAYS uses persistent storage and can NEVER silently switch to non-persistent databases that would cause data loss.

### Production Safety Guarantees

✅ **Default is persistent storage** - Production mode is the default  
✅ **Explicit test mode required** - Tests must explicitly enable non-persistent storage  
✅ **Runtime safety checks** - Dangerous configurations are detected and prevented  
✅ **Compile-time protection** - Prefer errors over silent data loss  
✅ **Backward compatibility** - Existing code continues to work  

## Database System Overview

### Two Primary Database Types

1. **Production Database** (`DriftDatabaseConnector`)
   - Persistent SQLite file storage
   - Data survives app restarts
   - Used by the real app
   - Default and heavily protected

2. **Test Database** (Drift in-memory or file-based)
   - In-memory or temporary file storage
   - Isolated between tests
   - Fast and safe for testing
   - Must be explicitly enabled

### Database Selection Methods

We provide **two complementary approaches** for database selection:

#### Method 1: DatabaseWrapper (Recommended for App-Level Tests)

Use this when testing through the app's database wrapper system:

```dart
import 'package:denik_zza/database/database_wrapper.dart';

void main() {
  setUp(() {
  DatabaseWrapper.setTestMode(); // Switch to in-memory Drift database
  });
  
  tearDown(() {
    DatabaseWrapper.resetToProduction(); // Always clean up!
  });
  
  test('app-level database test', () {
  // This will use a Drift in-memory database for test isolation
    DatabaseInterface db = DatabaseWrapper.getDatabase();
    // ... your test code
  });
}
```

#### Method 2: Direct Database Creation (Recommended for Unit Tests)

Use this for direct database testing with more control:

```dart
import 'helpers/database_test_helper.dart';

void main() {
  late AppDatabase database;
  
  setUp(() {
    // Choose your database type
    database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
    // or TestDatabaseType.file for integration tests
  });
  
  tearDown(() async {
    await database.close();
  });
  
  test('direct database test', () async {
    // Test database operations directly
  });
}
```

## Quick Start Guide

### For Production App

Add this to your `main()` function for maximum safety:

```dart
import 'package:denik_zza/database/database_wrapper.dart';

void main() {
  // Validate that the app is using safe, persistent storage
  DatabaseWrapper.ensureProductionMode();
  
  runApp(MyApp());
}
```

### For App-Level Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_wrapper.dart';

void main() {
  group('My App Tests', () {
    setUp(() {
  DatabaseWrapper.setTestMode(); // Use isolated in-memory Drift DB
    });
    
    tearDown(() {
      DatabaseWrapper.resetToProduction(); // Always reset!
    });
    
    test('my test', () {
      DatabaseInterface db = DatabaseWrapper.getDatabase();
  // Test your app logic - uses isolated Drift in-memory DB
    });
  });
}
```

### For Direct Database Testing  

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'helpers/database_test_helper.dart';

void main() {
  late AppDatabase database;
  
  setUp(() {
    // Fast unit tests - use memory database
    database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory);
    
    // OR for integration tests - use file database  
    // database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
  });
  
  tearDown(() async {
    await database.close();
  });
  
  test('your direct database test', () async {
    // Test database operations directly
    // This database is isolated and won't affect production or other tests
  });
}
```

## Advanced Features

### Global Test Database Override
### Three-Mode Testing via --dart-define

You can switch test modes using compile-time flags:
### Per-run directories (isolation)

Persistent tests now support per-run directories to keep artifacts grouped and avoid cross-run collisions when running tests in parallel:

- TestOutputManager.getDatabasePath is async and accepts a named parameter `useRunDir` (default true in our helpers) to place the `.db` file under a per-run path like `test/test_outputs/persist/test_YYYYMMDD_HHMMSS_rand/<filename>`.
- You can also access the run directory directly via `getOrCreatePersistRunDirectory()` and `getOrCreateProductionRunDirectory()`.

Notes:
- Do NOT delete per-run directories in per-test tearDown. Persist mode is meant to keep artifacts for the whole run and post-mortem debugging.
- AppDatabase treats paths ending with `.db` as file paths; directory paths will get `db.sqlite` appended internally.

### Optional FileManager wiring for persist runs

For app-aligned tests where you also want FileManager to point to the same output directory, UnifiedTestSetup can configure FileManager to the current run directory:

- Call `UnifiedTestSetup.createDatabase(useFileManagerPersist: true, useRunDir: true)` in your setup.
- This sets `FileManager().setPersistentTestMode(<runDir>)` so any file operations use the same per-run folder.

Default behavior for concurrency-heavy suites remains the direct `.db` path injection without altering FileManager.
- Default (in-memory):
  - Run: `flutter test`
  - Behavior: No disk writes, fastest execution.
- Persist mode (writes to disk for debugging):
  - Run: `flutter test --dart-define=TEST_MODE=persist`
  - Behavior: Database file is created on disk under `test/test_outputs/persist` (ignored by git).
- Production validation (guarded):
  - Run: `flutter test --dart-define=TEST_MODE=production --dart-define=CONFIRM_PRODUCTION_TESTING=yes`
  - Behavior: Uses production-like persistent paths; only for special validation.

Under the hood:
- `test/utils/test_configuration.dart` reads `TEST_MODE` and applies safety checks.
- `test/utils/test_output_manager.dart` creates and manages `test/test_outputs/*` directories.
- `test/utils/unified_test_setup.dart` wires the environment and constructs the database.
- `AppDatabase` treats a provided `path` ending with `.db` as a file path, or uses a directory path plus `db.sqlite` if a folder path (or no path) is provided. This enables clean control in persist mode.

Recommended patterns:
- Prefer the `TestingSetupHelper.setupGroup()` wrapper in tests for consistent setup/teardown across modes.
- Persist artifacts are placed in `test/test_outputs/` and are ignored by git.


Force all tests to use the same database type (useful for CI/CD):

```dart
void main() {
  setUpAll(() {
    // Force ALL tests to use memory database (fast CI)
    DatabaseTestHelper.setGlobalTestDatabaseOverride(TestDatabaseType.memory);
  });
  
  tearDownAll(() {
    DatabaseTestHelper.clearGlobalTestDatabaseOverride();
  });
  
  // Now all createTestDatabase() calls will use memory, regardless of what they specify
}
```

### Database Type Selection Guidelines

| Test Type | Recommended Database | Reason |
|-----------|---------------------|---------|
| Unit Tests | `TestDatabaseType.memory` | Fast, isolated, no I/O |
| Integration Tests | `TestDatabaseType.file` | Real SQLite behavior |
| Performance Tests | `TestDatabaseType.file` | Realistic performance |
| CI/CD Pipeline | `TestDatabaseType.memory` | Speed and reliability |

## Safety Features

### Production Protection

The system includes multiple layers of protection:

1. **Default Safe Mode**: Production is the default, test mode must be explicit
2. **Runtime Validation**: `validateProductionSafety()` detects dangerous configurations  
3. **Safety Assertions**: Debug builds catch unsafe state combinations
4. **Explicit Reset**: Tests must explicitly clean up to return to production mode

### Safety Methods

```dart
// Ensure production mode and validate safety
DatabaseWrapper.ensureProductionMode();

// Check if using persistent storage
bool isPersistent = DatabaseWrapper.isUsingPersistentStorage();

// Validate current configuration is safe
DatabaseWrapper.validateProductionSafety();

// Get current mode for debugging
DatabaseMode mode = DatabaseWrapper.getCurrentMode();
```

## File Database Features

When using `TestDatabaseType.file`, test databases get unique filenames:

- Location: `test/test_dbs/` directory (automatically created)
- Format: `test_YY-MM-DD_testDB_NNNNN.db`
- Example: `test/test_dbs/test_24-01-15_testDB_42837.db`
- **Files are preserved by default** for debugging and analysis
- Human-readable timestamps for easy identification
- Not committed to version control (in `.gitignore`)
- Optional cleanup methods available if needed

## Migration from Old System

If you have existing tests using the old system:

### Old Pattern (Still Works)
```dart
// Legacy pattern - still supported
DatabaseInterface db = DatabaseWrapper.getDatabase();
```

### New Recommended Pattern  
```dart
// For app-level tests
setUp(() => DatabaseWrapper.setTestMode());
tearDown(() => DatabaseWrapper.resetToProduction());
DatabaseInterface db = DatabaseWrapper.getDatabase();

// For direct database tests  
setUp(() => database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.memory));
tearDown(() => database.close());
```

## Common Patterns

### Pattern 1: Fast Unit Tests
```dart
group('Fast Unit Tests', () {
  setUp(() => DatabaseWrapper.setTestMode());
  tearDown(() => DatabaseWrapper.resetToProduction());
  
  test('business logic test', () {
    DatabaseInterface db = DatabaseWrapper.getDatabase();
  // Fast Drift in-memory testing
  });
});
```

### Pattern 2: Integration Tests
```dart
group('Integration Tests', () {
  late AppDatabase database;
  
  setUp(() {
    database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file);
  });
  
  tearDown(() async {
    await database.close();
  });
  
  test('full database workflow', () async {
    // Real SQLite file testing
  });
});
```

### Pattern 3: Mixed Test Suite
```dart
void main() {
  group('Unit Tests', () {
    setUp(() => DatabaseWrapper.setTestMode());
    tearDown(() => DatabaseWrapper.resetToProduction());
    // Fast tests here
  });
  
  group('Integration Tests', () {
    late AppDatabase database;
    setUp(() => database = DatabaseTestHelper.createTestDatabase(TestDatabaseType.file));
    tearDown(() => database.close());
    // Thorough tests here
  });
}
```

## Troubleshooting

### Common Issues

**Issue**: Tests interfering with each other
**Solution**: Ensure proper tearDown() calls reset to production mode

**Issue**: Production app using wrong database
**Solution**: Add `DatabaseWrapper.ensureProductionMode()` to main()

**Issue**: Test database files accumulating
**Solution**: File databases auto-generate unique names and should be cleaned up

**Issue**: Persist mode created a directory named like a file (e.g., `foo.db/db.sqlite`)
**Solution**: Fixed in `AppDatabase` — paths ending with `.db` are now treated as file paths. If you pass a directory, `db.sqlite` is added automatically.

### Debugging

```dart
// Check current database mode
print('Current mode: ${DatabaseWrapper.getCurrentMode()}');

// Check if using persistent storage  
print('Persistent: ${DatabaseWrapper.isUsingPersistentStorage()}');

// Get global test override
print('Global override: ${DatabaseTestHelper.getGlobalTestDatabaseOverride()}');
```

## Best Practices

1. **Always Clean Up**: Use tearDown() to reset to production mode
2. **Explicit Mode Setting**: Be explicit about test vs production mode
3. **Use Appropriate Database Type**: Memory for speed, file for realism
4. **Validate Production Safety**: Add ensureProductionMode() to main()
5. **Document Test Database Choice**: Comment why you chose memory vs file
6. **Isolate Tests**: Each test should start with clean database state

## Examples

See `test/infrastructure/testing_infrastructure_test.dart` and `test/database_safety_proof_test.dart` for comprehensive examples demonstrating:
- Production safety guarantees
- Test isolation
- Schema consistency  
- Backward compatibility
- Safety edge cases
- Real-world usage patterns
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

For file databases, you have several cleanup options:

```dart
// Option 1: Individual database cleanup (in tearDown)
tearDown(() async {
  await DatabaseTestHelper.cleanupTestDatabaseFile(database);
});

// Option 2: Clean up all test databases (in tearDownAll)
tearDownAll(() async {
  await DatabaseTestHelper.cleanupAllTestDatabaseFiles();
});

// Option 3: Manual cleanup (if needed)
// All test database files are located in: test/test_dbs/
// They follow the pattern: test_YY-MM-DD_testDB_NNNNN.db
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
