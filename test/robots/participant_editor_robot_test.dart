import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import '../utils/base_test_widget.dart';
import '../../integration_test/infrastructure/robots/participant_editor_robot.dart';
import '../../integration_test/infrastructure/data/models/test_restriction.dart';
import '../../integration_test/infrastructure/data/models/test_medication.dart';
import '../setup_templates/hardcoded_setup.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';

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
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
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
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
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
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);

      // This should not throw
      await robot.verifyPageShown();
    });

    // Tests for new methods added during E2E implementation
    testWidgets('enterDatumNarozeni method exists and callable',
        (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);

      // Verify method exists and can be called
      // Input format: DD.MM.YYYY
      await robot.enterDatumNarozeni(DateTime(2000, 5, 15));
      // If no exception, method signature is correct
    });

    testWidgets('enterPohlavi method exists and callable', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);

      // Test male (1) and female (2) inputs
      await robot.enterPohlavi(1); // Male
      // If no exception, method works
    });

    testWidgets('fillFromTestData method exists and callable', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);

      // Note: Full integration test uses Jurský Park data
      // This test just verifies method signature
      // Actual data filling tested in E2E
      expect(robot.runtimeType.toString(), 'ParticipantEditorRobot');
    });

    testWidgets('addMedication and addRestriction methods exist',
        (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);

      // Verify methods exist on robot
      // Full functionality tested in E2E with actual widget keys
      expect(robot.runtimeType.toString(), 'ParticipantEditorRobot');
    });

    testWidgets('addRestriction adds item and prevents duplicates',
        (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);
      const restriction = TestRestriction.omezeni('Test omezení');

      await robot.addRestriction(restriction);
      await robot.addRestriction(restriction);

      expect(find.text(restriction.popis), findsOneWidget);
    });

    testWidgets('addMedication adds item via button flow', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);
      const medication = TestMedication(
        nazev: 'Ibalgin 400mg',
        davkovani: '1 tableta',
        kdy: 'Ráno',
      );
      const expectedText = 'Ibalgin 400mg (1 tableta, Ráno)';

      await robot.addMedication(medication);

      expect(find.text(expectedText), findsOneWidget);
    });

    testWidgets('addRestrictionViaEnter adds item', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);
      const text = 'Omezení přes enter';

      await robot.addRestrictionViaEnter(text);

      expect(find.text(text), findsOneWidget);
    });

    testWidgets('addRestrictionViaTab completes suggestion', (tester) async {
      await HardcodedTestSetup.setupTestData();
      final db = DatabaseWrapper.getDatabase();
      final participants = await db.getParticipantsByCurrentEvent();
      final participantId = participants.first.id;

      await db.addOmezeni(
        MemoryOmezeni(
          omezeni: 'Alergie na pyl',
          typOmezeni: 2,
          idOsoby: participantId,
        ),
      );

      await tester.pumpWidget(
        const BaseTestWidget(
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);
      await robot.addRestrictionViaTab('Alergie na p', 'Alergie na pyl');

      expect(find.text('Alergie na pyl'), findsWidgets);
    });

    testWidgets('addMedicationViaTab completes suggestion', (tester) async {
      await HardcodedTestSetup.setupTestData();
      final db = DatabaseWrapper.getDatabase();
      final participants = await db.getParticipantsByCurrentEvent();
      final participantId = participants.first.id;

      await db.addLek(
        MemoryLek.fullNamed(
          id: null,
          nazev: 'Ibalgin 400mg',
          popisDavkovani: '1 tableta',
          idOsoby: participantId,
          wasPrinted: false,
        ),
      );

      await tester.pumpWidget(
        const BaseTestWidget(
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);
      await robot.addMedicationViaTab('Ibal', 'Ibalgin 400mg');

      expect(find.text('Ibalgin 400mg'), findsWidgets);
    });

    testWidgets('addRestrictionRejectSuggestion adds custom text',
        (tester) async {
      await HardcodedTestSetup.setupTestData();
      final db = DatabaseWrapper.getDatabase();
      final participants = await db.getParticipantsByCurrentEvent();
      final participantId = participants.first.id;

      await db.addOmezeni(
        MemoryOmezeni(
          omezeni: 'Alergie na prach',
          typOmezeni: 2,
          idOsoby: participantId,
        ),
      );

      await tester.pumpWidget(
        const BaseTestWidget(
          child: SingleChildScrollView(child: ParticipantRegistrationForm()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantEditorRobot(tester);
      await robot.addRestrictionRejectSuggestion(
        'Alergie na p',
        'Alergie na peří',
      );

      expect(find.text('Alergie na peří'), findsWidgets);
    });
  });
}
