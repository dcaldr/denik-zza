import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import '../shared/intake_types.dart';
import 'person_autocomplete.dart';

class IntakePersonRow extends StatelessWidget {
  final PersonSelectedCallback onPersonSelected;
  final IntakeRefreshCallback onRefresh;
  final List<MemoryOsoba> availablePersons;

  const IntakePersonRow({
    super.key,
    required this.onPersonSelected,
    required this.onRefresh,
    required this.availablePersons,
  });

  @override
  Widget build(BuildContext context) {
    print('🔍 IntakePersonRow: availablePersons.length = ${availablePersons.length}');
    return Padding(
      padding: AppSpacing.containerPadding,
      child: Row(
        children: [
          const Text('Select Person: '),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.s),
              child: PersonAutocomplete(
                onPersonSelected: onPersonSelected,
                onRefresh: onRefresh,
                availablePersons: availablePersons,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
