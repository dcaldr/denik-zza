/// Test configuration using --dart-define flags
/// 
/// Usage:
/// - flutter test → inMemory mode (default)
/// - flutter test --dart-define=TEST_MODE=persist → persist mode  
/// - flutter test --dart-define=TEST_MODE=production → production mode
enum TestMode { 
  inMemory,    // Default - no disk writes, database in-memory
  persist,     // Persistent test outputs in test_outputs/
  production   // Real app mode with safety validations
}

class TestConfiguration {
  /// Gets test mode from --dart-define=TEST_MODE, defaults to inMemory
  static TestMode getTestMode() {
    const String modeString = String.fromEnvironment('TEST_MODE', defaultValue: 'inMemory');
    return TestMode.values.firstWhere(
      (mode) => mode.name == modeString,
      orElse: () => TestMode.inMemory,
    );
  }
  
  /// Runtime check methods for debugging
  static bool get isInMemory => getTestMode() == TestMode.inMemory;
  static bool get isPersist => getTestMode() == TestMode.persist;
  static bool get isProduction => getTestMode() == TestMode.production;
  
  /// Get mode as string for logging
  static String get modeString => getTestMode().name;
  
  /// Get configuration summary for debugging
  static Map<String, dynamic> getConfigSummary() {
    return {
      'currentMode': modeString,
      'isInMemory': isInMemory,
      'isPersist': isPersist,
      'isProduction': isProduction,
      'environmentVariable': const String.fromEnvironment('TEST_MODE', defaultValue: 'not_set'),
    };
  }
  
  /// Production mode safety check
  static bool get isProductionSafe {
    if (!isProduction) return true;
    
    const confirmProduction = String.fromEnvironment('CONFIRM_PRODUCTION_TESTING', defaultValue: 'no');
    return confirmProduction.toLowerCase() == 'yes';
  }
}
