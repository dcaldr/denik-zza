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

      // In scrollable mode, the FORM renders its own button (not Page)
      // Key: ParticipantRegistrationForm_submit_button (not Page)
      final buttonFinder =
          find.byKey(const Key('ParticipantRegistrationForm_submit_button'));

      // Attempt to scroll to it
      await tester.scrollUntilVisible(
        buttonFinder,
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      expect(buttonFinder, findsOneWidget);
    });

    // UPDATED TEST: Verify default window size (1280x720) fits WITH SCROLLING
    // because 720px < 800px Safety Limit -> Compact Mode
    testWidgets(
        'Default Windows Size (1280x720): Uses Compact Mode (Scrollable)',
        (WidgetTester tester) async {
      // 1. Set Default Windows Size
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;

      await tester
          .pumpWidget(const MaterialApp(home: ParticipantRegistrationPage()));
      await tester.pumpAndSettle();

      // 2. Find the ScrollView
      // At 720px, we expect Compact Mode -> SingleChildScrollView (Safety First)
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    // NEW TEST: Verify Tall Window (1280x900) fits WITHOUT SCROLLING
    testWidgets(
        'Tall Windows Size (1280x900): Uses Standard Mode (No Scroll)',
        (WidgetTester tester) async {
      // 1. Set Tall Windows Size
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;

      await tester
          .pumpWidget(const MaterialApp(home: ParticipantRegistrationPage()));
      await tester.pumpAndSettle();

      // 2. Expect No ScrollView (Fit to Screen)
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(CustomScrollView), findsNothing);
    });
    
    // NEW TEST: Verify Standard Laptop (1366x768) uses SCROLLABLE layout logic
    // 768px - 56px (AppBar) = 712px < 800px Threshold -> Scrollable Mode
    testWidgets(
        'Laptop Size (1366x768): Uses Scrollable Layout (Safety)',
        (WidgetTester tester) async {
      // 1. Set Laptop Size
      tester.view.physicalSize = const Size(1366, 768);
      tester.view.devicePixelRatio = 1.0;

      await tester
          .pumpWidget(const MaterialApp(home: ParticipantRegistrationPage()));
      await tester.pumpAndSettle();

      // 2. Expect ScrollView (Compact Layout) because 712 < 800 (Safety Threshold)
      // This allows the BIG standard fields to fit via scrolling.
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
