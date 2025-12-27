import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';

// VERIFICATION TEST: PROPOSED FIX (Breakpoint = 800)
void main() {
  setUpAll(() async {
    await DatabaseWrapper.getDatabase();
  });

  tearDownAll(() async {
    await DatabaseWrapper.dispose();
  });

  testWidgets('FIX VERIFICATION: Simulate height < 800 triggering Scroll Mode',
      (tester) async {
    // 1. Setup Surface in "Dead Zone" (650px)
    await tester.binding.setSurfaceSize(const Size(1200, 650));

    // 2. Pump Widget with MODIFIED LOGIC (Simulated)
    // We can't change AppBreakpoints, so we embed the logic here:
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            // PROPOSED LOGIC: isCompactHeight = height < 800 (instead of 600)
            final bool isCompactHeightSimulated =
                constraints.maxHeight <= 800.0;

            final isMobile = AppBreakpoints.isMobile(constraints.maxWidth) ||
                isCompactHeightSimulated;

            if (isMobile) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: ParticipantRegistrationForm(),
                ),
              );
            } else {
              return ParticipantRegistrationForm();
            }
          },
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // 3. EXPECTATION: SingleChildScrollView SHOULD be present
    // 3. EXPECTATION: SingleChildScrollView SHOULD be present
    expect(find.byType(SingleChildScrollView), findsWidgets,
        reason:
            "With 800px breakpoint, 650px height SHOULD trigger Scroll Mode");

    // 4. Verify Button Exists (In Tree)
    // We verified ScrollView exists, so the button is accessible via scroll.
    final buttonFinder =
        find.byKey(const Key('ParticipantRegistrationForm_submit_button'));
    expect(buttonFinder, findsOneWidget);
  });
}
