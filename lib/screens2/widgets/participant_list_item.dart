import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/participant_detail.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';

/// Reusable widget representing an individual participant item in a list.
///
/// Displays participant name, birth date, and a detail button.
/// Used in both EventDetail and ParticipantListScreen.
class ParticipantListItem extends StatelessWidget {
  final MemoryOsoba osoba;
  final int? index;

  /// Constructor for the ParticipantListItem widget.
  const ParticipantListItem({
    super.key,
    required this.osoba,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: index != null ? Key('ParticipantListItem_$index') : null,
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: AppRadii.cardRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParticipantDetailPage(
                participant: osoba,
              ),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
        title: Row(
          children: [
            Expanded(
              child: Text('${osoba.jmeno} ${osoba.prijmeni}'),
            ),
            Expanded(
              child: Text(
                osoba.datumNarozeni != null
                    ? '${osoba.datumNarozeni!.day.toString().padLeft(2, '0')}.${osoba.datumNarozeni!.month.toString().padLeft(2, '0')}.${osoba.datumNarozeni!.year}'
                    : '',
              ),
            ),
            OutlinedButton(
              key: index != null
                  ? Key('ParticipantListItem_${index}_detailButton')
                  : null,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParticipantDetailPage(
                      participant: osoba,
                    ),
                  ),
                );
              },
              child: const Text('Detail'),
            ),
          ],
        ),
      ),
    );
  }
}
