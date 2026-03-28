import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

/// Robot for interacting with Print Center landing page.
///
/// Keys used (from print_center.dart):
/// - PrintCenter_personMode
/// - PrintCenter_aggregated
/// - PrintCenter_firstPrint
/// - PrintCenter_stateManagement
class PrintCenterRobot extends BaseRobot {
  PrintCenterRobot(super.tester);

  Finder get personModeCard => findKey('PrintCenter_personMode');
  Finder get aggregatedCard => findKey('PrintCenter_aggregated');
  Finder get firstPrintCard => findKey('PrintCenter_firstPrint');
  Finder get stateManagementCard => findKey('PrintCenter_stateManagement');

  Future<void> verifyPageShown() async {
    await pumpAndSettle();
    expect(find.text('Tisk Centrum – Nové'), findsOneWidget,
      reason: 'Print Center title missing — wrong page or navigation failed');
    expect(personModeCard, findsOneWidget,
      reason: 'PrintCenter_personMode card missing — check key in print_center.dart');
    expect(aggregatedCard, findsOneWidget,
      reason: 'PrintCenter_aggregated card missing — check key in print_center.dart');
    expect(firstPrintCard, findsOneWidget,
      reason: 'PrintCenter_firstPrint card missing — check key in print_center.dart');
    expect(stateManagementCard, findsOneWidget,
      reason: 'PrintCenter_stateManagement card missing — check key in print_center.dart');
  }

  Future<void> tapPersonModeCard() async {
    await waitForCardEnabled('PrintCenter_personMode');
    await tap(personModeCard);
  }

  Future<void> tapFirstPrintCard() async {
    await waitForCardEnabled('PrintCenter_firstPrint');
    await tap(firstPrintCard);
  }


  Future<void> tapStateManagementCard() async {
    await tap(stateManagementCard);
  }

  Future<void> waitForCardEnabled(String key, {Duration timeout = const Duration(seconds: 5)}) async {
    final cardFinder = findKey(key);
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      final inkWellFinder = find.descendant(
        of: cardFinder,
        matching: find.byType(InkWell),
      );
      if (inkWellFinder.evaluate().isNotEmpty) {
        final inkWell = tester.widget<InkWell>(inkWellFinder.first);
        if (inkWell.onTap != null) return;
      }
      await pump(const Duration(milliseconds: 100));
    }
    throw TestFailure('Card "$key" did not become enabled within $timeout');
  }

  Future<void> verifyCardEnabled(String key) async {
    final cardFinder = findKey(key);
    expect(cardFinder, findsOneWidget,
        reason: 'Expected card "$key" to be present');

    final inkWellFinder = find.descendant(
      of: cardFinder,
      matching: find.byType(InkWell),
    );
    expect(inkWellFinder, findsOneWidget,
        reason: 'Card "$key" should have InkWell');

    final inkWell = tester.widget<InkWell>(inkWellFinder);
    expect(inkWell.onTap, isNotNull,
        reason: 'Card "$key" should be enabled');
  }

}
