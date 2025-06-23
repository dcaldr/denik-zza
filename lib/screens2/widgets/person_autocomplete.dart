import 'package:flutter/material.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import '../shared/intake_types.dart';

class PersonAutocomplete extends StatefulWidget {
  final PersonSelectedCallback onPersonSelected;
  final IntakeRefreshCallback onRefresh;

  const PersonAutocomplete({
    super.key, 
    required this.onPersonSelected, 
    required this.onRefresh
  });

  @override
  State<PersonAutocomplete> createState() => _PersonAutocompleteState();
}

class _PersonAutocompleteState extends State<PersonAutocomplete> {
  final DatabaseInterface database = DatabaseWrapper.getDatabase();
  List<MemoryOsoba> _persons = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPersons();
  }

  void _fetchPersons() async {
    _persons = await database.getParticipantsByCurrentEvent();
    setState(() {});
  }

  void refreshData() {
    _fetchPersons();
  }

  static String _displayStringForOption(MemoryOsoba option) => '${option.jmeno} ${option.prijmeni} ${option.id}';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Autocomplete<MemoryOsoba>(
          displayStringForOption: _displayStringForOption,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<MemoryOsoba>.empty();
            }
            return _persons.where((MemoryOsoba person) {
              final lowerQuery = textEditingValue.text.toLowerCase();
              return person.jmeno.toLowerCase().contains(lowerQuery) ||
                     person.prijmeni.toLowerCase().contains(lowerQuery) ||
                     (person.cisloPojisteni?.toLowerCase().contains(lowerQuery) ?? false);
            });
          },
          onSelected: (MemoryOsoba person) async {
            _persons = await database.getParticipantsByCurrentEvent();
            widget.onPersonSelected(person);
          },
          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search for a person',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}