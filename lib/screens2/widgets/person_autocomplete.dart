import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import '../shared/intake_types.dart';

class PersonAutocomplete extends StatefulWidget {
  final PersonSelectedCallback onPersonSelected;
  final IntakeRefreshCallback onRefresh;
  final List<MemoryOsoba> availablePersons;
  final Key? textFieldKey;

  const PersonAutocomplete({
    super.key,
    required this.onPersonSelected,
    required this.onRefresh,
    required this.availablePersons,
    this.textFieldKey,
  });

  @override
  State<PersonAutocomplete> createState() => _PersonAutocompleteState();
}

class _PersonAutocompleteState extends State<PersonAutocomplete> {
  // Show first name, last name for display string
  static String _displayStringForOption(MemoryOsoba option) =>
      '${option.jmeno} ${option.prijmeni}';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Autocomplete<MemoryOsoba>(
          displayStringForOption: _displayStringForOption,
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: SizedBox(
                  width: 300,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: ListTile(
                          title: Text('${option.jmeno} ${option.prijmeni}'),
                          trailing: Text(
                            '${option.datumNarozeni != null ? "${option.datumNarozeni!.day.toString().padLeft(2, '0')}.${option.datumNarozeni!.month.toString().padLeft(2, '0')}.${option.datumNarozeni!.year} | " : ""}ID: ${option.id}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<MemoryOsoba>.empty();
            }

            // Handle empty available persons list
            if (widget.availablePersons.isEmpty) {
              return const Iterable<MemoryOsoba>.empty();
            }

            return widget.availablePersons.where((MemoryOsoba person) {
              final lowerQuery = textEditingValue.text.toLowerCase();
              return person.jmeno.toLowerCase().contains(lowerQuery) ||
                  person.prijmeni.toLowerCase().contains(lowerQuery) ||
                  (person.cisloPojisteni?.toLowerCase().contains(lowerQuery) ??
                      false);
            });
          },
          onSelected: (MemoryOsoba person) {
            widget.onPersonSelected(person);
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            return TextField(
              key: widget.textFieldKey,
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Vyhledat osobu',
                border: OutlineInputBorder(
                  borderRadius: AppRadii.inputRadius,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
