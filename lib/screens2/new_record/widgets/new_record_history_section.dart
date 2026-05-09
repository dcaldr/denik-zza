

import 'package:flutter/material.dart';

import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/widgets/count_badge.dart';
import 'package:denik_zza/screens2/widgets/record_list_widget.dart';

class NewRecordHistorySection extends StatelessWidget {
  final bool isCompact;
  final int recordCount;
  final GlobalKey historyHeaderKey;
  final double historyHeaderHeight;
  final double historyMaxHeight;
  final MemoryOsoba? selectedParticipant;
  final int refreshCounter;
  final void Function(int count)? onRecordsLoaded;

  const NewRecordHistorySection({
    super.key,
    required this.isCompact,
    required this.recordCount,
    required this.historyHeaderKey,
    required this.historyHeaderHeight,
    required this.historyMaxHeight,
    required this.selectedParticipant,
    required this.refreshCounter,
    required this.onRecordsLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final Widget historyList = selectedParticipant != null
        ? RecordListWidget(
            key: ValueKey(refreshCounter),
            participant: selectedParticipant!,
            onRecordsLoaded: onRecordsLoaded,
          )
        : Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_search,
                    size: 24,
                    color: AppColors.greyTextLight,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nejprve vyberte účastníka',
                    style: TextStyle(
                      fontSize: isCompact ? 10 : 12,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Po výběru účastníka se zde zobrazí\njejí historie úrazů',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.greyBorderDark, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            key: historyHeaderKey,
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8.0 : 12.0,
              vertical: isCompact ? 6.0 : 8.0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppColors.greyText,
                  size: isCompact ? 12 : 14,
                ),
                SizedBox(width: isCompact ? 4 : 6),
                Text(
                  'Historie úrazů',
                  style: TextStyle(
                    fontSize: isCompact ? 10 : 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyIcon,
                  ),
                ),
                if (recordCount > 0) ...[
                  const SizedBox(width: 6),
                  CountBadge(
                    count: recordCount,
                    isCompact: isCompact,
                  ),
                ],
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: historyList,
          ),
        ],
      ),
    );
  }
}
