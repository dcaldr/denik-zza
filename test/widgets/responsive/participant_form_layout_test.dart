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
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';

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
      // Wrapper should be present
      // 2. Assertions
      // Wrapper should be present (CustomScrollView with Slivers)
      expect(
          find.byType(CustomScrollView), findsOneWidget); // Always present now

      // Button should be visible (Page level button)
      final buttonFinder =
          find.byKey(const Key('ParticipantRegistrationPage_submit_button'));
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets(
        'Compact (650px - The Dead Zone): Button is accessible via scroll',
        (WidgetTester tester) async {
      // 1. Set Critical "Dead Zone" Size
      // (Between 600px breakpoint and ~750px form height)
      tester.view.physicalSize = const Size(1200, 650);
      tester.view.devicePixelRatio = 1.0;

      await tester
          .pumpWidget(const MaterialApp(home: ParticipantRegistrationPage()));
      await tester.pumpAndSettle();

      // 2. Assertions
      // CustomScrollView must be the parent/wrapper allowing scroll
      expect(find.byType(CustomScrollView), findsWidgets);

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

      // 2. Find the CustomScrollView
      final scrollFinder = find.byType(CustomScrollView);
      expect(scrollFinder, findsOneWidget);

      // 3. Verify Scroll Extent is 0.0 (Content fits in viewport)
      //    We need to check the PrimaryScrollController or the Scrollable's position
      final scrollableState =
          tester.state<ScrollableState>(find.byType(Scrollable).first);

      // In a CustomScrollView with SliverFillRemaining(hasScrollBody: false),
      // if the content is LESS than viewport, the SliverFillRemaining takes up the rest,
      // and maxScrollExtent should effectively be 0 because it fits.
      // However, if SliverFillRemaining is used, it might force the extent to match viewport.
      // Let's check maxScrollExtent.
      final extent = scrollableState.position.maxScrollExtent;
      // ignore: avoid_print
      print('DEBUG: maxScrollExtent at 1280x720 is: $extent');

      expect(extent, 0.0,
          reason:
              'Page should not be scrollable at 1280x720 default resolution');
    });
  });
}
