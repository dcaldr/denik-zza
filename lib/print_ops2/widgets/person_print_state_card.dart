import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/print_ops2/models/person_print_state.dart';
import 'package:denik_zza/print_ops2/models/toggle_impact.dart';
import 'package:denik_zza/print_ops2/widgets/record_print_toggle_row.dart';

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
  final ToggleImpact Function(int personId, int recordId) onPreviewImpact;
  final ValueChanged<int> onMarkAllPrinted;
  final ValueChanged<int> onResetAll;

  const PersonPrintStateCard({
    super.key,
    required this.state,
    required this.onTogglePersonPrinted,
    required this.onToggleRecordPrinted,
    required this.onPreviewImpact,
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
                    style: TextStyle(fontSize: 12, color: AppColors.greyText),
                  ),
                ],
              ),
            ),

            // Person printed badge (tappable)
            _PersonPrintBadge(
              printed: s.personPrinted,
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
    if (s.personPrinted && s.printedRecordCount == 0 && s.totalRecordCount > 0) {
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
    return Column(
      children: [
        const Divider(height: 1),
        ...List.generate(s.records.length, (i) {
          final record = s.records[i];
          final impact = widget.onPreviewImpact(s.person.id, record.idZaznamu);

          // Can mark as printed only if all earlier records are printed
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
            cascadeCount: record.isPrinted ? impact.affectedRecordCount : 0,
            canMarkPrinted: canMark,
            onToggle: () => _handleRecordToggle(context, s, record, impact),
          );
        }),
      ],
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
            label: const Text('Označit vše', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: AppSpacing.s),
          TextButton.icon(
            key: const Key('PrintState_resetAll'),
            onPressed: (s.personPrinted || s.printedRecordCount > 0)
                ? () => _handleResetAll(context, s)
                : null,
            icon: Icon(Icons.restart_alt, size: 16, color: AppColors.orangeText),
            label: Text('Odznačit vše',
                style: TextStyle(fontSize: 12, color: AppColors.orangeText)),
          ),
        ],
      ),
    );
  }

  // --- Handlers with confirmation dialogs ---

  Future<void> _handlePersonToggle(
      BuildContext context, PersonPrintState s) async {
    if (s.personPrinted && s.printedRecordCount > 0) {
      // Warn: cascading all records to unprinted
      final confirm = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Odznačit osobu?'),
          content: Text(
            'Tím se odznačí i ${s.printedRecordCount} záznam${_pluralSuffix(s.printedRecordCount)}. '
            'Dostisk nebude možný.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Zrušit'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Odznačit'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }
    widget.onTogglePersonPrinted(s.person.id);
  }

  Future<void> _handleRecordToggle(BuildContext context, PersonPrintState s,
      MemoryZaznam record, ToggleImpact impact) async {
    if (record.isPrinted && impact.hasCascade) {
      // Warn about cascade
      final confirm = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Odznačit záznam?'),
          content: Text(
            'Odznačením tohoto záznamu budou odznačeny i '
            '${impact.affectedRecordCount} následující '
            'záznam${_pluralSuffix(impact.affectedRecordCount)}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Zrušit'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Odznačit'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }
    widget.onToggleRecordPrinted(s.person.id, record.idZaznamu);
  }

  Future<void> _handleResetAll(
      BuildContext context, PersonPrintState s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Resetovat vše?'),
        content: const Text(
          'Tím se odznačí osoba i všechny záznamy jako nevytištěné. '
          'Bude nutný plný tisk.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Zrušit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Resetovat'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    widget.onResetAll(s.person.id);
  }

  String _pluralSuffix(int count) {
    if (count == 1) return '';
    if (count >= 2 && count <= 4) return 'y';
    return 'ů';
  }
}

// --- Small helper widgets ---

class _PersonPrintBadge extends StatelessWidget {
  final bool printed;
  final VoidCallback onTap;
  const _PersonPrintBadge({required this.printed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('PrintState_personBadge_toggle'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.small),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: 3),
        decoration: BoxDecoration(
          color: printed ? AppColors.greenBackground : AppColors.greyBackground,
          borderRadius: BorderRadius.circular(AppRadii.small),
          border: Border.all(
            color: printed ? AppColors.greenBorder : AppColors.greyBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              printed ? Icons.person : Icons.person_outline,
              size: 14,
              color: printed ? AppColors.greenIcon : AppColors.greyIcon,
            ),
            const SizedBox(width: 4),
            Text(
              printed ? 'Vytištěno' : 'Nevytištěno',
              style: TextStyle(
                fontSize: 11,
                color: printed ? AppColors.greenText : AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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
