# Phase 3: UI Consistency Implementation - Technical Details

**Purpose:** File-by-file technical instructions for Phase 3
**Companion:** See PHASE_3_OVERVIEW.md for high-level plan
**Branch:** claude/theme-implementation-011CUrKKs9V6BLrMRtfnH8Vd

---

## 📋 Step-by-Step Implementation Guide

---

## STEP 1: Activate Theme in main.dart

### File: `lib/main.dart`

**Current state (line 25-27):**
```dart
theme: ThemeData(
  primarySwatch: Colors.blue,
),
```

**Change to:**
```dart
theme: AppTheme.lightTheme,
```

**Add import at top:**
```dart
import 'core/themes/app_theme.dart';
```

### Test:
```bash
flutter run
```

**Expected result:**
- App compiles without errors
- App runs
- Visual appearance should be similar (theme not fully applied yet to screens)

### Commit:
```bash
git add lib/main.dart
git commit -m "feat: integrate AppTheme in main.dart

Activated custom theme with all design tokens.

Changes:
- Imported core/themes/app_theme.dart
- Replaced ThemeData(primarySwatch: Colors.blue) with AppTheme.lightTheme
- Theme includes:
  - Material Design 3
  - ColorScheme from extracted colors
  - Czech locale on all text styles
  - Button themes (2-button pattern)
  - Input field themes
  - All component themes

No visual changes to screens yet (hardcoded values override theme).
Next: Fix edge-to-edge screens in Step 2.

Reference: PHASE_3_TECHNICAL.md Step 1"
```

---

## STEP 2: Fix Edge-to-Edge Screens

### 2.1: ParticipantRegistrationForm (CRITICAL)

**File:** `lib/screens2/participant_registration_form.dart`

**Current state:** Form has NO padding (edge-to-edge)

**User complaint:** "completely edge to edge... spills whole screen" (APP_DESIGN_FEEL line 183-184)

**Find:** The Form widget (around line 100-150)

**Current pattern:**
```dart
return Scaffold(
  appBar: AppBar(...),
  body: Form(
    key: _formKey,
    child: SingleChildScrollView(
      child: Column(
        children: [
          _buildGridView(),  // NO Padding wrapper!
          ...
        ],
      ),
    ),
  ),
);
```

**Change to:**
```dart
return Scaffold(
  appBar: AppBar(...),
  body: Padding(
    padding: AppSpacing.screenPadding,  // ADD THIS WRAPPER
    child: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildGridView(),
            ...
          ],
        ),
      ),
    ),
  ),
);
```

**Add import:**
```dart
import '../core/constants/app_spacing.dart';
```

**Test:** Form should have 20px breathing room on all sides

---

### 2.2: EventRegistrationForm

**File:** `lib/screens2/event_registration_form.dart`

**Current state:** Line 100 has `EdgeInsets.all(16.0)` - not enough

**Find:**
```dart
body: Padding(
  padding: const EdgeInsets.all(16.0),  // Line ~100
  child: Form(
    ...
  ),
),
```

**Change to:**
```dart
body: Padding(
  padding: AppSpacing.screenPadding,  // 20px instead of 16px
  child: Form(
    ...
  ),
),
```

**Add import:**
```dart
import '../core/constants/app_spacing.dart';
```

**Test:** Form should have 20px padding (slightly more generous than before)

---

### 2.3: EventList

**File:** `lib/screens2/event_list.dart`

**Current state:** ListView probably has no padding or minimal padding

**Find:** The ListView.builder widget

**Add wrapper:**
```dart
body: Padding(
  padding: AppSpacing.screenPadding,  // ADD 20px padding
  child: ListView.builder(
    ...
  ),
),
```

**Add import:**
```dart
import '../core/constants/app_spacing.dart';
```

**Test:** Event list should have breathing room from screen edges

---

### 2.4: EventDetail (Verify Only)

**File:** `lib/screens2/event_detail.dart`

**Current state:** Line 107 already has `EdgeInsets.all(20.0)` ✅

**Find:**
```dart
Padding(
  padding: const EdgeInsets.all(20.0),  // Line ~107
  child: Column(
    ...
  ),
),
```

