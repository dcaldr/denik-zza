# CSV Import Documentation

## Overview

The CSV import system allows bulk import of participant data into the Deník ZZA application. This document describes current behavior, limitations, and future development plans.

## Current Field Validators

The system uses InputHold classes for validation, which are **shared between CSV parsing and UI form validation**. Changes to validator logic will affect both CSV import and the participant registration form.

### Email Validation (EmailHold)

**Current Behavior:**
- Empty input: Accepted as OK (returns empty string)
- Non-empty input: Must contain "@" symbol
- **No RFC compliance checking** - very basic validation

**Limitations:**
- No domain validation
- No format checking beyond "@" presence
- Accepts invalid emails like "a@" or "@b"

**Used in:**
- CSV import (`lib/input/input_hold.dart`)
- Participant registration form (`lib/screens2/participant_registration_form.dart`)

### Phone Validation (TelefonHold)

**Current Behavior:**
- **No validation** - accepts any input as OK
- Returns input string unchanged

**Limitations:**
- No format checking (Czech phone format +420 XXX XXX XXX)
- No length validation
- No digit-only validation

**Used in:**
- CSV import (`lib/input/input_hold.dart`)
- Participant registration form (`lib/screens2/participant_registration_form.dart`)

### Insurance Company Validation (PojistovnaHold)

**Current Behavior:**
- Empty input: Accepted as OK (returns null)
- Uses sophisticated loose matching with normalized text comparison
- Maps common names/codes to canonical short codes
- Supports major Czech insurance companies (VZP, VOZP, CPZP, OZP, ZPMV, RBP, ZPS)
- Unknown values: Kept as-is but still marked as OK

**Supported Mappings:**
```
VZP (111) → 'vzp'
VOZP (201) → 'vozp'  
CPZP (205) → 'cpzp'
OZP (207) → 'ozp'
ZPMV (211) → 'zpmv'
RBP (213) → 'rbp'
ZPS (209) → 'zps'
```

**Features:**
- Diacritic-insensitive matching
- Handles both company names and numeric codes
- First match wins policy

**Used in:**
- CSV import (`lib/input/input_hold.dart`)
- Participant registration form (`lib/screens2/participant_registration_form.dart`)

### Qualification Validation (PotvrzeniHold - způsobilost)

**Current Behavior:**
- Empty input: Defaults to false (not qualified)
- **Missing column**: Defaults to false (common use case for minimal CSV)
- Accepts various formats: "ano"/"ne", "yes"/"no", "y"/"n", "1"/"0", "true"/"false"
- Case-insensitive matching

**Default Policy:**
- If způsobilost column is missing from CSV → defaults to false
- If způsobilost column exists but is empty → defaults to false
- This supports minimal CSV imports with only essential fields

**Used in:**
- CSV import (`lib/input/input_hold.dart`)
- Participant registration form (`lib/screens2/participant_registration_form.dart`)

## Date Validation (Enhanced)

**Current Behavior (Recently Improved):**
- Validates date components before DateTime construction
- Prevents silent normalization of invalid dates
- Invalid dates result in WARN status (not hard failure)
- Supports DD.MM.YYYY and YYYY.MM.DD formats with various separators

**Range Validation:**
- Years: 1900-2100
- Months: 1-12
- Days: 1-31 with month-specific limits and leap year handling

## CSV Import Process

### Supported Formats
- Delimiter: Comma, semicolon, tab (auto-detected)
- Header: Required first row with column names
- Encoding: UTF-8 recommended

### Column Mapping
**Current Implementation (✅ IMPLEMENTED):**
- **Order-independent parsing**: Columns can be in any order
- **Loose header matching**: Uses diacritic-insensitive, case-insensitive comparison via `TextTools.looseCmp()`
- **Extra column tolerance**: Extra columns are tracked but don't break parsing
- **Missing column detection**: Logs warnings for missing mandatory columns
- **Data normalization**: Incoming CSV data is reordered to match internal definition structure

**Supported Header Variations:**
```
"jméno" matches: jmeno, Jméno, JMÉNO, jmeno , etc.
"příjmení" matches: prijmeni, Příjmení, PRIJMENI, etc.
"email rodič" matches: email rodic, Email Rodič, EMAIL RODIC, etc.
```

**Mandatory Fields:**
- `jméno` (first name)
- `příjmení` (surname)

**Example Working CSV Formats:**
```csv
# Standard order
jméno,příjmení,rodné číslo,datum narození,...

# Shuffled order - works perfectly
příjmení,pojišťovna,jméno,rodné číslo,email rodič,...

# With extra columns - works perfectly  
jméno,příjmení,extra_column,rodné číslo,another_extra,...
```

### Error Handling
- **OK**: Valid data, ready for import
- **WARN**: Suspicious data that may need attention (e.g., invalid dates)
- **BAD**: Invalid data that blocks import
- **EMPTY**: Missing required data

### Participant classification outputs

Parsing results are aggregated in `PersonResult`, which now exposes three
distinct views:

- `goodPersons` – participants whose rows parsed with `ParseStatus.ok` (no WARNs).
- `warnPersons` – map of `MemoryOsoba → ErrorLine` for rows with `ParseStatus.warn`.
- `passingPersons` – new lightweight list containing every row that is either
    OK or WARN. This projection powers tests and review tooling that need to count
    all non-rejected entries without hiding WARN banners.

