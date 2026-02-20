import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

/// Robot for the person print flow (select person -> mode -> preview -> confirm).
///
/// Keys used (from person_mode_flow_page.dart):
/// - PersonMode_select_{id}
/// - PersonMode_changePerson
/// - PersonMode_fullPrint
/// - PersonMode_appendPrint
/// - PersonMode_printButton
/// - PersonMode_backToCenter
/// - PersonMode_newPrint
/// - PersonMode_pdfPreview
///
/// Keys used (from print_confirm_dialog.dart):
/// - PrintConfirm_success
/// - PrintConfirm_repeat
/// - PrintConfirm_noChange
/// - PrintConfirm_reset
/// - PrintConfirm_resetOnly
/// - PrintConfirm_resetReprint
class PersonModeFlowRobot extends BaseRobot {
  PersonModeFlowRobot(super.tester);


  Finder get fullPrintMode => findKey('PersonMode_fullPrint');
  Finder get appendPrintMode => findKey('PersonMode_appendPrint');
  Finder get printButton => findKey('PersonMode_printButton');

  Finder get pdfPreview => findKey('PersonMode_pdfPreview');

  Future<void> _tapAndPump(Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> verifyPageShown() async {
    await tester.pump();
    expect(find.text('Tisk osoby – krokový průvodce'), findsOneWidget);
  }

  Future<void> selectParticipant(String fullName) async {
    final listFinder = find.byKey(const Key('select-person'));
    final itemFinder = find.text(fullName);

    // Scroll until the participant is visible
    // 15 participants might not fit on one screen
    await tester.scrollUntilVisible(
      itemFinder,
      100.0,
      scrollable: find.descendant(of: listFinder, matching: find.byType(Scrollable)),
      maxScrolls: 50,
    );

    final found = await waitForText(fullName,
        timeout: const Duration(seconds: 5));
    if (!found) {
      throw TestFailure('Participant "$fullName" not found in list');
    }
    await _tapAndPump(find.text(fullName).first);
  }

  Future<void> selectFullPrintMode() async {
    await _tapAndPump(fullPrintMode);
  }

  Future<void> selectAppendPrintMode() async {
    await _tapAndPump(appendPrintMode);
  }

  Future<void> tapPrintButton() async {
    await _tapAndPump(printButton);
  }

  Future<void> verifyPdfPreviewShown() async {
    await tester.pump();
    expect(pdfPreview, findsOneWidget);
  }

  Future<void> tapNewPrint() async {
    await _tapAndPump(findKey('PersonMode_newPrint'));
  }

  Future<void> confirmPrintSuccess() async {
    await _tapAndPump(findKey('PrintConfirm_success'));
  }


}
