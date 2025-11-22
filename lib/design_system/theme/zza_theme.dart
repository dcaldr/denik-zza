import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_radii.dart';

/// Complete theme for Deník ZZA app.
///
/// IMPORTANT: This theme is based on ACTUAL patterns extracted from:
/// - CSV import flow (you like this)
/// - NewRecord page (you like this)
///
/// NOT based on generic Material 3 defaults.
class ZzaTheme {
  ZzaTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color scheme
      colorScheme: AppColors.lightColorScheme,

      // Typography (actual font sizes from your code!)
      textTheme: AppTypography.textTheme,
      fontFamily: AppTypography.fontFamily,

      // Visual density
      visualDensity: VisualDensity.comfortable,

      // ========================================
      // BUTTON THEMES
      // ========================================

      /// Filled buttons - For major actions
      ///
      /// From NewRecord save button:
      /// backgroundColor: Colors.blue.shade600
      /// padding: vertical 12-14, horizontal 16-20
      /// borderRadius: 8.0
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.blue.shade600, // Actual color from code
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          minimumSize: const Size(120, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius, // 8px
          ),
          elevation: 2,
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      /// Outlined buttons - For secondary actions
      ///
      /// From NewRecord cancel button:
      /// foregroundColor: Colors.grey.shade700
      /// side: Colors.grey.shade400, width: 1.5
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey.shade700, // Actual color from code
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          minimumSize: const Size(100, 48),
          side: BorderSide(
            color: Colors.grey.shade400, // Actual from code
            width: 1.5, // Actual from code
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      /// Text buttons - Tertiary actions
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blueText,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          minimumSize: const Size(88, 36),
        ),
      ),

      /// Elevated buttons - Used in CSV import
      ///
      /// From CSV import "Vybrat soubor" button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.blueText,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
        ),
      ),

      // ========================================
      // FORM FIELD THEME
      // ========================================

      /// Input decoration - Minimalistic borders
      ///
      /// From NewRecord form fields:
      /// borderRadius: 8.0
      /// enabledBorder: Colors.blue.shade200
      /// focusedBorder: Colors.blue.shade600, width: 2
      /// contentPadding: all(12-16)
      inputDecorationTheme: InputDecorationTheme(
        // Border styling (actual from code)
        border: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius, // 8px
          borderSide: BorderSide(
            color: AppColors.blueBorder, // blue.shade200
            width: 1.0,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.blueBorder, // blue.shade200
            width: 1.0,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: Colors.blue.shade600, // Actual from code
            width: 2, // Actual from code
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.greyBorder,
            width: 1.0,
          ),
        ),

        // Padding (from NewRecord: 12-16)
        contentPadding: const EdgeInsets.all(AppSpacing.l), // 16px

        // Fill (minimalistic - no background fill)
        filled: true,
        fillColor: Colors.white,

        // Text styles
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.blueDark,
          fontWeight: FontWeight.w500,
        ),

        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.greyTextLight,
          fontStyle: FontStyle.italic,
        ),

        helperStyle: AppTypography.textTheme.bodySmall,
        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
          fontSize: 11,
          height: 0.8,
        ),
      ),

      // ========================================
      // CARD THEME
      // ========================================

      /// Cards - From CSV summary failure cards
      ///
      /// margin: EdgeInsets.only(bottom: 8)
      /// padding: EdgeInsets.all(12)
      cardTheme: CardTheme(
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        margin: const EdgeInsets.only(bottom: AppSpacing.s),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius, // 12px
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ========================================
      // APP BAR THEME
      // ========================================

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: Colors.blue, // Primary blue
        foregroundColor: Colors.white,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      // ========================================
      // DIALOG THEME
      // ========================================

      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.containerRadius, // 12px
        ),
        titleTextStyle: AppTypography.textTheme.headlineSmall,
        contentTextStyle: AppTypography.textTheme.bodyMedium,
      ),

      // ========================================
      // SNACKBAR THEME
      // ========================================

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade800,
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ========================================
      // DATA TABLE THEME (CSV)
      // ========================================

      dataTableTheme: DataTableThemeData(
        headingTextStyle: AppTypography.textTheme.labelLarge,
        dataTextStyle: AppTypography.textTheme.bodyMedium,
        columnSpacing: AppSpacing.xxl,
        horizontalMargin: AppSpacing.l,
      ),

      // ========================================
      // SCAFFOLD BACKGROUND
      // ========================================

      scaffoldBackgroundColor: AppColors.lightColorScheme.surface, // #FAFAFA

      // ========================================
      // DIVIDER THEME
      // ========================================

      dividerTheme: DividerThemeData(
        color: AppColors.greyBorderDark,
        thickness: 1,
        space: AppSpacing.m,
      ),
    );
  }
}
