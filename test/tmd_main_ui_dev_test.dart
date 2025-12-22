import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/main_UI_dev.dart';

void main() {
  setUp(() {
    // Mode handled by flutter_test_config.dart
  });

  testWidgets('Main UI dev app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for animations and async data loading
    await tester.pumpAndSettle();

    // Verify that the app bar title is present
    expect(find.text('Všechny akce'), findsOneWidget);

    // Verify that the main navigation elements are present
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
