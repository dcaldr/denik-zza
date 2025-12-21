import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Import Robot
import '../../integration_test/infrastructure/robots/event_detail_robot.dart';

void main() {
  testWidgets('EventDetailRobot finds key elements', (tester) async {
    // 1. Pump a harness simulating the Event Detail Page
    // We construct the widget tree to MATCH what the Robot expects.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
              title: const Text('Detail akce')), // Required verification title
          body: Column(
            children: [
              // Search Field (Robot expects this in verifyPageShown)
              const TextField(key: Key('EventDetail_searchField')),

              // Participants List (Standard)
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text('Karel Čapek'),
                      // Button for detail (Robot tapParticipantDetailButtonByIndex)
                      trailing: IconButton(
                        key: const Key('ParticipantListItem_0_detailButton'),
                        icon: const Icon(Icons.info),
                        onPressed: () {},
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            key: const Key('EventDetail_addButton'), // Correct Key matching App
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    // 2. Instantiate Robot
    final robot = EventDetailRobot(tester);

    // 3. Verify Interactions
    await robot.verifyPageShown();

    // Verify Participant Present
    await robot.verifyParticipantPresent('Karel Čapek');

    // Verify Tap Participant
    await robot.tapParticipant('Karel Čapek');

    // Verify Detail Button by Index (Full Coverage)
    await robot.tapParticipantDetailButtonByIndex(0);

    // Verify Add Participant Button (checking if it exists)
    expect(robot.addParticipantButton, findsOneWidget);
    await robot.tapAddParticipant();
  });
}
