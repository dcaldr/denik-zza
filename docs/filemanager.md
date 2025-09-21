ok ive read # FileManager Documentation

## Overview

The FileManager class handles file and directory operations for the Deník ZZA application, with support for different operational modes and robust backup functionality. It manages event directories, database backups, and provides configurable behavior for testing and production environments.

## Core Features

- **Multi-mode operation**: In-memory, persistent, and production modes
- **Event directory management**: Creates and manages per-event folder structures
- **Database backup**: Creates safe backups with collision resolution
- **IO validation**: Optional writability/readability checks
- **Test-friendly**: Configurable paths and modes for testing

## Operational Modes

The FileManager supports three operational modes via the `FileManagerMode` enum:

### InMemory Mode
- **Purpose**: Testing and development
- **Behavior**: Minimal file operations, primarily in-memory
- **Subfolders**: None (`subFolders: 0`)
- **Use case**: Unit tests, development without file system dependencies

### Persist Mode  
- **Purpose**: Development and testing with file persistence
- **Behavior**: Full file operations with persistent storage
- **Subfolders**: Standard structure (`subFolders: 1`)
- **Use case**: Integration tests, development debugging

### Production Mode
- **Purpose**: Live application usage
- **Behavior**: Full file operations with production paths
- **Subfolders**: Complete structure (`subFolders: 2`) 
- **Use case**: Real application deployment

## API Reference

### Constructor
```dart
FileManager({
  String? testOutputPath,
  FileManagerMode mode = FileManagerMode.production
})
```

**Parameters:**
- `testOutputPath`: Optional custom path for test outputs (overrides mode-based paths)
- `mode`: Operational mode (default: production)

### Core Methods

#### Directory Management

```dart
Future<String?> createNewEventDataDir(String nazevAkce)
```
Creates a new event directory with the given name.
- **Returns**: Directory path on success, null on failure
- **Behavior**: Creates directory structure, sets up subfolders based on mode
- **Side effects**: Updates internal `eventDir` state

```dart
Future<bool> changeEvent(String cesta)
```
Changes the current event directory.
- **Parameters**: `cesta` - path to event directory
- **Returns**: true on success, false on failure
- **Behavior**: Validates directory exists, updates internal state

#### Backup Operations

```dart
Future<bool> backupDB()
```
Creates a backup of the current database.
- **Returns**: true on success, false on failure
- **Source**: Copies `db.sqlite` from database directory
- **Destination**: `{eventDir}/backup/db_backup.sqlite`
- **Features**: Automatic collision resolution, content verification

#### Utility Methods

```dart
Future<bool> verifyWritableReadable(Directory dir)
```
Tests directory for read/write access.
- **Purpose**: IO sanity check
- **Method**: Creates temporary `.io_probe` file, writes, reads, deletes
- **Returns**: true if all operations succeed

```dart
void setIoCheckOnChange(bool enabled)
```
Toggles IO checking during `changeEvent()` operations.
- **Default**: false (disabled)
- **Purpose**: Optional validation without performance overhead

```dart
String getConfigSummary()
```
Returns human-readable configuration summary.
- **Includes**: Mode, subfolder count, event directory, paths

## Directory Structure

FileManager creates the following structure based on mode:

### Production Mode (subFolders: 3)
```
{eventDir}/
├── backup/           # Database backups
├── zpusobilosti/     # Qualification/capability files
└── vysetreni/        # Examination/medical record files
```

### Persist Mode (subFolders: 3)
```
{eventDir}/
├── backup/           # Database backups
├── zpusobilosti/     # Qualification/capability files
└── vysetreni/        # Examination/medical record files
```

### InMemory Mode (subFolders: 0)
```
{eventDir}/            # Minimal structure
```

## Database Integration

### Database Path Resolution
- **Source**: `DatabaseWrapper.getDatabase().getDbFilePath()`
- **File**: `db.sqlite` in the returned directory
- **Backup**: Copies entire `db.sqlite` file to event backup folder

### Database Modes Alignment
FileManager modes align with database wrapper modes:
- `FileManagerMode.inMemory` → Database in-memory mode
- `FileManagerMode.persist` → Database file mode (test directories)
- `FileManagerMode.production` → Database file mode (app directories)

## Error Handling and Logging

### Logging Policy
- **Framework**: Uses `Logger` package (never `print()`)
- **Levels**: 
  - `INFO`: Normal operations, mode changes
  - `WARN`: Non-critical issues, fallbacks
  - `ERROR`: Failures, exceptions

### Error Modes
- **Directory creation failure**: Returns null, logs error
- **Backup failure**: Returns false, logs detailed error
- **IO validation failure**: Returns false, logs access issues
- **Path resolution failure**: Throws exception with context

## Testing Integration

### Test Helper Usage
```dart
// Use UnifiedTestSetup for consistent test environments
final testPath = await UnifiedTestSetup.setupTestDirectory();
final fileManager = FileManager(
  testOutputPath: testPath,
  mode: FileManagerMode.persist
);
```

### Best Practices
- **Persistent tests**: Use `FileManagerMode.persist` with custom `testOutputPath`
- **Unit tests**: Use `FileManagerMode.inMemory` for speed
- **Cleanup**: Tests should clean up created directories
- **Path handling**: Use `package:path` for cross-platform compatibility

## Usage Examples

### Basic Event Setup
```dart
final fileManager = FileManager(mode: FileManagerMode.production);
final eventPath = await fileManager.createNewEventDataDir("Letní tábor 2024");
if (eventPath != null) {
  print("Event directory created: $eventPath");
}
```

### Database Backup
```dart
final success = await fileManager.backupDB();
if (success) {
  print("Database backup completed successfully");
} else {
  print("Backup failed - check logs for details");
}
```

### Testing Setup
```dart
final testFileManager = FileManager(
  testOutputPath: "test/test_outputs/filemanager_test",
  mode: FileManagerMode.persist
);
// Enables full file operations in controlled test environment
```

### Mode Transitions
```dart
// Start in memory for setup
var fm = FileManager(mode: FileManagerMode.inMemory);

// Switch to persistent for testing
fm = FileManager(mode: FileManagerMode.persist);

// Production deployment
fm = FileManager(mode: FileManagerMode.production);
```

## Migration and Compatibility

### Legacy Support
- **`isTesting` parameter**: Deprecated, maps to mode for backward compatibility
- **Mode precedence**: Explicit mode parameter overrides legacy `isTesting`
- **Path behavior**: `testOutputPath` overrides mode-based path resolution

### Future Considerations
- **Cloud storage**: Mode system designed to accommodate remote storage backends
- **Encryption**: Directory structure supports encrypted subfolder addition
- **Sync**: Event directories designed for potential multi-device synchronization

## Configuration Summary

Use `getConfigSummary()` for debugging and logging:

```dart
print(fileManager.getConfigSummary());
// Output: "Mode: production, SubFolders: 2, EventDir: /path/to/event, ..."
```

This provides complete visibility into FileManager state for troubleshooting and verification.