**Change to:**
```dart
Padding(
  padding: AppSpacing.screenPadding,  // Replace hardcoded with constant
  child: Column(
    ...
  ),
),
```

**Add import:**
```dart
import '../core/constants/app_spacing.dart';
```

**Test:** Visual appearance should be identical (20px → 20px)

---

### Commit Step 2:
```bash
git add lib/screens2/participant_registration_form.dart \
        lib/screens2/event_registration_form.dart \
        lib/screens2/event_list.dart \
        lib/screens2/event_detail.dart

git commit -m "fix: add padding to edge-to-edge screens

Fixed 'completely edge to edge' complaint from user.

Changes:
1. ParticipantRegistrationForm: 0px → 20px padding (CRITICAL)
2. EventRegistrationForm: 16px → 20px padding
3. EventList: Added 20px padding
4. EventDetail: Replaced hardcoded 20px with AppSpacing.screenPadding

All screens now use AppSpacing.screenPadding for consistency.

User feedback: 'completely edge to edge... spills whole screen' - FIXED
Reference: APP_DESIGN_FEEL.md lines 183-184, 341, 304
Reference: PHASE_3_TECHNICAL.md Step 2"
```

---

## STEP 3: Replace Hardcoded Colors

### Strategy:
Search for hardcoded color patterns and replace with AppColors constants.

### 3.1: Find All Hardcoded Colors

**Search patterns:**
```bash
# Blue shades
grep -rn "Colors\.blue\.shade50" lib/screens2/
grep -rn "Colors\.blue\.shade200" lib/screens2/
grep -rn "Colors\.blue\.shade600" lib/screens2/
grep -rn "Colors\.blue\.shade700" lib/screens2/

# Grey shades
grep -rn "Colors\.grey\.shade" lib/screens2/

# Orange shades (AppDrawer)
grep -rn "Colors\.orange\.shade" lib/screens2/

# Green shades (health)
grep -rn "Colors\.green\.shade" lib/screens2/

# Yellow/Amber shades (poznámka)
grep -rn "Colors\.yellow\.shade\|Colors\.amber\.shade" lib/screens2/
```

### 3.2: Replacement Mapping

**Blue shades:**
```dart
// BEFORE → AFTER
Colors.blue.shade50           → AppColors.blueBackground
Colors.blue.shade100          → AppColors.blueIconBackground
Colors.blue.shade200          → AppColors.blueBorder
Colors.blue.shade600          → AppColors.blueText
Colors.blue.shade700          → AppColors.blueDark
```

**Grey shades:**
```dart
Colors.grey.shade50           → AppColors.greyBackground
Colors.grey.shade100          → AppColors.greyBackgroundMedium
Colors.grey.shade200          → AppColors.greyBorder
Colors.grey.shade300          → AppColors.greyBorderDark
Colors.grey.shade400          → AppColors.greyTextLight
Colors.grey.shade600          → AppColors.greyText
Colors.grey.shade700          → AppColors.greyIcon
```

**Accent colors:**
```dart
Colors.green.shade50          → AppColors.greenBackground
Colors.green.shade700         → AppColors.greenText
Colors.yellow.shade50         → AppColors.yellowBackground
Colors.amber.shade300         → AppColors.yellowBorder
Colors.amber.shade700         → AppColors.yellowText
Colors.orange.shade100        → AppColors.orangeBackground
Colors.orange.shade300        → AppColors.orangeBorder
Colors.orange.shade600        → AppColors.orangeText
```

### 3.3: Files to Update (estimated)

**Priority 1 (definitely have hardcoded colors):**
- [ ] `lib/screens2/new_record_page.dart` - Blue/grey for buttons, participant boxes
- [ ] `lib/screens2/widgets/app_drawer.dart` - Orange highlights
- [ ] `lib/screens2/csv/import_screen.dart` - Blue containers
- [ ] `lib/screens2/csv/summary_screen.dart` - Blue cards

**Priority 2 (likely have hardcoded colors):**
- [ ] `lib/screens2/participant_list_screen.dart` - Empty state grey
- [ ] `lib/screens2/event_list.dart` - Empty state grey (if applicable)
- [ ] `lib/screens2/intake_form_improved.dart` - Check gradients

**NOTE:** IntakeForm 3-button colors (green/blue/red) stay hardcoded - this is intentional!

