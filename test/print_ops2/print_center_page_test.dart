import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/print_center.dart';

import '../utils/base_test_widget.dart';

void main() {
  testWidgets('renders print center feature cards', (tester) async {
    await tester.pumpWidget(
      const BaseTestWidget(
        child: PrintCenterPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tisk Centrum – Nové'), findsOneWidget);
    expect(find.byKey(const Key('PrintCenter_personMode')), findsOneWidget);
    expect(find.byKey(const Key('PrintCenter_aggregated')), findsOneWidget);
    expect(find.byKey(const Key('PrintCenter_stateManagement')), findsOneWidget);
    expect(find.byKey(const Key('PrintCenter_firstPrint')), findsOneWidget);
  });
}
