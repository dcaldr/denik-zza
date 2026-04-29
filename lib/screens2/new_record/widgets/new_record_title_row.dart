import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_layout.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_typography.dart';

class NewRecordTitleRow extends StatelessWidget {
  final bool isCompact;
  final bool isNarrow;
  final bool isParticipantSelected;
  final TextEditingController titleController;
  final TextEditingController temperatureController;
  final String dateTimeLabel;
  final VoidCallback? onSelectDateTime;
  final bool showDateTimeReset;
  final VoidCallback? onResetDateTime;
  final VoidCallback? onPrintFull;
  final VoidCallback? onPrintAppend;
  final Widget? zpusobilostButton;
  final FormFieldValidator<String>? titleValidator;
  final FormFieldValidator<String>? temperatureValidator;

  const NewRecordTitleRow({
    super.key,
    required this.isCompact,
    required this.isNarrow,
    required this.isParticipantSelected,
    required this.titleController,
    required this.temperatureController,
    required this.dateTimeLabel,
    required this.onSelectDateTime,
    required this.showDateTimeReset,
    required this.onResetDateTime,
    required this.onPrintFull,
    required this.onPrintAppend,
    required this.zpusobilostButton,
    required this.titleValidator,
    required this.temperatureValidator,
  });

  @override
  Widget build(BuildContext context) {
    final activeTextColor = AppColors.lightColorScheme.onSurface;
    final titleAndTemperatureRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTitleField(activeTextColor),
        ),
        const SizedBox(width: AppSpacing.s),
        _buildTemperatureField(activeTextColor),
      ],
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleAndTemperatureRow,
          const SizedBox(height: AppSpacing.s),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildDateTimeChip(context),
          ),
          const SizedBox(height: AppSpacing.s),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildPrintRow(context),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: AppLayout.inputFlex,
          child: titleAndTemperatureRow,
        ),
        SizedBox(width: AppSpacing.s),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: _buildDateTimeChip(context),
        ),
        SizedBox(width: AppSpacing.s),
        _buildSubtleDivider(),
        SizedBox(width: AppSpacing.s),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _buildPrintRow(context),
        ),
      ],
    );
  }

  Widget _buildSubtleDivider() {
    return Container(
      width: 2,
      height: isCompact ? 18 : 22,
      decoration: BoxDecoration(
        color: AppColors.greyBorderDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildTitleField(Color activeTextColor) {
    return TextFormField(
      key: const Key('NewRecordPage_title_input'),
      controller: titleController,
      enabled: isParticipantSelected,
      maxLines: 1,
      maxLength: 200,
      style: (isCompact
              ? AppTypography.desktopTextTheme.bodyMedium
              : AppTypography.desktopTextTheme.bodyLarge)
          ?.copyWith(
        fontWeight: FontWeight.w500,
        color: activeTextColor,
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: isCompact ? AppSpacing.m : AppSpacing.l,
          vertical: isCompact ? AppSpacing.s : AppSpacing.m,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(AppSpacing.s),
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.blueBackground,
            borderRadius: BorderRadius.circular(AppRadii.small),
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
    );
  }

  Widget _buildTemperatureField(Color activeTextColor) {
    return SizedBox(
      width: isCompact ? 84 : 96,
      child: TextFormField(
        key: const Key('NewRecordPage_temperature_input'),
        controller: temperatureController,
        enabled: isParticipantSelected,
        maxLines: 1,
        style: (isCompact
                ? AppTypography.desktopTextTheme.bodyMedium
                : AppTypography.desktopTextTheme.bodyLarge)
            ?.copyWith(
          fontWeight: FontWeight.w500,
          color: activeTextColor,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: 'Teplota',
          hintText: '37.0',
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: isCompact ? AppSpacing.s : AppSpacing.m,
            vertical: isCompact ? AppSpacing.s : AppSpacing.m,
          ),
          errorMaxLines: 1,
          errorStyle: const TextStyle(fontSize: 11, height: 0.8),
        ),
        validator: temperatureValidator,
      ),
    );
  }

  Widget _buildPrintRow(BuildContext context) {
    return Row(
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
            horizontal: isCompact ? AppSpacing.s : AppSpacing.m,
            vertical: isCompact ? AppSpacing.xs : AppSpacing.s,
          ),
          decoration: BoxDecoration(
            color: AppColors.blueBackground,
            borderRadius: AppRadii.containerRadius,
            border: Border.all(color: AppColors.blueBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: isCompact ? 14 : 16,
                color: AppColors.blueDark,
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isCompact ? 100 : 140),
                child: Text(
                  dateTimeLabel,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isCompact ? 11 : 12,
                    fontWeight: FontWeight.w500,
                    color: isParticipantSelected
                      ? AppColors.lightColorScheme.onSurface
                      : AppColors.greyTextLight,
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
