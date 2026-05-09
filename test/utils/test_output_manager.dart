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

  /// Clean up stale test artifacts.
  ///
  /// Only removes entries older than [maxAgeHours] (default: 1 hour).
  /// This ensures the previous run's artifacts remain inspectable until
  /// the next run's cleanup fires, rather than being destroyed immediately.
  static Future<void> cleanup({int maxAgeHours = 1}) async {
    final testOutputsDir = Directory(getTestOutputsDir());
    if (!testOutputsDir.existsSync()) return;

    final cutoff = DateTime.now().subtract(Duration(hours: maxAgeHours));

    try {
      await for (final entity in testOutputsDir.list(recursive: false)) {
        final stat = await entity.stat();
        if (stat.modified.isBefore(cutoff)) {
          try {
            await entity.delete(recursive: true);
          } catch (_) {
            // Ignore file-lock errors (parallel isolates)
          }
        }
      }
    } catch (_) {
      // Directory may have been wiped by a concurrent isolate — ignore
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
