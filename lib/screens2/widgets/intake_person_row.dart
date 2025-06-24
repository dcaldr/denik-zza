import 'package:flutter/material.dart';
import '../shared/intake_types.dart';
import 'person_autocomplete.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';

class IntakePersonRow extends StatelessWidget {
  final PersonSelectedCallback onPersonSelected;
  final IntakeRefreshCallback onRefresh;

  const IntakePersonRow({
    super.key, 
    required this.onPersonSelected, 
    required this.onRefresh,
  });

  void _createNewPerson() {
    // Create a new empty person with null ID
    final newPerson = MemoryOsoba.basic('', '');
    newPerson.id = -1; // -1 indicates this is a new person (as per the comment in MemoryOsoba)
    onPersonSelected(newPerson);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text('Select Person: '),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: PersonAutocomplete(
                onPersonSelected: onPersonSelected, 
                onRefresh: onRefresh
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _createNewPerson,
            child: const Text('New Person'),
          ),
        ],
      ),
    );
  }
}
