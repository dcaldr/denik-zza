import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/screens2/widgets/file_viewer_screen_widget.dart';

class NewRecordPageDialogs {
  static Future<void> showPoznamkaBottomSheet({
    required BuildContext context,
    required TextEditingController poznamkaController,
  }) async {
    final tempController = TextEditingController(text: poznamkaController.text);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.yellowBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.xl),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.l,
          right: AppSpacing.l,
          top: AppSpacing.m,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.yellowBorder,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.sticky_note_2, size: 20, color: AppColors.yellowText),
                const SizedBox(width: AppSpacing.s),
                Text(
                  'Poznámka',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.yellowTextDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Interní poznámka - netiskne se na výstup',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.yellowText,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              key: const Key('NewRecordPage_poznamka_bottomsheet_input'),
              controller: tempController,
              autofocus: true,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Alergie, léky, interní poznámky...',
                hintStyle: TextStyle(
                  color: AppColors.yellowText,
                  fontStyle: FontStyle.italic,
                ),
                filled: true,
                fillColor: AppColors.lightColorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  borderSide: BorderSide(color: AppColors.yellowBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  borderSide: BorderSide(color: AppColors.yellowText, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Zrušit',
                    style: TextStyle(color: AppColors.yellowText),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                FilledButton(
                  onPressed: () {
                    poznamkaController.text = tempController.text;
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.yellowText,
                  ),
                  child: const Text('Uložit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    tempController.dispose();
  }

  static void showBirthdateInfo({
    required BuildContext context,
    required DateTime birthDate,
  }) {
    final formatted = DateFormat('d. MMMM yyyy', 'cs_CZ').format(birthDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Datum narození'),
        content: Text(
          formatted,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            key: const Key('NewRecordPage_birthdate_dialog_close'),
            onPressed: () => Navigator.pop(context),
            child: const Text('Zavřít'),
          ),
        ],
      ),
    );
  }

  static void showZpusobilostDocument({
    required BuildContext context,
    required String? filePath,
  }) {
    if (filePath == null || filePath.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chybí dokument'),
          content: const Text(
              'Pro tohoto účastníka není k dispozici dokument způsobilosti.'),
          actions: [
            TextButton(
              key: const Key('NewRecordPage_zpusobilost_missing_close'),
              onPressed: () => Navigator.pop(context),
              child: const Text('Zavřít'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FileViewerScreen(
          initialFilePath: filePath,
        ),
      ),
    );
  }

  static Future<bool?> confirmParticipantChange(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Změnit účastníka?'),
          content: const Text(
              'Změnou účastníka se ztratí neuložené změny v formuláři. '
              'Chcete pokračovat?'),
          actions: [
            TextButton(
              key: const Key('dialog_cancel_button'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Zrušit'),
            ),
            FilledButton(
              key: const Key('dialog_confirm_button'),
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orangeBackground,
              ),
              child: const Text('Změnit účastníka'),
            ),
          ],
        );
      },
    );
  }
}