### 3.4: Add Import to Each File

```dart
import '../core/constants/app_colors.dart';  // Adjust path based on file location
// For files in lib/screens2/widgets/ use '../../core/constants/app_colors.dart'
```

### 3.5: Empty States Pattern

**BEFORE:**
```dart
Icon(Icons.people_outline, size: 48, color: Colors.grey)
Text('Žádní účastníci', style: TextStyle(fontSize: 18, color: Colors.grey))
```

**AFTER:**
```dart
Icon(
  Icons.people_outline,
  size: 48,
  color: Theme.of(context).colorScheme.onSurfaceVariant,
)
Text(
  'Žádní účastníci',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  ),
)
```

**OR with AppColors:**
```dart
Icon(Icons.people_outline, size: 48, color: AppColors.greyText)
Text('Žádní účastníci', style: TextStyle(fontSize: 18, color: AppColors.greyText))
```

### Commit Step 3:
```bash
git add lib/screens2/new_record_page.dart \
        lib/screens2/widgets/app_drawer.dart \
        lib/screens2/csv/ \
        lib/screens2/participant_list_screen.dart \
        lib/screens2/event_list.dart \
        # ... add all modified files

git commit -m "refactor: replace hardcoded colors with AppColors

Replaced all hardcoded Colors.blue/grey/orange with AppColors constants.

Changes:
- NewRecordPage: blue.shade200 → AppColors.blueBorder, etc.
- AppDrawer: orange.shade100 → AppColors.orangeBackground
- CSV screens: All blue shades → AppColors
- Empty states: Colors.grey → AppColors.greyText
- All screens now use consistent color palette

Preserved:
- IntakeForm 3-button pattern (green/blue/red) - intentionally manual

User priority: 9/10 for color consistency (APP_DESIGN_FEEL line 872)
Reference: PHASE_3_TECHNICAL.md Step 3"
```

---

## STEP 4: Replace Hardcoded Spacing

### 4.1: Find All Hardcoded Spacing

**Search patterns:**
```bash
# EdgeInsets patterns
grep -rn "EdgeInsets\.all(20" lib/screens2/
grep -rn "EdgeInsets\.all(16" lib/screens2/
grep -rn "EdgeInsets\.all(12" lib/screens2/
grep -rn "EdgeInsets\.symmetric" lib/screens2/

# SizedBox patterns
grep -rn "SizedBox(height: 24" lib/screens2/
grep -rn "SizedBox(height: 16" lib/screens2/
grep -rn "SizedBox(height: 12" lib/screens2/
grep -rn "SizedBox(height: 8" lib/screens2/
grep -rn "SizedBox(width: 16" lib/screens2/
grep -rn "SizedBox(width: 12" lib/screens2/
```

### 4.2: Replacement Mapping

**EdgeInsets:**
```dart
// Screen-level padding
EdgeInsets.all(20)                → AppSpacing.screenPadding
EdgeInsets.all(24)                → AppSpacing.screenPaddingGenerous

// Container padding
EdgeInsets.all(16)                → AppSpacing.containerPadding
EdgeInsets.all(12)                → AppSpacing.cardPadding

// Specific patterns
EdgeInsets.symmetric(h: 16, v: 12) → AppSpacing.formFieldPadding
EdgeInsets.symmetric(v: 14, h: 20) → AppSpacing.buttonPadding
EdgeInsets.symmetric(v: 14, h: 16) → AppSpacing.outlinedButtonPadding
```

**SizedBox (Vertical gaps):**
```dart
SizedBox(height: 4)               → AppSpacing.tinyGap
SizedBox(height: 8)               → AppSpacing.smallGap
SizedBox(height: 12)              → AppSpacing.mediumGap
SizedBox(height: 16)              → AppSpacing.largeGap
SizedBox(height: 20)              → AppSpacing.xlargeGap
SizedBox(height: 24)              → AppSpacing.xxlargeGap
```

**SizedBox (Horizontal gaps):**
```dart
SizedBox(width: 4)                → AppSpacing.tinyHGap
SizedBox(width: 8)                → AppSpacing.smallHGap
SizedBox(width: 12)               → AppSpacing.mediumHGap
SizedBox(width: 16)               → AppSpacing.buttonGap
SizedBox(width: 20)               → AppSpacing.xlargeHGap
SizedBox(width: 24)               → AppSpacing.xxlargeHGap
```

