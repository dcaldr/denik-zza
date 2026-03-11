import 'package:denik_zza/screens2/widgets/restrictions_widget.dart';
// removed unused import: zza_scrollable
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockLogic extends LogicInterface {
  final List<String> _items = List.generate(20, (i) => 'Item $i');

  @override
  void addItem(String name) {
    _items.add(name);
  }

  @override
  Future<void> fetchData([int? participantId]) async {}

  @override
  List<String> get items => _items;

  @override
  List<String> get names => ['Test', 'Test2'];

  @override
  String getText() => 'Test Restrictions';

  @override
  Future<void> update() async {}
}

void main() {
  testWidgets('RestrictionsWidget shows Up arrow when scrolled down',
      (WidgetTester tester) async {
    final logic = MockLogic();

    // Force a specific height to ensure scrolling is necessary
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            child: RestrictionsWidget(
              logic: logic,
              isBounded: false, // Force scroll mode
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial state: Down arrow visible, Up arrow NOT visible
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);

    // Scroll down
    final restrictionsList = find.descendant(
      of: find.byType(RestrictionsWidget),
      matching: find.byType(ListView),
    );
    await tester.drag(restrictionsList, const Offset(0, -100));
    await tester.pumpAndSettle();

    // Verify scrolled state: Both arrows should be visible (if not at bottom)
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);

    // Verify Scrollbar exists
    expect(find.byType(Scrollbar), findsOneWidget);
  });
}
