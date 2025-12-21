import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

/// Robot for interacting with [ParticipantDetailPage].
///
/// This robot provides methods to:
/// - Verify participant details are shown
/// - Navigate to edit participant
/// - Add new medical records
/// - Print records
///
/// ## Keys Used (from `participant_detail.dart`):
/// - `ParticipantDetail_edit_button`
/// - `ParticipantDetail_newRecord_button`
/// - `ParticipantDetail_print_button`
class ParticipantDetailRobot extends BaseRobot {
  ParticipantDetailRobot(super.tester);

  // Action buttons
  Finder get editButton => findKey('ParticipantDetail_edit_button');
  Finder get newRecordButton => findKey('ParticipantDetail_newRecord_button');
  Finder get printButton => findKey('ParticipantDetail_print_button');

  /// Verifies the page is shown with participant info section.
  Future<void> verifyPageShown() async {
    await pumpAndSettle();
    // The page title shows participant name, check for common section text
    expect(find.text('Informace o účastníkovi'), findsOneWidget);
  }

  /// Verifies participant name is displayed.
  Future<void> verifyParticipantName(String fullName) async {
    await pumpAndSettle();
    expect(find.text(fullName), findsOneWidget);
  }

  /// Taps the edit button in AppBar.
  Future<void> tapEdit() async {
    await tap(editButton);
  }

  /// Taps the "Nový záznam" button.
  Future<void> tapNewRecord() async {
    await tap(newRecordButton);
  }

  /// Taps the "Tisknout záznamy" button.
  Future<void> tapPrint() async {
    await tap(printButton);
  }
}