### 4.3: Files Already Updated in Step 2

**Skip these (already use AppSpacing):**
- ✅ participant_registration_form.dart
- ✅ event_registration_form.dart
- ✅ event_list.dart
- ✅ event_detail.dart

### 4.4: Add Import to Each File

```dart
import '../core/constants/app_spacing.dart';
```

### 4.5: Special Cases

**NewRecord button row gap (current):**
```dart
const SizedBox(width: 16)
```

**Replace with:**
```dart
AppSpacing.buttonGap
```

**CSV import sections (current):**
```dart
SizedBox(height: 24)  // Between major sections
```

**Replace with:**
```dart
AppSpacing.xxlargeGap
```

### Commit Step 4:
```bash
git add lib/screens2/
git commit -m "refactor: replace hardcoded spacing with AppSpacing

Replaced all hardcoded EdgeInsets and SizedBox with AppSpacing constants.

Changes:
- EdgeInsets.all(20) → AppSpacing.screenPadding
- EdgeInsets.all(16) → AppSpacing.containerPadding
- SizedBox(height: 12/16/24) → AppSpacing gaps
- SizedBox(width: 16) → AppSpacing.buttonGap
- All spacing now consistent across app

Benefits:
- Single source of truth for spacing
- Easier to adjust globally if needed
- More readable code (AppSpacing.buttonGap vs SizedBox(width: 16))

User priority: 9/10 for spacing consistency (APP_DESIGN_FEEL line 872)
Reference: PHASE_3_TECHNICAL.md Step 4"
```

---

## STEP 5: Replace Hardcoded Border Radius

### 5.1: Find All Hardcoded Border Radius

**Search patterns:**
```bash
grep -rn "BorderRadius\.circular(12" lib/screens2/
grep -rn "BorderRadius\.circular(8" lib/screens2/
grep -rn "borderRadius:" lib/screens2/
```

### 5.2: Replacement Mapping

```dart
// Containers, cards, participant boxes
BorderRadius.circular(12)          → AppRadii.containerRadius

// Buttons
BorderRadius.circular(8)           → AppRadii.buttonRadius
// (in button context)

// Input fields
BorderRadius.circular(8)           → AppRadii.inputRadius
// (in TextFormField context)

// Cards
BorderRadius.circular(12)          → AppRadii.cardRadius
```

### 5.3: Pattern Examples

**NewRecord participant box (current):**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    gradient: LinearGradient(...),
  ),
)
```

**Replace with:**
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: AppRadii.containerRadius,  // 12px
    gradient: LinearGradient(...),
  ),
)
```

**Buttons (current):**
```dart
RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(8),
)
```

**Replace with:**
```dart
AppRadii.buttonShape  // Pre-configured RoundedRectangleBorder
```

### 5.4: Add Import to Each File

```dart
import '../core/constants/app_radii.dart';
```

### Commit Step 5:
```bash
git add lib/screens2/
git commit -m "refactor: replace hardcoded radii with AppRadii

Replaced all hardcoded BorderRadius.circular() with AppRadii constants.

Changes:
- BorderRadius.circular(12) → AppRadii.containerRadius (containers, cards)
- BorderRadius.circular(8) → AppRadii.buttonRadius/inputRadius (buttons, inputs)
- Used pre-configured shapes where applicable (AppRadii.buttonShape)
- All border radius now consistent (8px inputs/buttons, 12px containers/cards)

Benefits:
- Consistent roundness across entire app
- Rounder than Material 3 default (4px) for softer feel
- Single source of truth

Reference: PHASE_3_TECHNICAL.md Step 5"
```

---

## STEP 6: Visual Testing & Verification

### 6.1: Manual Testing Checklist

**Test every screen:**

- [ ] **EventList**
  - No edge-to-edge ✅
  - Colors consistent ✅
  - Spacing comfortable ✅
  - List items render correctly ✅

- [ ] **ParticipantListScreen**
  - Has padding/breathing room ✅
  - Empty state colors correct ✅
  - List items styled consistently ✅

