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

            // Order-independent matching: split query into parts, 
            // each part must match either firstName or lastName
            // "Jan K" matches "Jan Komenský", "Ámos Jan" matches "Jan Ámos"
            final queryParts = textEditingValue.text.toLowerCase().split(' ')
                .where((p) => p.isNotEmpty).toList();
            
            final results = widget.availablePersons.where((MemoryOsoba person) {
              final lowerFirstName = person.jmeno.toLowerCase();
              final lowerLastName = person.prijmeni.toLowerCase();
              final lowerInsurance = person.cisloPojisteni?.toLowerCase() ?? '';
              
              // Each query part must match somewhere
              return queryParts.every((queryPart) =>
                  lowerFirstName.contains(queryPart) ||
                  lowerLastName.contains(queryPart) ||
                  lowerInsurance.contains(queryPart));
            }).toList();
            
            return results;
          },
          onSelected: (MemoryOsoba person) {
            widget.onPersonSelected(person);
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            return TextField(
              key: widget.textFieldKey ?? const Key('IntakeForm_personSearch_input'),
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
