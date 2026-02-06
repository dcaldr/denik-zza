import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/utils/date_format_utils.dart';
import 'package:denik_zza/print_ops2/print_utils.dart';
import 'package:denik_zza/print_ops2/widgets/print_status_badge.dart';

/// A row displaying a single record with a tappable print-status badge.
///
/// Used in [PersonPrintStateCard] for granular per-record toggle control.
/// The badge shows green "Vytištěno" or grey "Nevytištěno" and is tappable
/// to toggle the flag (with cascade confirmation handled by the parent).
class RecordPrintToggleRow extends StatelessWidget {
  final MemoryZaznam record;
  final VoidCallback? onToggle;

  /// Number of records that will be cascaded if this toggle proceeds.
  /// Shown as a warning hint when > 0.
  final int cascadeCount;

  /// Whether this record CAN be toggled to printed
  /// (false if earlier records are unprinted).
  final bool canMarkPrinted;

  const RecordPrintToggleRow({
    super.key,
    required this.record,
    this.onToggle,
    this.cascadeCount = 0,
    this.canMarkPrinted = true,
  });

  @override
  Widget build(BuildContext context) {
    final printed = record.isPrinted;
    final dateStr = formatCzechDate(record.casZaznamu);
    final timeStr = formatCzechTime(record.casZaznamu);
    final title = record.nazev ?? 'Bez názvu';

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.s,
      ),
      child: Row(
        children: [
          // Timestamp
          SizedBox(
            width: 110,
            child: Text(
              '$dateStr $timeStr',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.greyText,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),

          // Record title
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.s),

          // Cascade hint (shown when unmarking would affect later records)
          if (printed && cascadeCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Tooltip(
                message:
                    'Odznačení ovlivní $cascadeCount následující${cascadeCount == 1 ? '' : 'ch'} záznam${pluralSuffixCz(cascadeCount)}',
                child: Icon(Icons.warning_amber_rounded,
                    size: 16, color: AppColors.orangeText),
              ),
            ),

          // Cannot-mark hint (earlier records unprinted)
          if (!printed && !canMarkPrinted)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Tooltip(
                message: 'Nejdříve označte předchozí záznamy',
                child:
                    Icon(Icons.block, size: 14, color: AppColors.greyTextLight),
              ),
            ),

          // Toggle badge
          PrintStatusBadge(
            key: const Key('PrintStateManagement_toggle_badge'),
            backgroundColor:
                printed ? AppColors.greenBackground : AppColors.greyBackground,
            textColor: printed ? AppColors.greenText : AppColors.greyText,
            iconColor: printed ? AppColors.greenIcon : AppColors.greyIcon,
            label: printed ? 'Vytištěno' : 'Nevytištěno',
            icon: printed ? Icons.print : Icons.print_disabled,
            fontSize: 10,
            iconSize: 12,
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            enabled: printed || canMarkPrinted,
            onTap: (printed || canMarkPrinted) ? onToggle : null,
          ),
        ],
      ),
    );
  }
}
