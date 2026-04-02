import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

class AggregatedPrintRobot extends BaseRobot {
  AggregatedPrintRobot(super.tester);

  Finder get selectAllCheckbox => findKey('Aggregated_selectAll');
  Finder get printButton => findKey('Aggregated_printButton');

  Finder _currentRouteSelectAllCheckbox() {
    final candidates = find
        .byKey(const Key('Aggregated_selectAll'), skipOffstage: false)
        .evaluate()
        .toList();

    for (final element in candidates) {
      final route = ModalRoute.of(element);
      if (route != null && route.isCurrent) {
        return find.byElementPredicate((e) => identical(e, element));
      }
    }

    return selectAllCheckbox;
  }

  Finder _currentRoutePrintButton() {
    final candidates = find
        .byKey(const Key('Aggregated_printButton'), skipOffstage: false)
        .evaluate()
        .toList();

    for (final element in candidates) {
      final route = ModalRoute.of(element);
      if (route != null && route.isCurrent) {
        return find.byElementPredicate((e) => identical(e, element));
      }
    }

    return printButton;
  }

  Future<void> verifyPageShown() async {
    await pumpSettleOrTimeout();
    expect(find.text('Tisk vybraných – agregace'), findsOneWidget,
        reason: 'Aggregated print page title missing');
    expect(selectAllCheckbox, findsOneWidget,
        reason: 'Aggregated_selectAll checkbox missing');
    expect(printButton, findsOneWidget,
        reason: 'Aggregated_printButton missing');
  }

  Future<void> toggleSelectAll() async {
    final finder = _currentRouteSelectAllCheckbox();
    await tester.ensureVisible(finder);
    await pumpSettleOrTimeout();

    try {
      await tap(finder, settle: false);
    } catch (_) {
      final checkbox = tester.widget<Checkbox>(finder);
      final current = checkbox.value ?? false;
      final onChanged = checkbox.onChanged;
      expect(onChanged, isNotNull,
          reason: 'Aggregated select-all checkbox should be enabled');
      onChanged!.call(!current);
    }

    await pumpSettleOrTimeout();
  }

  Future<void> toggleParticipant(int participantId) async {
    final finder = findKey('Aggregated_participant_$participantId');
    expect(finder, findsOneWidget,
        reason: 'Participant $participantId not found in aggregated list');

    // CheckboxListTile might need scrolling to tap
    await tester.ensureVisible(finder);
    await pumpSettleOrTimeout();
    await tap(finder, settle: false);
    await pumpSettleOrTimeout();
  }

  Future<void> tapPrintButton() async {
    const timeout = Duration(seconds: 15);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final finder = _currentRoutePrintButton();
      if (finder.evaluate().isEmpty) {
        await pump(const Duration(milliseconds: 100));
        continue;
      }

      final button = tester.widget<FilledButton>(finder);
      if (button.onPressed != null) {
        await tester.ensureVisible(finder);
        await pumpSettleOrTimeout();
        try {
          await tap(finder, settle: false);
        } catch (_) {
          // Windows desktop can expose a stale/non-hittable snapshot even though
          // the active-route button is enabled. Fall back to direct callback.
          button.onPressed!.call();
        }
        await pumpSettleOrTimeout();
        return;
      }

      await pump(const Duration(milliseconds: 100));
    }

    throw TestFailure(
      'Aggregated print button did not become enabled within ${timeout.inSeconds}s.',
    );
  }

  // Dialog interactions
  Future<void> verifyConfirmationDialogShown() async {
    await pumpSettleOrTimeout();
    expect(find.text('Potvrzení hromadného tisku'), findsOneWidget,
        reason: 'Confirmation dialog should be visible');
  }

  Future<void> abandonConfirmationDialog() async {
    await verifyConfirmationDialogShown();
    await tap(find.text('Zrušit (nic neměnit)'), settle: false);
    await pumpSettleOrTimeout();
  }

  Future<void> confirmSuccessDialog() async {
    await verifyConfirmationDialogShown();
    await tap(find.text('Potvrdit úspěšný tisk'), settle: false);
    await pumpSettleOrTimeout();
    await _waitForConfirmOutcome();
  }

  Future<void> _waitForConfirmOutcome() async {
    const successText = 'Hromadný tisk potvrzen a uložen.';
    const partialFailurePrefix = 'Tisk byl potvrzen, ale nepodařilo se uložit';

    for (var i = 0; i < 80; i++) {
      final success = find.text(successText).evaluate().isNotEmpty;
      final partialFailure =
          find.textContaining(partialFailurePrefix).evaluate().isNotEmpty;
      final dialogGone = find.byType(AlertDialog).evaluate().isEmpty;

      if ((success || partialFailure) && dialogGone) {
        await pumpSettleOrTimeout();
        return;
      }

      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}
