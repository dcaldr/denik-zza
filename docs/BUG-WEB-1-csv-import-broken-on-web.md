# BUG-WEB-1: CSV Import Broken on Web Platform

**Status**: ⚠️ CONFIRMED CRITICAL BUG  
**Discovered**: 2025-10-25  
**Severity**: CRITICAL - Feature completely non-functional on web  
**Estimated Fix**: 4-8 hours (requires architectural changes)

## Summary

CSV import functionality is completely broken on web platform due to fundamental architectural incompatibility between web file handling (bytes-only) and the app's file-path-based CSV processing pipeline.

## Problem Description

The CSV import flow fails on web with an `UnsupportedError` because:

1. **Web file pickers can only provide bytes** (no filesystem paths)
2. **The app creates bytes-based payload** for web
3. **The service explicitly blocks bytes on web** with UnsupportedError
4. **The block is correct** because the fallback would crash (uses dart:io which doesn't exist on web)

## Affected Files

### 1. `lib/screens2/csv_review_variants/import_screen.dart` (Line 270-281)

Creates bytes payload on web:

```dart
if (kIsWeb) {
  final Uint8List? bytes = file.bytes;
  if (bytes == null) {
    _logger.e('$csvImportFlowLogTag: File picker did not provide bytes for web payload.');
    _showSnackBar('Soubor se nepodařilo načíst z prohlížeče.');
    return null;
  }
  await _cleanupTempFile();
  return CsvImportPayload.fromBytes(bytes: bytes, displayName: displayName);
}
```

### 2. `lib/services/csv_import_service.dart` (Line 140-147)

Blocks bytes on web:

```dart
if (kIsWeb) {
  _logger.w(
    'CSV import via bytes is not supported on web yet. Display name: ${payload.displayName}',
  );
  throw UnsupportedError(
    'Načtení CSV souboru z paměti není ve webové verzi zatím podporováno.',
  );
}
```

**Note**: The "yet" in the log message indicates this was a known limitation/TODO.

### 3. `lib/input/file_manager.dart` (Line 565-570)

Uses dart:io (unavailable on web):

```dart
case FileManagerMode.production:
  final Directory tempDir = await getTemporaryDirectory();
  final File target = File('${tempDir.path}/$resolvedName');
  await target.writeAsBytes(bytes, flush: true);
  logger.d('Temp CSV written (production): ${target.path}');
  return target.path;
```

## Root Cause Analysis

The entire CSV processing pipeline assumes file paths and temporary file storage:

1. **InputParser** expects file paths (`parser.filePath = path`)
2. **FileManager** uses `dart:io` for temp file operations
3. **Web browsers** don't provide filesystem access - only in-memory bytes
4. **dart:io** package doesn't exist in web builds

This creates an architectural incompatibility:
- Web → Bytes only → Service blocks → Error
- Native → Paths or bytes → Service writes temp file → Success

## User Impact

- CSV import fails immediately with error message on web
- No workaround available for web users
- Feature appears in UI but is completely non-functional
- Error message is user-facing: "Načtení CSV souboru z paměti není ve webové verzi zatím podporováno."

## Fix Options

### Option A: In-Memory CSV Parsing for Web (RECOMMENDED)

**Approach**: Refactor InputParser to accept bytes directly without temp files.

**Implementation Steps**:
1. Add new method to InputParser: `Future<void> parseFromBytes(Uint8List bytes)`
2. Convert bytes to String: `String csvContent = utf8.decode(bytes)`
3. Parse CSV content directly without file I/O
4. Update service to use bytes path on web:
   ```dart
   if (payload.isBytes) {
     if (kIsWeb) {
       return await _parseFromBytes(payload.bytes!);
     }
     // Existing native path with temp file
   }
   ```

**Pros**:
- Most aligned with web architecture
- No virtual filesystem needed
- Cleaner separation of concerns
- Fast to implement (4-6 hours)

**Cons**:
- Requires InputParser refactoring
- Need to handle large files in memory

### Option B: Browser-Specific Temp Storage

**Approach**: Use IndexedDB or localStorage for virtual temp files.

**Implementation Steps**:
1. Create WebFileManager extending FileManager
2. Override writeTempCsvBytes to use IndexedDB
3. Add async cleanup logic
4. Handle storage quotas

**Pros**:
- Minimal changes to InputParser
- Keeps existing architecture

**Cons**:
- Much more complex (6-8 hours)
- Browser storage limitations
- Async complexity
- Probably overkill for this use case

### Option C: Disable CSV Import on Web

**Approach**: Show clear error in UI before file picker.

**Implementation Steps**:
1. Add platform check before showing file picker
2. Display explanatory message
3. Document as platform limitation

**Pros**:
- Fast to implement (30 minutes)
- Clear user communication

**Cons**:
- Loses functionality on web
- Poor user experience
- Not a real fix

## Recommended Solution

**Choose Option A: In-Memory CSV Parsing**

This approach:
- Solves the problem properly
- Is architecturally sound for web
- Takes reasonable time (4-6 hours)
- Maintains feature parity across platforms

## Implementation Plan

1. **Phase 1: InputParser Refactoring** (2-3 hours)
   - Add `parseFromBytes(Uint8List bytes)` method
   - Extract common parsing logic
   - Handle String-based CSV parsing
   - Update tests for new path

2. **Phase 2: Service Integration** (1-2 hours)
   - Remove kIsWeb guard that throws UnsupportedError
   - Add bytes handling path for web
   - Keep existing temp file path for native
   - Update error handling

3. **Phase 3: Testing** (1-2 hours)
   - Add web-specific test cases
   - Mock web environment
   - Test large file handling
   - Integration tests with file picker

4. **Phase 4: Documentation** (30 minutes)
   - Update csv_flow_review.md
   - Add code comments
   - Update technical-todo.md

## Testing Checklist

- [ ] Web file picker provides bytes successfully
- [ ] InputParser.parseFromBytes handles valid CSV
- [ ] InputParser.parseFromBytes handles invalid CSV with proper errors
- [ ] Service routes web bytes to in-memory parsing
- [ ] Service routes native bytes through temp file (existing behavior)
- [ ] No temp file creation on web
- [ ] Large files handled without memory issues
- [ ] All existing tests still pass
- [ ] New web-specific tests pass
- [ ] End-to-end CSV import works on web
- [ ] End-to-end CSV import still works on native

## Related Issues

- **ORG-1**: Rejected - investigation led to discovery of this bug
- See `docs/reports/csv_flow_review.md` sections:
  - ORG-1 (rejected as false issue)
  - BUG-WEB-1 (this bug)

## Notes

- The service's UnsupportedError is actually **correct** - it prevents a crash
- The real problem is the pipeline architecture, not the guard
- The "yet" in the log message suggests this was always a planned TODO
- This was discovered during anti-over-engineering review (ORG-1 investigation)
