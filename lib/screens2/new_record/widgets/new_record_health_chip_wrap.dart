import 'package:flutter/material.dart';

import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_health_bottom_sheet.dart';

class NewRecordHealthChipWrap extends StatefulWidget {
  final List<NewRecordHealthSectionData> sections;
  final List<Widget> Function(
    NewRecordHealthSectionData section,
    int maxChars,
  ) buildChips;

  const NewRecordHealthChipWrap({
    super.key,
    required this.sections,
    required this.buildChips,
  });

  @override
  State<NewRecordHealthChipWrap> createState() => _NewRecordHealthChipWrapState();
}

class _NewRecordHealthChipWrapState extends State<NewRecordHealthChipWrap> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxCollapsedItems = screenWidth < 900 ? 6 : 8;

    final allHealthChips = <Widget>[
      for (final section in widget.sections) ...widget.buildChips(section, 30),
    ];

    final totalItems = allHealthChips.length;
    final shouldShowCollapseButton = totalItems > maxCollapsedItems;
    final visibleChips = (_expanded || !shouldShowCollapseButton)
        ? allHealthChips
        : allHealthChips.take(maxCollapsedItems).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ...visibleChips,
        if (shouldShowCollapseButton)
          _buildCompactCollapseButton(
            hiddenCount: totalItems - maxCollapsedItems,
          ),
      ],
    );
  }

  Widget _buildCompactCollapseButton({required int hiddenCount}) {
    return InkWell(
      key: const Key('NewRecordPage_health_info_toggle'),
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.greyBackgroundMedium,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.greyBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _expanded ? Icons.expand_less : Icons.more_horiz,
              size: 14,
              color: AppColors.greyText,
            ),
            if (!_expanded) ...[
              const SizedBox(width: 2),
              Text(
                '+$hiddenCount',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.greyText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
