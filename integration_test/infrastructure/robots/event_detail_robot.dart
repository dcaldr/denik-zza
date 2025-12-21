import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

class EventDetailRobot extends BaseRobot {
  EventDetailRobot(super.tester);

  Future<void> verifyPageShown() async {
    await pumpAndSettle();
    expect(findKey('EventDetail_addButton'), findsOneWidget);
    expect(findKey('EventDetail_searchField'), findsOneWidget);
  }

  Future<void> verifyParticipantPresent(String name) async {
    await pumpAndSettle();
    expect(find.text(name), findsOneWidget);
  }

  Future<void> tapParticipant(String name) async {
    // For Jurský Park: 'Karel Čapek' is index 0.
    // If we can't find by text easily (due to Row complexity), we might use index key.
    // However, find.text usually works if the text is visible.
    // Fallback: look for the "Detail" button associated with the participant.
    // For now, let's try finding the text and then finding the button near it or just finding the button by index if known.

    // Better approach given our Key analysis:
    // We know 'Karel Čapek' is the first participant (index 0).
    // Let's support tapping by Name (text) OR by Index (Key).

    final participantFinder = find.text(name);
    if (participantFinder.evaluate().isNotEmpty) {
      await tap(participantFinder);
      return;
    }

    // If text lookup fails (e.g. obscured), try Key fallback if we assume order.
    // For the Canary test, we know Karel Capek is likely Index 0.
    // But let's stick to the text finding as primary interaction for "User" simulation.
    // If this fails, we will refine.
    throw TestFailure('Participant "$name" not found on screen');
  }

  Future<void> tapParticipantDetailButtonByIndex(int index) async {
    await tap(findKey('ParticipantListItem_${index}_detailButton'));
  }
}
