import 'package:flutter/material.dart';

import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_health_bottom_sheet.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_health_badges.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_health_chip_wrap.dart';

class NewRecordHealthInfo extends StatefulWidget {
  final bool isCompact;
  final List<MemoryOmezeni> omezeniList;
  final List<MemoryLek> lekyList;

  const NewRecordHealthInfo({
    super.key,
    required this.isCompact,
    required this.omezeniList,
    required this.lekyList,
  });

  @override
  State<NewRecordHealthInfo> createState() => _NewRecordHealthInfoState();
}

class _OmezeniSplit {
  final List<MemoryOmezeni> alergie;
  final List<MemoryOmezeni> omezeni;

  const _OmezeniSplit({
    required this.alergie,
    required this.omezeni,
  });
}

class _NewRecordHealthInfoState extends State<NewRecordHealthInfo> {
  @override
  Widget build(BuildContext context) {
    final split = _splitOmezeni();
    final alergieList = split.alergie;
    final omezeniList = split.omezeni;
    final sections = _buildSections(
      context,
      alergieList: alergieList,
      omezeniList: omezeniList,
      lekyList: widget.lekyList,
    );

    final totalItems = sections.fold<int>(
      0,
      (sum, section) => sum + section.items.length,
    );

    if (totalItems == 0) {
      return _buildHealthAllClearIndicator();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final useCompactBadges =
        widget.isCompact || AppBreakpoints.isMobile(screenWidth);

    if (useCompactBadges) {
      return NewRecordHealthBadges(
        criticalCount: sections[0].items.length + sections[1].items.length,
        medCount: sections[2].items.length,
        onTap: _showHealthDetailsBottomSheet,
      );
    }

    return NewRecordHealthChipWrap(
      sections: sections,
      buildChips: (section, maxChars) =>
          _buildSectionChips(section: section, maxChars: maxChars),
    );
  }

  Widget _buildHealthAllClearIndicator() {
    return Container(
      key: const Key('NewRecordPage_health_all_clear'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.greenBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.greenBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: AppColors.greenIcon),
          const SizedBox(width: 4),
          Text(
            'Bez omezení',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.greenText,
            ),
          ),
        ],
      ),
    );
  }

  void _showHealthDetailsBottomSheet() {
    final split = _splitOmezeni();
    final sections = _buildSections(
      context,
      alergieList: split.alergie,
      omezeniList: split.omezeni,
      lekyList: widget.lekyList,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => NewRecordHealthBottomSheet(
        sections: sections,
        buildChip: (section, text, maxChars) => _buildHealthChip(
          icon: section.icon,
          iconColor: section.iconColor,
          backgroundColor: section.backgroundColor,
          text: text,
          maxChars: maxChars,
        ),
      ),
    );
  }

  _OmezeniSplit _splitOmezeni() {
    return _OmezeniSplit(
      alergie: widget.omezeniList.where((o) => o.typOmezeni == 2).toList(),
      omezeni: widget.omezeniList.where((o) => o.typOmezeni == 1).toList(),
    );
  }

  List<NewRecordHealthSectionData> _buildSections(
    BuildContext context, {
    required List<MemoryOmezeni> alergieList,
    required List<MemoryOmezeni> omezeniList,
    required List<MemoryLek> lekyList,
  }) {
    List<String> cleanItems(Iterable<String> items) => items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return [
      NewRecordHealthSectionData(
        label: 'Alergie',
        icon: Icons.warning_amber,
        iconColor: Theme.of(context).colorScheme.error,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        items: cleanItems(alergieList.map((item) => item.omezeni)),
      ),
      NewRecordHealthSectionData(
        label: 'Omezení',
        icon: Icons.block,
        iconColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        items: cleanItems(omezeniList.map((item) => item.omezeni)),
      ),
      NewRecordHealthSectionData(
        label: 'Léky',
        icon: Icons.medication,
        iconColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        items: cleanItems(lekyList.map((lek) => lek.nazev)),
      ),
    ];
  }

  List<Widget> _buildSectionChips({
    required NewRecordHealthSectionData section,
    required int maxChars,
  }) {
    return section.items
        .map(
          (text) => _buildHealthChip(
            icon: section.icon,
            iconColor: section.iconColor,
            backgroundColor: section.backgroundColor,
            text: text,
            maxChars: maxChars,
          ),
        )
        .toList();
  }

  Widget _buildHealthChip({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String text,
    required int maxChars,
  }) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return const SizedBox.shrink();
    }

    final truncated = normalized.length > maxChars;
    final displayText =
      truncated ? '${normalized.substring(0, maxChars)}...' : normalized;

    return InkWell(
        onTap: truncated
          ? () => _showHealthDetailOverlay(normalized, icon, iconColor)
          : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.greyBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.greyIcon,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHealthDetailOverlay(
      String fullText, IconData icon, Color iconColor) {
    final safeText = fullText.trim().isEmpty ? 'Neuvedeno' : fullText;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                safeText,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zavřít'),
          ),
        ],
      ),
    );
  }
}
