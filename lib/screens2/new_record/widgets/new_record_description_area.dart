import 'package:flutter/material.dart';

import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_typography.dart';

class NewRecordDescriptionArea extends StatelessWidget {
  final bool isCompact;
  final bool isNarrow;
  final bool isParticipantSelected;
  final TextEditingController descriptionController;
  final TextEditingController poznamkaController;
  final VoidCallback? onShowPoznamka;
  final FormFieldValidator<String>? descriptionValidator;

  const NewRecordDescriptionArea({
    super.key,
    required this.isCompact,
    required this.isNarrow,
    required this.isParticipantSelected,
    required this.descriptionController,
    required this.poznamkaController,
    required this.onShowPoznamka,
    required this.descriptionValidator,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact || isNarrow) {
      return SizedBox(
        height: 100,
        child: Stack(
          children: [
            _buildDescriptionField(
              hintText: 'Co se stalo, jak k úrazu došlo...',
              contentPadding: const EdgeInsets.all(AppSpacing.m),
              textStyle: (AppTypography.desktopTextTheme.bodyMedium ??
                      const TextStyle())
                  .copyWith(
                color: AppColors.lightColorScheme.onSurface,
                height: 1.4,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: AppColors.yellowBackground,
                borderRadius: BorderRadius.circular(AppRadii.medium),
                child: InkWell(
                  key: const Key('NewRecordPage_poznamka_icon'),
                  onTap: isParticipantSelected ? onShowPoznamka : null,
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  child: Tooltip(
                    message: poznamkaController.text.isNotEmpty
                        ? 'Poznámka: ${poznamkaController.text}'
                        : 'Přidat poznámku',
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sticky_note_2,
                            size: 16,
                            color: AppColors.yellowText,
                          ),
                          if (poznamkaController.text.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.yellowText,
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
      );
    }

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: _buildDescriptionField(
              hintText:
                  'Co se stalo, jak k úrazu došlo, jaké ošetření bylo poskytnuto...',
              contentPadding: const EdgeInsets.all(AppSpacing.l),
              textStyle: (AppTypography.desktopTextTheme.bodyLarge ??
                      const TextStyle())
                  .copyWith(
                color: AppColors.lightColorScheme.onSurface,
                height: 1.4,
              ),
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
              style: AppTypography.desktopTextTheme.bodySmall?.copyWith(
                color: AppColors.lightColorScheme.onSurface,
                height: 1.3,
              ),
              decoration: InputDecoration(
                labelText: 'Poznámka',
                labelStyle: TextStyle(
                  color: AppColors.yellowTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                hintText: 'Alergie, léky...',
                hintStyle: TextStyle(
                  color: AppColors.yellowText,
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                ),
                filled: true,
                fillColor: AppColors.yellowBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  borderSide:
                      BorderSide(color: AppColors.yellowBorder, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  borderSide:
                      BorderSide(color: AppColors.yellowBorder, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  borderSide: BorderSide(color: AppColors.yellowText, width: 2),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.m),
                alignLabelWithHint: true,
                helperText: 'Netiskne se',
                helperStyle: TextStyle(
                  color: AppColors.yellowText,
                  fontSize: 9,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField({
    required String hintText,
    required EdgeInsets contentPadding,
    required TextStyle textStyle,
  }) {
    return TextFormField(
      key: const Key('NewRecordPage_description_input'),
      controller: descriptionController,
      enabled: isParticipantSelected,
      maxLines: null,
      minLines: null,
      maxLength: 1024,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      style: textStyle,
      decoration: _buildDescriptionDecoration(
        hintText: hintText,
        contentPadding: contentPadding,
      ),
      validator: descriptionValidator,
    );
  }

  InputDecoration _buildDescriptionDecoration({
    required String hintText,
    required EdgeInsets contentPadding,
  }) {
    return InputDecoration(
      labelText: 'Popis úrazu a ošetření',
      labelStyle: TextStyle(
        color: AppColors.blueDark,
        fontWeight: FontWeight.w500,
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.greyText,
        fontStyle: FontStyle.italic,
      ),
      filled: true,
      fillColor: AppColors.lightColorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: AppRadii.inputRadius,
        borderSide: BorderSide(color: AppColors.blueBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadii.inputRadius,
        borderSide: BorderSide(color: AppColors.blueBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.inputRadius,
        borderSide: BorderSide(color: AppColors.blueText, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadii.inputRadius,
        borderSide:
            BorderSide(color: AppColors.lightColorScheme.error, width: 2),
      ),
      contentPadding: contentPadding,
      alignLabelWithHint: true,
      counterStyle: TextStyle(
        color: AppColors.greyText,
        fontSize: 11,
      ),
      errorMaxLines: 1,
      errorStyle: const TextStyle(fontSize: 11, height: 0.8),
    );
  }
}
