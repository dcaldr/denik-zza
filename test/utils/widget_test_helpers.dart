import 'package:flutter_test/flutter_test.dart';

/// Pumps frames until the widget defined by [finder] is no longer present in the widget tree.
///
/// This is a robust way to wait for transient UI elements (like loading spinners)
/// to disappear without using brittle [Future.delayed] or potentially hanging [pumpAndSettle].
///
/// [timeout] defaults to 10 seconds.
/// Throws a [TestFailure] if the widget is still present after the timeout.
Future<void> pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  bool found = finder.evaluate().isNotEmpty;

  while (found && DateTime.now().isBefore(end)) {
    // Pump a single frame with duration to advance clock and process timers (e.g. Drift)
    await tester.pump(const Duration(milliseconds: 100));
    found = finder.evaluate().isNotEmpty;
  }


  if (found) {
    throw TestFailure('Timed out waiting for ${finder.description} to disappear');
  }
}

/// A "Drift-safe" replacement for [WidgetTester.pumpAndSettle].
///
/// Standard [pumpAndSettle] may hang if background timers (Drift isolates)
/// are waiting for time to pass, as [pump] without duration freezes the clock.
///
/// This helper pumps with a 100ms duration step.
Future<int> pumpAndSettleWithDuration(
  WidgetTester tester, {
  Duration duration = const Duration(milliseconds: 100),
  EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  Duration timeout = const Duration(minutes: 10),
}) async {
  int count = 0;
  final end = DateTime.now().add(timeout);
  
  // Initial pump
  await tester.pump(duration, phase);
  count++;

  while (tester.binding.hasScheduledFrame && DateTime.now().isBefore(end)) {
    await tester.pump(duration, phase);
    count++;
  }
  
  return count;
}
