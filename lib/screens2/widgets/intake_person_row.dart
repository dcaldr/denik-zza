import 'package:flutter/material.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import 'person_autocomplete.dart';

class IntakePersonRow extends StatelessWidget {
  final Function(MemoryOsoba) onPersonSelected;
  final VoidCallback onRefresh;

  const IntakePersonRow({
    super.key, 
    required this.onPersonSelected, 
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text('First Row'),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: PersonAutocomplete(
                onPersonSelected: onPersonSelected, 
                onRefresh: onRefresh
              ),
            ),
          ),
        ],
      ),
    );
  }
}
