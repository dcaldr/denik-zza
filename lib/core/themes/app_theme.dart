import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../constants/app_radii.dart';

/// App-wide theme configuration bringing together all design tokens.
///
/// This theme creates the "open, clean, minimalistic, professional but not clinical"
/// feel from CSV import and NewRecord screens, applied consistently across the app.
///
/// BUTTON COLOR PATTERN:
/// - 2 buttons: Blue FilledButton (primary) + Grey OutlinedButton (secondary)
///   Example: NewRecord "Uložit" + "Zavřít"
///   Handled automatically by this theme
///
/// - 3 buttons: Green/Blue/Red ElevatedButtons (critical ternary choice)
///   Example: IntakeForm "uložit a přišel" (green) + "uložit" (blue) + "neukládat" (red)
///   Manual styling with .styleFrom() - NOT in theme
///   Reserve for critical choices only
///
/// Reference: THEME_CHECKLIST.md, PHASE_1_ANALYSIS.md
/// User priority: 9/10 for consistency (APP_DESIGN_FEEL.md line 872)
/// Date: 2025-11-16
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  /// Light theme for the application
  /// Based on extracted colors and patterns from actual code
  static ThemeData get lightTheme {
    return ThemeData(
      // ==========================================
      // BASIC CONFIGURATION
      // ==========================================

      /// Use Material Design 3 components
      useMaterial3: true,

      /// Color scheme from extracted colors (not generic defaults)
      /// Background: #FAFAFA for "open feel"
      colorScheme: AppColors.lightColorScheme,

      /// Typography with Czech locale on all styles
      /// Body medium: 15px (NOT 14px - preserves NewRecord responsive logic)
      textTheme: AppTypography.textTheme,

      /// Font family supporting Czech diacritics
      fontFamily: AppTypography.fontFamily,

      /// Visual density for comfortable spacing
      visualDensity: VisualDensity.comfortable,

      // ==========================================
      // BUTTON THEMES
      // 2-button pattern (default): Blue + Grey
      // 3-button pattern (manual): See IntakeForm for example
      // ==========================================

      /// FilledButton: Primary action (Blue - NewRecord "Uložit" style)
      /// Used for: Main save/submit actions in 2-button patterns
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blueText, // blue.shade600
          foregroundColor: Colors.white,
          padding: AppSpacing.buttonPadding, // 14v/20h from NewRecord
          minimumSize: const Size(120, 48),
          shape: AppRadii.buttonShape, // 8px radius
          elevation: 2,
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      /// OutlinedButton: Secondary action (Grey - NewRecord "Zavřít" style)
      /// Used for: Cancel/close actions in 2-button patterns
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.greyIcon, // grey.shade700
          padding: AppSpacing.outlinedButtonPadding, // 14v/16h
          minimumSize: const Size(100, 48),
          side: BorderSide(
            color: AppColors.greyBorderDark, // grey.shade400
            width: 1.5,
          ),
          shape: AppRadii.buttonShape, // 8px radius
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      /// ElevatedButton: For CSV import style and special cases
      /// Note: IntakeForm 3-button pattern uses manual styling (NOT this theme)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueText, // blue.shade600
          foregroundColor: Colors.white,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(120, 48),
          elevation: 2,
          shape: AppRadii.buttonShape, // 8px radius
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      /// TextButton: For tertiary/less prominent actions
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blueText, // blue.shade600
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // ==========================================
      // FORM FIELD THEME
      // Blue.shade200 borders (8px radius) from NewRecord
      // ==========================================

      inputDecorationTheme: InputDecorationTheme(
        // Default border (enabled state)
        border: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius, // 8px
          borderSide: BorderSide(
            color: AppColors.blueBorder, // blue.shade200
            width: 1.0,
          ),
        ),

        // Enabled border (unfocused)
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.blueBorder, // blue.shade200
            width: 1.0,
          ),
        ),

        // Focused border (user is typing)
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.blueText, // blue.shade600 (thicker when focused)
            width: 2.0,
          ),
        ),

        // Error border (validation failed)
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),

        // Focused error border
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),

        // Disabled border
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.greyBorder, // grey.shade200
            width: 1.0,
          ),
        ),

        // Content padding (16h/12v from analysis)
        contentPadding: AppSpacing.formFieldPadding,

        // Filled background
        filled: true,
        fillColor: Colors.white,

        // Label style (Czech locale)
        labelStyle: AppTypography.formFieldLabel,
        floatingLabelStyle: AppTypography.formFieldLabel.copyWith(
          color: AppColors.blueText, // blue.shade600 when focused
        ),

        // Hint style
        hintStyle: AppTypography.formFieldHint,

        // Error style (11px, height 0.8)
        errorStyle: AppTypography.formFieldError,

        // Helper text style
        helperStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.greyText,
        ),
      ),

      // ==========================================
      // CARD THEME
      // 12px radius, subtle shadow
      // ==========================================

      cardTheme: CardTheme(
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        margin: EdgeInsets.only(bottom: AppSpacing.s), // 8px
        shape: AppRadii.cardShape, // 12px radius
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
      ),

      // ==========================================
      // APPBAR THEME
      // Blue background, white text/icons
      // ==========================================

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      // ==========================================
      // LISTTILE THEME
      // For participant lists, event lists
      // ==========================================

      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listItemPadding, // 16h/12v
        minVerticalPadding: AppSpacing.s, // 8px
        shape: AppRadii.cardShape, // 12px radius
        textColor: Colors.black87,
        iconColor: AppColors.blueText,
      ),

      // ==========================================
      // SCAFFOLD THEME
      // Off-white background for "open feel"
      // ==========================================

      scaffoldBackgroundColor: AppColors.lightColorScheme.background, // #FAFAFA

      // ==========================================
      // DIVIDER THEME
      // Subtle separators
      // ==========================================

      dividerTheme: DividerThemeData(
        color: AppColors.greyBorderDark, // grey.shade300
        thickness: 1,
        space: AppSpacing.m, // 12px
      ),

      // ==========================================
      // DIALOG THEME
      // 12px radius, generous padding
      // ==========================================

      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 6,
        shape: AppRadii.dialogShape, // 12px radius
        titleTextStyle: AppTypography.textTheme.headlineMedium?.copyWith(
          color: Colors.black87,
        ),
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: Colors.black87,
        ),
      ),

      // ==========================================
      // SNACKBAR THEME
      // Floating, dark background
      // ==========================================

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

      // ==========================================
      // DATATABLE THEME
      // For CSV import table
      // ==========================================

      dataTableTheme: DataTableThemeData(
        headingTextStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        dataTextStyle: AppTypography.textTheme.bodyMedium,
        columnSpacing: AppSpacing.xxl, // 24px (from CSV)
        horizontalMargin: AppSpacing.l, // 16px
        headingRowColor: WidgetStateProperty.all(AppColors.greyBackground),
        dataRowMinHeight: 48,
        dataRowMaxHeight: 64,
      ),

      // ==========================================
      // CHIP THEME
      // For health status chips (NewRecord)
      // ==========================================

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.greyBackgroundMedium, // grey.shade100
        selectedColor: AppColors.blueBackground, // blue.shade50
        deleteIconColor: AppColors.greyIcon,
        labelStyle: AppTypography.healthChip, // 11px
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.chipRadius, // 8px
        ),
      ),

      // ==========================================
      // ICON THEME
      // ==========================================

      iconTheme: IconThemeData(
        color: AppColors.blueText, // blue.shade600
        size: 24,
      ),

      // ==========================================
      // FLOATING ACTION BUTTON THEME
      // ==========================================

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.blueText, // blue.shade600
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ==========================================
      // BOTTOM SHEET THEME
      // ==========================================

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.bottomSheetRadius, // Top corners only
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ==========================================
      // TOOLTIP THEME
      // ==========================================

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
