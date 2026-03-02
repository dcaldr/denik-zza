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

  Future<void> selectParticipant(String fullName, {int participantId = 1}) async {
    // Wait for the participant list to be loaded/rendered
    debugPrint('[selectParticipant] START: Looking for "$fullName"');
    final listKeyFound = await waitForKey(
      'select-person',
      timeout: const Duration(seconds: 5),
    );
    if (!listKeyFound) {
      debugPrint('[selectParticipant] ERROR: List key not found - participants not loaded');
      throw TestFailure('Participant list did not load (key: select-person)');
    }
    
    // Scope all finders to the list container to avoid hitting offstage/snapshot widgets
    final listFinder = find.byKey(const Key('select-person'));
    
    // Find text within the list only (not global search)
    final itemTextFinder = find.descendant(
      of: listFinder,
      matching: find.text(fullName),
    );

    // Debug: Check preconditions
    debugPrint('[selectParticipant] List finder matches: ${listFinder.evaluate().length}');
    debugPrint('[selectParticipant] Item text finder matches (before scroll): ${itemTextFinder.evaluate().length}');

    try {
      await tester.scrollUntilVisible(
        itemTextFinder,
        100.0,
        scrollable: find.descendant(of: listFinder, matching: find.byType(Scrollable)),
        maxScrolls: 50,
      );
      debugPrint('[selectParticipant] Scroll completed');
    } catch (e) {
      debugPrint('[selectParticipant] ERROR: Scroll failed - $e');
      debugDumpApp();
      rethrow;
    }

    // Debug: Check state after scroll (BEFORE settling)
    debugPrint('[selectParticipant] After scroll, text finder matches: ${itemTextFinder.evaluate().length}');
    debugPrint('[selectParticipant] About to pumpAndSettle...');

    // Wait for any route transition animations to complete (avoid hitting snapshot widgets)
    await pumpAndSettle();

    // Debug: Check state after setlle (AFTER settling)
    debugPrint('[selectParticipant] After pumpAndSettle, text finder matches: ${itemTextFinder.evaluate().length}');

    // Find the ListTile ancestor of the text (larger, more reliable tap target)
    final listTileFinder = find.ancestor(
      of: itemTextFinder,
      matching: find.byType(ListTile),
    );
    
    debugPrint('[selectParticipant] ListTile ancestor finder matches: ${listTileFinder.evaluate().length}');

    if (itemTextFinder.evaluate().isEmpty) {
      final listMatches = listFinder.evaluate().length;
      final listTileMatches = listTileFinder.evaluate().length;
      debugPrint('[selectParticipant] ERROR: Could not find participant text. List: $listMatches, ListTile ancestors: $listTileMatches');
      throw TestFailure('Participant "$fullName" not found in list (even after scroll)');
    }
    
    if (listTileFinder.evaluate().isEmpty) {
      debugPrint('[selectParticipant] ERROR: Text found but ListTile ancestor not found - unexpected UI structure');
      throw TestFailure('ListTile ancestor not found for "$fullName"');
    }

    // Tap the ListTile (larger target, more reliable)
    debugPrint('[selectParticipant] Tapping ListTile for "$fullName"');
    await _tapAndPump(listTileFinder.first);

    debugPrint('[selectParticipant] Tap completed, checking transition...');

    // Fast-fail assertion: verify mode selection stage appeared
    final modeStageAppeared = await waitForKey(
      'PersonMode_fullPrint',
      timeout: const Duration(seconds: 5),
    );
    
    if (!modeStageAppeared) {
      debugPrint('[selectParticipant] ERROR: Mode stage never appeared - selection may have failed');
      debugDumpApp();
      throw TestFailure(
        'Mode selection stage did not appear after selecting "$fullName". '
        'Selection may have failed or UI transition is broken.',
      );
    }
    
    debugPrint('[selectParticipant] SUCCESS: Mode stage appeared');
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
