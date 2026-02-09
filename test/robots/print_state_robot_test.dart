import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/print_ops2/print_state_controller.dart';
import 'package:denik_zza/print_ops2/print_state_management_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import '../utils/base_test_widget.dart';
import '../utils/widget_test_helpers.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';

// --- FAKE SERVICE ---
class FakePrintCenterService extends PrintCenterService {
  @override
  Stream<List<MemoryOsoba>> watchCurrentEventParticipants() {
    return Stream.value([
      MemoryOsoba.named(
        id: 1, 
        jmeno: 'Karel', 
        prijmeni: 'Čapek',
        // minimal fields for functionality
        pohlavi: 1, // POHLAVI_MUZ
        datumNarozeni: DateTime(1890),
        zpusobilost: true,
        bezinfekcnost: true,
      )
    ]);
  }

  @override
  Future<List<MemoryZaznam>> getRecords(int participantId) async {
    return [];
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    ModeCoordinator.setTestingMode();
  });

  tearDownAll(() async {
    await DatabaseWrapper.dispose();
  });

  group('PrintStateRobot', () {
    testWidgets('finds key elements and actions', (tester) async {
      
      // Use Fake Service to isolate DB layer and prevent test hangs
      final controller = PrintStateController(FakePrintCenterService());

      await tester.pumpWidget(
        BaseTestWidget(
          child: PrintStateManagementPage(controller: controller),
        ),
      );

      // Robustly wait for loading to finish (CircularProgressIndicator to disappear)
      await pumpUntilGone(tester, find.byType(CircularProgressIndicator));
      
      // Now safe to settle any remaining animations
      await tester.pumpAndSettle();

      // Verification that page loaded
      expect(find.byType(PrintStateManagementPage), findsOneWidget);
      expect(find.text('Karel Čapek'), findsOneWidget);
    });
  });
}
