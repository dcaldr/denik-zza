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
    expect(find.text('Tisk Centrum – Nové'), findsOneWidget);
    expect(personModeCard, findsOneWidget);
    expect(aggregatedCard, findsOneWidget);
    expect(firstPrintCard, findsOneWidget);
    expect(stateManagementCard, findsOneWidget);
  }

  Future<void> tapPersonModeCard() async {
    await tap(personModeCard);
  }

  Future<void> tapAggregatedCard() async {
    await tap(aggregatedCard);
  }

  Future<void> tapFirstPrintCard() async {
    await tap(firstPrintCard);
  }

  Future<void> tapStateManagementCard() async {
    await tap(stateManagementCard);
  }

  Future<void> verifyCardEnabled(String key) async {
    final cardFinder = findKey(key);
    expect(cardFinder, findsOneWidget,
        reason: 'Expected card "$key" to be present');

    final absorbFinder = find.ancestor(
      of: cardFinder,
      matching: find.byType(AbsorbPointer),
    );
    expect(absorbFinder, findsNothing,
        reason: 'Card "$key" should be enabled');
  }

  Future<void> verifyCardDisabled(String key) async {
    final cardFinder = findKey(key);
    expect(cardFinder, findsOneWidget,
        reason: 'Expected card "$key" to be present');

    final absorbFinder = find.ancestor(
      of: cardFinder,
      matching: find.byType(AbsorbPointer),
    );
    expect(absorbFinder, findsWidgets,
        reason: 'Card "$key" should be disabled');
  }
}
