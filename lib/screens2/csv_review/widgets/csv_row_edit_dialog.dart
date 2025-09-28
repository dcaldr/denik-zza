import 'package:denik_zza/input/csv_review_models.dart';
import 'package:flutter/material.dart';

/// Dialog that allows editing all fields of a CSV review row.
class CsvRowEditDialog extends StatefulWidget {
  const CsvRowEditDialog({
    super.key,
    required this.row,
    this.focusColumn,
  });

  final CsvReviewRow row;
  final String? focusColumn;

  @override
  State<CsvRowEditDialog> createState() => _CsvRowEditDialogState();
}

class _CsvRowEditDialogState extends State<CsvRowEditDialog> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{
      for (final MapEntry<String, CsvFieldReview> entry
          in widget.row.fields.entries)
        entry.key: TextEditingController(
          text: entry.value.originalValue ?? entry.value.normalizedValue ?? '',
        ),
    };
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('CsvReviewScreen_edit_dialog'),
      title: Text('Upravit řádek ${widget.row.originalIndex}'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.row.fields.entries
                .map((MapEntry<String, CsvFieldReview> entry) {
              final TextEditingController controller = _controllers[entry.key]!;
              final bool autofocus = widget.focusColumn == entry.key;
              final String? originalValue = entry.value.originalValue;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  key: Key(
                    'CsvReviewScreen_edit_field_${widget.row.originalIndex}_${entry.key}',
                  ),
                  controller: controller,
                  autofocus: autofocus,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: entry.value.columnName,
                    helperText:
                        originalValue != null && originalValue.isNotEmpty
                            ? 'Původní: $originalValue'
                            : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          key: const Key('CsvReviewScreen_edit_dialog_cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Zrušit'),
        ),
        FilledButton(
          key: const Key('CsvReviewScreen_edit_dialog_save'),
          onPressed: () {
            final Map<String, String?> result = <String, String?>{};
            _controllers
                .forEach((String key, TextEditingController controller) {
              result[key] = controller.text.trim();
            });
            Navigator.of(context).pop(result);
          },
          child: const Text('Uložit'),
        ),
      ],
    );
  }
}
