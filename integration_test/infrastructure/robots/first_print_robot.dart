
import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

/// Robot for navigating the Nastavení a průvodce před prvním tiskem
/// (First Print Calibration Wizard).
class FirstPrintRobot extends BaseRobot {
  FirstPrintRobot(super.tester);

  Future<void> verifyPageShown() async {
    await waitForKey('FirstPrint_stepBadges');
    expect(find.text('Nastavení prvního tisku'), findsOneWidget);
  }

  Future<void> tapNext() async {
    await tap(findKey('FirstPrint_next'));
  }

  Future<void> tapInitialPrint() async {
    await tap(findKey('FirstPrint_initial_print'), settle: false);
    
    // Test print proceeds automatically to the next step (evaluation) upon success
    final loaded = await waitForKey('FirstPrint_page1_on_top', timeout: const Duration(seconds: 10));
    expect(loaded, isTrue, reason: 'Should transition to evaluation step after initial print');
    await pumpAndSettle(); // Ensure any residual animations finish
  }

  Future<void> tapPage1OnTop() async {
    await tap(findKey('FirstPrint_page1_on_top'));
  }

  Future<void> tapAppendPrint() async {
    await tap(findKey('FirstPrint_append_print'), settle: false);
  }

  Future<void> confirmAppendInstruction() async {
    final found = await waitForKey('AppendInstruction_continue', timeout: const Duration(seconds: 5));
    expect(found, isTrue, reason: 'AppendInstruction dialog should appear');
    await tap(findKey('AppendInstruction_continue'), settle: false);
  }

  Future<void> confirmPrintDialogSuccess() async {
    final found = await waitForKey('PrintConfirm_success', timeout: const Duration(seconds: 5));
    expect(found, isTrue, reason: 'Print confirmation dialog should appear');
    await tap(findKey('PrintConfirm_success'), settle: false);
    
    final completeFound = await waitForKey('FirstPrint_complete', timeout: const Duration(seconds: 5));
    expect(completeFound, isTrue, reason: 'Should transition to confirmation step');
    await pumpAndSettle();
  }

  Future<void> tapComplete() async {
    await tap(findKey('FirstPrint_complete'));
    await pumpAndSettle();
  }
}
