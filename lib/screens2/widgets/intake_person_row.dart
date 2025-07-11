import 'package:flutter/material.dart';
import '../shared/intake_types.dart';
import 'person_autocomplete.dart';

class IntakePersonRow extends StatelessWidget {
  final PersonSelectedCallback onPersonSelected;
  final IntakeRefreshCallback onRefresh;

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
        ],
      ),
    );
  }
}