`CsvImportSession` re-exports the `passingPersons` list and a `passingCount`
getter so UI workflows (bulk approvals, analytics) can base decisions on the
highest severity per row while still surfacing WARN/INFO messaging. WARN/INFO/
ERROR precedence remains unchanged—the projection simply groups rows that are
eligible to pass without downgrading their severity.

## ⚠️ Critical Limitations & Risks

### 1. Shared Validation Logic
**Risk:** Changes to validators affect both CSV import AND participant registration form UI.

**Current Impact:**
- EmailHold validator used in registration form
- TelefonHold validator used in registration form  
- PojistovnaHold validator used in registration form
- Changes require coordinated testing of both CSV and form workflows

### 2. No Conflict Resolution
**Current Gap:** No handling for participants who already exist in database.

**Scenarios Not Handled:**
- Person with same name already exists
- Person with same rodné číslo already exists
- Updated information for existing person
- Duplicate entries within same CSV file

**Required Future Work:**
- Implement duplicate detection logic
- Design conflict resolution UI/workflow
- Define merge vs. skip vs. overwrite policies
- Add import preview with conflict highlighting

### 3. Missing Mandatory Column Edge Case
**Current Limitation:** When mandatory columns (jméno, příjmení) are completely missing from CSV headers, the parser correctly detects and logs the issue, but the `toPerson()` method fails due to hardcoded field position assumptions.

**Impact:**
- CSV files missing mandatory columns will cause parsing to fail with null pointer exception
- Workaround: Ensure CSV files include all mandatory columns (even if empty)
- Future fix: Enhance `toPerson()` method to handle missing fields gracefully

**Working Scenarios:**
- ✅ Reordered columns with all mandatory fields present
- ✅ Extra columns in any position  
- ✅ Empty values in mandatory fields (handled by validation)
- ❌ Completely missing mandatory column headers

## Future Improvements

### Phase 1: Validation Enhancements
**Email Validation:**
- RFC-lite regex pattern
- Domain validation
- Format standardization

**Phone Validation:**
- Czech phone number format validation (+420 XXX XXX XXX)
- Number normalization
- International format support

**Insurance Validation:**
- Database-backed mapping
- Strict validation mode option
- Support for new insurance companies

### Phase 2: Import Process Improvements (✅ MOSTLY COMPLETE)
**Header Mapping (✅ IMPLEMENTED):**
- ✅ Column order independence
- ✅ Normalized name matching (diacritic-insensitive) 
- ✅ Extra column tracking for UI display
- ✅ Missing mandatory column detection with clear warnings
- ⚠️ Missing mandatory column edge case (toPerson() hardcoded assumptions)

**Conflict Resolution (❌ PENDING):**
- Duplicate detection by name + birth date
- Rodné číslo uniqueness checking
- Preview import with conflict highlighting
- User-selectable merge/skip/overwrite policies

**Data Quality (❌ PENDING):**
- Import statistics and validation reports
- Rollback capability
- Batch processing with progress tracking

### Phase 3: Advanced Features
**Import Modes:**
- Test mode (validation only, no database changes)
- Incremental import (only new/changed records)
- Scheduled imports with monitoring

**Integration:**
- Export templates for common use cases
- API endpoints for programmatic import
- Audit trail for import operations

## Testing Strategy

### Current Test Coverage
- Date parsing robustness tests
- Basic CSV parsing functionality
- Input validation unit tests

### Required Test Additions
- Form validation integration tests
- Conflict resolution scenarios
- Header mapping tolerance tests
- Error handling edge cases

## File Structure

### Core CSV Components
```
lib/input/
├── input_parser.dart          # Main CSV parsing logic
├── csv_reader.dart           # File reading and header parsing
├── input_hold.dart           # Field validators (shared with forms)
├── csv_definitions.dart      # Column definitions
├── text_tools.dart          # Text processing utilities
└── rodne_cislo.dart         # Czech ID number validation
```

### Form Integration
```
lib/screens2/
├── participant_registration_form.dart  # Uses InputHold validators
└── widgets/
    └── custom_date_picker.dart        # Date input validation
```

### Documentation
```
docs/
├── csv-import.md            # This file
└── reports/tomake/
    └── csv-filemanager-remediation-plan.md  # Implementation plan
```

## Developer Notes

### Making Validator Changes
1. **Impact Assessment**: Changes affect both CSV import AND registration forms
2. **Testing Required**: Test both import workflows and form validation
3. **Coordination**: UI team must validate form behavior changes
4. **Rollback Plan**: Have rollback strategy for breaking changes

### Adding New Validators
1. Extend InputHold class
2. Add to participant_registration_form.dart `_validators` map
3. Update CSV column definitions
4. Add comprehensive tests for both contexts

### Debugging Import Issues
1. Check validator status (OK/WARN/BAD) for each field
2. Review normalized text matching for insurance/text fields
3. Verify date component validation logs
4. Test with sample CSV files of various formats

---

**Last Updated:** September 2025  
**Status:** Phase 3 - Documentation Complete, Conflict Resolution Pending  
**Next Review:** After Phase 4 implementation