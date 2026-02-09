# Testing Best Practices: Avoiding Hangs & Flakes

> [!IMPORTANT]
> The #1 cause of test hangs in our suite is **Timer Deadlocks** in `FakeAsync` environments when using Drift/Isolates.

## 1. Always Pump with Duration for Async Streams
When testing widgets that rely on Drift streams or complex isolate communication, `tester.pump()` alone is NOT enough. It typically freezes the clock, preventing background timers from firing.

**Problem:**
```dart
// BAD: Clock is frozen. Stream awaiting a timer/microtask might never emit.
await tester.pump(); 
await tester.pumpAndSettle(); // Hangs if background process is waiting for time
```

**Solution:**
Advance the clock explicitly to flush timers and allow background work to complete.
```dart
// GOOD: Advances clock by 100ms, allowing Drift/Timers to process
await tester.pump(const Duration(milliseconds: 100));
```

Use the `test/utils/widget_test_helpers.dart` utilities:
- `pumpUntilGone(tester, finder)`: Automatically pumps with duration.

## 2. Prefer Fake Services in Widget Tests
Drift's in-memory database (`AppDatabase.testInMemory`) is great for unit tests but **flaky** in Widget Tests due to race conditions between the main test isolate and Drift's transaction executor.

**Recommendation:**
For widget tests (robots), mock the service layer instead of using the real DB.

**Example:**
Instead of:
```dart
// Flaky: Uses real DB streams which might deadlock
final controller = PrintStateController(PrintCenterService()); 
```

Do this:
```dart
// Stable: Uses controlled behavior
class FakePrintService extends PrintCenterService { ... }
final controller = PrintStateController(FakePrintService());
```

## 3. Debugging Hangs
If a test hangs:
1. **Check for `pump()` loops**: Is something waiting for an animation/stream that never completes because time isn't moving?
2. **Add Logging**: Write to a file (not `print()`, which may be swallowed), as we did with `debug_log.txt`.
3. **Isolate**: Create a localized test to see if the logic works outside the widget tree.
