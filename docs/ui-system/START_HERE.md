# 🚀 START HERE - Theme Implementation Guide

**Easy Step-by-Step Manual for Tomorrow**

**Date:** 2025-11-16
**Est. Time:** 8-12 hours total (can split across days)
**Difficulty:** Medium (follow carefully)

---

## 📚 Quick Navigation

**Before you start, read:**
1. This file (START_HERE.md) - You are here ✅
2. THEME_CHECKLIST.md - Detailed task list

**Reference as needed:**
- LINE_BY_LINE_VERIFICATION.md - Everything verified ✅
- DEEP_INVESTIGATION.md - All issues resolved ✅
- SCREEN_ANALYSIS.md - Patterns extracted from your code

---

## 🎯 What We're Doing

**Goal:** Make app UI consistent (your #1 priority, 9/10)

**What changes:**
- ✅ Spacing: Add 20px padding where missing (ParticipantReg edge-to-edge → breathing room)
- ✅ Colors: Make consistent (all use same blue shades)
- ✅ Buttons: Context-sensitive (medical=green, data=blue)
- ✅ Fonts: 14-15px (smaller, as you requested)

**What does NOT change:**
- ❌ NO fields removed or reordered
- ❌ NO buttons moved or removed
- ❌ NO navigation changes
- ❌ NO offline support changes
- ❌ NO functionality changes

**Only:** Make it look consistent!

---

## ✅ Pre-Flight Checklist

Before starting Phase 1, verify:

- [ ] You read LINE_BY_LINE_VERIFICATION.md (everything verified ✅)
- [ ] You're OK with button color decision (Option C: medical=green, data=blue)
- [ ] You're OK with font sizes (15px default, screens override to 14px when compact)
- [ ] You're OK with padding (only ParticipantReg, EventList, EventRegistrationForm, EventDetail)
- [ ] Git working directory is clean
- [ ] You're on branch: `claude/ui-documentation-011CUrKKs9V6BLrMRtfnH8Vd`
- [ ] You have 2-3 hours for Phase 1 (or can save/resume)

**All checkboxes checked?** → Proceed to Phase 1!

---

## 📋 Implementation Phases (Overview)

### Phase 1: Create Design Constants (2-3 hours)
**What:** Create 4 files with color/spacing/font/radius values

**Files to create:**
```
lib/core/constants/app_colors.dart
lib/core/constants/app_spacing.dart
lib/core/constants/app_typography.dart
lib/core/constants/app_radii.dart
```

**Test after:** Run app, verify no errors

---

### Phase 2: Create Theme (1-2 hours)
**What:** Combine constants into ThemeData

**Files to create:**
```
lib/core/themes/app_theme.dart
```

**Test after:** Run app, verify buttons/fields look themed

---

### Phase 3: Integration (30 minutes)
**What:** Update main.dart to use theme

**Files to edit:**
```
lib/main.dart (update ~5 lines)
```

**Test after:** Run app, verify theme applies globally

---

### Phase 4: Fix Critical Screens (2-3 hours)
**What:** Add padding where missing

**Files to edit:**
```
lib/screens2/participant_registration_form.dart (add padding wrapper)
lib/screens2/event_list.dart (add padding wrapper)
lib/screens2/event_registration_form.dart (add padding wrapper)
lib/screens2/event_detail.dart (verify padding)
```

**Test after:** Forms have breathing room (not edge-to-edge)

---

### Phase 5: Apply Consistently (2-3 hours)
**What:** Replace hardcoded values with theme constants

**Many files** - See THEME_CHECKLIST.md for full list

**Test after:** App looks consistent

---

### Phase 6: Testing (1-2 hours)
**What:** Verify everything works

**Test on:** Windows laptop, Android tablet (if available), phone simulator

---

### Phase 7: Documentation (30 minutes)
**What:** Update docs with "implemented" status

---

## 🔥 Phase 1: Detailed Steps (START HERE TOMORROW)

### Step 1.1: Create Folder Structure

**Open terminal, run:**
```bash
cd /home/user/denik-zza
mkdir -p lib/core/constants
mkdir -p lib/core/themes
```

**Verify:**
```bash
ls lib/core/
# Should show: constants/ themes/
```

---

### Step 1.2: Create app_colors.dart

**Create file:** `lib/core/constants/app_colors.dart`

**Copy EXACTLY from:** `docs/ui-system/design-system/THEME_IMPLEMENTATION.md` Section "Step 2"

**Or use this template:**

<details>
<summary>Click to expand app_colors.dart template</summary>

```dart
import 'package:flutter/material.dart';

/// Color constants extracted from CSV import and NewRecord pages.
///
/// Based on actual usage:
/// - Blue: shade50 (backgrounds), shade100 (icon buttons),
///         shade200 (borders), shade600 (filled buttons), shade700 (text)
class AppColors {
  AppColors._();

  // Blue shades (EXACTLY as used in your code)
  static final Color blueBackground = Colors.blue.shade50;
  static final Color blueBackgroundLight = Colors.blue.shade50.withOpacity(0.3);
  static final Color blueIconBackground = Colors.blue.shade100;
  static final Color blueBorder = Colors.blue.shade200;
  static final Color blueBorderLight = Colors.blue.shade200.withOpacity(0.5);
  static final Color blueText = Colors.blue.shade600;
  static final Color blueDark = Colors.blue.shade700;

  // Green shades (from IntakeForm - you love these!)
  static final Color greenBackground = Colors.green.shade50;
  static final Color greenPrimary = Colors.green;  // IntakeForm buttons
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

  // Orange (unsaved changes badge, AppDrawer highlight)
  static final Color orangeBackground = Colors.orange.shade100;
  static final Color orangeBorder = Colors.orange.shade300;
  static final Color orangeText = Colors.orange.shade600;

  // Red (IntakeForm "neukládat" button)
  static final Color redPrimary = Colors.red;

  /// Light color scheme matching your actual app
  static final ColorScheme lightColorScheme = ColorScheme.light(
    primary: Colors.blue,
    onPrimary: Colors.white,
    primaryContainer: blueBackground,
    onPrimaryContainer: Color(0xFF001D35),

    secondary: Colors.blue.shade600,
    onSecondary: Colors.white,
    secondaryContainer: blueIconBackground,
    onSecondaryContainer: Color(0xFF001D35),

    error: Colors.red,
    onError: Colors.white,
    errorContainer: Colors.red.shade50,
    onErrorContainer: Colors.red.shade900,

    background: Color(0xFFFAFAFA),  // Slight off-white (open feel)
    onBackground: Colors.black87,

    surface: Colors.white,
    onSurface: Colors.black87,
    surfaceVariant: greyBackground,
    onSurfaceVariant: greyText,

    outline: greyBorderDark,      // Light grey, subtle borders
    outlineVariant: greyBorder,

    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}
```

</details>

**Test:**
```bash
cd /home/user/denik-zza
flutter analyze lib/core/constants/app_colors.dart
# Should show: No issues found!
```

**If errors:** Check for typos, missing commas, brackets

---

### Step 1.3: Create app_spacing.dart

**Create file:** `lib/core/constants/app_spacing.dart`

<details>
<summary>Click to expand app_spacing.dart template</summary>

```dart
import 'package:flutter/material.dart';

/// Spacing constants extracted from CSV import flow and NewRecord page.
///
/// Based on actual code analysis:
/// - CSV import uses: EdgeInsets.all(24)
/// - NewRecord uses: EdgeInsets.all(20)
/// - Internal spacing: 12-24px
class AppSpacing {
  AppSpacing._();

  // Base spacing scale (from actual code)
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;   // Compact spacing
  static const double l = 16.0;   // Form field padding
  static const double xl = 20.0;  // NewRecord page padding
  static const double xxl = 24.0; // CSV import padding

  // Screen-level padding (matches NewRecord: 20px, CSV: 24px)
  static const EdgeInsets screenPadding = EdgeInsets.all(xl);
  static const EdgeInsets screenPaddingGenerous = EdgeInsets.all(xxl);

  // Form-specific spacing (from NewRecord page)
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(
    horizontal: l,
    vertical: m,
  );

  // Container padding (from NewRecord participant box: all 16)
  static const EdgeInsets containerPadding = EdgeInsets.all(l);

  // Compact spacing (isCompact ? 8.0 : 12.0 from NewRecord)
  static const double compactSpacing = s;
  static const double regularSpacing = m;

  // Section spacing (from CSV: height: 12, 24)
  static const SizedBox smallGap = SizedBox(height: m);
  static const SizedBox largeGap = SizedBox(height: xxl);

  // Button spacing (from CSV: SizedBox(width: 16))
  static const SizedBox buttonGap = SizedBox(width: l);
}
```

</details>

**Test:** `flutter analyze lib/core/constants/app_spacing.dart`

---

### Step 1.4: Create app_typography.dart

**Create file:** `lib/core/constants/app_typography.dart`

<details>
<summary>Click to expand app_typography.dart template (with responsive support)</summary>

```dart
import 'package:flutter/material.dart';

/// Typography constants extracted from your actual screens.
///
/// Font sizes found in code:
/// - NewRecord body text: isCompact ? 13 : 14
/// - NewRecord labels: isCompact ? 12 : 13
/// - NewRecord title fields: isCompact ? 14 : 15
///
/// IMPORTANT: Theme provides DEFAULTS (15px body).
/// Screens can override for responsive: `isCompact ? 14 : 15`
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto'; // Supports Czech diacritics

  // Base font sizes (defaults for theme)
  static const double bodyLargeSize = 15.0;  // CSV labels
  static const double bodyMediumSize = 15.0; // CHANGED: Default for desktop/tablet
  static const double bodySmallSize = 12.0;  // Small labels

  // Responsive overrides (screens use these)
  static const double bodyMediumSizeCompact = 14.0;      // Compact screens
  static const double bodyMediumSizePhone = 14.0;        // Phones (per user request)
  static const double bodyMediumSizeVerticalCompact = 14.0; // Short screens (height <= 600)

  /// Text theme matching your actual font sizes
  static const TextTheme textTheme = TextTheme(
    // Display styles (large headings) - rarely used
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

    // Title styles
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,  // AppDrawer section headers
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),

    // Body styles (main content) - IMPORTANT
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: bodyLargeSize,  // 15px
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: bodyMediumSize,  // 15px DEFAULT (screens override)
      fontWeight: FontWeight.normal,
      letterSpacing: 0.25,
      height: 1.5,
      locale: Locale('cs', 'CZ'),
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: bodySmallSize,  // 12px
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
      fontSize: 11,  // NewRecord health chip, AppDrawer subtitles
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      locale: Locale('cs', 'CZ'),
    ),
  );
}
```

</details>

**Test:** `flutter analyze lib/core/constants/app_typography.dart`

---

### Step 1.5: Create app_radii.dart

**Create file:** `lib/core/constants/app_radii.dart`

<details>
<summary>Click to expand app_radii.dart template</summary>

```dart
import 'package:flutter/material.dart';

/// Border radius constants extracted from your actual screens.
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
  static const double large = 8.0;   // Form fields, buttons
  static const double xl = 12.0;     // Containers, cards

  // Common border radii (matching your actual code)
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(large));      // 8px
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(xl));           // 12px
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(large));       // 8px
  static const BorderRadius containerRadius = BorderRadius.all(Radius.circular(xl));      // 12px
}
```

</details>

**Test:** `flutter analyze lib/core/constants/app_radii.dart`

---

### Step 1.6: Test All Constants Together

**Run:**
```bash
flutter analyze lib/core/constants/
# Should show: No issues found!
```

**If errors:**
- Check for typos
- Check all files have `import 'package:flutter/material.dart';`
- Check all classes end with `}`
- Check all semicolons `;` present

**Phase 1 complete!** ✅ Take a break, commit your work.

---

## 💾 How to Commit After Each Phase

After completing a phase:

```bash
cd /home/user/denik-zza

# Check what changed
git status

# Add changes
git add lib/core/

# Commit with clear message
git commit -m "theme: implement Phase 1 - create design constants

- Created lib/core/constants/ folder
- Added app_colors.dart (blue/green/grey/yellow/orange shades)
- Added app_spacing.dart (20-24px padding, 8-16px gaps)
- Added app_typography.dart (14-15px body, Czech locale)
- Added app_radii.dart (8-12px border radius)

All constants extracted from CSV import + NewRecord patterns.
No code changes yet, just constant definitions.
"

# Push to remote
git push origin claude/ui-documentation-011CUrKKs9V6BLrMRtfnH8Vd
```

---

## 🆘 Troubleshooting

### Error: "No such file or directory"
**Solution:** Make sure you created `lib/core/constants/` folder first

### Error: "Unexpected token"
**Solution:** Check for missing commas, semicolons, or brackets

### Error: "undefined_class"
**Solution:** Add `import 'package:flutter/material.dart';` at top of file

### App won't run after Phase 1
**This is NORMAL!** Constants don't break anything, they're just definitions.
Continue to Phase 2 to actually use them.

---

## ⏭️ What's Next (After Phase 1)

1. **Phase 2:** Create `lib/core/themes/app_theme.dart`
   - See THEME_CHECKLIST.md Section 2.1
   - Combines your constants into ThemeData
   - ~1-2 hours

2. **Phase 3:** Update `lib/main.dart`
   - Change ~5 lines
   - `theme: AppTheme.lightTheme`
   - ~30 minutes

3. **Continue...** following THEME_CHECKLIST.md

---

## 📞 Need Help?

**During implementation:**
1. Check THEME_CHECKLIST.md for detailed steps
2. Check DEEP_INVESTIGATION.md for "why" behind decisions
3. Check LINE_BY_LINE_VERIFICATION.md for verification

**If stuck:**
- ✅ Commit what you have
- ✅ Note which step failed
- ✅ Continue in next session

---

## ✅ Success Criteria (You'll Know It's Working)

**After Phase 1:** No errors when analyzing
**After Phase 2:** No errors when analyzing
**After Phase 3:** App runs, looks slightly different
**After Phase 4:** ParticipantRegistrationForm has breathing room!
**After Phase 5:** App looks beautifully consistent
**After Phase 6:** Everything tested and working

---

**Good luck tomorrow!** 🚀

You have:
- ✅ All decisions made
- ✅ All requirements verified
- ✅ Easy step-by-step guide
- ✅ Templates to copy/paste
- ✅ Clear success criteria

**You got this!** 💪

