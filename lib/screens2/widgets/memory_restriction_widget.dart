import 'package:denik_zza/screens2/widgets/restrictions_widget.dart';
import 'package:denik_zza/input/text_tools.dart';
import '../../database/database_interface.dart';
import '../../database/database_wrapper.dart';
import '../../database/in_memory_structures_tmp/memory_lek.dart';
import '../../database/in_memory_structures_tmp/memory_omezeni.dart';

class MemoryOmezeniLogic implements LogicInterface {
  final DatabaseInterface db = DatabaseWrapper.getDatabase();
  final List<String> _items = [];
  final List<String> _names = [];
  final Map<String, int> _typeByName = {};
  final List<MemoryOmezeni> _newOmezeni = [];
  late int? pid;

  @override
  List<String> get items => _items;
  @override
  List<String> get names => _names;

  @override
  Future<void> fetchData([int? participantId]) async {
    pid = participantId;

    // ALWAYS refresh suggestions from DB for autocomplete
    _names.clear();
    _typeByName.clear();
    List<MemoryOmezeni> allOmezeni = await db.getAllOmezeni();
    for (final omezeni in allOmezeni) {
      _names.add(omezeni.omezeni);
      // If duplicates exist, prefer allergy type when present.
      final existingType = _typeByName[omezeni.omezeni];
      if (existingType == null || omezeni.typOmezeni == 2) {
        _typeByName[omezeni.omezeni] = omezeni.typOmezeni;
      }
    }

    // Load participant's items for edit mode
    if (participantId != null) {
      _items.clear();
      List<MemoryOmezeni> participantOmezeni =
          await db.getOmezeniByParticipantID(participantId);
      _items.addAll(participantOmezeni.map((e) => e.omezeni));
    }
  }

  @override
  void addItem(String name) {
    if (_items.contains(name)) {
      return;
    }
    _items.add(name);
    final typOmezeni = _resolveRestrictionType(name);
    MemoryOmezeni newOmezeni = MemoryOmezeni(
      omezeni: name,
      idOsoby: pid,
      typOmezeni: typOmezeni,
    );
    _newOmezeni.add(newOmezeni);
  }

  // Keep restriction semantic type when adding existing suggestions.
  // Fallback: if user enters custom text, infer allergy from common prefix.
  int _resolveRestrictionType(String name) {
    final fromDb = _typeByName[name];
    if (fromDb != null) {
      return fromDb;
    }
    if (_looksLikeAllergy(name)) {
      return 2;
    }
    return 1;
  }

  bool _looksLikeAllergy(String value) {
    final normalized = TextTools.normText(value);
    const allergyTokens = <String>[
      'alerg',
      'anafyl',
      'pyl',
      'latex',
      'lakt',
      'ara',
      'orech',
      'bodn',
      'stip',
      'stipn',
      'hmyzi',
      'vcel',
      'epipen',
    ];
    return allergyTokens.any(normalized.contains);
  }

  @override
  String getText() {
    return 'Omezení a alergie';
  }

  @override
  Future<void> update() async {
    for (int i = 0; i < _newOmezeni.length; i++) {
      final omezeni = _newOmezeni[i];
      await db.addOmezeni(omezeni);
    }
    _newOmezeni.clear();
    await fetchData();
  }

  void reset() {
    _items.clear();
    _newOmezeni.clear();
    // Refresh suggestions for next participant
    fetchData();
  }

  /// Update participant ID for all pending restrictions
  void updateParticipantId(int participantId) {
    pid = participantId;
    for (var omezeni in _newOmezeni) {
      omezeni.idOsoby = participantId;
    }
  }
}

class MemoryLekLogic implements LogicInterface {
  final DatabaseInterface db = DatabaseWrapper.getDatabase();
  final List<String> _items = [];
  final List<String> _names = [];
  final List<MemoryLek> _newLeky = [];
  int? pid;

  @override
  List<String> get items => _items;
  @override
  List<String> get names => _names;

  @override
  Future<void> fetchData([int? participantId]) async {
    pid = participantId;

    // ALWAYS refresh suggestions from DB for autocomplete
    _names.clear();
    List<MemoryLek> allLeky = await db.getAllLeky();
    _names.addAll(allLeky.map((e) => e.nazev));

    // Load participant's items for edit mode
    if (participantId != null) {
      _items.clear();
      List<MemoryLek> participantLeky =
          await db.getLekyByParticipantID(participantId);
      _items.addAll(participantLeky.map((e) => e.nazev));
    }
  }

  @override
  void addItem(String name) {
    if (!_items.contains(name)) {
      _items.add(name);
      final parsed = _parseMedicationInput(name);
      MemoryLek newLek = MemoryLek.fullNamed(
        nazev: parsed.name,
        popisDavkovani: parsed.dosage,
        idOsoby: pid ?? -1,
        id: null,
      );
      _newLeky.add(newLek);
    }
  }

  // Accepts either plain names ("Panthenol") or formatted values
  // like "Ibalgin 400mg (1 tableta, Při bolesti)" and preserves structure.
  ({String name, String? dosage}) _parseMedicationInput(String input) {
    final trimmed = input.trim();
    final open = trimmed.lastIndexOf('(');
    final close = trimmed.endsWith(')') ? trimmed.length - 1 : -1;
    if (open > 0 && close > open) {
      final medName = trimmed.substring(0, open).trim();
      final details = trimmed.substring(open + 1, close).trim();
      if (medName.isNotEmpty) {
        return (
          name: medName,
          dosage: details.isEmpty ? null : details,
        );
      }
    }
    return (name: trimmed, dosage: null);
  }

  @override
  String getText() {
    return 'Léky';
  }

  @override
  Future<void> update() async {
    for (var lek in _newLeky) {
      await db.addLek(lek);
    }
    _newLeky.clear();
    await fetchData();
  }

  void reset() {
    _items.clear();
    _newLeky.clear();
    // Refresh suggestions for next participant
    fetchData();
  }

  /// Update participant ID for all pending medications
  void updateParticipantId(int participantId) {
    pid = participantId;
    for (var lek in _newLeky) {
      lek.idOsoby = participantId;
    }
  }
}
