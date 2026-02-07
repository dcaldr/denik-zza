import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/widgets/print_confirm_dialog.dart';

import '../utils/base_test_widget.dart';

void main() {
  Future<Future<PrintSimulationResult?>> showDialogInTest(
    WidgetTester tester, {
    bool? appendActive,
    bool? appendPossible,
    bool showTip = true,
  }) {
    late BuildContext dialogContext;
    return tester.pumpWidget(
      BaseTestWidget(
        child: Builder(
          builder: (context) {
            dialogContext = context;
            return const SizedBox();
          },
        ),
      ),
    ).then((_) {
      final future = showPrintConfirmDialog(
        context: dialogContext,
        appendActive: appendActive,
        appendPossible: appendPossible,
        showTip: showTip,
      );
      return tester.pumpAndSettle().then((_) => future);
    });
  }

  group('PrintConfirmDialog main actions', () {
    testWidgets('returns success when user confirms (Vše OK)', (tester) async {
      final future = await showDialogInTest(tester);

      await tester.tap(find.byKey(const Key('PrintConfirm_success')));
      await tester.pumpAndSettle();

      final result = await future;
      expect(result, PrintSimulationResult.success);
    });

    testWidgets('returns repeat when user taps Zopakovat', (tester) async {
      final future = await showDialogInTest(tester);

      await tester.tap(find.byKey(const Key('PrintConfirm_repeat')));
      await tester.pumpAndSettle();

      final result = await future;
      expect(result, PrintSimulationResult.repeat);
    });

    testWidgets('returns noChange when user taps Neměnit', (tester) async {
      final future = await showDialogInTest(tester);

      await tester.tap(find.byKey(const Key('PrintConfirm_noChange')));
      await tester.pumpAndSettle();

      final result = await future;
      expect(result, PrintSimulationResult.noChange);
    });
  });

  group('PrintConfirmDialog reset flow', () {
    testWidgets('reset button opens sub-dialog', (tester) async {
      await showDialogInTest(tester);

      await tester.tap(find.byKey(const Key('PrintConfirm_reset')));
      await tester.pumpAndSettle();

      expect(find.text('Reset tisku'), findsOneWidget);
      expect(find.byKey(const Key('PrintConfirm_resetOnly')), findsOneWidget);
      expect(find.byKey(const Key('PrintConfirm_resetReprint')), findsOneWidget);
    });

    testWidgets('resetOnly returns reset result', (tester) async {
      final future = await showDialogInTest(tester);

      await tester.tap(find.byKey(const Key('PrintConfirm_reset')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('PrintConfirm_resetOnly')));
      await tester.pumpAndSettle();

      final result = await future;
      expect(result, PrintSimulationResult.reset);
    });

    testWidgets('resetReprint returns resetAndReprint result', (tester) async {
      final future = await showDialogInTest(tester);

      await tester.tap(find.byKey(const Key('PrintConfirm_reset')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('PrintConfirm_resetReprint')));
      await tester.pumpAndSettle();

      final result = await future;
      expect(result, PrintSimulationResult.resetAndReprint);
    });
  });

  group('AppendInfoBanner visibility', () {
    testWidgets('shows banner when appendActive is true', (tester) async {
      await showDialogInTest(tester, appendActive: true, appendPossible: true);

      expect(find.byType(AppendInfoBanner), findsOneWidget);
      expect(find.text('Režim Dostisk'), findsOneWidget);
    });

    testWidgets('shows banner when appendPossible is set (even if not active)',
        (tester) async {
      await showDialogInTest(tester, appendActive: false, appendPossible: false);

      expect(find.byType(AppendInfoBanner), findsOneWidget);
      // It should show instructions about why append is not active/possible
    });

    testWidgets('hides banner when both are null/false appropriately',
        (tester) async {
      // Logic in dialog: if (appendActive != null || appendPossible != null) -> show
      // So if pass true/false it shows.
      // If we pass nulls (default in showDialog wrapper above is null? No, signature is nullable)
      
       await showDialogInTest(tester, appendActive: null, appendPossible: null);
       expect(find.byType(AppendInfoBanner), findsNothing);
    });
  });
}
