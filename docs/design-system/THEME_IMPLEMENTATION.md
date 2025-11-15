# ThemeData Implementation Guide

**Complete Code for Deník ZZA Design System**

Based on **ACTUAL patterns** from your CSV import flow and NewRecord page (not generic Material 3).

---

## 🔍 Design Patterns Extracted from Your Best Screens

I analyzed the actual code from:
- `lib/screens2/csv/import_screen.dart` ✅ (you like this flow)
- `lib/screens2/csv/summary_screen.dart` ✅
- `lib/screens2/new_record_page.dart` ✅ (you like this page)

### What I Found:

**Spacing:**
- Main padding: `20-24px` (not edge-to-edge)
- Section spacing: `12-24px` between major sections
- Compact spacing: `8-12px` for tight layouts
- Button spacing: `16px` horizontal gap

**Font Sizes (actual from code):**
- Body text: `13-15px` (NOT 16px!)
- Labels: `12-13px`
- Small text: `11px`
- Compact mode reduces by 1-2px

**Border Radius:**
- Cards/containers: `12px` (rounder than Material 3 default)
- Form fields: `8px`
- Buttons: `8px`

**Colors (actual shades used):**
- `Colors.blue.shade50` - light backgrounds
- `Colors.blue.shade100` - icon button backgrounds
- `Colors.blue.shade200` - borders
- `Colors.blue.shade600` - primary actions
- `Colors.blue.shade700` - text/icons

---

## 🏗️ File Structure (Flutter Best Practice 2024)

```
lib/
├── design_system/
│   ├── tokens/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   └── app_radii.dart
│   └── theme/
│       └── app_theme.dart
└── screens2/
    └── (your screens)
```

---

## 📝 Step 1: Spacing Tokens (Extracted from Your Code)

**File:** `lib/design_system/tokens/app_spacing.dart`

```dart
import 'package:flutter/material.dart';

/// Spacing tokens extracted from CSV import flow and NewRecord page.
///
/// Based on actual code analysis:
/// - CSV import uses: EdgeInsets.all(24)
/// - NewRecord uses: EdgeInsets.all(20) "for better breathing room"
/// - Internal spacing: 12-24px
class AppSpacing {
  AppSpacing._();

  // Base spacing scale (from actual code)
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;   // Used for compact spacing
  static const double large = 16.0;    // Form field padding
  static const double xl = 20.0;       // NewRecord page padding
  static const double xxl = 24.0;      // CSV import padding

  // Screen-level padding (matches NewRecord: 20px, CSV: 24px)
  static const EdgeInsets screenPadding = EdgeInsets.all(xl);
  static const EdgeInsets screenPaddingGenerous = EdgeInsets.all(xxl);

  // Form-specific spacing (from NewRecord page)
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(
    horizontal: large,
    vertical: medium,
  );

  // Container padding (from NewRecord participant box: all 16)
  static const EdgeInsets containerPadding = EdgeInsets.all(large);

  // Compact spacing (isCompact ? 8.0 : 12.0 from NewRecord)
  static const double compactSpacing = small;
  static const double regularSpacing = medium;

  // Section spacing (from CSV: height: 12, 24)
  static const SizedBox smallGap = SizedBox(height: medium);
  static const SizedBox largeGap = SizedBox(height: xxl);

  // Button spacing (from CSV: SizedBox(width: 16))
  static const SizedBox buttonGap = SizedBox(width: large);
}
```

---

## 🎨 Step 2: Color Tokens (Extracted from Your Code)

**File:** `lib/design_system/tokens/app_colors.dart`

