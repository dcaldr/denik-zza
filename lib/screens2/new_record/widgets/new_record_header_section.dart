import 'package:flutter/material.dart';

import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';

class NewRecordHeaderSection extends StatelessWidget {
  final bool isCompact;
  final bool hasParticipant;
  final bool hasUnsavedChanges;
  final String participantTitle;
  final String participantSubtitle;
  final bool showBirthdateInfo;
  final VoidCallback? onBirthdateInfo;
  final Widget? healthInfo;
  final List<MemoryOsoba> availableParticipants;
  final ValueChanged<MemoryOsoba> onParticipantSelected;
  final VoidCallback onRefresh;
  final GlobalKey headerKey;

  const NewRecordHeaderSection({
    super.key,
    required this.isCompact,
    required this.hasParticipant,
    required this.hasUnsavedChanges,
    required this.participantTitle,
    required this.participantSubtitle,
    required this.showBirthdateInfo,
    required this.onBirthdateInfo,
    required this.healthInfo,
    required this.availableParticipants,
    required this.onParticipantSelected,
    required this.onRefresh,
    required this.headerKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: headerKey,
      padding: AppSpacing.containerPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.5),
          ],
        ),
        borderRadius: AppRadii.containerRadius,
        border:
            Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              hasParticipant ? Icons.person : Icons.person_search,
              color: Theme.of(context).colorScheme.primary,
              size: isCompact ? 18 : 20,
            ),
          ),
          SizedBox(width: AppSpacing.m),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        participantTitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCompact ? 12 : 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blueText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (hasUnsavedChanges)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.orangeBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.orangeBorder, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber,
                              size: 10,
                              color: AppColors.orangeText,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Neuloženo',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: AppColors.orangeText,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        participantSubtitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCompact ? 14 : 15,
                          fontWeight: FontWeight.bold,
                          color: hasParticipant
                              ? AppColors.greyIcon
                              : AppColors.greyText,
                        ),
                      ),
                    ),
                    if (showBirthdateInfo) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        key:
                            const Key('NewRecordPage_birthdate_info_icon'),
                        onTap: onBirthdateInfo,
                        borderRadius: AppRadii.containerRadius,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.info_outline,
                            size: 14,
                            color: AppColors.blueText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (healthInfo != null) ...[
                  const SizedBox(height: 4),
                  healthInfo!,
                ],
              ],
            ),
          ),
          SizedBox(width: AppSpacing.m),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 0),
                SizedBox(height: isCompact ? 2 : 4),
                PersonAutocomplete(
                  key:
                      const Key('NewRecordPage_participantAutocomplete'),
                  onPersonSelected: onParticipantSelected,
                  onRefresh: onRefresh,
                  availablePersons: availableParticipants,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
