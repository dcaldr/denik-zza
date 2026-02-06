import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/widgets/print_confirm_dialog.dart';

import '../utils/base_test_widget.dart';

void main() {
  testWidgets('returns success when user confirms', (tester) async {
    late BuildContext dialogContext;

    await tester.pumpWidget(
      BaseTestWidget(
        child: Builder(
          builder: (context) {
            dialogContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    final future = showPrintConfirmDialog(
      context: dialogContext,
      appendActive: true,
      appendPossible: true,
      showTip: false,
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('PrintConfirm_success')));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, PrintSimulationResult.success);
  });

  testWidgets('reset flow returns reset result', (tester) async {
    late BuildContext dialogContext;

    await tester.pumpWidget(
      BaseTestWidget(
        child: Builder(
          builder: (context) {
            dialogContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    final future = showPrintConfirmDialog(
      context: dialogContext,
      appendActive: false,
      appendPossible: null,
      showTip: false,
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('PrintConfirm_reset')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('PrintConfirm_resetOnly')));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, PrintSimulationResult.reset);
  });
}
