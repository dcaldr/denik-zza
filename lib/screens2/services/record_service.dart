import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';

class RecordService {
  final DatabaseInterface _db = DatabaseWrapper.getDatabase();

  Future<void> addRecord(MemoryZaznam record) async {
    await _db.addZaznam(record);
  }
}

