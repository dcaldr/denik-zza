# ThemeData Implementation Guide

**Complete Code for Deník ZZA Design System**

Based on Flutter Material 3 (2024/2025) and your design preferences.

---

## 📋 What Can Be Put in ThemeData?

Based on [Flutter API documentation](https://api.flutter.dev/flutter/material/ThemeData-class.html), ThemeData contains **90+ properties**:

### Core Styling
✅ `colorScheme` - All colors (primary, secondary, backgrounds, etc.)
✅ `textTheme` - All text styles (titles, body, labels)
✅ `typography` - Platform-specific typography

### Component Themes (Partial List)
✅ `appBarTheme` - AppBar styling
✅ `filledButtonTheme` - Filled button styling ⭐
✅ `outlinedButtonTheme` - Outlined button styling ⭐
✅ `textButtonTheme` - Text button styling
✅ `inputDecorationTheme` - Form field styling ⭐
✅ `cardTheme` - Card styling
✅ `chipTheme` - Chip styling
✅ `listTileTheme` - List item styling ⭐
✅ `dialogTheme` - Dialog styling
✅ `snackBarTheme` - SnackBar styling
✅ `bottomSheetTheme` - Bottom sheet styling
✅ `drawerTheme` - Drawer styling
✅ `badgeTheme` - Badge styling
✅ `dataTableTheme` - DataTable styling
✅ `datePickerTheme` - Date picker styling
✅ ...and 60+ more!

### Material Behavior
✅ `useMaterial3` - Enable Material 3 (default: true in Flutter 3.16+)
✅ `visualDensity` - Spacing density
✅ `materialTapTargetSize` - Touch target size
✅ `splashFactory` - Ripple effect
✅ `pageTransitionsTheme` - Page transition animations

---

## 🏗️ File Structure

```
lib/design_system/
├── tokens/
│   ├── app_colors.dart
│   ├── app_typography.dart
│   ├── app_spacing.dart
│   └── app_radii.dart
└── theme/
    └── app_theme.dart
```

---

## 📝 Step 1: Spacing Tokens

**File:** `lib/design_system/tokens/app_spacing.dart`

```dart
import 'package:flutter/material.dart';

/// Spacing tokens for consistent spacing across the app.
///
/// Based on feedback: "too cramped, need more whitespace"
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Base spacing scale
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Screen-level padding (more generous for "open feel")
  static const EdgeInsets screenPadding = EdgeInsets.all(large);

  // Form-specific spacing (prevent edge-to-edge)
  static const double formSideMargin = xl; // 32px breathing room
  static const EdgeInsets formPadding = EdgeInsets.symmetric(
    horizontal: formSideMargin,
    vertical: large,
  );

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(medium);

  // List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: medium,
    vertical: small,
  );

  // Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: medium,
  );

  // Form field spacing
  static const SizedBox fieldSpacing = SizedBox(height: medium);
  static const SizedBox sectionSpacing = SizedBox(height: large);
}
```

---

## 🎨 Step 2: Color Tokens

**File:** `lib/design_system/tokens/app_colors.dart`

```dart
import 'package:flutter/material.dart';

/// Color tokens for the app.
///
/// Based on:
/// - Current blue (okay per feedback)
/// - Vibrant intake form buttons for major actions
/// - Open, clean feel
class AppColors {
  AppColors._();

  // Intake form button colors (your favorite!)
  static const Color vibrantGreen = Color(0xFF4CAF50);
  static const Color vibrantGreenLight = Color(0xFFC8E6C9);
  static const Color vibrantGreenDark = Color(0xFF388E3C);

  // Blue primary (current, keep it)
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFFE3F2FD);
  static const Color primaryBlueDark = Color(0xFF1565C0);

  /// Light color scheme for the app
  static const ColorScheme lightColorScheme = ColorScheme.light(
    // Primary color (navigation, emphasis)
    primary: primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: primaryBlueLight,
    onPrimaryContainer: Color(0xFF001D35),

    // Secondary color (vibrant for major actions like intake form!)
    secondary: vibrantGreen,
    onSecondary: Colors.white,
    secondaryContainer: vibrantGreenLight,
    onSecondaryContainer: Color(0xFF002106),

    // Tertiary (for accents if needed)
    tertiary: Color(0xFFFFA726), // Orange for highlights
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFFFE0B2),
    onTertiaryContainer: Color(0xFF2A1800),

    // Error colors
    error: Color(0xFFD32F2F),
    onError: Colors.white,
    errorContainer: Color(0xFFFFCDD2),
    onErrorContainer: Color(0xFF410002),

    // Backgrounds (open, clean feel - slight off-white)
    background: Color(0xFFFAFAFA), // Very light grey for openness
    onBackground: Color(0xFF1A1C1E),

    // Surface colors
    surface: Colors.white,
    onSurface: Color(0xFF1A1C1E),
    surfaceVariant: Color(0xFFE0E3E6),
    onSurfaceVariant: Color(0xFF43474E),

    // Outlines (for less intrusive borders)
    outline: Color(0xFFE0E0E0), // Light grey, subtle
    outlineVariant: Color(0xFFC3C7CF),

    // Shadows
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),

    // Inverse colors (for dark elements on light bg)
    inverseSurface: Color(0xFF2F3033),
    onInverseSurface: Color(0xFFF1F0F4),
    inversePrimary: Color(0xFF90CAF9),
  );

  // Semantic colors (for specific uses)
  static const Color success = vibrantGreen;
  static const Color warning = Color(0xFFFFA726);
  static const Color info = primaryBlue;
}
```

---

## 📖 Step 3: Typography Tokens

**File:** `lib/design_system/tokens/app_typography.dart`

```dart
import 'package:flutter/material.dart';

/// Typography tokens for the app.
///
/// Requirements:
/// - Support Czech diacritics well
/// - Slightly smaller font sizes (feedback: "too large")
/// - Current weights are good
class AppTypography {
  AppTypography._();

  /// Font family that supports Czech diacritics
  static const String fontFamily = 'Roboto'; // Default, supports Czech well

  /// Text theme for the app
  static TextTheme textTheme = TextTheme(
    // Display styles (large headings)
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      height: 1.2,
      locale: Locale('cs', 'CZ'),
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
      height: 1.2,
      locale: Locale('cs', 'CZ'),
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),

    // Headline styles (section headers)
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
      locale: Locale('cs', 'CZ'),
    ),

    // Title styles (smaller headings)
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18, // Slightly smaller
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),

    // Body styles (main content)
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15, // Slightly smaller than default 16
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.4,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),

    // Label styles (buttons, tabs)
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
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
  );
}
```

---

## 📐 Step 4: Radii Tokens

**File:** `lib/design_system/tokens/app_radii.dart`

```dart
import 'package:flutter/material.dart';

/// Border radius tokens for consistent rounded corners.
class AppRadii {
  AppRadii._();

  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double xl = 16.0;

  // Common border radii
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(large));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius dialogRadius = BorderRadius.all(Radius.circular(xl));
}
```

---

## 🎨 Step 5: Complete App Theme

**File:** `lib/design_system/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_radii.dart';

/// Complete theme configuration for Deník ZZA app.
///
/// Based on Material 3 and design preferences:
/// - Vibrant buttons for major actions (like intake form)
/// - Material 3 standard for minor actions
/// - Minimalistic, open feel
/// - Less intrusive form borders
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      // Enable Material 3
      useMaterial3: true,

      // Color scheme
      colorScheme: AppColors.lightColorScheme,

      // Typography
      textTheme: AppTypography.textTheme,
      fontFamily: AppTypography.fontFamily,

      // Visual density (comfortable for desktop/tablet)
      visualDensity: VisualDensity.comfortable,

      // ========================================
      // BUTTON THEMES
      // ========================================

      /// Filled buttons - Vibrant for major actions (like intake form!)
      ///
      /// Use for:
      /// - Form submissions
      /// - Primary workflow actions
      /// - "Označit jako příchozí" style buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.vibrantGreen, // Vibrant!
          foregroundColor: Colors.white,
          padding: AppSpacing.buttonPadding,
          minimumSize: Size(120, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          elevation: 2,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      /// Outlined buttons - Material 3 for secondary/minor actions
      ///
      /// Use for:
      /// - Cancel buttons
      /// - Secondary actions
      /// - Less important actions
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: AppSpacing.buttonPadding,
          minimumSize: Size(100, 48),
          side: BorderSide(
            color: AppColors.lightColorScheme.outline,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.buttonRadius,
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      /// Text buttons - For tertiary actions
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: AppSpacing.small,
          ),
          minimumSize: Size(88, 36),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // ========================================
      // FORM FIELD THEME
      // ========================================

      /// Input decoration - Minimalistic with less intrusive borders
      inputDecorationTheme: InputDecorationTheme(
        // Less intrusive borders (feedback: "minimalistic approach")
        border: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.lightColorScheme.outline,
            width: 1.0, // Thin
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.lightColorScheme.outline,
            width: 1.0,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5, // Slightly thicker when focused
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.lightColorScheme.error,
            width: 1.0,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.lightColorScheme.error,
            width: 1.5,
          ),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.inputRadius,
          borderSide: BorderSide(
            color: AppColors.lightColorScheme.outlineVariant,
            width: 1.0,
          ),
        ),

        // Padding for open feel
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.medium,
        ),

        // Transparent background (minimalistic)
        filled: false,

        // Label style
        labelStyle: AppTypography.textTheme.bodyMedium,
        floatingLabelStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.primaryBlue,
        ),

        // Helper/error text style
        helperStyle: AppTypography.textTheme.bodySmall,
        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: AppColors.lightColorScheme.error,
        ),
      ),

      // ========================================
      // CARD THEME
      // ========================================

      cardTheme: CardTheme(
        elevation: 1,
        shadowColor: AppColors.lightColorScheme.shadow.withOpacity(0.1),
        margin: EdgeInsets.symmetric(
          vertical: AppSpacing.small,
          horizontal: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ========================================
      // LIST TILE THEME
      // ========================================

      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listItemPadding,
        minVerticalPadding: AppSpacing.small,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
        ),
      ),

      // ========================================
      // APP BAR THEME
      // ========================================

      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),

      // ========================================
      // DRAWER THEME
      // ========================================

      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.lightColorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),

      // ========================================
      // DIALOG THEME
      // ========================================

      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightColorScheme.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.dialogRadius,
        ),
        titleTextStyle: AppTypography.textTheme.headlineSmall,
        contentTextStyle: AppTypography.textTheme.bodyMedium,
      ),

      // ========================================
      // SNACKBAR THEME
      // ========================================

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.lightColorScheme.inverseSurface,
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.lightColorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.medium * BorderRadius.all(Radius.circular(1)),
        ),
      ),

      // ========================================
      // CHIP THEME
      // ========================================

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightColorScheme.surfaceVariant,
        deleteIconColor: AppColors.lightColorScheme.onSurfaceVariant,
        selectedColor: AppColors.primaryBlueLight,
        secondarySelectedColor: AppColors.vibrantGreenLight,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: AppSpacing.xs,
        ),
        labelStyle: AppTypography.textTheme.labelSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.medium)),
        ),
      ),

      // ========================================
      // DATA TABLE THEME (for CSV)
      // ========================================

      dataTableTheme: DataTableThemeData(
        headingTextStyle: AppTypography.textTheme.labelLarge,
        dataTextStyle: AppTypography.textTheme.bodyMedium,
        columnSpacing: AppSpacing.large,
        horizontalMargin: AppSpacing.medium,
      ),

      // ========================================
      // DATE PICKER THEME
      // ========================================

      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.lightColorScheme.surface,
        headerBackgroundColor: AppColors.primaryBlue,
        headerForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.dialogRadius,
        ),
      ),

      // ========================================
      // BOTTOM SHEET THEME
      // ========================================

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightColorScheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
      ),

      // ========================================
      // SCAFFOLD BACKGROUND
      // ========================================

      scaffoldBackgroundColor: AppColors.lightColorScheme.background,

      // ========================================
      // DIVIDER THEME
      // ========================================

      dividerTheme: DividerThemeData(
        color: AppColors.lightColorScheme.outlineVariant,
        thickness: 1,
        space: AppSpacing.medium,
      ),
    );
  }
}
```

---

## 🚀 Step 6: Integration in main.dart

**File:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:denik_zza/design_system/theme/app_theme.dart';
import 'package:denik_zza/screens2/event_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize any services here...

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deník ZZA',

      // 🎨 Use our complete theme!
      theme: AppTheme.lightTheme,

      // Czech localization
      locale: const Locale('cs', 'CZ'),
      supportedLocales: const [
        Locale('cs', 'CZ'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Home screen
      home: EventList(),

      // Debug banner
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## 💡 Usage Examples

### Example 1: Using Themed Buttons

```dart
// Major action (vibrant, like intake form)
FilledButton(
  onPressed: _submit,
  child: Text('Uložit'), // Automatically uses theme style!
)

// Secondary action (Material 3 standard)
OutlinedButton(
  onPressed: _cancel,
  child: Text('Zrušit'),
)

// Tertiary action
TextButton(
  onPressed: _back,
  child: Text('Zpět'),
)
```

### Example 2: Using Themed Form Fields

```dart
// Automatically gets minimalistic borders!
TextFormField(
  decoration: InputDecoration(
    labelText: 'Jméno',
    helperText: 'Zadejte jméno účastníka',
  ),
  validator: (value) => value?.isEmpty ?? true ? 'Povinné pole' : null,
)
```

### Example 3: Using Spacing Constants

```dart
Padding(
  padding: AppSpacing.screenPadding, // Not edge-to-edge!
  child: Column(
    children: [
      Text('Title'),
      AppSpacing.sectionSpacing, // SizedBox with correct height
      TextFormField(...),
      AppSpacing.fieldSpacing,
      TextFormField(...),
    ],
  ),
)
```

### Example 4: Using Colors

```dart
// For specific color needs (rare - theme handles most)
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primaryContainer,
    border: Border.all(
      color: Theme.of(context).colorScheme.outline,
    ),
  ),
)
```

---

## ✅ Testing Checklist

After implementation:

- [ ] All buttons display correctly
- [ ] Vibrant buttons for major actions (intake form style)
- [ ] Material 3 buttons for minor actions
- [ ] Form fields have less intrusive borders
- [ ] Czech diacritics render correctly (ě, š, č, ř, ž, ý, á, í, é, ú, ů, ď, ť, ň)
- [ ] Spacing consistent across all screens
- [ ] No edge-to-edge forms (margins present)
- [ ] Text sizes feel appropriate (not too large)
- [ ] Open, clean feel achieved
- [ ] Test on Windows 10, Linux
- [ ] Test on 375px, 768px, 1440px widths

---

## 🔄 Migration Path

To migrate existing screens to use the theme:

### Before:
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    padding: EdgeInsets.all(16),
  ),
  onPressed: _submit,
  child: Text('Uložit'),
)
```

### After:
```dart
FilledButton( // Theme handles styling!
  onPressed: _submit,
  child: Text('Uložit'),
)
```

### Before:
```dart
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    contentPadding: EdgeInsets.all(12),
  ),
)
```

### After:
```dart
TextField( // Theme handles styling!
  decoration: InputDecoration(
    labelText: 'Field label',
  ),
)
```

---

## 📚 Related Documentation

- **Your Preferences:** `APP_DESIGN_FEEL.md`
- **Implementation Plan:** `CONSISTENCY_PLAN.md`
- **Official Flutter Docs:** https://api.flutter.dev/flutter/material/ThemeData-class.html

---

**Created:** 2025-11-15
**Flutter Version:** 3.16+ (Material 3 default)
**Locale:** cs_CZ (Czech)

💡 **Pro Tip:** Once ThemeData is set up, you rarely need to specify styling in individual widgets!
