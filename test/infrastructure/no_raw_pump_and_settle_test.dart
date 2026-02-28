import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Guard test: Ensures no integration test file uses raw `tester.pumpAndSettle()`
/// outside of `base_robot.dart`.
///
/// Raw `pumpAndSettle()` hangs indefinitely on infinite animations (spinners,
/// progress indicators). All settling must go through `BaseRobot.pumpAndSettle()`
/// or use bounded `tester.pump(Duration)` instead.
///
/// If this test fails, replace:
///   `await tester.pumpAndSettle();`
/// with one of:
///   `await pumpAndSettle();`  (inside a Robot — uses BaseRobot's method)
///   `await tester.pump(const Duration(milliseconds: 500));`  (in test body)
void main() {
  test('no raw tester.pumpAndSettle() in integration tests outside BaseRobot',
      () {
    final integrationDir = Directory('integration_test');
    expect(integrationDir.existsSync(), isTrue,
        reason: 'integration_test directory must exist');

    final violations = <String>[];

    final dartFiles = integrationDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        // base_robot.dart is the ONLY file allowed to call tester.pumpAndSettle
        .where((f) => !f.path.contains('base_robot.dart'));

    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      final lines = content.split('\n');

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.contains('tester.pumpAndSettle()') ||
            line.contains('tester.pumpAndSettle(')) {
          // Allow commented-out lines
          final trimmed = line.trimLeft();
          if (trimmed.startsWith('//') || trimmed.startsWith('*')) continue;

          violations.add(
            '${file.path}:${i + 1}: ${line.trim()}',
          );
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Found raw tester.pumpAndSettle() calls outside BaseRobot. '
          'Use robot.pumpAndSettle() or tester.pump(Duration) instead.\n'
          'Violations:\n${violations.join('\n')}',
    );
  });
}
