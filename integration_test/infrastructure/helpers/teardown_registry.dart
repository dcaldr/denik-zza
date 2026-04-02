// TeardownRegistry - Centralized disposal ownership management for test teardowns.
//
// Prevents duplicate disposal calls that cause test timeouts and ConnectionClosedException.
// Thread-safe singleton using internal Mutex implementation (no external async_lock dependency).
//
// Usage:
// ```dart
// // Guard disposal calls with ownership claims:
// if (TeardownRegistry.instance.claimOwnership('database', TeardownScope.testLevel)) {
//   await Database.dispose();
// }
//
// // Track lifecycle phases:
// TeardownRegistry.instance.recordPhase('database_dispose_start', 'started');
// await Database.dispose();
// TeardownRegistry.instance.recordPhase('database_dispose_end', 'completed');
// ```

import 'dart:async';

enum TeardownScope {
  /// Test-level teardown (individual testWidgets block)
  testLevel,
  
  /// Group-level teardown (group() block within a test suite)
  groupLevel,
  
  /// Suite-level teardown (global teardown across all tests)
  suiteLevel,
}

/// Records a phase in the teardown lifecycle.
class TeardownPhase {
  final String name;
  final String status; // 'started', 'completed', 'failed'
  final int durationMs;
  final DateTime recordedAt;

  TeardownPhase({
    required this.name,
    required this.status,
    this.durationMs = 0,
    DateTime? recordedAt,
  }) : recordedAt = recordedAt ?? DateTime.now();

  @override
  String toString() =>
      'TeardownPhase($name, status=$status, duration=${durationMs}ms @ $recordedAt)';
}

/// Simple async synchronization using Completer with timeout protection.
class _Mutex {
  Completer<void>? _currentLock;

  Future<void> lock(Future<void> Function() fn) async {
    // Wait for any existing lock with timeout protection
    Completer<void>? existingLock = _currentLock;
    if (existingLock != null && !existingLock.isCompleted) {
      try {
        await existingLock.future.timeout(const Duration(seconds: 5));
      } catch (e) {
        // If timeout, proceed anyway to prevent total hang
      }
    }

    // Create new lock
    final newLock = Completer<void>();
    _currentLock = newLock;
    
    try {
      await fn();
    } catch (e) {
      rethrow;
    } finally {
      // Always complete and clear the lock
      if (!newLock.isCompleted) {
        newLock.complete();
      }
      if (_currentLock == newLock) {
        _currentLock = null;
      }
    }
  }
}

/// Centralized registry for test teardown resource ownership.
///
/// Singleton that tracks which resources have been claimed for disposal at each scope level.
/// Prevents duplicate disposals by returning false if a resource is already owned at that scope.
///
/// Thread-safe via internal Mutex implementation.
class TeardownRegistry {
  static final TeardownRegistry _instance = TeardownRegistry._internal();
  static TeardownRegistry get instance => _instance;

  // Ownership tracking: resource -> scope -> owner (test name or null for suite)
  final Map<String, Map<TeardownScope, String?>> _ownedResources = {};
  final List<TeardownPhase> _phases = [];
  final _Mutex _mutex = _Mutex();

  bool _initialized = false;
  String? _currentTestName;
  bool _debugMode = false;

  TeardownRegistry._internal();

  /// Mark that a test has started. Must be called once per test setUp().
  /// Thread-safe: acquires mutex lock before updating state.
  Future<void> markTestStarted(String testName) async {
    await _mutex.lock(() async {
      _currentTestName = testName;
      _initialized = true;
    });
  }

  /// Claim ownership of a resource at a specific scope.
  /// Returns true if this is the first claim; false if already owned.
  /// 
  /// This guards disposal calls:
  /// ```dart
  /// if (TeardownRegistry.instance.claimOwnership('database', TeardownScope.testLevel)) {
  ///   await database.dispose();
  /// }
  /// ```
  bool claimOwnership(String resource, TeardownScope scope) {
    _ownedResources.putIfAbsent(resource, () => {});

    if (_ownedResources[resource]!.isNotEmpty) {
      // Already owned by some scope - second claim denied
      return false;
    }

    // First claim - mark as owned by current test/suite
    _ownedResources[resource]![scope] = _currentTestName;
    return true;
  }

  /// Record a teardown phase for diagnostic purposes.
  /// Tracks timing and status of lifecycle events.
  void recordPhase(String name, String status, {int? durationMs}) {
    _phases.add(TeardownPhase(
      name: name,
      status: status,
      durationMs: durationMs ?? 0,
      recordedAt: DateTime.now(),
    ));
  }

  /// Whether debug mode is enabled.
  bool get isDebugMode => _debugMode;

  /// Enable debug mode tracking.
  void setDebugMode(bool enabled) {
    _debugMode = enabled;
  }

  /// Reset state between tests. Called in tearDown() cleanup.
  /// Thread-safe: acquires mutex lock before clearing.
  Future<void> reset() async {
    await _mutex.lock(() async {
      _ownedResources.clear();
      _phases.clear();
      _currentTestName = null;
      _initialized = false;
      _debugMode = false;
    });
  }

  /// Get diagnostic dump for debugging teardown issues.
  /// Returns detailed string with all tracked phases and ownership info.
  String getDiagnosticDump() {
    final buffer = StringBuffer();
    buffer.writeln('=== TeardownRegistry Diagnostic Dump ===');
    buffer.writeln('Current Test: $_currentTestName');
    buffer.writeln('Initialized: $_initialized');
    buffer.writeln('Debug Mode: $_debugMode');
    buffer.writeln();

    buffer.writeln('Owned Resources:');
    _ownedResources.forEach((resource, scopeMap) {
      scopeMap.forEach((scope, owner) {
        buffer.writeln('  $resource @ ${scope.toString()} -> owner: $owner');
      });
    });
    if (_ownedResources.isEmpty) {
      buffer.writeln('  (none)');
    }
    buffer.writeln();

    buffer.writeln('Recorded Phases:');
    for (final phase in _phases) {
      buffer.writeln('  $phase');
    }
    if (_phases.isEmpty) {
      buffer.writeln('  (none)');
    }

    return buffer.toString();
  }
}
