import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// MOCK FORM CONTENT: Simulates the Registration Form
class MockFormContent extends StatelessWidget {
  final double height;
  const MockFormContent({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Colors.blue.withOpacity(0.2),
      child: Center(child: Text("Form Content ($height px)")),
    );
  }
}

void main() {
  testWidgets('APPROACH A: IntrinsicHeight (Performance Risk?)',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const MockFormContent(height: 400),
                      const Spacer(),
                      Container(
                          height: 50,
                          color: Colors.red,
                          child: const Text("Button")),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ));

    // 1. Tall Screen (800px) -> Button at bottom (400 + Spacer + 50)
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpAndSettle();
    expect(find.text("Button"), findsOneWidget);
    // Verify Spacer took space (Button should be at bottom)
    final btnLocation = tester.getBottomLeft(find.text("Button"));
    expect(btnLocation.dy,
        equals(800.0)); // Adjusted for text centering? Frame bottom is 800.

    // 2. Short Screen (300px) -> Scrollable (400 + 50 > 300)
    await tester.binding.setSurfaceSize(const Size(400, 300));
    await tester.pumpAndSettle();
    expect(find.text("Button"), findsOneWidget); // Is it visible?
    // It should be off-screen if scrolled to top
    // Wait, pumpAndSettle might not scroll.
    // Check if ScrollView exists.
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('APPROACH B: CustomScrollView + SliverFillRemaining (Optimized)',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: const MockFormContent(height: 400),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      height: 50,
                      color: Colors.green,
                      child: const Text("Button")),
                ],
              ),
            ),
          ],
        ),
      ),
    ));

    // 1. Tall Screen (800px) -> Button at bottom
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpAndSettle();
    expect(find.text("Button"), findsOneWidget);
    final btnLocation = tester.getBottomLeft(find.text("Button"));
    expect(btnLocation.dy, equals(800.0));

    // 2. Short Screen (300px) -> Scrollable
    await tester.binding.setSurfaceSize(const Size(400, 300));
    await tester.pumpAndSettle();
    // Scroll to bottom
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text("Button"), findsOneWidget);
  });
}
