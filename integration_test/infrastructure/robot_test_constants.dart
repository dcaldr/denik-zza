/// Test infrastructure constants for integration tests.
///
/// Values here are test-specific and do NOT collide with design system tokens
/// (which live in lib/design_system/tokens/).
///
/// Use these constants to avoid magic numbers scattered across robot code.
class RobotTestConstants {
  RobotTestConstants._();

  // ============ Drag/Scroll Configuration ============
  /// Maximum number of drag attempts before giving up on scrolling
  static const int dragMaxAttempts = 100;

  /// Vertical offset per drag operation (negative = scroll down)
  static const double dragOffsetPx = 200.0;

  /// Duration for each drag operation to complete
  static const Duration dragDuration = Duration(milliseconds: 40);

  // ============ Wait/Timeout Configuration ============
  /// Standard timeout for waiting on UI elements
  static const Duration waitTimeoutStandard = Duration(seconds: 5);

  /// Extended timeout for operations with network/database delays
  static const Duration waitTimeoutExtended = Duration(seconds: 10);

  /// Short timeout for quick operations
  static const Duration waitTimeoutShort = Duration(seconds: 2);

  /// Minimum visible records before considering list fully loaded
  static const int minVisibleRecordsForLoad = 3;

  // ============ Print State Card Heights (Test Specific) ============
  /// Maximum expanded height ratio for print state card (test variant)
  static const double expandedHeightRatio = 0.4;

  /// Medium height ratio for print state card (test variant)
  static const double mediumHeightRatio = 0.35;

  /// Compact height ratio for print state card (test variant)
  static const double compactHeightRatio = 0.3;

  // ============ Animation/Pump Durations ============
  /// Short pump duration for basic frame setup
  static const Duration pumpShort = Duration(milliseconds: 500);

  /// Standard pump duration for UI transitions
  static const Duration pumpStandard = Duration(milliseconds: 100);

  /// Key wait duration before expecting UI changes
  static const Duration keyWaitPrelude = Duration(milliseconds: 500);
}
