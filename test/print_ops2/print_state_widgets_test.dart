import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/print_ops2/print_state_controller.dart';
import 'package:denik_zza/print_ops2/print_state_management_page.dart';
import 'package:denik_zza/print_ops2/widgets/person_print_state_card.dart';
import 'package:denik_zza/print_ops2/widgets/record_print_toggle_row.dart';
import 'package:denik_zza/print_ops2/models/person_print_state.dart';
import 'package:denik_zza/print_ops2/models/toggle_impact.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';

import '../utils/base_test_widget.dart';
import '../utils/print_test_helpers.dart';

class FakePrintCenterService extends PrintCenterService {
  FakePrintCenterService({
    required this.streamFactory,
    required this.recordsByPerson,
  }) : super(database: null);

  final Stream<List<MemoryOsoba>> Function() streamFactory;
  final Map<int, List<MemoryZaznam>> recordsByPerson;
  int watchCalls = 0;

  @override
  Stream<List<MemoryOsoba>> watchCurrentEventParticipants() {
    watchCalls += 1;
    return streamFactory();
  }

  @override
  Future<List<MemoryZaznam>> getRecords(int participantId) async {
    return recordsByPerson[participantId] ?? <MemoryZaznam>[];
  }
}

void main() {
  group('RecordPrintToggleRow', () {
    testWidgets('shows printed badge, cascade warning, and handles tap',
        (tester) async {
      final record = buildTestRecord(
        id: 1,
        participantId: 10,
        title: 'A',
        description: 'a',
      )..isPrinted = true;

      var tapped = false;

      await tester.pumpWidget(
        BaseTestWidget(
          child: RecordPrintToggleRow(
            record: record,
            cascadeCount: 2,
            onToggle: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Vytištěno'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      await tester.tap(
          find.byKey(const Key('PrintStateManagement_toggle_badge')));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('shows blocked icon and disables toggle when not allowed',
        (tester) async {
      final record = buildTestRecord(
        id: 2,
        participantId: 10,
        title: 'B',
        description: 'b',
      )..isPrinted = false;

      var tapped = false;

      await tester.pumpWidget(
        BaseTestWidget(
          child: RecordPrintToggleRow(
            record: record,
            canMarkPrinted: false,
            onToggle: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Nevytištěno'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);

      await tester.tap(
          find.byKey(const Key('PrintStateManagement_toggle_badge')));
      await tester.pump();

      expect(tapped, false);
    });
  });

  group('PersonPrintStateCard', () {
    testWidgets('renders name, record count, and expands records',
        (tester) async {
      final person = buildTestPerson(id: 7, jmeno: 'Karel', prijmeni: 'Test')
        ..wasPrinted = true;
      final records = [
        buildTestRecord(
          id: 1,
          participantId: 7,
          title: 'A',
          description: 'a',
        )..isPrinted = true,
        buildTestRecord(
          id: 2,
          participantId: 7,
          title: 'B',
          description: 'b',
        )..isPrinted = false,
      ];

      final state = PersonPrintState(
        person: person,
        records: records,
        appendPossible: true,
        hasSequenceIssue: false,
      );

      await tester.pumpWidget(
        BaseTestWidget(
          child: PersonPrintStateCard(
            state: state,
            onTogglePersonPrinted: (_) {},
            onToggleRecordPrinted: (_, __) {},
            onPreviewImpact: (_, __) => const ToggleImpact.none(),
            onMarkAllPrinted: (_) {},
            onResetAll: (_) {},
          ),
        ),
      );

      expect(find.text('Karel Test'), findsOneWidget);
      expect(find.text('1/2 záznamů vytištěno'), findsOneWidget);
      expect(find.byKey(const Key('PrintState_record_1')), findsNothing);

      await tester.tap(find.byKey(const Key('PrintState_person_7')));
      await tester.pump();

      expect(find.byKey(const Key('PrintState_record_1')), findsOneWidget);
    });

    testWidgets('asks for confirmation on destructive person toggle',
        (tester) async {
      final person = buildTestPerson(id: 9, jmeno: 'Anna', prijmeni: 'Test')
        ..wasPrinted = true;
      final records = [
        buildTestRecord(
          id: 5,
          participantId: 9,
          title: 'X',
          description: 'x',
        )..isPrinted = true,
      ];

      final state = PersonPrintState(
        person: person,
        records: records,
        appendPossible: true,
        hasSequenceIssue: false,
      );

      var toggled = false;

      await tester.pumpWidget(
        BaseTestWidget(
          child: PersonPrintStateCard(
            state: state,
            onTogglePersonPrinted: (_) => toggled = true,
            onToggleRecordPrinted: (_, __) {},
            onPreviewImpact: (_, __) => const ToggleImpact.none(),
            onMarkAllPrinted: (_) {},
            onResetAll: (_) {},
          ),
        ),
      );

      await tester.tap(
          find.byKey(const Key('PrintState_personBadge_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Odznačit osobu?'), findsOneWidget);

      await tester.tap(find.text('Odznačit'));
      await tester.pumpAndSettle();

      expect(toggled, true);
    });

    testWidgets('bulk actions invoke callbacks with confirmation',
        (tester) async {
      final person = buildTestPerson(id: 3, jmeno: 'Lukas', prijmeni: 'Test')
        ..wasPrinted = true;
      final records = [
        buildTestRecord(
          id: 1,
          participantId: 3,
          title: 'A',
          description: 'a',
        )..isPrinted = false,
      ];

      final state = PersonPrintState(
        person: person,
        records: records,
        appendPossible: false,
        hasSequenceIssue: false,
      );

      var markedAll = false;
      var resetAll = false;

      await tester.pumpWidget(
        BaseTestWidget(
          child: PersonPrintStateCard(
            state: state,
            onTogglePersonPrinted: (_) {},
            onToggleRecordPrinted: (_, __) {},
            onPreviewImpact: (_, __) => const ToggleImpact.none(),
            onMarkAllPrinted: (_) => markedAll = true,
            onResetAll: (_) => resetAll = true,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('PrintState_person_3')));
      await tester.pump();

      await tester.tap(find.byKey(const Key('PrintState_markAll')));
      await tester.pump();

      expect(markedAll, true);

      await tester.tap(find.byKey(const Key('PrintState_resetAll')));
      await tester.pumpAndSettle();

      expect(find.text('Resetovat vše?'), findsOneWidget);

      await tester.tap(find.text('Resetovat'));
      await tester.pumpAndSettle();

      expect(resetAll, true);
    });

    testWidgets('shows sequence issue banner when expanded', (tester) async {
      final person = buildTestPerson(id: 4, jmeno: 'Eva', prijmeni: 'Test')
        ..wasPrinted = true;
      final records = [
        buildTestRecord(
          id: 1,
          participantId: 4,
          title: 'A',
          description: 'a',
        )..isPrinted = false,
      ];

      final state = PersonPrintState(
        person: person,
        records: records,
        appendPossible: false,
        hasSequenceIssue: true,
      );

      await tester.pumpWidget(
        BaseTestWidget(
          child: PersonPrintStateCard(
            state: state,
            onTogglePersonPrinted: (_) {},
            onToggleRecordPrinted: (_, __) {},
            onPreviewImpact: (_, __) => const ToggleImpact.none(),
            onMarkAllPrinted: (_) {},
            onResetAll: (_) {},
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('PrintState_person_4')));
      await tester.pump();

      expect(
        find.text('Pořadí záznamů je porušeno — dostisk není možný.'),
        findsOneWidget,
      );
    });
  });

  group('PrintStateManagementPage', () {
    testWidgets('shows loading indicator while waiting for data',
        (tester) async {
      final controllerStream = StreamController<List<MemoryOsoba>>();
      final service = FakePrintCenterService(
        streamFactory: () => controllerStream.stream,
        recordsByPerson: const {},
      );
      final controller = PrintStateController(service);

      await tester.pumpWidget(
        BaseTestWidget(
          child: PrintStateManagementPage(controller: controller),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await controllerStream.close();
    });

    testWidgets('shows error state with retry button', (tester) async {
      final service = FakePrintCenterService(
        streamFactory: () => Stream.error(StateError('boom')),
        recordsByPerson: const {},
      );
      final controller = PrintStateController(service);

      await tester.pumpWidget(
        BaseTestWidget(
          child: PrintStateManagementPage(controller: controller),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Zkusit znovu'), findsOneWidget);
    });

    testWidgets('shows empty state when no participants', (tester) async {
      final service = FakePrintCenterService(
        streamFactory: () => Stream.value(const <MemoryOsoba>[]),
        recordsByPerson: const {},
      );
      final controller = PrintStateController(service);

      await tester.pumpWidget(
        BaseTestWidget(
          child: PrintStateManagementPage(controller: controller),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Žádní účastníci'), findsOneWidget);
    });

    testWidgets('refresh button triggers reload', (tester) async {
      final service = FakePrintCenterService(
        streamFactory: () => Stream.value(const <MemoryOsoba>[]),
        recordsByPerson: const {},
      );
      final controller = PrintStateController(service);

      await tester.pumpWidget(
        BaseTestWidget(
          child: PrintStateManagementPage(controller: controller),
        ),
      );

      await tester.pumpAndSettle();
      expect(service.watchCalls, 1);

      await tester
          .tap(find.byKey(const Key('PrintStateManagement_refresh')));
      await tester.pumpAndSettle();

      expect(service.watchCalls, 2);
    });
  });
}
