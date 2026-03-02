import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/widgets/record_print_toggle_row.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'base_robot.dart';

/// Robot for Print State Management page.
///
/// Keys used (from print_state_management_page.dart / person_print_state_card.dart):
/// - PrintStateManagement_appBar
/// - PrintStateManagement_refresh
/// - PrintStateManagement_list
/// - PrintState_person_{id}
/// - PrintState_record_{recordId}
/// - PrintState_markAll
/// - PrintState_resetAll
/// - PrintState_personBadge_toggle
/// - PrintStateManagement_toggle_badge
class PrintStateRobot extends BaseRobot {
  PrintStateRobot(super.tester);

  Finder get refreshButton => findKey('PrintStateManagement_refresh');

  Finder personCard(int personId) => findKey('PrintState_person_$personId');

  Finder _personCardContainer(int personId) => find.ancestor(
        of: personCard(personId),
        matching: find.byType(Card),
      );

  Finder markAllButton(int personId) => find.descendant(
        of: _personCardContainer(personId),
        matching: findKey('PrintState_markAll'),
      );

  Finder resetAllButton(int personId) => find.descendant(
        of: _personCardContainer(personId),
        matching: findKey('PrintState_resetAll'),
      );

  Future<void> verifyPageShown() async {


    expect(findKey('PrintStateManagement_appBar'), findsOneWidget);
  }

  /// Robust scroll helper that works with lazy-loaded ListView.
  ///
  /// **Why deterministic drag loop instead of scrollUntilVisible?**
  /// 
  /// The Print State page has nested Scrollables:
  /// - Outer: Main ListView (keyed: PrintStateManagement_list)
  /// - Inner: Per-card record list (inside expanded PersonPrintStateCard)
  /// 
  /// Problem with scrollUntilVisible:
  /// - Ambiguous which Scrollable to use (nested context conflict)
  /// - May scroll inner list instead of outer list
  /// - Target widget stays hidden despite scrolling attempts
  /// 
  /// Solution: Deterministic drag on outer list key
  /// - Directly targets outer list key (PrintStateManagement_list)
  /// - No ambiguity - always drags the correct Scrollable
  /// - Up to 100 attempts × 200px drag per attempt
  /// - Guaranteed to find any visible person in list
  /// 
  /// Performance: Quick return if already visible (short-circuit)
  Future<void> _scrollToFinder(Finder finder) async {
    // Outer list key - we drag this widget directly to avoid nested-scrollable ambiguity
    final listFinder = find.byKey(const Key('PrintStateManagement_list'));
    
    // Quick return if already visible
    if (finder.evaluate().isNotEmpty) {
      await pump();
      return;
    }

    // Deterministic drag loop (avoids Scrollable.single ambiguity)
    int drags = 0;
    while (finder.evaluate().isEmpty && drags < 100) {
      try {
        await tester.drag(listFinder, const Offset(0, -200));
        await pump(const Duration(milliseconds: 40));
        drags++;
      } catch (e) {
        AppLogger.l.e(
          '[SCROLL] Drag failed at attempt #$drags: ${e.runtimeType}',
          error: e,
        );
        throw TestFailure('Scroll drag failed: $e');
      }
    }

    if (finder.evaluate().isEmpty) {
      AppLogger.l.e(
        '[SCROLL] Target not found after $drags drag attempts',
      );
      throw TestFailure(
        'Scroll failed: target not found after $drags attempts'
      );
    }

    await pump();
  }

  Future<void> expandPerson(String fullName) async {
    // Scope search to the PrintState list (avoid hitting off-screen widgets)
    final listFinder = findKey('PrintStateManagement_list');
    
    // Create scoped text finder (descendant of list only)
    final nameFinder = find.descendant(
      of: listFinder,
      matching: find.text(fullName),
    );
    
    // Scroll the list until the name becomes visible
    try {
      await _scrollToFinder(nameFinder);
    } catch (e) {
      AppLogger.l.e(
        '[EXPAND] Failed to find person "$fullName": $e',
        error: e,
      );
      throw TestFailure(
        'Person "$fullName" not found in PrintState page after scrolling.'
      );
    }
    
    // Verify it's now visible
    if (nameFinder.evaluate().isEmpty) {
      AppLogger.l.e('[EXPAND] Person "$fullName" not visible after scrolling');
      throw TestFailure('Person "$fullName" not visible after scrolling');
    }
    
    // Tap to expand
    await tap(nameFinder.first);
  }

  Future<void> toggleRecordPrinted(int recordIndex) async {
    final row = find.byType(RecordPrintToggleRow).at(recordIndex);
    final toggle = find.descendant(
      of: row,
      matching: findKey('PrintStateManagement_toggle_badge'),
    );
    
    if (toggle.evaluate().isEmpty) {
      AppLogger.l.e('[TOGGLE] Toggle not found at record index $recordIndex');
      throw TestFailure('Toggle badge not found at record index $recordIndex');
    }
    
    await _scrollToFinder(toggle);
    await tap(toggle);
  }

  Future<void> tapMarkAll(int personId) async {
    debugPrint('[tapMarkAll] START: personId=$personId');
    final button = markAllButton(personId);
    if (button.evaluate().isEmpty) {
      debugPrint('[tapMarkAll] ERROR: Mark all button not found');
      throw TestFailure('Mark all button not found for person $personId');
    }
    await _scrollToFinder(button);
    await tap(button);
    debugPrint('[tapMarkAll] SUCCESS');
  }

  Future<void> tapResetAll(int personId) async {
    debugPrint('[tapResetAll] START: personId=$personId');
    final button = resetAllButton(personId);
    if (button.evaluate().isEmpty) {
      debugPrint('[tapResetAll] ERROR: Reset all button not found');
      throw TestFailure('Reset all button not found for person $personId');
    }
    await _scrollToFinder(button);
    await tap(button);
    debugPrint('[tapResetAll] SUCCESS');
  }

  Future<void> verifyPersonPrintedBadge(String fullName, bool expected) async {


    final nameFinder = find.text(fullName);
    expect(nameFinder, findsOneWidget);

    final cardFinder = find.ancestor(
      of: nameFinder,
      matching: find.byType(Card),
    );
    expect(cardFinder, findsOneWidget);

    final badgeFinder = find.descendant(
      of: cardFinder,
      matching: find.byKey(const Key('PrintState_personBadge_toggle')),
    );
    expect(badgeFinder, findsOneWidget);

    final label = expected ? 'Vytištěno' : 'Nevytištěno';
    expect(find.descendant(of: badgeFinder, matching: find.text(label)),
        findsOneWidget);
  }

  Future<void> verifyRecordPrintedBadge(int recordIndex, bool expected) async {
    final row = find.byType(RecordPrintToggleRow).at(recordIndex);
    final badgeFinder = find.descendant(
      of: row,
      matching: find.byKey(const Key('PrintStateManagement_toggle_badge')),
    );
    expect(badgeFinder, findsOneWidget);

    final label = expected ? 'Vytištěno' : 'Nevytištěno';
    expect(find.descendant(of: badgeFinder, matching: find.text(label)),
        findsOneWidget);
  }

  Future<void> tapRefresh() async {
    await tap(refreshButton);
  }
}