- [ ] **ParticipantRegistrationForm**
  - 20px padding (NOT edge-to-edge!) ✅
  - Form fields styled correctly ✅
  - 3-column layout still works ✅
  - All 12 fields in same order ✅

- [ ] **IntakeFormImproved**
  - 3-button pattern preserved (green/blue/red) ✅
  - Spacing looks good ✅
  - No layout breaks ✅

- [ ] **NewRecordPage**
  - Colors consistent with theme ✅
  - Participant box styled correctly ✅
  - Buttons styled correctly (blue FilledButton + grey OutlinedButton) ✅
  - Icon panel unchanged ✅
  - Health chips styled ✅
  - Poznámka yellow box preserved ✅

- [ ] **EventDetail**
  - 20px padding ✅
  - Participant list items consistent ✅
  - Search works ✅

- [ ] **EventRegistrationForm**
  - 20px padding (not 16px) ✅
  - Form fields styled ✅

- [ ] **CSV Import Flow**
  - import_screen styling ✅
  - confirm_screen table styling ✅
  - summary_screen cards styling ✅
  - 24px generous padding preserved ✅

- [ ] **AppDrawer**
  - Orange highlights preserved ✅
  - Menu structure unchanged ✅
  - Section headers styled ✅

- [ ] **PrintCenter** (just verify no crashes)
  - Opens without errors ✅

- [ ] **ParticipantDetail** (will be redesigned later)
  - No crashes ✅

- [ ] **FileViewerScreen** (if accessible)
  - No crashes ✅

### 6.2: Responsive Testing

Resize window to test breakpoints:

- [ ] **Mobile (375px wide)**
  - Forms stack to 1 column ✅
  - No horizontal overflow ✅
  - Padding visible ✅
  - Font sizes readable (14px) ✅

- [ ] **Tablet (768px wide)**
  - Forms adapt layout ✅
  - Spacing looks good ✅

- [ ] **Desktop (1440px wide)**
  - Forms use 3 columns (where applicable) ✅
  - Generous spacing ✅
  - Font sizes comfortable (15px) ✅

### 6.3: Czech Diacritics Testing

Type test text with diacritics in form fields:

**Test string:**
```
Příliš žluťoučký kůň úpěl ďábelské ódy
```

**Verify:**
- [ ] All diacritics render correctly (ě, š, č, ř, ž, ý, á, í, é, ú, ů, ď, ť, ň)
- [ ] No font substitution or weird rendering
- [ ] Text is readable and looks professional

### 6.4: Before/After Comparison

**Key screens to compare:**

| Screen | Before (Pre-Phase 3) | After (Post-Phase 3) |
|--------|---------------------|----------------------|
| ParticipantReg | Edge-to-edge | 20px breathing room |
| EventReg | 16px padding | 20px padding |
| NewRecord | Hardcoded blue.shade200 | AppColors.blueBorder |
| All screens | Inconsistent colors | Consistent palette |
| All screens | Hardcoded spacing | AppSpacing constants |

**Expected result:** Screens look **better** but not radically different.

### 6.5: Regression Testing

**Check for broken functionality:**

- [ ] Forms still submit correctly
- [ ] Buttons still trigger correct actions
- [ ] Navigation still works
- [ ] No crashes when navigating between screens
- [ ] Offline mode still works
- [ ] Database operations still work

**IMPORTANT:** If functionality is broken, it's likely pre-existing (see FIXME.md)

### 6.6: Performance Check

- [ ] App startup time unchanged
- [ ] Screen transitions smooth
- [ ] No jank or stuttering
- [ ] Memory usage unchanged

### Final Commit:
```bash
git add docs/ui-system/PHASE_3_VERIFICATION_RESULTS.md  # Optional: document test results
git commit -m "docs: Phase 3 complete - UI consistency implemented

Phase 3 verification complete - all tests passed.

Implemented:
✅ Theme activated (main.dart)
✅ Edge-to-edge screens fixed (4 screens)
✅ Hardcoded colors replaced with AppColors
✅ Hardcoded spacing replaced with AppSpacing
✅ Hardcoded radii replaced with AppRadii

Testing completed:
✅ All 12 screens tested visually
✅ Responsive behavior verified (mobile/tablet/desktop)
✅ Czech diacritics rendering correctly
✅ No regressions found
✅ Performance unchanged

Preserved:
✅ IntakeForm 3-button pattern (green/blue/red)
✅ NewRecord responsive font logic (isCompact ? 14 : 15)
✅ CSV table horizontal scroll
✅ AppDrawer design
✅ All functionality intact

User priority: 9/10 for consistency - ACHIEVED
Reference: APP_DESIGN_FEEL.md line 872

Phase 3 complete. UI is now consistent across the app.
Next: Functional fixes from docs/ui-system/FIXME.md (separate work)"
```

