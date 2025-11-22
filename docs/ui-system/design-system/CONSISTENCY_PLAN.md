# UI Consistency Implementation Plan

**Deník ZZA - Focused on Creating Consistent App Feel**

Based on your design preferences (APP_DESIGN_FEEL.md) and 2024 Flutter best practices.

---

## 🎯 Goal

**Create consistent, open, minimalistic UI across the entire app WITHOUT rearranging functionality.**

### What This Means
✅ **DO:** Make things look and feel consistent
✅ **DO:** Use ThemeData for all styling
✅ **DO:** Keep all form fields, buttons, navigation
❌ **DON'T:** Move buttons around
❌ **DON'T:** Remove or reorder form fields
❌ **DON'T:** Change navigation structure

---

## 📊 Priority Rankings (From Your Preferences)

| Item | Priority | Status |
|------|----------|--------|
| Consistent spacing across app | 9/10 | 🔴 High |
| Consistent colors across app | 9/10 | 🔴 High |
| Consistent buttons across app | 9/10 | 🔴 High |
| Better empty states | 7/10 | 🟡 Medium |
| Make forms work on mobile | 7/10 | 🟡 Medium |
| Better error messages | 7/10 | 🟡 Medium |
| Auto-save drafts | 8/10 | 🟢 Feature |
| Offline support | 10/10 | ✅ Already have |

---

## 🎨 Design Direction (Your Preferences)

###Colors
- **Primary:** Blue (current is okay)
- **Backgrounds:** White with light accents (keep current, more open feel)
- **Major Actions:** Vibrant like intake form buttons 💚
- **Minor Actions:** Material 3 standard

### Typography
- **Must:** Support Czech diacritics well
- **Size:** Slightly smaller in some places (too large now)
- **Weight:** Current weights are good

### Spacing
- **Overall:** Need MORE whitespace (currently too cramped)
- **Forms:** Add margins (currently full-width edge-to-edge)
- **Reference:** CSV import flow has good spacing

### Form Fields
- **Style:** Less intrusive borders (minimalistic)
- **Layout:** 3-column desktop → 1-column mobile
- **Keep:** All fields in same order

### Buttons
- **Major Actions (Next to each other):** Vibrant intake form style
- **Single/Minor Actions:** Material 3 standard
- **Example:** Intake form "Označit jako příchozí" button

---

## 🏗️ Implementation Strategy

### Phase 1: Foundation (ThemeData First) - Week 1

**Goal:** Create single source of truth for all styling

#### Step 1.1: Create Design Tokens

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

**What goes in ThemeData:**
- ✅ Colors (colorScheme)
- ✅ Typography (textTheme - with Czech diacritics support)
- ✅ Button styles (filledButtonTheme, outlinedButtonTheme, textButtonTheme)
- ✅ Input fields (inputDecorationTheme - less intrusive borders)
- ✅ Cards (cardTheme)
- ✅ AppBar (appBarTheme)
- ✅ Spacing (through EdgeInsets constants)

#### Step 1.2: Define Spacing System

Based on your "too cramped" feedback:

```dart
class AppSpacing {
  // Base spacing (more generous than before)
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Screen margins (add breathing room)
  static const EdgeInsets screenPadding = EdgeInsets.all(24.0);

  // Form spacing (prevent edge-to-edge)
  static const double formSideMargin = 32.0; // Important!
  static const EdgeInsets formPadding = EdgeInsets.symmetric(
    horizontal: formSideMargin,
    vertical: large,
  );
}
```

#### Step 1.3: Define Colors

```dart
class AppColors {
  // Based on intake form buttons (your favorite!)
  static const primaryGreen = Color(0xFF4CAF50); // Intake form button
  static const primaryGreenLight = Color(0xFFC8E6C9);

  static ColorScheme lightScheme = ColorScheme.light(
    primary: Colors.blue,  // Keep current blue
    primaryContainer: Color(0xFFE3F2FD),

    // Major action button (vibrant like intake form)
    secondary: primaryGreen,
    secondaryContainer: primaryGreenLight,

    // Standard Material 3 for rest
    error: Color(0xFFD32F2F),
    surface: Colors.white,
    background: Color(0xFFFAFAFA), // Slight off-white for open feel
  );
}
```

#### Step 1.4: Define Typography (Czech Diacritics)

