# Test Documentation

This directory contains all automated tests for the Deník ZZA application.

> ⚠️ **Note:** The test suite is pending a full restructure and reorganization. Current structure and patterns may change. Take this into account when adding new tests or relying on existing test infrastructure. There is also discussion on where to put docs for tests - still tests are preferred, but creating docs folder in test dir is also considered. Also some possible renaming of test folders or restructure -- now it seems a bit messy and duplicate

## Test Structure -- KEEP IN MIND THIS IS PASTED FROM WEB AND NOT PROBABLY RIGHT

```
test/
├── README.md                           # This file - test overview
├── flutter_test_config.dart            # Test configuration
├── widget_tests/
│   └── participant_list_screen_widget_test.md  # Widget test docs
├── services/                           # Service layer tests
├── setup_templates/                    # Test data setup helpers
├── helpers/                            # Test utilities
└── utils/                              # Test helper functions
```

## Test Categories

### Widget Tests
- **participant_list_screen_widget_test.dart** - 22 comprehensive tests for participant list feature
  - See: [Widget Test Documentation](./widget_tests/participant_list_screen_widget_test.md)

### Unit Tests
- Service layer tests
- Database interface tests
- Utility function tests

### Integration Tests
- Complete user flow tests
- Database + UI integration

### Feature Contract Tests
**Purpose:** Catch accidental breaking changes to critical user-facing features.

**When to use:** For features that might break during refactoring/renaming without obvious failures.

**What they test:**
- Observable behavior (dropdown appears, fields present, interactions work)
- Functional issues (missing data, broken callbacks, layout problems like scroll overflow)
- **NOT** pixel-perfect styling (use golden tests for that)

**Naming pattern:**
```dart
group('Feature Contracts -', () {
  group('WidgetName -', () {
    testWidgets('must <behavior> when <condition>', (tester) async {});
  });
});
```

**Examples:** `person_autocomplete_test.dart` contains Feature Contract tests protecting dropdown behavior.

**Key rule:** If test fails unexpectedly → Fix the code, not the test (unless requirements changed).

## Running Tests

### All Tests
```bash
flutter test
```

### Specific Test File
```bash
flutter test test/participant_list_screen_widget_test.dart
```

### With Coverage
```bash
flutter test --coverage
```

### Test Reports
```bash
flutter test --reporter expanded
```

## ⚠️ Known Testing Limitations

**CRITICAL:** See [fixme.md](./fixme.md) for known issues with widget testing that affect ALL interactive tests.

**Key Limitation:** `tester.enterText()` bypasses focus mechanism and doesn't simulate real keyboard input. This means:
- Focus loss bugs won't be caught by widget tests
- Tests can pass 100% while features are unusable for real users
- Interactive widgets need integration tests for real interaction validation

**Action Required:** Review fixme.md before writing tests for interactive widgets (TextField, buttons, gestures).

## Test Best Practices

### Database Testing
- **ALWAYS use in-memory databases** for unit/widget tests
- Call `DatabaseWrapper.setTestMode()` in `setUp()`
- Use `HardcodedTestSetup` for consistent test data
- Clean up with `DatabaseWrapper.resetToProduction()` in `tearDown()`

### Widget Testing & Keys
- **MANDATORY:** Use named keys for ALL testable elements
- **Key naming convention:** `Key('ScreenName_elementName')` 
  - Example: `Key('ParticipantList_searchField')`
  - Example: `Key('NewRecordPage_saveButton')`
- **Why keys matter:**
  - Enable reliable widget testing (find by key instead of text)
  - Prevent test breakage when UI text changes
  - Allow testing non-interactive widgets
  - Make tests readable and maintainable
- Account for ListView viewport rendering (only visible items render initially)
- Be aware of alphabetical sorting in data queries
- Use `find.descendant()` for specific widget tree searches
- Use `dragUntilVisible()` for items not in viewport

### Test Data
- Prefer using `setup_templates/` for consistent test data
- Include edge cases: diacritics, special characters, null values
- Test with realistic Czech data (names, dates, insurance numbers)

## Documentation Philosophy

**Prefer documenting IN tests over separate .md files:**
- Use descriptive test names: `test('search filters participants by first name with Czech diacritics')`
- Add comments within tests to explain non-obvious setup or assertions
- Use `group()` descriptions to document test categories

**When to create .md documentation:**
- ✅ Complex test patterns used across multiple files (e.g., database setup)
- ✅ Reusable test utilities that need examples
- ✅ Common mistakes or gotchas (e.g., "ListView viewport rendering")
- ✅ Test suites with >20 tests that need overview/organization
- ❌ Simple, self-explanatory test cases

**Existing Documentation:**
- **Widget Tests:** `widget_tests/` - Feature-specific test docs (comprehensive tests only)
- **Test Helpers:** `helpers/README.md` - Utility documentation
- **Test Setup:** `setup_templates/README.md` - Data setup patterns
- **Database Testing:** `docs/testing-database-setup.md` - Database patterns

## Contributing

When adding new tests:
1. Follow existing naming conventions (`feature_name_test.dart`)
2. **Add named keys** to all widgets being tested (`Key('Screen_element')`)
3. Document complex logic IN tests with comments, not separate files
4. Use `group()` to organize related tests
5. Include challenging edge case tests
6. Create .md documentation only for:
   - Test suites with >20 tests
   - Reusable patterns/utilities
   - Common gotchas that cause repeated issues
