import 'package:denik_zza/screens2/widgets/restrictions_widget.dart';
import '../../database/database_interface.dart';
import '../../database/database_wrapper.dart';
import '../../database/in_memory_structures_tmp/memory_omezeni.dart';


class MemoryRestrictionLogic implements LogicInterface {
  final DatabaseInterface db = DatabaseWrapper.getDatabase();
  final List<String> _items = [];
  final List<String> _names = [];

  @override
  List<String> get items => _items;
  @override
  List<String> get names => _names;

  @override
  Future<void> fetchData() async {
    List<MemoryOmezeni> omezeni = await db.getAllOmezeni();
    _names.addAll(omezeni.map((e) => e.omezeni));
  }

  @override
  void addItem(String name) {
    _items.add(name);
  }

  @override
  String getText() {
    return 'Omezení';
  }
}


class MemoryLekLogic implements LogicInterface {
  final DatabaseInterface db = DatabaseWrapper.getDatabase();
  final List<String> _items = [];
  final List<String> _names = [];

  @override
  List<String> get items => _items;
  @override
  List<String> get names => _names;

  @override
  Future<void> fetchData() async {
    var leky = await db.getAllLeky();
    _names.addAll(leky.map((e) => e.nazev));
  }

  @override
  void addItem(String name) {
    _items.add(name);
  }

  @override
  String getText() {
    return 'Léky';
  }
}