```dart
class AppTypography {
  static const String fontFamily = 'Roboto'; // Supports Czech well

  static TextTheme textTheme = TextTheme(
    // Titles
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      locale: Locale('cs', 'CZ'),
    ),
    titleLarge: TextStyle(
      fontSize: 20, // Slightly smaller
      fontWeight: FontWeight.w600,
      locale: Locale('cs', 'CZ'),
    ),

    // Body text
    bodyLarge: TextStyle(
      fontSize: 15, // Slightly smaller
      fontWeight: FontWeight.normal,
      locale: Locale('cs', 'CZ'),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      locale: Locale('cs', 'CZ'),
    ),

    // Labels
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      locale: Locale('cs', 'CZ'),
    ),
  );
}
```

---

### Phase 2: Button Consistency - Week 2

**Goal:** Two button styles across app

#### Major Actions (Vibrant - Like Intake Form)

Use for:
- Form submissions next to cancel
- Primary workflow actions
- "Označit jako příchozí" style buttons

```dart
// In ThemeData
filledButtonTheme: FilledButtonThemeData(
  style: FilledButton.styleFrom(
    backgroundColor: AppColors.primaryGreen, // Vibrant!
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.medium,
    ),
    minimumSize: Size(120, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
),
```

#### Minor Actions (Material 3 Standard)

Use for:
- Single buttons on screen
- Less important actions
- Cancel buttons

```dart
outlinedButtonTheme: OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.primary,
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.large,
      vertical: AppSpacing.medium,
    ),
    minimumSize: Size(100, 48),
    side: BorderSide(
      color: Theme.of(context).colorScheme.outline,
      width: 1,
    ),
  ),
),
```

---

### Phase 3: Form Field Consistency - Week 3

**Goal:** Minimalistic, less intrusive borders

#### Input Decoration Theme

```dart
inputDecorationTheme: InputDecorationTheme(
  // Less intrusive borders (your preference!)
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: Colors.grey.shade300, // Light, subtle
      width: 1.0, // Thin
    ),
  ),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: Colors.grey.shade300,
      width: 1.0,
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: Theme.of(context).colorScheme.primary,
      width: 1.5, // Slightly thicker when focused
    ),
  ),

  // More padding for open feel
  contentPadding: EdgeInsets.symmetric(
    horizontal: AppSpacing.medium,
    vertical: AppSpacing.medium,
  ),

  filled: false, // Transparent background (minimalistic)
),
```

---

### Phase 4: Screen-by-Screen Application - Week 4-6

**Apply ThemeData to screens WITHOUT rearranging**

#### Priority Order (Based on Your Feedback)

1. **ParticipantDetail** - Complete UI/UX redo (URGENT)
2. **ParticipantRegistrationForm** - Add margins, responsive grid
3. **EventRegistrationForm** - Add margins, fix spacing
4. **EventList** - List item UI improvements
5. **ParticipantListScreen** - List item UI, clickable items
6. **NewRecordPage** - Minor spacing adjustments

#### For Each Screen:

✅ **DO:**
- Wrap content in ConstrainedBox with max width
- Add margins (no more edge-to-edge)
- Use AppSpacing constants
- Use themed buttons
- Use themed input fields
- Keep all fields in same order

❌ **DON'T:**
- Move buttons to different positions
- Remove or reorder form fields
- Change navigation structure

#### Example: EventRegistrationForm

**Before (Problems):**
- Full width edge-to-edge ❌
- Inconsistent spacing ❌
- Mixed button styles ❌

**After (Solution):**
```dart
Scaffold(
  body: Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 800),
      child: Padding(
        padding: AppSpacing.screenPadding, // Margins!
        child: Form(
          child: Column(
            children: [
              // Title field (themed automatically)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Název akce',
                ),
              ),
              SizedBox(height: AppSpacing.medium),

              // Description (themed automatically)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Popis',
                ),
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.large),

              // Date fields...

              Spacer(),

              // Buttons (SAME POSITION, new style)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton( // Material 3 for cancel
                    onPressed: _cancel,
                    child: Text('Zrušit'),
                  ),
                  SizedBox(width: AppSpacing.medium),
                  FilledButton( // Vibrant for submit
                    onPressed: _submit,
                    child: Text('Uložit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ),
)
```

---

## 🎯 Specific Screen Improvements

### ParticipantDetail (URGENT - Complete Redesign)

**Your Feedback:**
- Feels detached from rest of app
- Too boxy
- Missing data (parents contacts, meds, restrictions)
- Null values shown
- Needs complete redesign using existing patterns

**Plan:**
1. Use Card pattern from CSV flow (you like that design)
2. Group info logically (personal + insurance together)
3. Add all missing fields from current data model
4. Hide null values gracefully
5. Make consistent with rest of app
6. Keep "Nový záznam" and "Tisk" buttons in same place

### ParticipantRegistrationForm (Mobile Support)

**Your Feedback:**
- Love 3-column desktop layout ✓
- Full width edge-to-edge (add margins)
- Need mobile support (1 column)

