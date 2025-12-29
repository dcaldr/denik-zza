import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';
import 'utils/base_test_widget.dart';

/// Tests for ParticipantRegistrationForm behavior:
/// - Form clearing after successful submit
/// - Validation errors prevent clearing
/// - Multiple people entry flow
/// - DB verification after submit
void main() {
  late AppDatabase database;

  // Use taller surface to fit entire form without scrolling
  const testSurfaceSize = Size(1200, 1000);

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    DatabaseWrapper.setTestMode();
    database = AppDatabase.testInMemory();
    DatabaseWrapper.useTestDriftDatabase(database);

    final eventId = await database.addZzaAction(ZzaActionsCompanion(
      actionTitle: const Value('Test Event'),
      actionDescription: const Value('Test'),
      dateFrom: Value(DateTime.now()),
      dateTo: Value(DateTime.now().add(const Duration(days: 7))),
    ));

    await database.updateCache(CacheCompanion(
      id: const Value(1),
      currentActionID: Value(eventId),
    ));
  });

  tearDown(() async {
    await database.close();
  });

  group('Form Validation', () {
    testWidgets('empty Jméno shows error and prevents submit', (tester) async {
      await tester.binding.setSurfaceSize(testSurfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const BaseTestWidget(child: ParticipantRegistrationForm()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_prijmeni_input')),
        'Testovic',
      );

      await tester.tap(
        find.byKey(const Key('ParticipantRegistrationForm_submit_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jméno je povinné pole'), findsOneWidget);
      expect(await database.getAllParticipants(), isEmpty);
    });

    testWidgets('empty Příjmení shows error and prevents submit',
        (tester) async {
      await tester.binding.setSurfaceSize(testSurfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const BaseTestWidget(child: ParticipantRegistrationForm()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_jmeno_input')),
        'Test',
      );

      await tester.tap(
        find.byKey(const Key('ParticipantRegistrationForm_submit_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Příjmení je povinné pole'), findsOneWidget);
      expect(await database.getAllParticipants(), isEmpty);
    });

    testWidgets('both fields empty shows both errors', (tester) async {
      await tester.binding.setSurfaceSize(testSurfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const BaseTestWidget(child: ParticipantRegistrationForm()),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('ParticipantRegistrationForm_submit_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jméno je povinné pole'), findsOneWidget);
      expect(find.text('Příjmení je povinné pole'), findsOneWidget);
      expect(await database.getAllParticipants(), isEmpty);
    });
  });

  group('Successful Submit + DB Verification', () {
    testWidgets('valid data saves to DB and clears form', (tester) async {
      await tester.binding.setSurfaceSize(testSurfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const BaseTestWidget(child: ParticipantRegistrationForm()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_jmeno_input')),
        'Jan',
      );
      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_prijmeni_input')),
        'Novák',
      );

      await tester.tap(
        find.byKey(const Key('ParticipantRegistrationForm_submit_button')),
      );
      await tester.pumpAndSettle();

      final participants = await database.getAllParticipants();
      expect(participants.length, 1);
      expect(participants.first.firstName, 'Jan');
      expect(participants.first.lastName, 'Novák');

      // Verify form cleared
      final jmenoField = tester.widget<TextFormField>(
        find.byKey(const Key('ParticipantRegistrationForm_jmeno_input')),
      );
      expect(jmenoField.controller?.text, isEmpty);
    });

    testWidgets('success snackbar shown after save', (tester) async {
      await tester.binding.setSurfaceSize(testSurfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const BaseTestWidget(child: ParticipantRegistrationForm()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_jmeno_input')),
        'Marie',
      );
      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_prijmeni_input')),
        'Svobodová',
      );

      await tester.tap(
        find.byKey(const Key('ParticipantRegistrationForm_submit_button')),
      );
      await tester.pump();

      expect(find.text('Marie Svobodová byl úspěšně přidán'), findsOneWidget);
    });
  });

  group('Multiple People Entry', () {
    testWidgets('can add multiple people sequentially', (tester) async {
      await tester.binding.setSurfaceSize(testSurfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const BaseTestWidget(child: ParticipantRegistrationForm()),
      );
      await tester.pumpAndSettle();

      // Add first person
      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_jmeno_input')),
        'Petr',
      );
      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_prijmeni_input')),
        'Černý',
      );
      await tester.tap(
        find.byKey(const Key('ParticipantRegistrationForm_submit_button')),
      );
      await tester.pumpAndSettle();
      // Verify inline success message (immediate, no occlusion)
      expect(find.text('Petr Černý byl úspěšně přidán'), findsOneWidget);
      await tester.pumpAndSettle();

      var participants = await database.getAllParticipants();
      expect(participants.length, 1);
      expect(participants.first.firstName, 'Petr');

      // Add second person (form should be cleared)
      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_jmeno_input')),
        'Eva',
      );
      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_prijmeni_input')),
        'Bílá',
      );
      await tester.tap(
        find.byKey(const Key('ParticipantRegistrationForm_submit_button')),
      );
      await tester.pumpAndSettle();

      participants = await database.getAllParticipants();
      expect(participants.length, 2);
      expect(
          participants.map((p) => p.firstName), containsAll(['Petr', 'Eva']));
    });
  });

  group('Autocomplete Logic', () {
    testWidgets('safety guard: existing gender selection is NOT overridden by RC',
        (tester) async {
      await tester.binding.setSurfaceSize(testSurfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const BaseTestWidget(child: ParticipantRegistrationForm()),
      );
      await tester.pumpAndSettle();

      // 1. Manually select "Muž" (Male)
      // Note: "Muž" behaves as default in logic sometimes, so explicitly setting it is safer
      // Only set if field is empty, but here we want to force it.
      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_pohlavi_input')),
        'Muž',
      );
      await tester.pumpAndSettle();

      // 2. Enter Female RC (855512/0006 -> Female)
      // Intrinsic Gender: Female
      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_cisloPojisteni_input')),
        '855512/0006',
      );
      await tester.pumpAndSettle();

      // 3. Assert Gender is STILL "Muž" (Not overridden)
      final pohlaviField = tester.widget<TextFormField>(
        find.byKey(const Key('ParticipantRegistrationForm_pohlavi_input')),
      );
      expect(pohlaviField.controller?.text, 'Muž',
          reason: 'Existing gender selection should be protected from autofill');
    });

    testWidgets('preservation: manual change after autofill is preserved',
        (tester) async {
      await tester.binding.setSurfaceSize(testSurfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const BaseTestWidget(child: ParticipantRegistrationForm()),
      );
      await tester.pumpAndSettle();

      // 1. Enter Female RC (855512/0006) into EMPTY form
      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_cisloPojisteni_input')),
        '855512/0006',
      );
      await tester.pumpAndSettle();

      // 2. Assert Autofill Happened (Gender = Žena)
      var pohlaviField = tester.widget<TextFormField>(
        find.byKey(const Key('ParticipantRegistrationForm_pohlavi_input')),
      );
      expect(pohlaviField.controller?.text, 'Žena',
          reason: 'Should autofill Female for this RC');

      // 3. Manually Override to "Muž"
      await tester.enterText(
        find.byKey(const Key('ParticipantRegistrationForm_pohlavi_input')),
        'Muž',
      );
      await tester.pumpAndSettle();

      // 4. Assert Manual Change Persists
      pohlaviField = tester.widget<TextFormField>(
        find.byKey(const Key('ParticipantRegistrationForm_pohlavi_input')),
      );
      expect(pohlaviField.controller?.text, 'Muž',
          reason: 'Manual override should persist');
    });
  });
}
