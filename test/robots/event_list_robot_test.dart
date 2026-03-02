import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Import Robot
import '../../integration_test/infrastructure/robots/event_list_robot.dart';

void main() {
  testWidgets('EventListRobot finds key elements', (tester) async {
    // 1. Pump a harness simulating the Dashboard
    // We simulate the structure expected by the Robot
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Všechny akce'), // Expected title
            actions: [
              IconButton(
                key: const Key('EventList_add_button'), // Key expected by Robot
                icon: const Icon(Icons.add),
                onPressed: () {},
              )
            ],
          ),
          body: ListView(
            children: [
              ListTile(
                key: const Key(
                    'EventList_select_action_1'), // Key expected by Robot
                title: const Text('Test Event 1'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    // 2. Instantiate Robot
    final robot = EventListRobot(tester);

    // 3. Verify Interactions
    // Verify Page Title
    await robot.verifyPageShown();

    // Verify Add Button exists
    expect(robot.addEventButton, findsOneWidget);
    await robot.tapCreateNewEvent(); // Should tap without error

    // Verify Event List Item
    await robot.verifyEventPresent('Test Event 1');
    await robot.tapEvent('Test Event 1');

    // Verify specific selection by ID
    await robot.selectEvent(1);
  });
}
