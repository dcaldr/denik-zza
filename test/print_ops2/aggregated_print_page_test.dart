import 'dart:typed_data';

import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/print_ops2/aggregated_print_page.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/services/system/system_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../utils/base_test_widget.dart';

class _NoopDb implements DatabaseInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeAggregatedController extends PrintCenterController {
  _FakeAggregatedController({
    required List<MemoryOsoba> participants,
    this.failedIds = const <int>[],
  })  : _participants = participants,
        super(PrintCenterService(database: _NoopDb()));

  final List<MemoryOsoba> _participants;
  final List<int> failedIds;

  List<int>? lastConfirmedIds;

  @override
  List<MemoryOsoba> get participants => _participants;

  @override
  Future<Uint8List> generateAggregatedPdf(List<int> ids) async {
    return Uint8List.fromList(const [1, 2, 3]);
  }

  @override
  Future<List<int>> confirmAggregatedPrint(List<int> ids) async {
    lastConfirmedIds = List<int>.from(ids);
    return List<int>.from(failedIds);
  }
}

MemoryOsoba _p(int id, String jmeno, String prijmeni) {
  return MemoryOsoba.named(
    id: id,
    jmeno: jmeno,
    prijmeni: prijmeni,
    zpusobilost: true,
    bezinfekcnost: true,
    wasPrinted: false,
  );
}

Future<void> _pumpPage(WidgetTester tester, _FakeAggregatedController ctrl) async {
  await tester.binding.setSurfaceSize(const Size(1600, 1000));
  await tester.pumpWidget(
    ChangeNotifierProvider<PrintCenterController>.value(
      value: ctrl,
      child: const BaseTestWidget(
        child: SelectedAggregatedPrintPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    SystemInterface.registerWith(TestSystemInterface());
  });

  testWidgets('select all toggle enables and disables print button', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final ctrl = _FakeAggregatedController(
      participants: [
        _p(1, 'Karel', 'Capek'),
        _p(2, 'Franz', 'Kafka'),
      ],
    );

    await _pumpPage(tester, ctrl);

    final printButton = find.byKey(const Key('Aggregated_printButton'));
    expect(printButton, findsOneWidget);
    expect(tester.widget<FilledButton>(printButton).onPressed, isNull);

    await tester.tap(find.byKey(const Key('Aggregated_selectAll')));
    await tester.pumpAndSettle();

    expect(find.text('Vybráno: 2'), findsOneWidget);
    expect(tester.widget<FilledButton>(printButton).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('Aggregated_selectAll')));
    await tester.pumpAndSettle();

    expect(find.text('Vybráno: 0'), findsOneWidget);
    expect(tester.widget<FilledButton>(printButton).onPressed, isNull);
  });

  testWidgets('confirm success sends selected IDs and clears selection', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final ctrl = _FakeAggregatedController(
      participants: [
        _p(1, 'Karel', 'Capek'),
        _p(2, 'Franz', 'Kafka'),
      ],
    );

    await _pumpPage(tester, ctrl);

    await tester.tap(find.byKey(const Key('Aggregated_participant_1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('Aggregated_printButton')));
    await tester.pumpAndSettle();

    expect(find.text('Potvrzení hromadného tisku'), findsOneWidget);

    await tester.tap(find.text('Potvrdit úspěšný tisk'));
    await tester.pumpAndSettle();

    expect(ctrl.lastConfirmedIds, equals([1]));
    expect(find.text('Vybráno: 0'), findsOneWidget);
    expect(find.text('Hromadný tisk potvrzen a uložen.'), findsOneWidget);
  });

  testWidgets('cancel in confirm dialog keeps selection and does not save', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final ctrl = _FakeAggregatedController(
      participants: [
        _p(1, 'Karel', 'Capek'),
      ],
    );

    await _pumpPage(tester, ctrl);

    await tester.tap(find.byKey(const Key('Aggregated_participant_1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('Aggregated_printButton')));
    await tester.pumpAndSettle();

    expect(find.text('Potvrzení hromadného tisku'), findsOneWidget);

    await tester.tap(find.text('Zrušit (nic neměnit)'));
    await tester.pumpAndSettle();

    expect(ctrl.lastConfirmedIds, isNull);
    expect(find.text('Vybráno: 1'), findsOneWidget);
  });

  testWidgets('partial persistence failure keeps selection and shows warning', (tester) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final ctrl = _FakeAggregatedController(
      participants: [
        _p(1, 'Karel', 'Capek'),
      ],
      failedIds: const [1],
    );

    await _pumpPage(tester, ctrl);

    await tester.tap(find.byKey(const Key('Aggregated_participant_1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('Aggregated_printButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Potvrdit úspěšný tisk'));
    await tester.pumpAndSettle();

    expect(ctrl.lastConfirmedIds, equals([1]));
    expect(find.text('Vybráno: 1'), findsOneWidget);
    expect(
      find.text('Tisk byl potvrzen, ale nepodařilo se uložit 1 účastníků. Zkuste znovu.'),
      findsOneWidget,
    );
  });
}
