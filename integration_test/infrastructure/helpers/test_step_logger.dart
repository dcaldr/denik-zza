import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:denik_zza/utils/app_logger.dart';

/// specialized logger for E2E tests that buffers logs and only shows them on failure.
///
/// Wraps [AppLogger] to capture all application logs during a "step".
/// - On Success: Logs are discarded (silent console).
/// - On Failure: Logs are flushed to console for debugging.
class TestStepLogger extends LogOutput {
  static final TestStepLogger _instance = TestStepLogger._();
  factory TestStepLogger() => _instance;

  TestStepLogger._();

  final List<OutputEvent> _buffer = [];
  String? _currentPhase;

  /// Initialize this logger and redirect AppLogger output to it.
  static void initialize() {
    AppLogger.configureOutput(_instance);
  }

  /// Reset AppLogger to default.
  static void dispose() {
    AppLogger.reset();
  }

  @override
  void output(OutputEvent event) {
    _buffer.add(event);
  }

  /// Start a new major section/phase.
  void section(String title) {
    _currentPhase = title;
    // Simple, clean header without massive banners
    debugPrint('\n🔹 [SECTION] $title');
  }

  /// Execute a specific test step with buffering.
  Future<T> step<T>(String name, Future<T> Function() action) async {
    _buffer.clear();
    // Log start internally (will be buffered)
    AppLogger.l.i('⏳ [STEP START] $name');

    try {
      final result = await action();
      // On success: do nothing (silence)
      return result;
    } catch (e, stack) {
      // On failure: Flush everything
      _flushBuffer(name, e, stack);
      rethrow;
    } finally {
      _buffer.clear();
    }
  }

  void _flushBuffer(String stepName, Object error, StackTrace stack) {
    debugPrint('\n❌❌❌ STEP FAILED: "$stepName" ❌❌❌');
    if (_currentPhase != null) {
      debugPrint('📂 Phase: $_currentPhase');
    }
    debugPrint('────────────────── LOGS DUMP START ──────────────────');
    
    // We use a temporary simple printer to dump the events to console
    // because we are technically inside the LogOutput, we can't use AppLogger here 
    // without risking infinite recursion if we weren't careful.
    // But since we are just printing strings via debugPrint, it's safe.
    for (final event in _buffer) {
      for (final line in event.lines) {
        debugPrint(line);
      }
    }
    debugPrint('────────────────── LOGS DUMP END ────────────────────');
    debugPrint('💥 Exception: $error');
    debugPrint('Stack trace:\n$stack');
    debugPrint('════════════════════════════════════════════════════════════\n');
  }
}
