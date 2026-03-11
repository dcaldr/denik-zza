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
  bool _softMode = false;
  final List<_SoftError> _collectedErrors = [];

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

  /// Enables soft mode. In soft mode, [step] will catch errors and collect them
  /// instead of rethrowing immediately. Errors will be rethrown by [finalize].
  void enableSoftMode() {
    _softMode = true;
    _collectedErrors.clear(); // Clear any previous errors when enabling soft mode
    AppLogger.l.i('💡 TestStepLogger soft mode enabled.');
  }

  /// Finalizes the test run. If soft mode is enabled and errors were collected,
  /// this method will rethrow the first collected error.
  void finalize() {
    if (_softMode) {
      _softMode = false; // Reset soft mode
      if (_collectedErrors.isNotEmpty) {
        final firstError = _collectedErrors.first;
        debugPrint('\n❌❌❌ FINALIZATION FAILED: ${firstError.stepName} ❌❌❌');
        debugPrint('Collected ${_collectedErrors.length} errors in soft mode.');
        if (firstError.phaseName != null) {
          _currentPhase = firstError.phaseName;
        }
        _flushBuffer(firstError.stepName, firstError.error, firstError.stack, firstError.bufferedLogs);
        _collectedErrors.clear(); // Clear after flushing
        Error.throwWithStackTrace(firstError.error, firstError.stack);
      }
      AppLogger.l.i('✅ TestStepLogger soft mode finalized with no errors.');
    }
    _collectedErrors.clear(); // Always clear collected errors
    _buffer.clear(); // Always clear buffer
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
      if (_softMode) {
        // In soft mode, collect the error and continue
        _collectedErrors.add(
          _SoftError(name, _currentPhase, e, stack, List.of(_buffer)),
        );
        debugPrint(
          '⚠️ FIRST FAILURE CANDIDATE: step="$name" phase="${_currentPhase ?? 'n/a'}"',
        );
        AppLogger.l.e('⚠️ [STEP FAILED - SOFT MODE] "$name" - Error collected.', error: e, stackTrace: stack);
        // Return a default value. This might need to be handled carefully by the caller
        // if T is non-nullable and there's no sensible default.
        return null as T; // This cast assumes T can be null or caller handles it.
      } else {
        // On failure: Flush everything
        _flushBuffer(name, e, stack);
        rethrow;
      }
    } finally {
      _buffer.clear();
    }
  }

  void _flushBuffer(String stepName, Object error, StackTrace stack, [List<OutputEvent>? logsToFlush]) {
    debugPrint('\n❌❌❌ STEP FAILED: "$stepName" ❌❌❌');
    if (_currentPhase != null) {
      debugPrint('📂 Phase: $_currentPhase');
    }
    debugPrint('────────────────── LOGS DUMP START ──────────────────');
    
    // We use a temporary simple printer to dump the events to console
    // because we are technically inside the LogOutput, we can't use AppLogger here 
    // without risking infinite recursion if we weren't careful.
    // But since we are just printing strings via debugPrint, it's safe.
    final bufferToDump = logsToFlush ?? _buffer;
    for (final event in bufferToDump) {
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

/// Private class to hold error details when in soft mode.
class _SoftError {
  final String stepName;
  final String? phaseName;
  final Object error;
  final StackTrace stack;
  final List<OutputEvent> bufferedLogs;

  _SoftError(this.stepName, this.phaseName, this.error, this.stack, this.bufferedLogs);
}
