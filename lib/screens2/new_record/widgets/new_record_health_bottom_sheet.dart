import 'package:flutter/material.dart';

import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';

class NewRecordHealthSectionData {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final List<String> items;

  const NewRecordHealthSectionData({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.items,
  });
}

class NewRecordHealthBottomSheet extends StatelessWidget {
  final List<NewRecordHealthSectionData> sections;
  final Widget Function(NewRecordHealthSectionData data, String text, int maxChars)
      buildChip;

  const NewRecordHealthBottomSheet({
    super.key,
    required this.sections,
    required this.buildChip,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnyItems = sections.any((section) => section.items.isNotEmpty);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.greyBorderDark,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                ),
              ),
            ),
            Text(
              'Zdravotní údaje',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.greyIcon,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            if (!hasAnyItems)
              Text(
                'Nejsou zadány žádné údaje.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.greyText,
                ),
              ),
            for (final section in sections)
              if (section.items.isNotEmpty) ...[
                _HealthSectionHeader(
                  icon: section.icon,
                  iconColor: section.iconColor,
                  label: section.label,
                ),
                const SizedBox(height: AppSpacing.s),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: section.items
                      .map((text) => buildChip(section, text, 50))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.m),
              ],
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}

class _HealthSectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _HealthSectionHeader({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.greyIcon,
          ),
        ),
      ],
    );
  }
}
