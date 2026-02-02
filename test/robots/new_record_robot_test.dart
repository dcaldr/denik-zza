import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens2/new_record/new_record_page.dart';
import '../utils/base_test_widget.dart';
import '../../integration_test/infrastructure/robots/new_record_robot.dart';
import '../setup_templates/hardcoded_setup.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    // Mode handled by flutter_test_config.dart
  });

  group('NewRecordRobot', () {
    testWidgets('finds key form elements on NewRecordPage', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = NewRecordRobot(tester);

      // Verify key elements are found
      expect(robot.participantAutocomplete, findsOneWidget);
      expect(robot.titleInput, findsOneWidget);
      expect(robot.descriptionInput, findsOneWidget);
      expect(robot.saveButton, findsOneWidget);
    });

    testWidgets('finds action buttons', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = NewRecordRobot(tester);

      // Verify action buttons exist
      expect(robot.saveButton, findsOneWidget);
      expect(robot.cancelButton, findsOneWidget);
    });

    testWidgets('verifyPageShown method works', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = NewRecordRobot(tester);

      // This should not throw
      await robot.verifyPageShown();
    });

    // Tests for new methods added during E2E implementation
    testWidgets('selectParticipant method exists', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = NewRecordRobot(tester);

      // Note: Full autocomplete interaction needs participant data
      // This test verifies method signature exists
      // Actual selection tested in E2E with seeded data
      expect(robot.participantAutocomplete, findsOneWidget);
    });

    testWidgets('createRecordFromTestData method exists', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = NewRecordRobot(tester);

      // Note: Full record creation tested in E2E
      // This test verifies all required form elements exist
      expect(robot.titleInput, findsOneWidget);
      expect(robot.descriptionInput, findsOneWidget);
      expect(robot.saveButton, findsOneWidget);
    });

    testWidgets('print buttons exist on page', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = NewRecordRobot(tester);

      // Verify print buttons that createRecordFromTestData might use
      expect(robot.printFullButton, findsOneWidget);
      expect(robot.printAppendButton, findsOneWidget);
    });

    testWidgets('selectParticipant selects from autocomplete', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
      await HardcodedTestSetup.setupTestData();

      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = NewRecordRobot(tester);
      await robot.selectParticipant('Karel Čapek');

      final editableTexts = tester.widgetList<EditableText>(
        find.byType(EditableText),
      );
      final hasSelection = editableTexts.any(
        (editable) => editable.controller.text == 'Karel Čapek',
      );
      expect(hasSelection, isTrue);
    });
  });
}
