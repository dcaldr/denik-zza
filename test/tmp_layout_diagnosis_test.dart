import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'utils/base_test_widget.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
import 'package:denik_zza/screens2/widgets/restrictions_widget.dart';

void main() {
  setUpAll(() async {
    // Ensure DB is ready (mock/memory)
    await DatabaseWrapper.getDatabase();
  });

  tearDownAll(() async {
    await DatabaseWrapper.dispose();
  });

  group('Layout Diagnosis Stress Tests', () {
    // SCENARIO 1: Unbounded Height (The "Crash" Case)
    // Simulates being inside a SingleChildScrollView (like NewIntakeFormImproved)
    testWidgets('CRASH PROBE: Unbounded Height Constraint (Infinity)',
        (tester) async {
      print('DEBUG_TEST: Starting CRASH PROBE');

      // We wrap in SingleChildScrollView to provide Unbounded Height to the child
      // But BaseTestWidget puts child in Scaffold body (Bounded typically).
      // So we must Construct the hierarchy carefully.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ParticipantRegistrationForm(),
            ),
          ),
        ),
      );

      // Force a frame
      await tester.pump();

      // Detection: If we crashed, tester.takeException() will be non-null
      // Or we check specifically for RenderFlex error in generic exceptions
      final exception = tester.takeException();
      if (exception != null) {
        print('DEBUG_TEST: 🔴 CRASH DETECTED! Exception: $exception');
      } else {
        print('DEBUG_TEST: 🟢 NO CRASH. Widget handled unbounded height.');
      }
    });

    // SCENARIO 2: Bounded Desktop Height but Content Overflow (The "SnackBar Block" Case)
    // Simulates checking if Form fits in 1000px
    testWidgets('OVERFLOW PROBE: 1000px Height (Desktop)', (tester) async {
      print('DEBUG_TEST: Starting OVERFLOW PROBE');

      // Set surface size to 1000px height (Desktop default in tests)
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const BaseTestWidget(child: ParticipantRegistrationForm()),
      );
      await tester.pumpAndSettle();

      // Check for overflow
      // This is tricky in tests, usually it prints to console.
      // But we can check if the Submit button is hit-testable and visible
      final buttonFinder =
          find.byKey(const Key('ParticipantRegistrationForm_submit_button'));

      expect(buttonFinder, findsOneWidget, reason: "Button should exist");

      // Check if button is fully visible (in viewport)
      final buttonRect = tester.getRect(buttonFinder);
      print('DEBUG_TEST: Button Rect: $buttonRect');

      if (buttonRect.bottom > 1000) {
        print(
            'DEBUG_TEST: 🔴 OVERFLOW DETECTED! Button bottom (${buttonRect.bottom}) > 1000');
      } else {
        print('DEBUG_TEST: 🟢 Button within bounds.');
      }
    });

    // SCENARIO 3: REACTIVE BEHAVIOR VERIFICATION
    // We check if ParticipantRegistrationForm correctly toggles 'isBounded' on RestrictionsWidget
    // based on the constraints it receives.

    testWidgets('REACTIVE VERIFICATION: Unbounded Parent -> List Mode',
        (tester) async {
      // simulate Mobile/Scrollable parent
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ParticipantRegistrationForm(),
          ),
        ),
      ));

      // Check that RestrictionsWidget shows up
      final restrictionsFinder = find.byType(RestrictionsWidget);
      expect(restrictionsFinder,
          findsWidgets); // Should find 2 (restrictions + meds)

      // Verify isBounded = false
      final firstRestriction =
          tester.widget<RestrictionsWidget>(restrictionsFinder.first);
      expect(firstRestriction.isBounded, isFalse,
          reason:
              "Should be in Unbounded/List mode when parent is SingleChildScrollView");
    });

    testWidgets('REACTIVE VERIFICATION: Bounded Parent -> Expanded Mode',
        (tester) async {
      // Set surface size to Desktop
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // simulate Desktop/Fixed parent (big enough to fit)
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 1000,
            width: 1000,
            child: ParticipantRegistrationForm(),
          ),
        ),
      ));

      // Check that RestrictionsWidget shows up
      final restrictionsFinder = find.byType(RestrictionsWidget);
      expect(restrictionsFinder, findsWidgets);

      // Verify isBounded = true
      final firstRestriction =
          tester.widget<RestrictionsWidget>(restrictionsFinder.first);
      expect(firstRestriction.isBounded, isTrue,
          reason: "Should be in Bounded/Expanded mode when parent is SizedBox");
    });
  });
}
