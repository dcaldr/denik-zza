# Input Module

This module handles data validation, CSV import processing, and file management for the Deník ZZA application.

## Quick Links

- **📄 [CSV Import Documentation](../../docs/csv-import.md)** - Comprehensive guide to CSV processing, field validation, and import workflows
- **📁 [FileManager Documentation](../../docs/filemanager.md)** - File operations, backup management, and operational modes

## Module Overview

### CSV Processing
- **Parser**: `input_parser.dart` - Main CSV processing engine with sparse data support
- **Readers**: `csv_reader.dart` - File reading and header detection
- **Validators**: `input_hold.dart` - Field-specific validation classes
- **Definitions**: `csv_definitions.dart` - Column mapping and structure
- **Text Tools**: `text_tools.dart` - Date parsing, text normalization utilities

### File Management  
- **FileManager**: `file_manager.dart` - Event directories, backups, multi-mode operation
- **Features**: Database backup, directory lifecycle, IO validation

### Data Models
- **RodneCislo**: `rodne_cislo.dart` - Czech national ID validation and processing
- **Response**: `response.dart` - Status and message handling

## Key Features Implemented

### ✅ Robust CSV Import
- **Minimal CSV support**: Works with only jméno + příjmení fields
- **Header mapping tolerance**: Order-independent, extra columns supported
- **Field validation**: Email, phone, insurance, date parsing with business defaults
- **Error handling**: Clear status messages, graceful failure modes

### ✅ FileManager Reliability
- **Multi-mode operation**: InMemory/Persist/Production modes
- **Database backup**: Safe copying with collision resolution
- **Directory management**: Single creation, proper lifecycle
- **Test integration**: Configurable paths, mode consistency

### ✅ Data Validation
- **Date parsing robustness**: Component validation, no silent normalization
- **Field-specific validators**: Shared between CSV and UI forms
- **Cross-line isolation**: No state bleeding between CSV rows
- **Default handling**: Business-meaningful defaults (e.g., způsobilost → false)

## Architecture Notes

This module follows the established project pattern:
- **Service Layer Integration**: Used by services, not directly by UI widgets
- **Database Wrapper**: All DB access through `DatabaseWrapper.getDatabase()`
- **Logging**: Uses `Logger` package, no `print()` statements
- **Testing**: Extensive test coverage with helper utilities

## Legacy Notes

The original design concepts below were the foundation for the current implementation:

### Historical Design Vision *(Implemented)*
- ✅ `verifyInputRecord()` pattern - now implemented as InputHold validation pipeline
- ✅ Chain of responsibility - implemented through fresh() instances and validation stages  
- ✅ Status response system - ParseStatus enum with Ok/Info/Warning/Error states
- ✅ Message handling - comprehensive error/warning messages for users
- ✅ Data cleaning pipeline - normalization in addInput() methods
- ✅ Type-safe parsing - InputHold subclasses for different data types
- ✅ Reusable validation - shared between CSV import and registration forms

### Implementation Evolution
The current system evolved from these concepts into a robust, production-ready CSV import and file management system with comprehensive test coverage and documentation.

---

## Development Guidelines

When modifying this module:

1. **Read the documentation first** - Both CSV and FileManager docs contain critical details
2. **Use test helpers** - `test/utils/` contains utilities for consistent test setup
3. **Follow service patterns** - No direct DB access, use DatabaseWrapper
4. **Maintain compatibility** - Validators are shared with registration forms
5. **Test thoroughly** - Changes affect both CSV import and manual data entry
- TODO: add fix/workaround/catch for bad db state -- ie records pointing to non-existent participant
  - stalo se že v průběhu testování existoval záznam odkazující na osobu s id 1, ale osoba s id 1 neexistovala. V okamžiku přidání došlo ke spojení osamocených starých záznamů s tím novým.