---

## 📊 Files Changed Summary

### Estimated Files Modified: 15-20 files

**Core Integration (1 file):**
- lib/main.dart

**Edge-to-Edge Fixes (4 files):**
- lib/screens2/participant_registration_form.dart
- lib/screens2/event_registration_form.dart
- lib/screens2/event_list.dart
- lib/screens2/event_detail.dart

**Color Replacements (~7 files):**
- lib/screens2/new_record_page.dart
- lib/screens2/widgets/app_drawer.dart
- lib/screens2/csv/import_screen.dart
- lib/screens2/csv/summary_screen.dart
- lib/screens2/participant_list_screen.dart
- lib/screens2/event_list.dart (if empty states)
- lib/screens2/intake_form_improved.dart (if needed)

**Spacing Replacements (~10 files):**
- Same files as above + any additional screens with hardcoded spacing

**Radii Replacements (~10 files):**
- Same files as above

---

## 🔗 Functional Fixes (NOT in Phase 3)

**See:** `docs/ui-system/FIXME.md`

These are **separate work** after Phase 3:

### HUGE MISSES:
1. IntakeForm - No inline participant creation
2. IntakeForm - No arrived counter (23/56)
3. CSV Import - Wrong navigation destination
4. ParticipantDetail - Needs complete redesign

### High Priority:
5. ParticipantListScreen - Search broken
6. ParticipantListScreen - List items not clickable
7. NewRecordPage - Účastník section not clickable
8. EventList - Toast stacking
9. NewRecordPage - Spacing off (form → buttons)

### Medium Priority:
10-21. Various PrintCenter, FileViewer, AppDrawer issues

**Important:** These are **functional fixes**, not UI consistency. They should be addressed AFTER Phase 3 is complete to avoid confusion about what broke what.

---

## ⚠️ Critical Reminders

1. **DO NOT change IntakeForm 3-button colors** - They stay green/blue/red
2. **DO NOT change NewRecord responsive logic** - `isCompact ? 14 : 15` stays
3. **DO NOT add padding to CSV table** - Would break horizontal scroll
4. **DO NOT change AppDrawer design** - User loves current design
5. **ONLY UI/visual changes** - No functional fixes in Phase 3

---

## 🆘 Troubleshooting

### Problem: App crashes after theme integration

**Solution:** Check import paths
```dart
// Correct paths:
import 'core/themes/app_theme.dart';  // From lib/main.dart
import '../core/constants/app_colors.dart';  // From lib/screens2/
import '../../core/constants/app_colors.dart';  // From lib/screens2/widgets/
```

### Problem: Screen looks broken after padding change

**Solution:** Verify wrapping structure
```dart
// Make sure Padding wraps the scrollable content:
Padding(
  padding: AppSpacing.screenPadding,
  child: SingleChildScrollView(  // or ListView
    child: Column(...),
  ),
)
```

### Problem: Colors don't look right

**Solution:** Verify correct AppColors constant
```bash
# Check app_colors.dart for exact mapping
grep "blueText" lib/core/constants/app_colors.dart
# Should be: static final Color blueText = Colors.blue.shade600;
```

### Problem: Import not found

**Solution:** Check relative path depth
```dart
// lib/screens2/some_file.dart
import '../core/constants/app_colors.dart';  // One level up

// lib/screens2/widgets/some_widget.dart
import '../../core/constants/app_colors.dart';  // Two levels up
```

---

**Created:** 2025-11-16
**Branch:** claude/theme-implementation-011CUrKKs9V6BLrMRtfnH8Vd
**Status:** Ready for Implementation
**Estimated Time:** 4-6 hours of focused work
