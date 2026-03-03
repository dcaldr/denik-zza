import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Base class for all Page Object Robots.
/// Provides common interaction methods wrapped with [pumpAndSettle].
class BaseRobot {
  final WidgetTester tester;

  // --- Speed Control ---
  int _interactionRound = 0;
  
  /// Number of rounds to run at human-observable speed before switching to fast mode.
  int get slowRounds => 2;
  
  /// Returns whether the robot should interact at machine speed now.
  bool get isFastMode => _interactionRound >= slowRounds;
  
  /// Call this when a repetitive transaction/form submission completes.
  void incrementRound() => _interactionRound++;
  
  /// Injects a human-observable delay ONLY if not in fast mode.
  Future<void> humanObservationDelay() async {
    if (!isFastMode) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }
  // --------------------

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

  /// Helper that uses pumpAndSettle in normal mode and pump in fast mode.
  /// Use this to replace hardcoded explicit pumpAndSettle() calls.
  Future<void> smartSettle() async {
    if (isFastMode) {
      await pump();
    } else {
      await pumpAndSettle();
    }
  }

  /// Taps a widget found by [finder] and waits for animations.
  /// If [settle] is not provided, defaults to `!isFastMode`.
  /// Set [settle] to false if tapping triggers an infinite animation (e.g., a loading spinner)
  /// to prevent pumpAndSettle from hanging indefinitely.
  Future<void> tap(Finder finder, {bool? settle}) async {
    // print('tapping $finder'); // Optional debug logging
    final shouldSettle = settle ?? !isFastMode;
    await tester.tap(finder);
    if (shouldSettle) {
      await pumpAndSettle();
    } else {
      await pump();
    }
  }

  /// Enters text into a widget found by [finder] and waits.
  /// If [settle] is not provided, defaults to `!isFastMode`.
  /// Set [settle] to false if typing triggers an infinite animation.
  Future<void> enterText(Finder finder, String text, {bool? settle}) async {
    final shouldSettle = settle ?? !isFastMode;
    await tester.enterText(finder, text);
    if (shouldSettle) {
      await pumpAndSettle();
    } else {
      await pump();
    }
  }

  /// Waits for a text field to be completely cleared after an async save operation.
  /// 
  /// This is critical for repeating forms (like Intake or New Record) that 
  /// clear controllers in-place instead of popping the route. Otherwise, 
  /// robot loops race the async form clearing.
  Future<bool> waitForFieldToClear(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      final widgets = finder.evaluate();
      if (widgets.isNotEmpty) {
        final widget = widgets.first.widget;
        if (widget is TextField) {
          if ((widget.controller?.text ?? '').isEmpty) return true;
        } else if (widget is TextFormField) {
          if ((widget.controller?.text ?? '').isEmpty) return true;
        }
      }
      await pump(pollInterval);
    }
    return false;
  }

  /// Unified method for selecting an item from an autocomplete dropdown.
  /// 
  /// [inputField] The finder for the text field.
  /// [searchText] The text to type into the field to trigger the dropdown.
  /// [selectionText] The exact text of the dropdown option to tap. Defaults to [searchText].
  Future<void> selectAutocompleteItem(
    Finder inputField, 
    String searchText, 
    {String? selectionText}
  ) async {
    final targetText = selectionText ?? searchText;
    
    await tap(inputField, settle: false);
    
    // Use the smart enterText wrapper (with settle: false) to respect human observation speed
    await enterText(inputField, searchText, settle: false);

    var dropdownFound = await waitForAnyText(
      targetText,
      timeout: const Duration(seconds: 3),
      pollInterval: const Duration(milliseconds: 50),
    );

    if (!dropdownFound) {
      await enterText(inputField, '', settle: false);
      await pump(const Duration(milliseconds: 50));
      dropdownFound = await waitForAnyText(
        targetText,
        timeout: const Duration(seconds: 5),
        pollInterval: const Duration(milliseconds: 50),
      );
    }

    if (!dropdownFound) {
      throw StateError('BaseRobot: No autocomplete suggestion found for "$targetText"');
    }

    // Tap the suggestion (use .last to get dropdown, not any input echo).
    await tester.tap(find.text(targetText).last);
    
    // Wait for dropdown to close and value to populate
    await smartSettle();
  }

  /// Scrolls to make a widget visible before interaction.
  ///
  /// Use this before tapping widgets that may be off-screen due to
  /// responsive layout changes (e.g., restrictions list expanding).
  Future<void> ensureVisible(Finder finder) async {
    await tester.ensureVisible(finder);
    await pump();
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

    // Check immediately before pumping (avoids wasting one poll cycle
    // when widget is already present).
    if (finder.evaluate().isNotEmpty) return true;

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

    if (finder.evaluate().isNotEmpty) return true;

    while (stopwatch.elapsed < timeout) {
      await pump(pollInterval);
      if (finder.evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Waits for a widget with the given text to appear.
  ///
  /// Use when the text may appear multiple times or in overlays.
  /// Returns true if at least one widget is found within timeout.
  Future<bool> waitForAnyText(
    String text, {
    Duration timeout = const Duration(seconds: 10),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    final finder = find.text(text);

    if (finder.evaluate().isNotEmpty) return true;

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

  /// Opens the app drawer using ScaffoldState.
  ///
  /// Uses ScaffoldState.openDrawer() which is more reliable than finding
  /// the menu icon, especially on wide screens where hamburger may be hidden.
  Future<void> openDrawer() async {
    final scaffoldFinder = find.byType(Scaffold);
    expect(scaffoldFinder, findsWidgets,
        reason: 'No Scaffold found to open drawer');
    final ScaffoldState scaffold = tester.firstState(scaffoldFinder);
    scaffold.openDrawer();
    await pumpAndSettle();
  }

  /// Ensures a Drawer is available by popping routes if needed.
  ///
  /// Some flows (e.g., Print Center) use screens without a Drawer.
  /// This helper navigates back until a Drawer is found or fails after retries.
  Future<void> ensureDrawerAvailable({int maxBack = 3}) async {
    for (int i = 0; i < maxBack; i++) {
      final scaffoldFinder = find.byType(Scaffold);
      if (scaffoldFinder.evaluate().isNotEmpty) {
        final hasDrawer = scaffoldFinder.evaluate().any((element) {
          final widget = element.widget;
          return widget is Scaffold && widget.drawer != null;
        });
        if (hasDrawer) {
          return;
        }
      }
      try {
        await tester.pageBack();
      } catch (_) {
        final handled = await tester.binding.handlePopRoute();
        if (!handled) {
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        }
      }
      await pumpAndSettle();
    }
    if (find.byType(Drawer).evaluate().isEmpty) {
      throw TestFailure('Drawer not available after navigating back');
    }
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
  /// Opens drawer, expands the medical section, and taps intake form button.
  /// IntakeForm is inside a collapsed ExpansionTile (ZDRAVOTNICKÝ FILTR).
  Future<void> navigateToIntakeForm() async {
    await ensureDrawerAvailable();
    await openDrawer();
    // Expand the medical section first (intake form is inside this ExpansionTile)
    await tap(findKey('AppDrawer_filtr'));
    await pumpAndSettle();
    await tapDrawerIntakeForm();
  }

  /// Navigates to New Record Page via drawer.
  Future<void> navigateToNewRecordPage() async {
    await ensureDrawerAvailable();
    await openDrawer();
    await tapDrawerNewRecord();
  }

  /// Navigates to Print Center via drawer.
  Future<void> navigateToPrintCenter() async {
    await ensureDrawerAvailable();
    await openDrawer();
    await tapDrawerPrintCenter();
  }
}
