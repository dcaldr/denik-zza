import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/print_center.dart';


import '../utils/base_test_widget.dart';

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import '../utils/test_configuration.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    DatabaseWrapper.setTestMode();
    database = AppDatabase.testInMemory();
    DatabaseWrapper.useTestDriftDatabase(database);
  });

  tearDown(() async {
    if (TestConfiguration.isPersist) {
      await database.close();
    }
  });

  // Helper not strictly needed if we use BaseTestWidget directly 
  // but kept for consistency if we expand features


  testWidgets('renders print center feature cards', (tester) async {
    // We need to override the provider creation in PrintCenterPage
    // or use a wrapper that injects it if PrintCenterPage allows it.
    // Since PrintCenterPage creates its own provider, we might need to modify it 
    // or test the UI components individually.
    // However, looking at PrintCenterPage, it uses ChangeNotifierProvider(create: ...).
    // To test with mock, we should change PrintCenterPage to accept controller or use overrides.
    // But since we can't easily change production code just for this without refactoring,
    // let's test the interactions we can control or use a realistic service mock if possible.
    // 
    // Actually, we can use Navigator observer to verify navigation
    // and just let it run with the real controller but mocked service.
    
    await tester.pumpWidget(
      const BaseTestWidget(
        child: PrintCenterPage(),
      ),
    );

    // Initial load
    await tester.pumpAndSettle();

    expect(find.text('Tisk Centrum – Nové'), findsOneWidget);
    expect(find.byKey(const Key('PrintCenter_personMode')), findsOneWidget);
    expect(find.byKey(const Key('PrintCenter_aggregated')), findsOneWidget);
    expect(find.byKey(const Key('PrintCenter_stateManagement')), findsOneWidget);
    expect(find.byKey(const Key('PrintCenter_firstPrint')), findsOneWidget);
  });

  testWidgets('navigates to FirstPrint when tapped', (tester) async {
    await tester.pumpWidget(
      const BaseTestWidget(
        child: PrintCenterPage(),
      ),
    );
    await tester.pumpAndSettle();

    final firstPrintCard = find.byKey(const Key('PrintCenter_firstPrint'));
    expect(firstPrintCard, findsOneWidget);

    await tester.tap(firstPrintCard);
    await tester.pumpAndSettle();

    // Verify visual change or navigation pushes new route
    // Since we are in a simplified test env, we just check no crash and logic works
    // To verify navigation properly we'd need a mock navigator observer, 
    // but simplified check is often enough for this phase.
    expect(find.text('Nastavení prvního tisku'), findsOneWidget); // Title of FirstPrint
  });
}
