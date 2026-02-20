
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/screens2/services/participant_service.dart';
import 'package:denik_zza/shared/safe_change_notifier.dart';

class ParticipantNotifier extends SafeChangeNotifier {
  final ParticipantService _participantService = ParticipantService();
  List<MemoryZaznam> _records = [];
  bool _isLoading = false;

  List<MemoryZaznam> get records => _records;
  bool get isLoading => _isLoading;

  Future<void> fetchRecords(int participantId) async {
    _isLoading = true;
    notifyListeners();
    _records = await _participantService.getParticipantRecords(participantId);
    _isLoading = false;
    notifyListeners();
  }
}

