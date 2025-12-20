import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Base class for all Page Object Robots.
/// Provides common interaction methods wrapped with [pumpAndSettle].
class BaseRobot {
  final WidgetTester tester;

  BaseRobot(this.tester);

  /// Helper to wait for animations to complete.
  Future<void> pumpAndSettle() async {
    await tester.pumpAndSettle();
  }

  /// Taps a widget found by [finder] and waits for animations.
  Future<void> tap(Finder finder) async {
    // print('tapping $finder'); // Optional debug logging
    await tester.tap(finder);
    await pumpAndSettle();
  }

  /// Enters text into a widget found by [finder] and waits.
  Future<void> enterText(Finder finder, String text) async {
    await tester.enterText(finder, text);
    await pumpAndSettle();
  }

  /// Helper to find a widget by its Key String.
  Finder findKey(String key) => find.byKey(Key(key));

  /// Helper to find a widget by Icon data.
  Finder findIcon(IconData icon) => find.byIcon(icon);

  /// Helper to find a widget by Text content.
  Finder findText(String text) => find.text(text);
}
