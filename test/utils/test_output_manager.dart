import 'dart:io';
import 'package:path/path.dart' as path;
import 'test_configuration.dart';

/// Manages test output directories and file paths for different testing modes
class TestOutputManager {
  static const String _testOutputsDir = 'test_outputs';
  static const String _persistDir = 'persist';
  static const String _productionDir = 'production';
  
  /// Initialize test output directories based on current test mode
  static Future<void> initialize() async {
    final testMode = TestConfiguration.getTestMode();
    
    switch (testMode) {
      case TestMode.inMemory:
        // No directory initialization needed for in-memory mode
        break;
      case TestMode.persist:
        await _ensureDirectoryExists(_getPersistDir());
        break;
      case TestMode.production:
        if (TestConfiguration.isProductionSafe) {
          await _ensureDirectoryExists(_getProductionDir());
        } else {
          throw Exception('Production testing requires CONFIRM_PRODUCTION_TESTING=yes');
        }
        break;
    }
  }
  
  /// Get the base test outputs directory path
  static String getTestOutputsDir() {
    return path.absolute(_testOutputsDir);
  }
  
  /// Get directory for persist mode
  static String _getPersistDir() {
    return path.join(getTestOutputsDir(), _persistDir);
  }
  
  /// Get directory for production mode  
  static String _getProductionDir() {
    return path.join(getTestOutputsDir(), _productionDir);
  }
  
  /// Get database file path for current test mode
  static String getDatabasePath(String filename) {
    final testMode = TestConfiguration.getTestMode();
    
    switch (testMode) {
      case TestMode.inMemory:
        // Return empty string for in-memory databases
        return '';
      case TestMode.persist:
        return path.join(_getPersistDir(), filename);
      case TestMode.production:
        return path.join(_getProductionDir(), filename);
    }
  }
  
  /// Clean up test outputs (useful for CI environments)
  static Future<void> cleanup() async {
    final testOutputsDir = Directory(getTestOutputsDir());
    if (await testOutputsDir.exists()) {
      await testOutputsDir.delete(recursive: true);
    }
  }
  
  /// Clean up only persist mode outputs
  static Future<void> cleanupPersist() async {
    final persistDir = Directory(_getPersistDir());
    if (await persistDir.exists()) {
      await persistDir.delete(recursive: true);
    }
  }
  
  /// Clean up only production mode outputs
  static Future<void> cleanupProduction() async {
    final productionDir = Directory(_getProductionDir());
    if (await productionDir.exists()) {
      await productionDir.delete(recursive: true);
    }
  }
  
  /// Get output summary for debugging
  static Map<String, dynamic> getOutputSummary() {
    return {
      'testOutputsDir': getTestOutputsDir(),
      'persistDir': _getPersistDir(),
      'productionDir': _getProductionDir(),
      'currentMode': TestConfiguration.modeString,
      'outputsExist': Directory(getTestOutputsDir()).existsSync(),
    };
  }
  
  /// Ensure directory exists, create if needed
  static Future<void> _ensureDirectoryExists(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }
}
