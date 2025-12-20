import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

class DashboardRobot extends BaseRobot {
  DashboardRobot(super.tester);

  Finder get addEventButton => findKey('EventList_add_button');

  Future<void> tapCreateNewEvent() async {
    await tap(addEventButton);
  }

  Future<void> selectEvent(int id) async {
    await tap(findKey('EventList_select_action_$id'));
  }
}
