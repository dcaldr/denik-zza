import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/participant_edit_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import '../utils/base_test_widget.dart';
import '../setup_templates/hardcoded_setup.dart';
import 'package:denik_zza/database/database_wrapper.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Future<MemoryOsoba> loadTestParticipant() async {
    await HardcodedTestSetup.setupTestData();
    final db = DatabaseWrapper.getDatabase();
    final participants = await db.getParticipantsByCurrentEvent();
    return participants.first;
  }

  group('ParticipantEditPage', () {
    testWidgets('renders edit shell and key controls', (tester) async {
      final participant = await loadTestParticipant();

      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantEditPage(participant: participant),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Upravit účastníka:'), findsOneWidget);
      expect(find.byKey(const Key('ParticipantEditPage_submit_button')),
          findsOneWidget);
      expect(find.text('Zrušit'), findsOneWidget);

      // Edit page should own the footer action; form-level submit should be hidden.
      expect(find.byKey(const Key('ParticipantRegistrationForm_submit_button')),
          findsNothing);
    });

    testWidgets('shows registration form fields inside edit page', (tester) async {
      final participant = await loadTestParticipant();

      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantEditPage(participant: participant),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ParticipantRegistrationForm_jmeno_input')),
          findsOneWidget);
      expect(find.byKey(const Key('ParticipantRegistrationForm_prijmeni_input')),
          findsOneWidget);
    });
  });
}
