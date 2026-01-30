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
  // Focus node supplied by Autocomplete.fieldViewBuilder; stored so
  // optionsBuilder can show all entries when the field is focused.
  FocusNode? _autocompleteFocusNode;
  bool _focusListenerAttached = false;
  VoidCallback? _focusListener;

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
                  width: (MediaQuery.of(context).size.width * 0.95).clamp(200.0, 600.0),
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
            // If the field is focused and empty, show all available persons
            // so the user can pick without typing.
            if (textEditingValue.text.isEmpty) {
              if ((widget.availablePersons.isNotEmpty) &&
                  (_autocompleteFocusNode?.hasFocus ?? false)) {
                return widget.availablePersons;
              }

              return const Iterable<MemoryOsoba>.empty();
            }

            // Handle empty available persons list
            if (widget.availablePersons.isEmpty) {
              return const Iterable<MemoryOsoba>.empty();
            }

            // Order-independent matching: split query into parts,
            // each part must match either firstName or lastName
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
            // Store the focus node provided by Autocomplete so optionsBuilder
            // can know whether the field currently has focus.
            _autocompleteFocusNode = focusNode;
            if (!_focusListenerAttached) {
              _focusListenerAttached = true;
              _focusListener = () {
                // Trigger rebuild so optionsBuilder can react to focus changes
                if (mounted) setState(() {});
              };
              _autocompleteFocusNode?.addListener(_focusListener!);
            }

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

  @override
  void dispose() {
    if (_autocompleteFocusNode != null && _focusListenerAttached) {
      if (_focusListener != null) {
        _autocompleteFocusNode?.removeListener(_focusListener!);
      }
    }
    super.dispose();
  }
}
