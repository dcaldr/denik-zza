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

  /// Pumps a single frame without waiting for animations to settle.
  ///
  /// Use this instead of pumpAndSettle when:
  /// - You need control over timing
  /// - There are infinite animations (loaders) that prevent settling
  /// - You want faster test execution for simple operations
  Future<void> pump([Duration? duration]) async {
    await tester.pump(duration);
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

  /// Waits for a widget with the given key to appear.
  ///
  /// Use this instead of pumpAndSettle when there are infinite animations
  /// (like CircularProgressIndicator) that prevent settling.
  ///
  /// Returns true if widget was found within timeout, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final found = await waitForKey('ParticipantList_container');
  /// expect(found, isTrue);
  /// ```
  Future<bool> waitForKey(
    String key, {
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    final finder = findKey(key);

    while (stopwatch.elapsed < timeout) {
      await pump(pollInterval);
      if (finder.evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Waits for text to appear in the widget tree.
  ///
  /// Use this instead of pumpAndSettle when there are infinite animations
  /// (like CircularProgressIndicator) that prevent settling.
  ///
  /// Returns true if text was found within timeout, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// final found = await waitForText('Karel Čapek');
  /// expect(found, isTrue, reason: 'Participant should appear in list');
  /// ```
  Future<bool> waitForText(
    String text, {
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    final finder = findText(text);

    while (stopwatch.elapsed < timeout) {
      await pump(pollInterval);
      if (finder.evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Helper to confirm date picker dialogs.
  Future<void> confirmDatePicker() async {
    // Try standard material "OK" (English/Default)
    if (find.text('OK').evaluate().isNotEmpty) {
      await tap(find.text('OK'));
      await pumpAndSettle();
      return;
    }
    // Try "Uložit"
    if (find.text('Uložit').evaluate().isNotEmpty) {
      await tap(find.text('Uložit'));
      await pumpAndSettle();
      return;
    }
    // Try "Vybrat"
    if (find.text('Vybrat').evaluate().isNotEmpty) {
      await tap(find.text('Vybrat'));
      await pumpAndSettle();
      return;
    }
  }

  // ==================== DRAWER NAVIGATION ====================

  /// Opens the app drawer by tapping the menu icon.
  Future<void> openDrawer() async {
    await tap(findIcon(Icons.menu));
  }

  /// Taps the Intake Form item in the drawer.
  ///
  /// Requires drawer to be open first.
  Future<void> tapDrawerIntakeForm() async {
    await tap(findKey('AppDrawer_intake_form'));
  }

  /// Taps the New Record item in the drawer.
  Future<void> tapDrawerNewRecord() async {
    await tap(findKey('AppDrawer_new_record'));
  }

  /// Taps the Print Center item in the drawer.
  Future<void> tapDrawerPrintCenter() async {
    await tap(findKey('AppDrawer_print_center'));
  }

  /// Navigates to Intake Form via drawer.
  ///
  /// Opens drawer and taps intake form button.
  Future<void> navigateToIntakeForm() async {
    await openDrawer();
    await tapDrawerIntakeForm();
  }

  /// Navigates to New Record Page via drawer.
  Future<void> navigateToNewRecordPage() async {
    await openDrawer();
    await tapDrawerNewRecord();
  }

  /// Navigates to Print Center via drawer.
  Future<void> navigateToPrintCenter() async {
    await openDrawer();
    await tapDrawerPrintCenter();
  }
}
