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
    // Pump a single frame only.
    // This allows animations/futures to progress without waiting for "settled" state.
    await tester.pump();
    found = finder.evaluate().isNotEmpty;
  }

  if (found) {
    throw TestFailure('Timed out waiting for ${finder.description} to disappear');
  }
}
