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

  Finder get changePersonButton => findKey('PersonMode_changePerson');
  Finder get fullPrintMode => findKey('PersonMode_fullPrint');
  Finder get appendPrintMode => findKey('PersonMode_appendPrint');
  Finder get printButton => findKey('PersonMode_printButton');
  Finder get backToCenterButton => findKey('PersonMode_backToCenter');
  Finder get newPrintButton => findKey('PersonMode_newPrint');
  Finder get pdfPreview => findKey('PersonMode_pdfPreview');

  Future<void> verifyPageShown() async {
    await pumpAndSettle();
    expect(find.text('Tisk osoby – krokový průvodce'), findsOneWidget);
  }

  Future<void> selectParticipant(String fullName) async {
    final found = await waitForText(fullName,
        timeout: const Duration(seconds: 5));
    if (!found) {
      throw TestFailure('Participant "$fullName" not found in list');
    }
    await tap(find.text(fullName).first);
  }

  Future<void> selectFullPrintMode() async {
    await tap(fullPrintMode);
  }

  Future<void> selectAppendPrintMode() async {
    await tap(appendPrintMode);
  }

  Future<void> tapPrintButton() async {
    await tap(printButton);
  }

  Future<void> verifyPdfPreviewShown() async {
    await pumpAndSettle();
    expect(pdfPreview, findsOneWidget);
  }

  Future<void> verifyAppendHint(String text) async {
    final found = await waitForAnyText(text,
        timeout: const Duration(seconds: 5));
    expect(found, isTrue, reason: 'Append hint "$text" not found');
  }

  Future<void> confirmPrintSuccess() async {
    await tap(findKey('PrintConfirm_success'));
  }

  Future<void> confirmPrintRepeat() async {
    await tap(findKey('PrintConfirm_repeat'));
  }

  Future<void> confirmPrintNoChange() async {
    await tap(findKey('PrintConfirm_noChange'));
  }

  Future<void> confirmPrintReset() async {
    await tap(findKey('PrintConfirm_reset'));
    await tap(findKey('PrintConfirm_resetOnly'));
  }
}
