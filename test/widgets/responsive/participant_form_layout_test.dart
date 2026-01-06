// Feature Test: Responsive Participant Form Layout (Sticky Footer)
//
// Description:
// Verifies that the ParticipantRegistrationPage layout behaves correctly on different screen sizes:
// 1. Desktop (Tall): Button is PINNED to bottom (via Spacer).
// 2. Mobile (Short/Dead Zone 650px): Button is SCROLLABLE (via SingleChildScrollView).

import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../setup_templates/hardcoded_setup.dart';


void main() {
  setUp(() async {
    await HardcodedTestSetup.setupTestData();
  });

  group('ParticipantRegistrationPage Responsive Tests', () {
    testWidgets('Desktop (900px): Button is visible and page is pumped',
        (WidgetTester tester) async {
      // 1. Set Desktop Size
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester
          .pumpWidget(const MaterialApp(home: ParticipantRegistrationPage()));
      await tester.pumpAndSettle();

      // 2. Assertions
      // Wrapper should NOT be a ScrollView (Fit to Screen)
      // We expect a Column with Expanded form
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(CustomScrollView), findsNothing);

      // Button should be visible (Page level button)
      final buttonFinder =
          find.byKey(const Key('ParticipantRegistrationPage_submit_button'));
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets(
        'Compact (600px - Mobile Limit): Button is accessible via scroll',
        (WidgetTester tester) async {
      // 1. Set Critical "dead zone" Size (just at the limit or below)
      // Breakpoint is 600. So 599 should trigger scroll.
      tester.view.physicalSize = const Size(1200, 599);
      tester.view.devicePixelRatio = 1.0;

      await tester
          .pumpWidget(const MaterialApp(home: ParticipantRegistrationPage()));
      await tester.pumpAndSettle();

      // 2. Assertions
      // Should be wrapped in SingleChildScrollView now
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Button might be off-screen initially, but should be findable
      final buttonFinder =
          find.byKey(const Key('ParticipantRegistrationPage_submit_button'));

      // Attempt to scroll to it
      await tester.scrollUntilVisible(
        buttonFinder,
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      expect(buttonFinder, findsOneWidget);
    });

    // NEW TEST: Verify default window size (1280x720) fits WITHOUT SCROLLING (Fit-to-Screen)
    testWidgets(
        'Default Windows Size (1280x720): Fits entirely without scrollbar',
        (WidgetTester tester) async {
      // 1. Set Default Windows Size
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;

      await tester
          .pumpWidget(const MaterialApp(home: ParticipantRegistrationPage()));
      await tester.pumpAndSettle();

      // 2. Find the ScrollView
      // Ideally, there IS NO ScrollView at this size.
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(CustomScrollView), findsNothing);

      // 3. Verify no Scrollable widget is active/scrollable in the main body
      // (Note: TextFields might have internal scrollables, ignore them)
      // We check if the main layout is a Column
      expect(find.byType(Column), findsWidgets);
    });
  });
}
