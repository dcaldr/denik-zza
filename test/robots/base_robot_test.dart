import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../integration_test/infrastructure/robots/base_robot.dart';

void main() {
  testWidgets('BaseRobot drawer navigation triggers targets', (tester) async {
    final selected = ValueNotifier<String?>(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                ExpansionTile(
                  key: const Key('AppDrawer_filtr'),
                  title: const Text('Zdravotnický filtr'),
                  children: [
                    ListTile(
                      key: const Key('AppDrawer_intake_form'),
                      title: const Text('Intake'),
                      onTap: () => selected.value = 'intake',
                    ),
                  ],
                ),
                ListTile(
                  key: const Key('AppDrawer_new_record'),
                  title: const Text('New Record'),
                  onTap: () => selected.value = 'new_record',
                ),
                ListTile(
                  key: const Key('AppDrawer_print_center'),
                  title: const Text('Print Center'),
                  onTap: () => selected.value = 'print_center',
                ),
              ],
            ),
          ),
          body: const Text('Home'),
        ),
      ),
    );

    final robot = BaseRobot(tester);

    await robot.navigateToIntakeForm();
    expect(selected.value, equals('intake'));

    await robot.navigateToNewRecordPage();
    expect(selected.value, equals('new_record'));

    await robot.navigateToPrintCenter();
    expect(selected.value, equals('print_center'));
  });

  testWidgets('BaseRobot ensureDrawerAvailable pops to drawer route',
      (tester) async {
    final navKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navKey,
        routes: {
          '/': (_) => Scaffold(
                drawer: Drawer(
                  child: ListView(
                    children: const [
                      ListTile(
                        key: Key('AppDrawer_new_record'),
                        title: Text('New Record'),
                      ),
                    ],
                  ),
                ),
                body: const Text('Home'),
              ),
          '/noDrawer': (_) => const Scaffold(
                body: Text('No Drawer'),
              ),
        },
      ),
    );

    navKey.currentState!.pushNamed('/noDrawer');
    await tester.pumpAndSettle();
    expect(find.text('No Drawer'), findsOneWidget);

    final robot = BaseRobot(tester);
    await robot.ensureDrawerAvailable();
    await robot.openDrawer();

    expect(find.text('Home'), findsOneWidget);
    expect(find.byKey(const Key('AppDrawer_new_record')), findsOneWidget);
  });
}