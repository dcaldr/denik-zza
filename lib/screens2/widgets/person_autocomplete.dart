import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
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
  // Keep references to clear field after selection
  TextEditingController? _searchController;
  FocusNode? _focusNode;

  // Show only first and last name to match test expectations
  static String _displayStringForOption(MemoryOsoba option) => '${option.jmeno} ${option.prijmeni}';
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
            
            // Handle empty available persons list
            if (widget.availablePersons.isEmpty) {
              return const Iterable<MemoryOsoba>.empty();
            }
            
            return widget.availablePersons.where((MemoryOsoba person) {
              final lowerQuery = textEditingValue.text.toLowerCase();
              return person.jmeno.toLowerCase().contains(lowerQuery) ||
                     person.prijmeni.toLowerCase().contains(lowerQuery) ||
                     (person.cisloPojisteni?.toLowerCase().contains(lowerQuery) ?? false);
            });
          },
          onSelected: (MemoryOsoba person) {
            widget.onPersonSelected(person);
            // Clear the search field to avoid duplicate text matches in tests
            if (_searchController != null) {
              _searchController!.clear();
            }
            // Dismiss keyboard / suggestions
            _focusNode?.unfocus();
          },
          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
            _searchController = textEditingController;
            _focusNode = focusNode;
            return TextField(
              key: widget.textFieldKey,
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Hledat osobu...',
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