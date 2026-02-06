import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/widgets/append_instruction_dialog.dart';

import '../utils/base_test_widget.dart';

void main() {
  testWidgets('shows custom content and returns true on continue',
      (tester) async {
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

    final future = showDialog<bool>(
      context: dialogContext,
      builder: (_) => const AppendInstructionDialog(
        customContent: Text('Custom instructions'),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Custom instructions'), findsOneWidget);

    await tester.tap(find.byKey(const Key('AppendInstruction_continue')));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, true);
  });

  testWidgets('returns false on cancel', (tester) async {
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

    final future = showDialog<bool>(
      context: dialogContext,
      builder: (_) => const AppendInstructionDialog(
        customContent: Text('Custom instructions'),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('AppendInstruction_cancel')));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, false);
  });
}
