import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';

// REPRO TEST: RESIZE BEHAVIOR DEAD ZONE
void main() {
  setUpAll(() async {
    await DatabaseWrapper.getDatabase();
  });

  tearDownAll(() async {
    await DatabaseWrapper.dispose();
  });

  // Helper to check visibility
  Future<void> checkButtonVisibility(
      WidgetTester tester, double surfaceHeight) async {
    final buttonFinder =
        find.byKey(const Key('ParticipantRegistrationForm_submit_button'));
    expect(buttonFinder, findsOneWidget);

    final buttonRect = tester.getRect(buttonFinder);
    final surfaceRect = Rect.fromLTWH(0, 0, 1200, surfaceHeight);

    // Allow small margin of error/padding
    final isVisible = surfaceRect.contains(buttonRect.bottomLeft) &&
        surfaceRect.contains(buttonRect.bottomRight);

    if (!isVisible) {
      print(
          'DEBUG_FAILURE: Button Bottom (${buttonRect.bottom}) is outside Surface Height ($surfaceHeight)');
    }

    expect(isVisible, isTrue,
        reason:
            "Submit Button should be fully visible at height $surfaceHeight");
  }

  testWidgets('DEAD ZONE PROBE: Check visibility in "Uncomfortable Zone"',
      (tester) async {
    // 1. Test "Comfortable" Desktop Height
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    await tester
        .pumpWidget(const MaterialApp(home: ParticipantRegistrationPage()));
    await tester.pumpAndSettle();

    await checkButtonVisibility(tester, 900);

    // 2. Test "Dead Zone" Candidate (650px)
    // 600px is the breakpoint. 650px should stay in Fixed Mode.
    // If content > 650px, it will clip.
    print('DEBUG_TEST: Resizing to 650h (Dead Zone Candidate)...');
    await tester.binding.setSurfaceSize(const Size(1200, 650));
    await tester.pump();
    await tester.pumpAndSettle();

    // EXPECTATION: FAILS if content is taller than 650
    await checkButtonVisibility(tester, 650);
  });
}
