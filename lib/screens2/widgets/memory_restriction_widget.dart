import 'package:denik_zza/screens2/widgets/restrictions_widget.dart';
import '../../database/database_interface.dart';
import '../../database/database_wrapper.dart';
import '../../database/in_memory_structures_tmp/memory_lek.dart';
import '../../database/in_memory_structures_tmp/memory_omezeni.dart';

class MemoryOmezeniLogic implements LogicInterface {
  final DatabaseInterface db = DatabaseWrapper.getDatabase();
  final List<String> _items = [];
  final List<String> _names = [];
  final List<MemoryOmezeni> _newOmezeni = [];
  late int? pid;

  @override
  List<String> get items => _items;
  @override
  List<String> get names => _names;

  @override
  Future<void> fetchData([int? participantId]) async {
    pid = participantId;
    if (_names.isEmpty) {
      List<MemoryOmezeni> allOmezeni = await db.getAllOmezeni();
      _names.addAll(allOmezeni.map((e) => e.omezeni));
    }

    if (participantId != null && _items.isEmpty) {
      List<MemoryOmezeni> participantOmezeni =
          await db.getOmezeniByParticipantID(participantId);
      _items.addAll(participantOmezeni.map((e) => e.omezeni));
    }
  }

  @override
  void addItem(String name) {
    if (!_items.contains(name)) {
      _items.add(name);
      MemoryOmezeni newOmezeni = MemoryOmezeni(omezeni: name, idOsoby: pid);
      _newOmezeni.add(newOmezeni);
      // DEBUG: Trace item added
      // ignore: avoid_print
      print(
          '🔵 MemoryOmezeniLogic.addItem: Added "$name" (pid=$pid, _newOmezeni.length=${_newOmezeni.length})');
    } else {
      // DEBUG: Trace duplicate skipped
      // ignore: avoid_print
      print('🟡 MemoryOmezeniLogic.addItem: SKIPPED duplicate "$name"');
    }
  }

  @override
  String getText() {
    return 'Omezení a alergie';
  }

  @override
  Future<void> update() async {
    // DEBUG: Trace update start
    // ignore: avoid_print
    print(
        '🔵 MemoryOmezeniLogic.update: START - _newOmezeni.length=${_newOmezeni.length}');

    for (int i = 0; i < _newOmezeni.length; i++) {
      final omezeni = _newOmezeni[i];
      // DEBUG: Trace each save
      // ignore: avoid_print
      print(
          '🔵 MemoryOmezeniLogic.update: Saving ${i + 1}/${_newOmezeni.length} - "${omezeni.omezeni}" (idOsoby=${omezeni.idOsoby})');

      final result = await db.addOmezeni(omezeni);

      // DEBUG: Trace result
      // ignore: avoid_print
      print(
          '🔵 MemoryOmezeniLogic.update: Result for ${i + 1}/${_newOmezeni.length} = $result');
    }
    _newOmezeni.clear();
    await fetchData();
    // ignore: avoid_print
    print('🔵 MemoryOmezeniLogic.update: COMPLETE');
  }

  void reset() {
    _items.clear();
    _newOmezeni.clear();
  }

  /// Update participant ID for all pending restrictions
  void updateParticipantId(int participantId) {
    // DEBUG: Trace ID update
    // ignore: avoid_print
    print(
        '🔵 MemoryOmezeniLogic.updateParticipantId: Setting pid=$participantId for ${_newOmezeni.length} pending restrictions');

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
    if (_names.isEmpty) {
      List<MemoryLek> allLeky = await db.getAllLeky();
      _names.addAll(allLeky.map((e) => e.nazev));
    }

    if (participantId != null && _items.isEmpty) {
      List<MemoryLek> participantLeky =
          await db.getLekyByParticipantID(participantId);
      _items.addAll(participantLeky.map((e) => e.nazev));
    }
  }

  @override
  void addItem(String name) {
    if (!_items.contains(name)) {
      _items.add(name);
      MemoryLek newLek =
          MemoryLek.fullNamed(nazev: name, idOsoby: pid ?? -1, id: null);
      _newLeky.add(newLek);
    }
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
  }

  /// Update participant ID for all pending medications
  void updateParticipantId(int participantId) {
    pid = participantId;
    for (var lek in _newLeky) {
      lek.idOsoby = participantId;
    }
  }
}
