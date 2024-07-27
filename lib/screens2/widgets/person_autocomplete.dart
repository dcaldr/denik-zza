import 'package:flutter/material.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';

class PersonAutocomplete extends StatefulWidget {
  final void Function(MemoryOsoba) onPersonSelected;

  const PersonAutocomplete({super.key, required this.onPersonSelected});

  @override
  _PersonAutocompleteState createState() => _PersonAutocompleteState();
}

class _PersonAutocompleteState extends State<PersonAutocomplete> {
  final DatabaseInterface database = DatabaseWrapper.getDatabase();
  List<MemoryOsoba> _persons = [];

  @override
  void initState() {
    super.initState();
    _fetchPersons();
  }

  void _fetchPersons() async {
    _persons = await database.getParticipantsByCurrentEvent();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<MemoryOsoba>(
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
      displayStringForOption: (MemoryOsoba person) => '${person.jmeno} ${person.prijmeni}',
      onSelected: (MemoryOsoba person) {
        widget.onPersonSelected(person);
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'najít osobu',
          ),
        );
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<MemoryOsoba> onSelected, Iterable<MemoryOsoba> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: Container(
              height: 200,
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final MemoryOsoba option = options.elementAt(index);
                  return ListTile(
                    title: Text('${option.jmeno} ${option.prijmeni}'),
                    subtitle: Text('Číslo pojištění: ${option.cisloPojisteni ?? 'N/A'}'),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}