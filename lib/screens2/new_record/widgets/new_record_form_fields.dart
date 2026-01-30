import 'package:flutter/material.dart';

import 'package:denik_zza/screens2/new_record/widgets/new_record_description_area.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_title_row.dart';

class NewRecordFormFields extends StatelessWidget {
  final bool isCompact;
  final bool isNarrow;
  final bool isParticipantSelected;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController poznamkaController;
  final String dateTimeLabel;
  final VoidCallback? onSelectDateTime;
  final bool showDateTimeReset;
  final VoidCallback? onResetDateTime;
  final VoidCallback? onPrintFull;
  final VoidCallback? onPrintAppend;
  final Widget? zpusobilostButton;
  final VoidCallback? onShowPoznamka;
  final FormFieldValidator<String>? titleValidator;
  final FormFieldValidator<String>? descriptionValidator;

  const NewRecordFormFields({
    super.key,
    required this.isCompact,
    required this.isNarrow,
    required this.isParticipantSelected,
    required this.titleController,
    required this.descriptionController,
    required this.poznamkaController,
    required this.dateTimeLabel,
    required this.onSelectDateTime,
    required this.showDateTimeReset,
    required this.onResetDateTime,
    required this.onPrintFull,
    required this.onPrintAppend,
    required this.zpusobilostButton,
    required this.onShowPoznamka,
    required this.titleValidator,
    required this.descriptionValidator,
  });

  @override
  Widget build(BuildContext context) {
    final titleSpacing = isCompact ? 12.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NewRecordTitleRow(
          isCompact: isCompact,
          isNarrow: isNarrow,
          isParticipantSelected: isParticipantSelected,
          titleController: titleController,
          dateTimeLabel: dateTimeLabel,
          onSelectDateTime: onSelectDateTime,
          showDateTimeReset: showDateTimeReset,
          onResetDateTime: onResetDateTime,
          onPrintFull: onPrintFull,
          onPrintAppend: onPrintAppend,
          zpusobilostButton: zpusobilostButton,
          titleValidator: titleValidator,
        ),
        SizedBox(height: titleSpacing),
        NewRecordDescriptionArea(
          isCompact: isCompact,
          isNarrow: isNarrow,
          isParticipantSelected: isParticipantSelected,
          descriptionController: descriptionController,
          poznamkaController: poznamkaController,
          onShowPoznamka: onShowPoznamka,
          descriptionValidator: descriptionValidator,
        ),
      ],
    );
  }
}
