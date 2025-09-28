import 'package:denik_zza/input/csv_review_models.dart';
import 'package:flutter/material.dart';

import 'review_style.dart';

/// Card that presents a single CSV row with status, messages, and edit affordances.
class CsvReviewRowCard extends StatefulWidget {
  const CsvReviewRowCard({
    super.key,
    required this.row,
    required this.onRowEdit,
    required this.onFieldEdit,
    required this.isEdited,
    required this.isLoading,
    required this.decision,
    required this.duplicateMatches,
    required this.onDecisionChanged,
  });

  final CsvReviewRow row;
  final VoidCallback onRowEdit;
  final Future<void> Function(CsvFieldReview field, {String? overrideValue})
      onFieldEdit;
  final bool isEdited;
  final bool isLoading;
  final CsvRowDecision decision;
  final List<CsvDuplicateCandidate> duplicateMatches;
  final ValueChanged<CsvRowDecision> onDecisionChanged;

  @override
  State<CsvReviewRowCard> createState() => _CsvReviewRowCardState();
}

class _CsvReviewRowCardState extends State<CsvReviewRowCard> {
  final Map<String, TextEditingController> _inlineControllers =
      <String, TextEditingController>{};
  final Set<String> _editingFields = <String>{};

  @override
  void dispose() {
    for (final TextEditingController controller in _inlineControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startInlineEdit(CsvFieldReview field) {
    if (_editingFields.contains(field.columnKey)) {
      return;
    }
    final TextEditingController controller = TextEditingController(
      text: field.originalValue ?? field.normalizedValue ?? '',
    );
    setState(() {
      _editingFields.add(field.columnKey);
      _inlineControllers[field.columnKey] = controller;
    });
  }

  Future<void> _submitInlineEdit(CsvFieldReview field) async {
    final TextEditingController? controller =
        _inlineControllers[field.columnKey];
    if (controller == null) {
      return;
    }
    final String newValue = controller.text;
    await widget.onFieldEdit(field, overrideValue: newValue);
    if (!mounted) {
      return;
    }
    setState(() {
      _editingFields.remove(field.columnKey);
      _inlineControllers.remove(field.columnKey)?.dispose();
    });
  }

  void _cancelInlineEdit(String columnKey) {
    setState(() {
      _editingFields.remove(columnKey);
      _inlineControllers.remove(columnKey)?.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final Color currentStatusColor = statusColor(context, widget.row.status);
    final String currentStatusLabel = statusLabel(widget.row.status);
    final Iterable<String> messageTexts =
        widget.row.messages.map((CsvReviewMessage message) => message.message);
    final List<CsvFieldReview> fields = widget.row.fields.values.toList();
    final List<String> fieldPreviews = fields
        .take(3)
        .map((CsvFieldReview field) =>
            '${field.columnName}: ${field.originalValue ?? ''}')
        .toList();
    final bool hasDuplicates = widget.duplicateMatches.isNotEmpty;

    return Card(
      key: Key('CsvReviewScreen_row_${widget.row.originalIndex}'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text('Řádek ${widget.row.originalIndex}',
                          style: textTheme.titleMedium),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Chip(
                          key: Key(
                              'CsvReviewScreen_row_${widget.row.originalIndex}_status'),
                          label: Text(currentStatusLabel),
                          backgroundColor:
                              currentStatusColor.withValues(alpha: 0.15),
                          labelStyle: textTheme.labelMedium
                              ?.copyWith(color: currentStatusColor),
                        ),
                        if (widget.decision != CsvRowDecision.none)
                          Tooltip(
                            message: widget.decision == CsvRowDecision.approved
                                ? 'Řádek bude schválen'
                                : 'Řádek bude odmítnut',
                            child: Chip(
                              key: Key(
                                  'CsvReviewScreen_row_${widget.row.originalIndex}_decision_chip'),
                              avatar: Icon(
                                widget.decision == CsvRowDecision.approved
                                    ? Icons.check
                                    : Icons.close,
                                size: 16,
                              ),
                              label: Text(decisionLabel(widget.decision)),
                              backgroundColor:
                                  decisionColor(context, widget.decision)
                                      .withValues(alpha: 0.15),
                              labelStyle: textTheme.labelMedium?.copyWith(
                                color: decisionColor(context, widget.decision),
                              ),
                            ),
                          ),
                        if (hasDuplicates)
                          Tooltip(
                            message:
                                'Řádek může odpovídat již existujícímu účastníkovi',
                            child: Chip(
                              key: Key(
                                  'CsvReviewScreen_row_${widget.row.originalIndex}_duplicate_badge'),
                              avatar: const Icon(Icons.warning_amber_rounded,
                                  size: 16),
                              label: const Text('Možná duplicita'),
                              backgroundColor: theme.colorScheme.errorContainer,
                              labelStyle: textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        if (widget.isEdited)
                          Tooltip(
                            message:
                                'Řádek byl upraven v rámci aktuální relace',
                            child: Chip(
                              key: Key(
                                  'CsvReviewScreen_row_${widget.row.originalIndex}_edited_badge'),
                              avatar: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Upraveno'),
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              labelStyle: textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (widget.isLoading) ...<Widget>[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    key: Key(
                        'CsvReviewScreen_row_${widget.row.originalIndex}_loading_indicator'),
                    minHeight: 3,
                  ),
                ],
                if (fieldPreviews.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (int i = 0; i < fieldPreviews.length; i++)
                        Chip(
                          key: Key(
                              'CsvReviewScreen_row_${widget.row.originalIndex}_field_$i'),
                          label: Text(fieldPreviews[i]),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  messageTexts.isNotEmpty
                      ? messageTexts.join('\n')
                      : 'Bez zprávy',
                  key: Key(
                      'CsvReviewScreen_row_${widget.row.originalIndex}_messages'),
                ),
                if (hasDuplicates) ...<Widget>[
                  const SizedBox(height: 12),
                  DuplicateWarningPanel(
                    key: Key(
                        'CsvReviewScreen_row_${widget.row.originalIndex}_duplicate_panel'),
                    rowIndex: widget.row.originalIndex,
                    matches: widget.duplicateMatches,
                  ),
                ],
                if (widget.row.derived.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.row.derived.entries
                        .map(
                          (MapEntry<String, CsvDerivedValue> entry) => Chip(
                            key: Key(
                                'CsvReviewScreen_row_${widget.row.originalIndex}_derived_${entry.key}'),
                            avatar: Icon(
                              entry.value.applied
                                  ? Icons.check_circle
                                  : Icons.lightbulb_outline,
                              size: 18,
                              color: entry.value.applied
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.primary,
                            ),
                            label: Text(
                                '${entry.value.key}: ${entry.value.value}'),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                SegmentedButton<CsvRowDecision>(
                  key: Key(
                      'CsvReviewScreen_row_${widget.row.originalIndex}_decision_segmented'),
                  segments: const <ButtonSegment<CsvRowDecision>>[
                    ButtonSegment<CsvRowDecision>(
                      value: CsvRowDecision.none,
                      label: Text('Bez rozhodnutí'),
                      icon: Icon(Icons.remove_circle_outline),
                    ),
                    ButtonSegment<CsvRowDecision>(
                      value: CsvRowDecision.approved,
                      label: Text('Schválit'),
                      icon: Icon(Icons.check_circle_outline),
                    ),
                    ButtonSegment<CsvRowDecision>(
                      value: CsvRowDecision.rejected,
                      label: Text('Odmítnout'),
                      icon: Icon(Icons.cancel_outlined),
                    ),
                  ],
                  selected: <CsvRowDecision>{widget.decision},
                  onSelectionChanged: widget.isLoading
                      ? null
                      : (Set<CsvRowDecision> selection) {
                          if (selection.isEmpty) {
                            return;
                          }
                          widget.onDecisionChanged(selection.first);
                        },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    key: Key(
                        'CsvReviewScreen_row_${widget.row.originalIndex}_edit_button'),
                    onPressed: widget.isLoading ? null : widget.onRowEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Upravit řádek'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ExpansionTile(
            key: Key(
                'CsvReviewScreen_row_${widget.row.originalIndex}_fields_tile'),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            title: const Text('Detaily polí'),
            childrenPadding: const EdgeInsets.only(bottom: 16),
            maintainState: true,
            children: <Widget>[
              for (final CsvFieldReview field in fields)
                FieldDetailTile(
                  key: Key(
                    'CsvReviewScreen_row_${widget.row.originalIndex}_field_tile_${field.columnKey}',
                  ),
                  field: field,
                  isLoading: widget.isLoading,
                  isEditing: _editingFields.contains(field.columnKey),
                  controller: _inlineControllers[field.columnKey],
                  onStartInlineEdit: () => _startInlineEdit(field),
                  onCancelInlineEdit: () => _cancelInlineEdit(field.columnKey),
                  onSubmitInlineEdit: () => _submitInlineEdit(field),
                  onOpenDialog: () => widget.onFieldEdit(field),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Warns about possible duplicate participants for the current row.
class DuplicateWarningPanel extends StatelessWidget {
  const DuplicateWarningPanel({
    super.key,
    required this.rowIndex,
    required this.matches,
  });

  final int rowIndex;
  final List<CsvDuplicateCandidate> matches;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.errorContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Možní duplicitní účastníci v databázi:',
            style: textTheme.titleSmall
                ?.copyWith(color: theme.colorScheme.onErrorContainer),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < matches.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• ${matches[i].displayName} – ${matches[i].reason}',
                key: Key('CsvReviewScreen_row_${rowIndex}_duplicate_$i'),
                style: textTheme.bodyMedium,
              ),
            ),
          Text(
            'Zkontrolujte, zda se nejedná o již registrovaného účastníka.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Displays a single field row with inline editing support.
class FieldDetailTile extends StatelessWidget {
  const FieldDetailTile({
    super.key,
    required this.field,
    required this.isLoading,
    required this.isEditing,
    required this.controller,
    required this.onStartInlineEdit,
    required this.onCancelInlineEdit,
    required this.onSubmitInlineEdit,
    required this.onOpenDialog,
  });

  final CsvFieldReview field;
  final bool isLoading;
  final bool isEditing;
  final TextEditingController? controller;
  final VoidCallback onStartInlineEdit;
  final VoidCallback onCancelInlineEdit;
  final Future<void> Function() onSubmitInlineEdit;
  final Future<void> Function() onOpenDialog;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            fieldStatusIcon(field.status),
            color: fieldStatusColor(context, field.status),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(field.columnName, style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  fieldSummaryText(field),
                  style: textTheme.bodySmall,
                ),
                if (field.messages.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: field.messages
                        .map(
                          (CsvReviewMessage message) => Text(
                            '• ${message.message}',
                            style: textTheme.bodySmall,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (isEditing && controller != null) ...<Widget>[
                  const SizedBox(height: 12),
                  TextField(
                    key: Key(
                        'CsvReviewScreen_inline_field_${field.columnKey}_input'),
                    controller: controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Nová hodnota',
                      helperText: 'Úprava přímo v tabulce',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      FilledButton(
                        key: Key(
                            'CsvReviewScreen_inline_field_${field.columnKey}_save'),
                        onPressed: isLoading ? null : onSubmitInlineEdit,
                        child: const Text('Uložit'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        key: Key(
                            'CsvReviewScreen_inline_field_${field.columnKey}_cancel'),
                        onPressed: onCancelInlineEdit,
                        child: const Text('Zrušit'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (!isEditing)
                IconButton(
                  key: Key(
                      'CsvReviewScreen_inline_field_${field.columnKey}_edit_button'),
                  tooltip: 'Upravit přímo v řádku',
                  icon: const Icon(Icons.edit_note_outlined),
                  onPressed: isLoading ? null : onStartInlineEdit,
                ),
              IconButton(
                key: Key(
                    'CsvReviewScreen_dialog_field_${field.columnKey}_edit_button'),
                tooltip: 'Otevřít dialog pro úpravu',
                icon: const Icon(Icons.open_in_new),
                onPressed: isLoading ? null : onOpenDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
