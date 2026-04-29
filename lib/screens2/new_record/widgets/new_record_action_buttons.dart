import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';

class NewRecordActionButtons extends StatelessWidget {
  final bool isCompact;
  final bool isNarrow;
  final bool isSaving;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const NewRecordActionButtons({
    super.key,
    required this.isCompact,
    required this.isNarrow,
    required this.isSaving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.containerPadding, // 16px padding
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: AppRadii.containerRadius, // 12px rounded
        border: Border.all(color: AppColors.greyBorder, width: 1),
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min, // Fix for greedy column
              children: [
                _buildSaveButton(context),
                const SizedBox(height: AppSpacing.s),
                _buildCancelButton(context),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildSaveButton(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildCancelButton(context),
                ),
              ],
            ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return FilledButton.icon(
      key: const Key('NewRecordPage_save_button'),
      onPressed: isSaving ? null : onSave,
      icon: isSaving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.save, size: 18),
      label: Text(
        isSaving ? 'Ukládání...' : 'Uložit do deníku',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('NewRecordPage_cancel_button'),
      onPressed: isSaving ? null : onCancel,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.greyIcon,
        side: BorderSide(color: AppColors.greyTextLight, width: 1.5),
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 12 : 14,
          horizontal: isCompact ? 12 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      icon: Icon(
        Icons.close,
        size: isCompact ? 16 : 18,
      ),
      label: Text(
        'Zavřít',
        style: TextStyle(
          fontSize: isCompact ? 13 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
