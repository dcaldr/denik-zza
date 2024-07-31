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

  @override
  List<String> get items => _items;
  @override
  List<String> get names => _names;

  @override
  Future<void> fetchData([int? participantId]) async {
    if (_names.isEmpty) {
      List<MemoryOmezeni> allOmezeni = await db.getAllOmezeni();
      _names.addAll(allOmezeni.map((e) => e.omezeni));
    }

    if (participantId != null && _items.isEmpty) {
      List<MemoryOmezeni> participantOmezeni = await db.getOmezeniByParticipantID(participantId);
      _items.addAll(participantOmezeni.map((e) => e.omezeni));
    }
  }

  @override
  void addItem(String name) {
    if (!_items.contains(name)) {
      _items.add(name);
      MemoryOmezeni newOmezeni = MemoryOmezeni(omezeni: name);
      _newOmezeni.add(newOmezeni);
    }
  }

  @override
  String getText() {
    return 'Omezení';
  }

  @override
  Future<void> update() async {
    for (var omezeni in _newOmezeni) {
      await db.addOmezeni(omezeni);
    }
    _newOmezeni.clear();
    await fetchData();
  }

  void reset() {
    _items.clear();
    _newOmezeni.clear();
  }
}


class MemoryLekLogic implements LogicInterface {
  final DatabaseInterface db = DatabaseWrapper.getDatabase();
  final List<String> _items = [];
  final List<String> _names = [];
  final List<MemoryLek> _newLeky = [];

  @override
  List<String> get items => _items;
  @override
  List<String> get names => _names;

  @override
  Future<void> fetchData([int? participantId]) async {
    if (_names.isEmpty) {
      List<MemoryLek> allLeky = await db.getAllLeky();
      _names.addAll(allLeky.map((e) => e.nazev));
    }

    if (participantId != null && _items.isEmpty) {
      List<MemoryLek> participantLeky = await db.getLekyByParticipantID(participantId);
      _items.addAll(participantLeky.map((e) => e.nazev));
    }
  }

  @override
  void addItem(String name) {
    if (!_items.contains(name)) {
      _items.add(name);
      MemoryLek newLek = MemoryLek(null, name, null, false, null);
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
}