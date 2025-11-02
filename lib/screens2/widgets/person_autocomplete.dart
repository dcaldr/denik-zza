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
  // Create stable controllers in State to survive rebuilds
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Show only first and last name to match test expectations
  static String _displayStringForOption(MemoryOsoba option) => '${option.jmeno} ${option.prijmeni}';
  
  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<MemoryOsoba>(
      textEditingController: _textController,
      focusNode: _focusNode,
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
        _textController.clear();
        // Dismiss keyboard / suggestions
        _focusNode.unfocus();
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        // RawAutocomplete provides our controllers back to us
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
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<MemoryOsoba> onSelected, Iterable<MemoryOsoba> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 400),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final MemoryOsoba option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(_displayStringForOption(option)),
                    ),
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