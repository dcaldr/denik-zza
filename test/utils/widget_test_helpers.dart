import 'dart:ui';
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
    throw TestFailure('Timed out waiting for ${finder.toString()} to disappear');
  }
}

/// Pumps frames until the widget defined by [finder] is present in the widget tree.
///
/// This is a robust, dynamic way to wait for delayed UI population
/// (like Drift stream emissions) without brittle loops or [Future.delayed].
///
/// [timeout] defaults to 10 seconds.
/// Throws a [TestFailure] if the widget is not present after the timeout.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  bool found = finder.evaluate().isNotEmpty;

  int iter = 0;
  while (!found && DateTime.now().isBefore(end)) {
    iter++;
    if (iter % 10 == 0) {
      print('[VERBOSE] pumpUntilFound (${finder.toString()}): iter $iter, fake_time: ${DateTime.now()} (waiting for isolate stream)');
    }
    // Drift Streams cross isolate/asynchronous boundaries. We MUST yield to the real 
    // Dart event loop to prevent FakeAsync from starving the database read operations!
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 10)));
    await tester.pump(const Duration(milliseconds: 50));
    found = finder.evaluate().isNotEmpty;
  }
  print('[VERBOSE] pumpUntilFound finished. found: $found, iter: $iter');

  if (!found) {
    throw TestFailure('Timed out waiting for ${finder.toString()} to appear');
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

/// A centralized emergency fallback for setting explicitly dimensioned surfaces.
/// 
/// ⚠️ ANTI-PATTERN WARNING: Hardcoding surface sizes in Widget tests is generally 
/// a bad practice and should be avoided. Tests should ideally be responsive and 
/// agnostic to absolute pixel coordinates.
/// 
/// 🚨 USE CASE: This is meant STRICTLY as an emergency bypass for the `printing` 
/// package's `PdfPreview` widget, which enters catastrophic infinite Measure 
/// loops when rendered in headless test zones without explicit geometric bounds.
/// DO NOT use this to fix generic layout overflows.
Future<void> applyPdfPreviewSurfaceWorkaround(WidgetTester tester) async {
  // 1280x720 is the standard Flutter desktop `run` default. We define it once 
  // here to prevent scattering magic numbers across the codebase.
  await tester.binding.setSurfaceSize(const Size(1280, 720));
}