**Plan:**
1. Add responsive grid (3 col desktop → 1 col mobile)
2. Add side margins (not edge-to-edge)
3. Keep all fields in exact same order
4. Gentle animation for autofill (optional enhancement)

### List Items (ParticipantListScreen, EventDetail)

**Your Feedback:**
- Ugly list items UI
- Not clickable (only button is)
- Should be consistent

**Plan:**
1. Make entire list item clickable
2. Improve visual design (inspired by CSV flow)
3. Add icons for restrictions/medications
4. Keep same information displayed

---

## 🔧 Technical Implementation

### File Structure

```
lib/
├── design_system/
│   ├── tokens/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   └── app_radii.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── components/
│       ├── buttons.dart (if need custom variants)
│       └── forms.dart (if need custom components)
├── screens2/
│   └── (apply theme to existing screens)
└── main.dart (use AppTheme.lightTheme)
```

### main.dart Integration

```dart
import 'package:denik_zza/design_system/theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deník ZZA',
      theme: AppTheme.lightTheme, // Single source of truth!
      locale: Locale('cs', 'CZ'),
      // ... rest of config
    );
  }
}
```

---

## 📋 Implementation Checklist

### Week 1: Foundation
- [ ] Create `lib/design_system/tokens/app_spacing.dart`
- [ ] Create `lib/design_system/tokens/app_colors.dart`
- [ ] Create `lib/design_system/tokens/app_typography.dart`
- [ ] Create `lib/design_system/theme/app_theme.dart`
- [ ] Test ThemeData in one screen
- [ ] Update main.dart to use AppTheme

### Week 2: Buttons
- [ ] Define FilledButton theme (vibrant for major actions)
- [ ] Define OutlinedButton theme (Material 3 for minor)
- [ ] Define TextButton theme (for tertiary actions)
- [ ] Update 5 screens to use themed buttons
- [ ] Test on actual devices

### Week 3: Forms
- [ ] Define InputDecorationTheme (less intrusive borders)
- [ ] Test on ParticipantRegistrationForm
- [ ] Test on EventRegistrationForm
- [ ] Test on NewRecordPage
- [ ] Verify Czech diacritics render correctly

### Week 4: Screen Updates
- [ ] ParticipantDetail - Complete redesign
- [ ] ParticipantRegistrationForm - Add margins + responsive
- [ ] EventRegistrationForm - Add margins
- [ ] Test all on mobile (375px width)

### Week 5: List Items
- [ ] Redesign ParticipantListItem
- [ ] Make list items clickable
- [ ] Add icons for restrictions/medications
- [ ] Apply to ParticipantListScreen
- [ ] Apply to EventDetail

### Week 6: Polish
- [ ] Test Czech diacritics on all screens
- [ ] Verify spacing consistency
- [ ] Verify color consistency
- [ ] Test on Windows 10, Linux
- [ ] Final review against APP_DESIGN_FEEL.md

---

## 🚫 What We're NOT Doing (Per Your Requirements)

❌ Rearranging form field order
❌ Moving buttons to different positions
❌ Changing navigation structure
❌ Removing any current functionality
❌ Making CSV mobile-friendly (nice-to-have only)
❌ Dark mode (priority 4/10, later)

---

## ✅ Success Criteria

**After Implementation:**

1. **Visual Consistency**
   - All screens use same colors from ThemeData
   - All screens use same typography
   - All screens use same spacing constants
   - Major actions = vibrant (intake form style)
   - Minor actions = Material 3 standard

2. **Open Feel**
   - No more edge-to-edge forms
   - More whitespace between elements
   - Less intrusive form borders
   - Breathing room on all screens

3. **Responsive**
   - Forms work on mobile (1 column)
   - Forms work on desktop (3 columns)
   - All screens tested at 375px, 768px, 1440px

4. **Czech Support**
   - All text renders diacritics correctly
   - Font family supports Czech characters
   - Locale set to cs_CZ throughout

5. **Functional Integrity**
   - All form fields still present in same order
   - All buttons still present in same positions
   - All navigation paths unchanged
   - Offline support still works (10/10 priority)

---

## 📖 Related Documentation

- **Your Preferences:** `APP_DESIGN_FEEL.md`
- **Implementation Details:** `THEME_IMPLEMENTATION.md`
- **Quick Reference:** `../implementation/DESIGN_RULES_QUICK_REF.md`

---

**Created:** 2025-11-15
**Focus:** UI Consistency Without Rearranging
**Priority:** #1 (9/10 from your feedback)

💡 **Remember:** We're making things LOOK and FEEL consistent, not changing what they DO!
