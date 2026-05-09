import 'dart:io';
import 'package:path/path.dart' as path;

/// Manages test output directories for local persist testing (System B)
class TestOutputManager {
  static const String _testOutputsDir = 'test/.test_artifacts';
  static const String _dbsDir = 'dbs';

  /// Get the base test artifacts directory path (absolute).
  static String getTestOutputsDir() {
    return path.absolute(_testOutputsDir);
  }

  /// Get directory for databases.
  static String getDbsDir() {
    return path.join(getTestOutputsDir(), _dbsDir);
  }

  /// Get database file path.
  static Future<String> getDatabasePath(String filename) async {
    final dir = getDbsDir();
    await _ensureDirectoryExists(dir);
    return path.join(dir, filename);
  }

  /// Clean up all test artifacts.
  /// Used by flutter_test_config.dart to auto-wipe at the start of a test run.
  static Future<void> cleanup() async {
    final testOutputsDir = Directory(getTestOutputsDir());
    try {
      if (await testOutputsDir.exists()) {
        await testOutputsDir.delete(recursive: true);
      }
    } catch (e) {
      // Ignore concurrent deletion errors when flutter test runs in parallel isolates
    }
  }

  /// Ensure directory exists, create if needed.
  static Future<void> _ensureDirectoryExists(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }
}
