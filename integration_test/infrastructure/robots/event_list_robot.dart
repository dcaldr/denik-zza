import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

/// Robot for EventList screen interactions (home/dashboard).
///
/// Provides methods for:
/// - Verifying event list is displayed
/// - Finding and tapping events
/// - Creating new events
class EventListRobot extends BaseRobot {
  EventListRobot(super.tester);

  Finder get addEventButton => findKey('EventList_add_button');

  Future<void> verifyPageShown() async {
    await pumpAndSettle();
    expect(find.text('Všechny akce'), findsOneWidget);
  }

  Future<void> verifyEventPresent(String eventName) async {
    await pumpAndSettle();
    expect(find.text(eventName), findsOneWidget);
  }

  Future<void> tapEvent(String name) async {
    await tap(find.text(name));
  }

  Future<void> tapCreateNewEvent() async {
    await tap(addEventButton);
  }

  Future<void> selectEvent(int id) async {
    await tap(findKey('EventList_select_action_$id'));
  }
}
