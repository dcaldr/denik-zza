import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';

import 'package:denik_zza/print_ops2/models/person_print_state.dart';
import 'package:denik_zza/print_ops2/widgets/record_print_toggle_row.dart';
import 'package:denik_zza/print_ops2/widgets/print_status_badge.dart';

/// Expandable card showing a person's print state with record-level toggles.
///
/// Provides:
/// - Person-level wasPrinted toggle (header badge)
/// - Record count summary
/// - Append status indicator
/// - Expandable list of records with per-record toggles
/// - Bulk actions (mark all / reset all)
class PersonPrintStateCard extends StatefulWidget {
  final PersonPrintState state;
  final ValueChanged<int> onTogglePersonPrinted;
  final void Function(int personId, int recordId) onToggleRecordPrinted;
  final ValueChanged<int> onMarkAllPrinted;
  final ValueChanged<int> onResetAll;

  const PersonPrintStateCard({
    super.key,
    required this.state,
    required this.onTogglePersonPrinted,
    required this.onToggleRecordPrinted,
    required this.onMarkAllPrinted,
    required this.onResetAll,
  });

  @override
  State<PersonPrintStateCard> createState() => _PersonPrintStateCardState();
}

class _PersonPrintStateCardState extends State<PersonPrintStateCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.state;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      child: Column(
        children: [
          // Header — person info + toggle + summary
          _buildHeader(context, s),

          // Append status / warnings
          if (_expanded) _buildStatusBanner(context, s),

          // Records list
          if (_expanded && s.records.isNotEmpty) _buildRecordsList(context, s),

          // Bulk actions
          if (_expanded) _buildBulkActions(context, s),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PersonPrintState s) {
    return InkWell(
      key: Key('PrintState_person_${s.person.id}'),
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: AppRadii.cardRadius,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            // Person avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: s.personPrinted
                  ? AppColors.greenBackground
                  : AppColors.greyBackground,
              child: Text(
                s.person.jmeno.isNotEmpty ? s.person.jmeno[0] : '?',
                style: TextStyle(
                  color: s.personPrinted
                      ? AppColors.greenText
                      : AppColors.greyText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),

            // Name + record summary
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${s.printedRecordCount}/${s.totalRecordCount} záznamů vytištěno',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.greyText,
                        ),
                  ),
                ],
              ),
            ),

            // Person printed badge (tappable)
            PrintStatusBadge(
              key: const Key('PrintState_personBadge_toggle'),
              backgroundColor: s.personPrinted
                  ? AppColors.greenBackground
                  : AppColors.greyBackground,
              textColor:
                  s.personPrinted ? AppColors.greenText : AppColors.greyText,
              iconColor:
                  s.personPrinted ? AppColors.greenIcon : AppColors.greyIcon,
              label: s.personPrinted ? 'Vytištěno' : 'Nevytištěno',
              icon: s.personPrinted ? Icons.person : Icons.person_outline,
              fontSize: 11,
              iconSize: 14,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: 3,
              ),
              borderColor: s.personPrinted
                  ? AppColors.greenBorder
                  : AppColors.greyBorder,
              onTap: () => _handlePersonToggle(context, s),
            ),
            const SizedBox(width: AppSpacing.xs),

            // Append indicator
            _AppendIndicator(possible: s.appendPossible),
            const SizedBox(width: AppSpacing.xs),

            // Expand arrow
            Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.greyIcon,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, PersonPrintState s) {
    if (s.hasSequenceIssue) {
      return _StatusBanner(
        color: AppColors.orangeBackground,
        borderColor: AppColors.orangeBorder,
        icon: Icons.warning_amber_rounded,
        text: 'Pořadí záznamů je porušeno — dostisk není možný.',
      );
    }
    if (s.personPrinted &&
        s.printedRecordCount == 0 &&
        s.totalRecordCount > 0) {
      return _StatusBanner(
        color: AppColors.blueBackground,
        borderColor: AppColors.blueBorder,
        icon: Icons.info_outline,
        text: 'Hlavička vytištěna, záznamy k dotisku.',
      );
    }
    if (!s.personPrinted) {
      return _StatusBanner(
        color: AppColors.greyBackground,
        borderColor: AppColors.greyBorder,
        icon: Icons.info_outline,
        text: 'Osoba dosud nevytištěna — nejprve označte jako vytištěnou.',
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRecordsList(BuildContext context, PersonPrintState s) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final screenHeight = MediaQuery.sizeOf(context).height;
        
        /// Responsive max height calculation prevents ListView overflow.
        /// 
        /// Ratios by breakpoint (conservatively low to leave room for controls):
        /// - Desktop (≥900px):  40% screen height (max 500px)
        /// - Tablet (600-899px): 35% screen height (max 400px)  
        /// - Mobile (<600px):    30% screen height (max 300px)
        /// 
        /// Lower ratios on mobile because:
        /// 1. Screen real estate is limited
        /// 2. User needs room to scroll the parent page
        /// 3. Prevents nested scroll jank when both lists need scrolling
        /// 4. Safe during cascade mode when many cards are expanded
        /// 
        /// Clamped behavior:
        /// - Minimum: 3 items visible (AppBreakpoints.getItemHeight * 3)
        /// - Maximum: Absolute ceiling per device class
        /// 
        /// This ensures:
        /// - Never shows <3 items (useless for interaction)
        /// - Never causes viewport overflow on any device
        /// - Cascade mode (multiple cards expanded) remains usable
        final maxHeightRatio = AppBreakpoints.isDesktop(width) ? 0.4
            : AppBreakpoints.isTablet(width) ? 0.35
            : 0.3;
        final absoluteMax = AppBreakpoints.isDesktop(width) ? 500.0
            : AppBreakpoints.isTablet(width) ? 400.0
            : 300.0;
        
        // Calculate max height: responsive ratio, clamped to min 3 items and absolute max
        final minHeight = AppBreakpoints.getItemHeight(context, dense: true) * 3;
        final maxHeight = (screenHeight * maxHeightRatio).clamp(minHeight, absoluteMax);
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: ListView.builder(
                key: Key('PersonCard_records_${s.person.id}'),
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: s.records.length,
                itemBuilder: (context, i) {
                  final record = s.records[i];
                  
                  // Can mark as printed only if all earlier records are printed (Strict Mode)
                  bool canMark = true;
                  if (!record.isPrinted) {
                    for (int j = 0; j < i; j++) {
                      if (!s.records[j].isPrinted) {
                        canMark = false;
                        break;
                      }
                    }
                  }
                  
                  return RecordPrintToggleRow(
                    key: Key('PrintState_record_${record.idZaznamu}'),
                    record: record,
                    cascadeCount: 0, // No cascades known to UI anymore
                    canMarkPrinted: canMark,
                    onToggle: () => _handleRecordToggle(context, s, record),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBulkActions(BuildContext context, PersonPrintState s) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          TextButton.icon(
            key: const Key('PrintState_markAll'),
            onPressed: s.totalRecordCount > s.printedRecordCount
                ? () => widget.onMarkAllPrinted(s.person.id)
                : null,
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: Text(
              'Označit vše',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          TextButton.icon(
            key: const Key('PrintState_resetAll'),
            onPressed: (s.personPrinted || s.printedRecordCount > 0)
                ? () => _handleResetAll(context, s)
                : null,
            icon:
                Icon(Icons.restart_alt, size: 16, color: AppColors.orangeText),
            label: Text(
              'Odznačit vše',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.orangeText),
            ),
          ),
        ],
      ),
    );
  }

  // --- Handlers (Simplified - Direct Action) ---

  Future<void> _handlePersonToggle(BuildContext context, PersonPrintState s) async {
    // No confirmation dialog - direct toggle
    widget.onTogglePersonPrinted(s.person.id);
  }

  Future<void> _handleRecordToggle(BuildContext context, PersonPrintState s,
      MemoryZaznam record) async {
    // No confirmation dialog - direct toggle
    widget.onToggleRecordPrinted(s.person.id, record.idZaznamu);
  }

  Future<void> _handleResetAll(BuildContext context, PersonPrintState s) async {
    // Keep confirmation for Reset All as it's a destructive bulk action?
    // User requested "Manual Control" and "No cascading logic".
    // A simple confirmation for "Uncheck ALL" is still good UX, but let's keep it simple for now if requested.
    // However, the prompt said "remove confirmation dialogs". I will remove them to be consistent with "Manual Control".
    // If the user misclicks, they can just click "Mark All" to fix it.
    widget.onResetAll(s.person.id);
  }
}

class _AppendIndicator extends StatelessWidget {
  final bool possible;
  const _AppendIndicator({required this.possible});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: possible ? 'Dostisk možný' : 'Nutný plný tisk',
      child: Icon(
        possible ? Icons.playlist_add_check : Icons.replay,
        size: 18,
        color: possible ? AppColors.greenIcon : AppColors.orangeText,
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final IconData icon;
  final String text;

  const _StatusBanner({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.small),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: borderColor.darken(0.2)),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
