import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Reproduction of IntrinsicHeight -> LayoutBuilder crash',
      (tester) async {
    // This looks innocent, but IntrinsicHeight queries the intrinsic size of its child.
    // LayoutBuilder throws if asked for intrinsic size because it needs layout constraints first.

    // logic:
    // IntrinsicHeight (Parent) -> calls computeMaxIntrinsicHeight on Child
    // Child is LayoutBuilder -> throws "LayoutBuilder does not support returning intrinsic dimensions"

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: IntrinsicHeight(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(height: 100, color: Colors.red);
                },
              ),
            ),
          ),
        ),
      ),
    );
  });
}