```dart
import 'package:flutter/material.dart';

/// Color tokens extracted from your CSV import and NewRecord pages.
///
/// Based on actual usage:
/// - Blue: shade50 (backgrounds), shade100 (icon buttons),
///         shade200 (borders), shade600 (filled buttons), shade700 (text)
/// - Green: For positive actions (from NewRecord zpusobilost button)
class AppColors {
  AppColors._();

  // Blue shades (EXACTLY as used in your code)
  static final Color blueBackground = Colors.blue.shade50;
  static final Color blueBackgroundLight = Colors.blue.shade50.withOpacity(0.3); // NewRecord datetime box
  static final Color blueIconBackground = Colors.blue.shade100;
  static final Color blueBorder = Colors.blue.shade200;
  static final Color blueBorderLight = Colors.blue.shade200.withOpacity(0.5);
  static final Color blueText = Colors.blue.shade600;
  static final Color blueDark = Colors.blue.shade700;

  // Green shades (from NewRecord zpusobilost button)
  static final Color greenBackground = Colors.green.shade50;
  static final Color greenText = Colors.green.shade700;

  // Grey shades (from NewRecord history section)
  static final Color greyBackground = Colors.grey.shade50;
  static final Color greyBackgroundMedium = Colors.grey.shade100;
  static final Color greyBorder = Colors.grey.shade200;
  static final Color greyBorderDark = Colors.grey.shade300;
  static final Color greyText = Colors.grey.shade600;
  static final Color greyTextLight = Colors.grey.shade400;
  static final Color greyIcon = Colors.grey.shade700;

  // Yellow (poznámka sticky note from NewRecord)
  static final Color yellowBackground = Colors.yellow.shade50;
  static final Color yellowBorder = Colors.amber.shade300;
  static final Color yellowText = Colors.amber.shade700;
  static final Color yellowTextDark = Colors.amber.shade800;

  // Orange (unsaved changes badge from NewRecord)
  static final Color orangeBackground = Colors.orange.shade100;
  static final Color orangeBorder = Colors.orange.shade300;
  static final Color orangeText = Colors.orange.shade600;

  /// Light color scheme matching your actual app
  static final ColorScheme lightColorScheme = ColorScheme.light(
    // Primary: Blue (your current color - "okay" per feedback)
    primary: Colors.blue,
    onPrimary: Colors.white,
    primaryContainer: blueBackground,
    onPrimaryContainer: Color(0xFF001D35),

    // Secondary: Use for vibrant major actions
    // (Will configure FilledButton to use custom vibrant green separately)
    secondary: Colors.blue.shade600,
    onSecondary: Colors.white,
    secondaryContainer: blueIconBackground,
    onSecondaryContainer: Color(0xFF001D35),

    // Error
    error: Colors.red,
    onError: Colors.white,
    errorContainer: Colors.red.shade50,
    onErrorContainer: Colors.red.shade900,

    // Background (open, clean feel - slight off-white like CSV import)
    background: Color(0xFFFAFAFA),
    onBackground: Colors.black87,

    // Surface
    surface: Colors.white,
    onSurface: Colors.black87,
    surfaceVariant: greyBackground,
    onSurfaceVariant: greyText,

    // Outline (for minimalistic borders)
    outline: greyBorderDark,           // Light grey, subtle
    outlineVariant: greyBorder,        // Even lighter

    // Shadows
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}
```

---

## 📖 Step 3: Typography Tokens (Actual Font Sizes from Your Code)

**File:** `lib/design_system/tokens/app_typography.dart`

```dart
import 'package:flutter/material.dart';

/// Typography tokens extracted from your actual screens.
///
/// Font sizes found in code:
/// - NewRecord body text: isCompact ? 13 : 14
/// - NewRecord labels: isCompact ? 12 : 13
/// - NewRecord title fields: isCompact ? 14 : 15
/// - Small text: 11, 10, 9 (various places)
///
/// These are SMALLER than Material 3 defaults (which use 14-16px body text).
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto'; // Supports Czech diacritics

  /// Text theme matching your actual font sizes
  static const TextTheme textTheme = TextTheme(
    // Display styles (large headings) - rarely used in your app
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      height: 1.2,
      locale: Locale('cs', 'CZ'),
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.2,
      locale: Locale('cs', 'CZ'),
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),

    // Headline styles (section headers)
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),

    // Title styles (CSV uses theme.textTheme.titleMedium for labels)
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,        // Matches NewRecord title fields (non-compact)
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),

    // Body styles (main content)
    // CRITICAL: These match your actual code!
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,        // CSV import file label uses bodyLarge
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,        // NewRecord description field (non-compact)
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,        // NewRecord poznámka label
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),

    // Label styles (buttons, small UI elements)
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,        // NewRecord health chip text
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
  );
}
```

---

## 📐 Step 4: Radii Tokens (Extracted from Your Code)

**File:** `lib/design_system/tokens/app_radii.dart`

```dart
import 'package:flutter/material.dart';

/// Border radius tokens extracted from your actual screens.
///
/// Found in code:
/// - CSV import file box: BorderRadius.circular(12)
/// - NewRecord participant box: BorderRadius.circular(12.0)
/// - NewRecord form fields: BorderRadius.circular(8.0)
/// - NewRecord action buttons: BorderRadius.circular(8.0)
class AppRadii {
  AppRadii._();

  static const double small = 4.0;
  static const double medium = 6.0;
  static const double large = 8.0;      // Form fields, buttons
  static const double xl = 12.0;        // Containers, cards

  // Common border radii (matching your actual code)
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(large));      // 8px
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(xl));           // 12px
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(large));       // 8px
  static const BorderRadius containerRadius = BorderRadius.all(Radius.circular(xl));      // 12px
}
```

---

## 🎨 Step 5: Complete App Theme (Based on Your Actual Patterns)

**File:** `lib/design_system/theme/app_theme.dart`

