import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';

/// Enhanced service for managing medical records
/// Provides more functionality than the basic version
class RecordService {
  final DatabaseInterface _db = DatabaseWrapper.getDatabase();

  /// Add a new medical record
  Future<void> addRecord(MemoryZaznam record) async {
    await _db.addZaznam(record);
  }

  /// Get all records for a specific participant
  Future<List<MemoryZaznam>> getRecordsByParticipant(int participantId) async {
    return await _db.getRecordsByParticipantID(participantId);
  }

  /// Validate record data before saving
  static String? validateRecord({
    required String title,
    required String description,
  }) {
    if (title.trim().isEmpty) {
      return 'Název je povinný';
    }
    
    if (title.length > 200) {
      return 'Název nesmí být delší než 200 znaků';
    }
    
    if (description.trim().isEmpty) {
      return 'Popis je povinný';
    }
    
    if (description.length > 1024) {
      return 'Popis nesmí být delší než 1024 znaků';
    }
    
    return null; // No validation errors
  }
}

