import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/utils/app_logger.dart';
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

  Future<void> selectParticipant(String fullName, {int participantId = 1}) async {
    // We use the new, robust semantic key if possible, falling back to text.
    final listFinder = find.byKey(const Key('select-person'));
    
    // Instead of scrolling blindly for unrendered text, we find the ListTile's specific Key
    // Using a known fallback order. We don't have ID reliably from just name in test,
    // but the test name is fine if we use scrollUntilVisible properly.
    final itemFinder = find.text(fullName);

    try {
      await tester.scrollUntilVisible(
        itemFinder,
        100.0,
        scrollable: find.descendant(of: listFinder, matching: find.byType(Scrollable)),
        maxScrolls: 50,
      );
    } catch (e) {
      debugDumpApp();
      rethrow;
    }

    final found = await waitForText(fullName, timeout: const Duration(seconds: 5));
    if (!found) {
      throw TestFailure('Participant "$fullName" not found in list (even after scroll)');
    }
    
    await _tapAndPump(itemFinder.first);
  }

  Future<void> selectFullPrintMode() async {
    await _tapAndPump(fullPrintMode);
  }

  Future<void> selectAppendPrintMode() async {
    await _tapAndPump(appendPrintMode);
  }

  Future<void> tapPrintButton() async {
    
    // Step 1: Wait for Enablement
    int ticks = 0;
    while (true) {
      await tester.pump(const Duration(milliseconds: 100));
      ticks++;
      
      final buttonFinder = find.byKey(const Key('PersonMode_printButton'));
      if (buttonFinder.evaluate().isEmpty) {
         if (ticks > 150) { 
           debugDumpApp();
           throw TestFailure("Print button not found in UI after 15 seconds.");
         }
         continue;
      }
      
      final buttonWidget = tester.widget<FilledButton>(buttonFinder);
      if (buttonWidget.onPressed != null) {
        break;
      }
      
      
      if (ticks > 150) { // 15 seconds
        AppLogger.l.e('Timeout! Print button remained disabled.');
        debugDumpApp();
        throw TestFailure("Print button remained disabled. PDF generation likely failed or took too long.");
      }
    }

    await _tapAndPump(printButton);
  }

  Future<void> verifyPdfPreviewShown() async {
    await tester.pump();
    expect(pdfPreview, findsOneWidget);
  }

  Future<void> tapNewPrint() async {
    await tap(findKey('PersonMode_newPrint'));
  }

  Future<void> confirmPrintSuccess({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final successFound = await waitForKey(
      'PrintConfirm_success',
      timeout: timeout,
    );
    if (!successFound) {
      debugDumpApp();
      throw TestFailure(
        'Print confirmation dialog did not appear in time (key: PrintConfirm_success).',
      );
    }
    await tap(findKey('PrintConfirm_success'));
  }

}
