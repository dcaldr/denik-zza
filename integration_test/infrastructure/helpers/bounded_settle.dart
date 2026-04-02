import 'package:flutter_test/flutter_test.dart';

Future<void> boundedSettle(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 4),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final endTime = DateTime.now().add(timeout);
  do {
    await tester.pump(step);
  } while (tester.binding.hasScheduledFrame && DateTime.now().isBefore(endTime));
}