import '../../database/database_interface.dart';
import '../../database/database_wrapper.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../widgets/memory_restriction_widget.dart';
import 'package:denik_zza/utils/app_logger.dart';

/// Service class for handling participant registration with restrictions and medications
/// Implements two-step save: first save participant, then save restrictions with proper ID
class ParticipantRegistrationService {
  final DatabaseInterface _db = DatabaseWrapper.getDatabase();

  /// Save a participant with restrictions and medications using two-step process
  /// Returns the participant ID if successful, null if failed
  Future<int?> saveParticipantWithRestrictions({
    required MemoryOsoba osoba,
    required MemoryOmezeniLogic omezeniLogic,
    required MemoryLekLogic lekLogic,
  }) async {
    try {
      int? participantId;

      // Step 1: Save or update the participant
      if (osoba.id == -1) {
        // New participant - use addOsobaAndReturnId
        participantId = await _db.addOsobaAndReturnId(osoba);
        if (participantId == null) {
          throw Exception('Failed to create new participant');
        }
      } else {
        // Existing participant - update and use existing ID
        final updateResult = await _db.updateParticipant(osoba: osoba);
        if (updateResult <= 0) {
          throw Exception('Failed to update participant');
        }
        participantId = osoba.id;
      }

      // Step 2: Update logic classes with the participant ID and save restrictions
      await _saveRestrictions(participantId, omezeniLogic, lekLogic);

      return participantId;
    } catch (e) {
      AppLogger.l.e('Error saving participant with restrictions: $e');
      return null;
    }
  }

  /// Save restrictions and medications for a participant
  Future<void> _saveRestrictions(int participantId,
      MemoryOmezeniLogic omezeniLogic, MemoryLekLogic lekLogic) async {
    // Update the logic classes with the correct participant ID
    omezeniLogic.updateParticipantId(participantId);
    lekLogic.updateParticipantId(participantId);

    // Save to database
    await omezeniLogic.update();
    await lekLogic.update();
  }

  /// Load restrictions and medications for an existing participant
  Future<void> loadRestrictionsForParticipant({
    required int participantId,
    required MemoryOmezeniLogic omezeniLogic,
    required MemoryLekLogic lekLogic,
  }) async {
    await omezeniLogic.fetchData(participantId);
    await lekLogic.fetchData(participantId);
  }

  /// Reset restrictions for creating a new participant
  void resetRestrictions({
    required MemoryOmezeniLogic omezeniLogic,
    required MemoryLekLogic lekLogic,
  }) {
    omezeniLogic.reset();
    lekLogic.reset();
  }
}
