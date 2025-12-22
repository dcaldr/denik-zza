import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import '../utils/base_test_widget.dart';
import '../../integration_test/infrastructure/robots/participant_editor_robot.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    // Mode handled by flutter_test_config.dart
  });

  group('ParticipantEditorRobot', () {
    testWidgets('finds key form elements on ParticipantRegistrationForm',
        (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: ParticipantRegistrationForm(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);

      // Verify key elements are found
      expect(robot.jmenoInput, findsOneWidget);
      expect(robot.prijmeniInput, findsOneWidget);
      expect(robot.submitButton, findsOneWidget);
    });

    testWidgets('finds additional form fields', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: ParticipantRegistrationForm(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);

      // Verify additional fields
      expect(robot.cisloPojisteniInput, findsOneWidget);
      expect(robot.datumNarozeniInput, findsOneWidget);
      expect(robot.zdravotniPojistovnaInput, findsOneWidget);
    });

    testWidgets('verifyPageShown method works', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: ParticipantRegistrationForm(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);

      // This should not throw
      await robot.verifyPageShown();
    });
  });
}
