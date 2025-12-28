import 'package:logger/logger.dart';

/// Centralized logger for the app with a global, adjustable filter.
///
/// - Use AppLogger.l everywhere instead of creating new Logger() instances.
/// - Tests can call [configureForTests] to reduce noise (e.g., only errors).
const String csvImportFlowLogTag = 'CSV_IMPORT_FLOW';

class AppLogger {
  AppLogger._();

  static final LogPrinter _printer = PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 100,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  );

  static Logger _logger = Logger(
    filter: _AppLogFilter(),
    printer: _printer,
  );

  /// Access the shared Logger instance.
  static Logger get l => _logger;

  /// Configure custom output (e.g., for capturing logs in tests).
  static void configureOutput(LogOutput output) {
    _logger = Logger(
      filter: _AppLogFilter(),
      printer: _printer,
      output: output,
    );
  }

  /// Reset logger to default configuration.
  static void reset() {
    _logger = Logger(
      filter: _AppLogFilter(),
      printer: _printer,
    );
  }



  /// Configure global minimum level for logs (useful in tests).
  static void setMinLevel(Level level) {
    _AppLogFilter.minLevel = level;
  }

  /// Convenience for tests to silence non-critical logs.
  static void configureForTests({Level level = Level.error}) {
    setMinLevel(level);
  }
}

/// Global filter driven by a static minLevel, affecting all AppLogger logs.
class _AppLogFilter extends LogFilter {
  static Level minLevel = Level.debug;

  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= minLevel.index;
  }
}