```dart
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
class AppTheme {
  AppTheme._();

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
          backgroundColor: Colors.blue.shade600,    // Actual color from code
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 20,
          ),
          minimumSize: Size(120, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,  // 8px
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
          foregroundColor: Colors.grey.shade700,   // Actual color from code
          padding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          minimumSize: Size(100, 48),
          side: BorderSide(
            color: Colors.grey.shade400,            // Actual from code
            width: 1.5,                             // Actual from code
          ),
          shape: RoundedRectangleBorder(
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
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.large,
            vertical: AppSpacing.small,
          ),
          minimumSize: Size(88, 36),
        ),
      ),

      /// Elevated buttons - Used in CSV import
      ///
      /// From CSV import "Vybrat soubor" button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.blueText,
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          shape: RoundedRectangleBorder(
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
          borderRadius: AppRadii.inputRadius,  // 8px
          borderSide: BorderSide(
            color: AppColors.blueBorder,        // blue.shade200
            width: 1.0,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.blueBorder,        // blue.shade200
            width: 1.0,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: Colors.blue.shade600,        // Actual from code
            width: 2,                           // Actual from code
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
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
        contentPadding: EdgeInsets.all(AppSpacing.large),  // 16px

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
        margin: EdgeInsets.only(bottom: AppSpacing.small),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,  // 12px
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
        backgroundColor: Colors.blue,           // Primary blue
        foregroundColor: Colors.white,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),

      // ========================================
      // DIALOG THEME
      // ========================================

      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.containerRadius,  // 12px
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
        horizontalMargin: AppSpacing.large,
      ),

      // ========================================
      // SCAFFOLD BACKGROUND
      // ========================================

      scaffoldBackgroundColor: AppColors.lightColorScheme.background,  // #FAFAFA

      // ========================================
      // DIVIDER THEME
      // ========================================

      dividerTheme: DividerThemeData(
        color: AppColors.greyBorderDark,
        thickness: 1,
        space: AppSpacing.medium,
      ),
    );
  }
}
```

---

## 🚀 Step 6: Integration in main.dart

**File:** `lib/main.dart` (update)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:denik_zza/design_system/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deník ZZA',

      // 🎨 Use theme extracted from your actual code!
      theme: AppTheme.lightTheme,

      // Czech localization
      locale: const Locale('cs', 'CZ'),
      supportedLocales: const [Locale('cs', 'CZ')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: EventList(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## 💡 Usage Examples

### Example 1: Using Themed Buttons (Like Your CSV Import)

```dart
// Primary action (like CSV "Pokračovat")
FilledButton(
  onPressed: _continue,
  child: Text('Pokračovat'),  // Auto-styled like CSV import!
)

// Secondary action (like CSV "Vybrat soubor")
ElevatedButton(
  onPressed: _pickFile,
  child: Text('Vybrat soubor'),
)
```

### Example 2: Using Themed Form Fields (Like NewRecord)

```dart
// Automatically gets blue.shade200 borders, 8px radius!
TextFormField(
  decoration: InputDecoration(
    labelText: 'Nadpis',
    hintText: 'Zadejte nadpis záznamu',
  ),
)
```

### Example 3: Using Spacing (Like NewRecord)

```dart
// Main screen padding (matches NewRecord: 20px)
Padding(
  padding: AppSpacing.screenPadding,  // 20px all sides
  child: Column(
    children: [
      Text('Section 1'),
      AppSpacing.largeGap,              // 24px vertical gap
      Text('Section 2'),
      AppSpacing.smallGap,              // 12px vertical gap
      TextFormField(...),
    ],
  ),
)
```

### Example 4: Participant Container (Like NewRecord)

```dart
// Blue gradient box (like NewRecord participant section)
Container(
  padding: AppSpacing.containerPadding,  // 16px all
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.blueBackground,
        AppColors.blueBackgroundLight,
      ],
    ),
    borderRadius: AppRadii.containerRadius,  // 12px
    border: Border.all(
      color: AppColors.blueBorder,           // blue.shade200
      width: 1,
    ),
  ),
  child: YourContent(),
)
```

---

## ✅ Testing Checklist

After implementation:

- [ ] Buttons match CSV import style (blue.shade600, not green)
- [ ] Form fields have blue.shade200 borders (8px radius)
- [ ] Font sizes feel smaller/more compact (14-15px body, not 16px)
- [ ] Screen padding is 20-24px (not edge-to-edge)
- [ ] Border radius is 8-12px (rounder than Material 3 default)
- [ ] Czech diacritics render correctly (ě, š, č, ř, ž, ý, á, í, é, ú, ů, ď, ť, ň)
- [ ] App feels consistent with CSV import and NewRecord pages
- [ ] Test on Windows 10, Linux
- [ ] Test responsive (375px, 768px, 1440px widths)

---

## 🔍 Key Differences from Material 3 Defaults

| Element | Material 3 Default | Your Actual Code |
|---------|-------------------|------------------|
| Body text | 16px | 14-15px |
| Border radius | 4px | 8-12px |
| Form padding | 12px | 16px |
| Screen padding | 16px | 20-24px |
| Button height | 40px | 48px |
| Primary button color | Theme primary | blue.shade600 |
| Form border color | Theme outline | blue.shade200 |

---

## 📚 Related Documentation

- **Your Preferences:** `APP_DESIGN_FEEL.md`
- **Implementation Plan:** `CONSISTENCY_PLAN.md`
- **UI Audit:** `../ui-audit/UI_AUDIT_DOCUMENTATION.md`

---

**Created:** 2025-11-15
**Based on:** Actual code from CSV import flow + NewRecord page
**Flutter Version:** 3.16+ (Material 3)
**Locale:** cs_CZ (Czech)

💡 **Important:** This theme extracts patterns from screens you already like (CSV import, NewRecord), not generic Material 3 defaults!
