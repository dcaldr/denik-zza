// Regression Test: Intrinsic LayoutBuilder Crash
//
// Description:
// Verifies that ParticipantRegistrationPage can be laid out inside an IntrinsicHeight
// without crashing due to "LayoutBuilder does not support returning intrinsic dimensions".
//
// Fix Mechanism:
// The page passes reference bypassLayoutBuilder: true to the form, forcing it to use MediaQuery
// instead of LayoutBuilder, breaking the IntrinsicHeight -> LayoutBuilder dependency cycle.

import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// removed unused imports: app_drawer, participant_registration_service, database_wrapper
import '../../setup_templates/hardcoded_setup.dart';

void main() {
  setUp(() async {
    await HardcodedTestSetup.setupTestData();
  });

  testWidgets('ParticipantRegistrationPage should pump without intrinsic crash',
      (WidgetTester tester) async {
    // 1. Set Safe Size (avoid unrelated overflows)
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;

    // 2. Pump the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: ParticipantRegistrationPage(),
      ),
    );

    // 2. Wait for layout settling (bounded timeout, max 500ms)
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 3. Assertions
    // If we reached here, the crash (which happens during layout) did not occur.
    // Verify basic presence to ensure we actually rendered content.
    expect(find.byType(ParticipantRegistrationPage), findsOneWidget, reason: 'Page should render without intrinsic dimension crash');
    expect(find.byType(ParticipantRegistrationForm), findsOneWidget, reason: 'Form widget should be present');
    expect(find.text('Registrace Účastníka'), findsOneWidget, reason: 'Page title should be visible');
    expect(
      find.byKey(const Key('ParticipantRegistrationPage_submit_button')),
      findsOneWidget,
      reason: 'Submit button should be rendered',
    );
  });
}
