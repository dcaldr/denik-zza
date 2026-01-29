import 'package:flutter/material.dart';

import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_layout.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';

class NewRecordFormFields extends StatelessWidget {
  final bool isCompact;
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: AppLayout.inputFlex,
              child: TextFormField(
                key: const Key('NewRecordPage_title_input'),
                controller: titleController,
                enabled: isParticipantSelected,
                maxLines: 1,
                maxLength: 200,
                style: TextStyle(
                  fontSize: isCompact ? 14 : 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Nadpis * (povinné)',
                  labelStyle: TextStyle(
                    color: AppColors.blueDark,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: isParticipantSelected
                      ? 'Povinné - typ úrazu nebo stížnosti (např. "Odřenina kolena", "Bolest hlavy")'
                      : 'Vyberte účastníka pro pokračování',
                  hintStyle: TextStyle(
                    color: AppColors.greyText,
                    fontStyle: FontStyle.italic,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: AppColors.blueBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: AppColors.blueBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: AppColors.blueText, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 12 : 16,
                    vertical: isCompact ? 8 : 12,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: AppColors.blueBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.title,
                      color: AppColors.blueDark,
                      size: isCompact ? 16 : 18,
                    ),
                  ),
                  errorMaxLines: 1,
                  errorStyle: const TextStyle(fontSize: 11, height: 0.8),
                ),
                validator: titleValidator,
              ),
            ),
            SizedBox(width: AppSpacing.s),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _buildDateTimeChip(context),
            ),
            SizedBox(width: AppSpacing.s),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildPrintIconButton(
                    context,
                    key: const Key('NewRecordPage_print_full_button'),
                    icon: Icons.print,
                    tooltip: 'Tisknout záznam',
                    onPressed: onPrintFull,
                  ),
                  _buildPrintIconButton(
                    context,
                    key: const Key('NewRecordPage_print_append_button'),
                    icon: Icons.add_to_photos,
                    tooltip: 'Přitisknout k existujícímu',
                    onPressed: onPrintAppend,
                  ),
                  if (zpusobilostButton != null) zpusobilostButton!,
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: titleSpacing),
        if (isCompact)
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                TextFormField(
                  key: const Key('NewRecordPage_description_input'),
                  controller: descriptionController,
                  enabled: isParticipantSelected,
                  maxLines: null,
                  minLines: null,
                  maxLength: 1024,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Popis úrazu a ošetření',
                    labelStyle: TextStyle(
                      color: AppColors.blueDark,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: 'Co se stalo, jak k úrazu došlo...',
                    hintStyle: TextStyle(
                      color: AppColors.greyText,
                      fontStyle: FontStyle.italic,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: AppColors.blueBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: AppColors.blueBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide(color: AppColors.blueText, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    alignLabelWithHint: true,
                    counterStyle: TextStyle(
                      color: AppColors.greyText,
                      fontSize: 11,
                    ),
                    errorMaxLines: 1,
                    errorStyle: const TextStyle(fontSize: 11, height: 0.8),
                  ),
                  validator: descriptionValidator,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      key: const Key('NewRecordPage_poznamka_icon'),
                      onTap: isParticipantSelected ? onShowPoznamka : null,
                      borderRadius: BorderRadius.circular(6),
                      child: Tooltip(
                        message: poznamkaController.text.isNotEmpty
                            ? 'Poznámka: ${poznamkaController.text}'
                            : 'Přidat poznámku',
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sticky_note_2,
                                size: 16,
                                color: Colors.amber.shade700,
                              ),
                              if (poznamkaController.text.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade600,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    key: const Key('NewRecordPage_description_input'),
                    controller: descriptionController,
                    enabled: isParticipantSelected,
                    maxLines: null,
                    minLines: null,
                    maxLength: 1024,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Popis úrazu a ošetření',
                      labelStyle: TextStyle(
                        color: AppColors.blueDark,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText:
                          'Co se stalo, jak k úrazu došlo, jaké ošetření bylo poskytnuto...',
                      hintStyle: TextStyle(
                        color: AppColors.greyText,
                        fontStyle: FontStyle.italic,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: AppColors.blueBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: AppColors.blueBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: AppColors.blueText, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      alignLabelWithHint: true,
                      counterStyle: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 11,
                      ),
                      errorMaxLines: 1,
                      errorStyle: const TextStyle(fontSize: 11, height: 0.8),
                    ),
                    validator: descriptionValidator,
                  ),
                ),
                SizedBox(width: AppSpacing.m),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    key: const Key('NewRecordPage_poznamka_input'),
                    controller: poznamkaController,
                    enabled: isParticipantSelected,
                    maxLines: null,
                    minLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Poznámka',
                      labelStyle: TextStyle(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      hintText: 'Alergie, léky...',
                      hintStyle: TextStyle(
                        color: Colors.amber.shade700,
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                      ),
                      filled: true,
                      fillColor: Colors.yellow.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Colors.amber.shade300, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Colors.amber.shade300, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide:
                            BorderSide(color: Colors.amber.shade600, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(10),
                      alignLabelWithHint: true,
                      helperText: 'Netiskne se',
                      helperStyle: TextStyle(
                        color: Colors.amber.shade700,
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDateTimeChip(BuildContext context) {
    return Tooltip(
      message: 'Čas záznamu',
      child: InkWell(
        key: const Key('datetime_change_button'),
        onTap: isParticipantSelected ? onSelectDateTime : null,
        borderRadius: AppRadii.containerRadius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 10,
            vertical: isCompact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.blueBackground.withValues(alpha: 0.3),
            borderRadius: AppRadii.containerRadius,
            border: Border.all(
              color: AppColors.blueBorder.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.blueDark,
                size: isCompact ? 16 : 18,
              ),
              SizedBox(width: isCompact ? 4 : 6),
              Flexible(
                child: Text(
                  dateTimeLabel,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isCompact ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    color: isParticipantSelected
                        ? Colors.black87
                        : Colors.grey.shade400,
                  ),
                ),
              ),
              if (showDateTimeReset) ...[
                const SizedBox(width: 4),
                InkWell(
                  key: const Key('datetime_reset_button'),
                  onTap: isParticipantSelected ? onResetDateTime : null,
                  child: Icon(
                    Icons.refresh,
                    size: isCompact ? 14 : 16,
                    color: AppColors.blueDark,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrintIconButton(
    BuildContext context, {
    required Key key,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        key: key,
        icon: Icon(icon),
        iconSize: 20,
        onPressed: onPressed,
        color: onPressed != null
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).disabledColor,
      ),
    );
  }
}
