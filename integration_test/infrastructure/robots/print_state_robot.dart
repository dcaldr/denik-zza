import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/widgets/record_print_toggle_row.dart';
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

  Finder markAllButton(int personId) => find.descendant(
        of: personCard(personId),
        matching: findKey('PrintState_markAll'),
      );

  Finder resetAllButton(int personId) => find.descendant(
        of: personCard(personId),
        matching: findKey('PrintState_resetAll'),
      );

  Future<void> verifyPageShown() async {
    await pumpAndSettle();
    expect(findKey('PrintStateManagement_appBar'), findsOneWidget);
  }

  Future<void> expandPerson(String fullName) async {
    await tap(find.text(fullName).first);
  }

  Future<void> toggleRecordPrinted(int recordIndex) async {
    final row = find.byType(RecordPrintToggleRow).at(recordIndex);
    final toggle = find.descendant(
      of: row,
      matching: findKey('PrintStateManagement_toggle_badge'),
    );
    await tap(toggle);
  }

  Future<void> tapMarkAll(int personId) async {
    await tap(markAllButton(personId));
  }

  Future<void> tapResetAll(int personId) async {
    await tap(resetAllButton(personId));
  }

  Future<void> verifyPersonPrintedBadge(String fullName, bool expected) async {
    await pumpAndSettle();
    final nameFinder = find.text(fullName);
    expect(nameFinder, findsOneWidget);

    final cardFinder = find.ancestor(
      of: nameFinder,
      matching: find.byType(Card),
    );
    expect(cardFinder, findsOneWidget);

    final label = expected ? 'Vytištěno' : 'Nevytištěno';
    expect(find.descendant(of: cardFinder, matching: find.text(label)),
        findsOneWidget);
  }

  Future<void> verifyRecordPrintedBadge(int recordIndex, bool expected) async {
    final row = find.byType(RecordPrintToggleRow).at(recordIndex);
    final label = expected ? 'Vytištěno' : 'Nevytištěno';
    expect(find.descendant(of: row, matching: find.text(label)),
        findsOneWidget);
  }

  Future<void> tapRefresh() async {
    await tap(refreshButton);
  }
}
