import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import '../setup_templates/hardcoded_setup.dart';

/// Max retry attempts for async state waits
const int _maxWaitAttempts = 100;

/// Delay between async state checks
const Duration _waitCheckDelay = Duration(milliseconds: 10);

/// Shared async wait loop: polls a boolean condition up to [_maxWaitAttempts].
/// Used to wait for controller state changes during async operations.
Future<void> _waitForCondition(
  WidgetTester tester, {
  required bool Function() condition,
  required String timeoutMessage,
}) async {
  await tester.runAsync(() async {
    int checks = 0;
    while (!condition() && checks < _maxWaitAttempts) {
      await Future.delayed(_waitCheckDelay);
      checks++;
    }
  });
  expect(condition(), isTrue, reason: timeoutMessage);
}

void main() {
  group('PrintCenterController.selectionAbandoned', () {
    late PrintCenterService service;
    late PrintCenterController controller;

    setUp(() async {
      await HardcodedTestSetup.setupTestData();
      service = PrintCenterService();
      controller = PrintCenterController(service);
      controller.init();
    });

    tearDown(() async {
      controller.dispose();
    });

    Future<void> waitForParticipants(WidgetTester tester) async {
      await _waitForCondition(
        tester,
        condition: () => controller.participants.isNotEmpty,
        timeoutMessage: 'Participants should be loaded from DB',
      );
    }

    Future<void> waitForDetail(WidgetTester tester) async {
      await _waitForCondition(
        tester,
        condition: () => !controller.loadingDetail,
        timeoutMessage: 'Detail loading should complete',
      );
    }

    testWidgets('markSelectionAbandoned clears print state but keeps person', (tester) async {
      await waitForParticipants(tester);
      final osoba = controller.participants.first;

      // Select person
      // Need runAsync because selectParticipant fetches records asynchronously using service
      await tester.runAsync(() async {
        await controller.selectParticipant(osoba);
      });
      await waitForDetail(tester);

      expect(controller.selected, equals(osoba));
      expect(controller.selectionAbandoned, false);
      expect(controller.simulatedPrinted, false);

      // Mark as abandoned (like clicking "back to center")
      controller.markSelectionAbandoned();

      // Person should still be selected
      expect(controller.selected, equals(osoba));
      
      // But print state should be reset
      expect(controller.selectionAbandoned, true);
      expect(controller.simulatedPrinted, false);
      expect(controller.mode, PrintMode.full);
    });

    testWidgets('selectParticipant clears selectionAbandoned flag', (tester) async {
      await waitForParticipants(tester);
      const int minParticipantCount = 2;
      expect(controller.participants.length, greaterThanOrEqualTo(minParticipantCount), reason: 'Need at least $minParticipantCount participants');

      final osoba1 = controller.participants[0];
      final osoba2 = controller.participants[1];

      // Select person 1 and abandon
      await tester.runAsync(() async {
        await controller.selectParticipant(osoba1);
      });
      await waitForDetail(tester);
      
      controller.markSelectionAbandoned();
      expect(controller.selectionAbandoned, true);

      // Select different person - should clear abandoned flag
      await tester.runAsync(() async {
        await controller.selectParticipant(osoba2);
      });
      await waitForDetail(tester);
      
      expect(controller.selected, equals(osoba2));
      expect(controller.selectionAbandoned, false);
    });

    testWidgets('re-selecting same person after abandon clears abandoned flag', (tester) async {
      await waitForParticipants(tester);
      final osoba = controller.participants.first;

      // Select person, mark abandoned
      await tester.runAsync(() async {
         await controller.selectParticipant(osoba);
      });
      await waitForDetail(tester);
      
      controller.markSelectionAbandoned();
      expect(controller.selectionAbandoned, true);

      // Re-select same person - should clear abandoned flag
      await tester.runAsync(() async {
         await controller.selectParticipant(osoba);
      });
      await waitForDetail(tester);
      
      expect(controller.selected, equals(osoba));
      expect(controller.selectionAbandoned, false);
    });
  });
}

