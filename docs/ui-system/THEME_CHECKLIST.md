# Theme Implementation Checklist

**Complete checklist for implementing consistent design system**

**References:**
- APP_DESIGN_FEEL.md (user preferences)
- SCREEN_ANALYSIS.md (actual code patterns)
- THEME_IMPLEMENTATION.md (implementation guide)

**Target:** lib/core/ architecture (2025 best practice)

---

## 📋 Pre-Implementation Checklist

### ✅ Research & Documentation (DONE)
- [x] Analyze CSV import flow design patterns
- [x] Analyze NewRecord page design patterns
- [x] Extract actual spacing values (20-24px screen, 12-16px internal)
- [x] Extract actual font sizes (13-15px body, 11-13px labels)
- [x] Extract actual colors (blue/grey shades)
- [x] Extract actual border radius (8-12px)
- [x] Document user preferences from APP_DESIGN_FEEL.md
- [x] Cross-reference all screens with user feedback
- [x] Research Flutter 2025 best practices (lib/core/)

### ⬜ File Structure Setup (TODO)
- [ ] Create `lib/core/` folder
- [ ] Create `lib/core/constants/` subfolder
- [ ] Create `lib/core/themes/` subfolder
- [ ] Verify folder structure matches 2025 pattern

---

## 🎨 Phase 1: Create Design Constants (Tokens)

### ⬜ 1.1 Create `lib/core/constants/app_colors.dart`

**Reference:** SCREEN_ANALYSIS.md - Colors section, NewRecord + CSV patterns

**Must include:**
- [ ] Blue shades (exact values from code):
  - [ ] `blueBackground = Colors.blue.shade50` (participant boxes)
  - [ ] `blueBackgroundLight = Colors.blue.shade50.withOpacity(0.3)` (gradients)
  - [ ] `blueIconBackground = Colors.blue.shade100` (icon buttons)
  - [ ] `blueBorder = Colors.blue.shade200` (form field borders)
  - [ ] `blueBorderLight = Colors.blue.shade200.withOpacity(0.5)`
  - [ ] `blueText = Colors.blue.shade600` (primary buttons, text)
  - [ ] `blueDark = Colors.blue.shade700` (dark text, icons)

- [ ] Grey shades:
  - [ ] `greyBackground = Colors.grey.shade50` (secondary backgrounds)
  - [ ] `greyBackgroundMedium = Colors.grey.shade100`
  - [ ] `greyBorder = Colors.grey.shade200` (light borders)
  - [ ] `greyBorderDark = Colors.grey.shade300` (outline borders)
  - [ ] `greyText = Colors.grey.shade600` (secondary text)
  - [ ] `greyTextLight = Colors.grey.shade400` (disabled text)
  - [ ] `greyIcon = Colors.grey.shade700` (icons)

- [ ] Accent colors:
  - [ ] `greenBackground = Colors.green.shade50` (zpusobilost)
  - [ ] `greenText = Colors.green.shade700`
  - [ ] `yellowBackground = Colors.yellow.shade50` (poznámka boxes)
  - [ ] `yellowBorder = Colors.amber.shade300`
  - [ ] `yellowText = Colors.amber.shade700`
  - [ ] `orangeBackground = Colors.orange.shade100` (AppDrawer highlight)
  - [ ] `orangeBorder = Colors.orange.shade300`
  - [ ] `orangeText = Colors.orange.shade600`

- [ ] ColorScheme for ThemeData:
  - [ ] `lightColorScheme` with all Material 3 properties
  - [ ] Use extracted colors (not generic Material 3 defaults)

**APP_DESIGN_FEEL.md reference:** Line 872 - "Consistent colors across app" (priority 9/10)

---

### ⬜ 1.2 Create `lib/core/constants/app_spacing.dart`

**Reference:** SCREEN_ANALYSIS.md - Spacing section, CSV (24px) + NewRecord (20px)

**Must include:**
- [ ] Base scale:
  - [ ] `xs = 4.0` (minimal spacing)
  - [ ] `s = 8.0` (compact, card gaps)
  - [ ] `m = 12.0` (section gaps, card padding)
  - [ ] `l = 16.0` (form field padding, button gaps)
  - [ ] `xl = 20.0` (NewRecord screen padding)
  - [ ] `xxl = 24.0` (CSV screen padding - most generous)

- [ ] Semantic spacing (use-case specific):
  - [ ] `screenPadding = EdgeInsets.all(xl)` (20px - default)
  - [ ] `screenPaddingGenerous = EdgeInsets.all(xxl)` (24px - CSV style)
  - [ ] `formFieldPadding = EdgeInsets.symmetric(h: l, v: m)` (16/12)
  - [ ] `containerPadding = EdgeInsets.all(l)` (16px - internal)
  - [ ] `cardPadding = EdgeInsets.all(m)` (12px)
  - [ ] `buttonPadding = EdgeInsets.symmetric(v: 14, h: 20)` (from NewRecord)

- [ ] Gap widgets (for Column/Row):
  - [ ] `smallGap = SizedBox(height: m)` (12px)
  - [ ] `mediumGap = SizedBox(height: l)` (16px)
  - [ ] `largeGap = SizedBox(height: xxl)` (24px)
  - [ ] `buttonGap = SizedBox(width: l)` (16px horizontal)

**APP_DESIGN_FEEL.md references:**
- Line 872: "Consistent spacing across app" (priority 9/10)
- Line 183-184: ParticipantReg "edge-to-edge, spills whole screen" (DISLIKE)
- Line 382: IntakeForm "too much space on sides" (DISLIKE)
- Line 697: "more whitespace (too cramped)"

**Critical:** Fix ParticipantRegistrationForm from 0px → 20px padding

---

### ⬜ 1.3 Create `lib/core/constants/app_typography.dart`

**Reference:** SCREEN_ANALYSIS.md - Font sizes section, actual code from NewRecord + AppDrawer

**Must include:**
- [ ] Font family:
  - [ ] `fontFamily = 'Roboto'` (supports Czech diacritics)

- [ ] TextTheme with actual sizes from code:
  - [ ] `displayLarge: 28px` (rarely used)
  - [ ] `displayMedium: 24px`
  - [ ] `displaySmall: 20px`
  - [ ] `headlineLarge: 18px`
  - [ ] `headlineMedium: 16px`
  - [ ] `headlineSmall: 15px`
  - [ ] `titleLarge: 16px`
  - [ ] `titleMedium: 15px` ← **Form title fields** (NewRecord)
  - [ ] `titleSmall: 13px` ← **Section headers** (AppDrawer)
  - [ ] `bodyLarge: 15px` ← **CSV labels**
  - [ ] `bodyMedium: 14px` ← **Main body text** (NewRecord)
  - [ ] `bodySmall: 12px` ← **Small labels**
  - [ ] `labelLarge: 14px` ← **Button text**
  - [ ] `labelMedium: 12px`
  - [ ] `labelSmall: 11px` ← **Health chips** (NewRecord), **Menu subtitles** (AppDrawer)

- [ ] ALL text styles must include:
  - [ ] `locale: Locale('cs', 'CZ')` for Czech diacritics (ě, š, č, ř, ž...)

**APP_DESIGN_FEEL.md references:**
- Line 694: "Too large, decrease default size"
- Line 695: "Some screens well packed (CSV, NewRecord)" ← Use their sizes!

**IMPORTANT - Responsive Font Sizes:**
- Theme provides 15px default (NOT 14px) to avoid breaking responsive logic
- Screens that need responsive behavior override with: `isCompact ? 14 : 15`
- User chose 15px as desktop/tablet default, 14px for compact views
- Constants to add:
  - [ ] `bodyMediumSize = 15.0` (Desktop/tablet default)
  - [ ] `bodyMediumSizeCompact = 14.0` (Responsive override for screens)
  - [ ] `bodyMediumSizePhone = 14.0` (Phone-specific)

**Critical:** Body text is 14-15px (NOT 16px Material 3 default)

---

### ⬜ 1.4 Create `lib/core/constants/app_radii.dart`

**Reference:** SCREEN_ANALYSIS.md - Border radius section, NewRecord (12/8px) + CSV (12px)

**Must include:**
- [ ] Base values:
  - [ ] `small = 4.0` (minimal rounding)
  - [ ] `medium = 6.0`
  - [ ] `large = 8.0` ← **Form fields, buttons** (NewRecord)
  - [ ] `xl = 12.0` ← **Containers, cards** (NewRecord, CSV)

- [ ] Semantic radii:
  - [ ] `buttonRadius = BorderRadius.all(Radius.circular(large))` (8px)
  - [ ] `cardRadius = BorderRadius.all(Radius.circular(xl))` (12px)
  - [ ] `inputRadius = BorderRadius.all(Radius.circular(large))` (8px)
  - [ ] `containerRadius = BorderRadius.all(Radius.circular(xl))` (12px)

**Note:** 8-12px is **rounder** than Material 3 default (4px)

---

## 🎨 Phase 2: Create Theme Composition

### ⬜ 2.1 Create `lib/core/themes/app_theme.dart`

**Reference:** THEME_IMPLEMENTATION.md, actual patterns from CSV + NewRecord

**Must include:**

#### 2.1.1 Basic Configuration
- [ ] `useMaterial3: true`
- [ ] `colorScheme: AppColors.lightColorScheme`
- [ ] `textTheme: AppTypography.textTheme`
- [ ] `fontFamily: AppTypography.fontFamily`
- [ ] `visualDensity: VisualDensity.comfortable`

#### 2.1.2 Button Themes

**Reference:** APP_DESIGN_FEEL.md line 374 - IntakeForm buttons "LOVE the colors"

**IMPORTANT - Button Count Pattern (User's Simpler Solution):**
- **2 buttons:** Blue FilledButton (primary) + Grey OutlinedButton (secondary)
  - Example: NewRecord "Uložit" + "Zavřít"
  - User feedback: "Current actions great"
  - Theme handles automatically

- **3 buttons:** Green/Blue/Red ElevatedButtons (critical ternary choice)
  - Example: IntakeForm "uložit a přišel" (green) + "uložit" (blue) + "neukládat" (red)
  - User feedback: "**love** the main action button"
  - Manual styling (NOT in theme)
  - Reserve for critical choices only

**Why button count (not context)?**
- Simpler rule: just count buttons
- Objective: count is clear, "medical" vs "data" is subjective
- Matches actual patterns: IntakeForm = 3, NewRecord = 2
- Predictable: all 2-button screens look consistent

**User quote:** "for bigger actions next to each other its good to have vibrant like intake form, for small actions or single actions newest material standard is ok"

- [ ] **FilledButtonTheme (Default for 2-button pattern - Primary action):**
  - [ ] `backgroundColor: Colors.blue.shade600` (from NewRecord save button)
  - [ ] `foregroundColor: Colors.white`
  - [ ] `padding: EdgeInsets.symmetric(v: 14, h: 20)` (from actual code)
  - [ ] `minimumSize: Size(120, 48)`
  - [ ] `shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonRadius)` (8px)
  - [ ] `elevation: 2`
  - [ ] `textStyle: AppTypography.textTheme.labelLarge.copyWith(fontWeight: w600)`

- [ ] **3-Button Pattern (Manual styling - NOT in theme):**
  - [ ] IntakeForm keeps existing code unchanged
  - [ ] Button 1: `ElevatedButton.styleFrom(backgroundColor: Colors.green)` - "uložit a přišel"
  - [ ] Button 2: `ElevatedButton.styleFrom(backgroundColor: Colors.blue)` - "uložit"
  - [ ] Button 3: `ElevatedButton.styleFrom(backgroundColor: Colors.red)` - "neukládat"
  - [ ] Document in app_theme.dart comments: "3-button pattern is manual"

- [ ] **OutlinedButtonTheme:**
  - [ ] `foregroundColor: Colors.grey.shade700` (from NewRecord cancel)
  - [ ] `padding: EdgeInsets.symmetric(v: 14, h: 16)`
  - [ ] `minimumSize: Size(100, 48)`
  - [ ] `side: BorderSide(color: Colors.grey.shade400, width: 1.5)` (actual from code)
  - [ ] `shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonRadius)`

- [ ] **ElevatedButtonTheme:**
  - [ ] Configure for CSV import "Vybrat soubor" button style
  - [ ] `backgroundColor: AppColors.blueText` (blue.shade600)
  - [ ] `foregroundColor: Colors.white`

- [ ] **TextButtonTheme:**
  - [ ] For tertiary actions (less common)
  - [ ] `foregroundColor: AppColors.blueText`

**APP_DESIGN_FEEL.md reference:** Line 872 - "Consistent buttons across app" (priority 9/10)

#### 2.1.3 Form Field Theme

**Reference:** NewRecord form fields (blue.shade200 borders, 8px radius)

- [ ] **InputDecorationTheme:**
  - [ ] `border: OutlineInputBorder` with `AppColors.blueBorder` (blue.shade200), width 1.0
  - [ ] `enabledBorder:` same as border
  - [ ] `focusedBorder:` `Colors.blue.shade600`, width 2 (thicker when focused)
  - [ ] `errorBorder:` `Colors.red`, width 2
  - [ ] `focusedErrorBorder:` `Colors.red`, width 2
  - [ ] `disabledBorder:` `AppColors.greyBorder`
  - [ ] `borderRadius: AppRadii.inputRadius` (8px) for ALL border types
  - [ ] `contentPadding: EdgeInsets.all(AppSpacing.l)` (16px)
  - [ ] `filled: true`
  - [ ] `fillColor: Colors.white`
  - [ ] Label styles with Czech locale
  - [ ] Error style fontSize: 11px, height: 0.8

**APP_DESIGN_FEEL.md reference:** Line 678 - "minimalistic approach to form field borders"

#### 2.1.4 Card Theme
- [ ] `elevation: 1`
- [ ] `shadowColor: Colors.black.withOpacity(0.1)`
- [ ] `margin: EdgeInsets.only(bottom: AppSpacing.s)` (8px)
- [ ] `shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius)` (12px)
- [ ] `clipBehavior: Clip.antiAlias`

#### 2.1.5 AppBar Theme
- [ ] `centerTitle: false`
- [ ] `elevation: 0`
- [ ] `scrolledUnderElevation: 2`
- [ ] `backgroundColor: Colors.blue` (primary)
- [ ] `foregroundColor: Colors.white`
- [ ] `titleTextStyle: AppTypography.textTheme.titleLarge.copyWith(color: white, fontSize: 18)`
- [ ] `iconTheme: IconThemeData(color: Colors.white)`

#### 2.1.6 ListTile Theme
- [ ] `contentPadding: AppSpacing.listItemPadding`
- [ ] `minVerticalPadding: AppSpacing.s`
- [ ] `shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius)`

#### 2.1.7 Scaffold Theme
- [ ] `scaffoldBackgroundColor: AppColors.lightColorScheme.background` (#FAFAFA)

#### 2.1.8 Divider Theme
- [ ] `color: AppColors.greyBorderDark`
- [ ] `thickness: 1`
- [ ] `space: AppSpacing.m` (12px)

#### 2.1.9 Dialog Theme
- [ ] `backgroundColor: Colors.white`
- [ ] `elevation: 6`
- [ ] `shape: RoundedRectangleBorder(borderRadius: AppRadii.containerRadius)` (12px)
- [ ] Title and content text styles

#### 2.1.10 SnackBar Theme
- [ ] `behavior: SnackBarBehavior.floating`
- [ ] `backgroundColor: Colors.grey.shade800`
- [ ] `contentTextStyle: AppTypography.textTheme.bodyMedium.copyWith(color: white)`
- [ ] `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))`

#### 2.1.11 DataTable Theme (CSV)
- [ ] `headingTextStyle: AppTypography.textTheme.labelLarge`
- [ ] `dataTextStyle: AppTypography.textTheme.bodyMedium`
- [ ] `columnSpacing: AppSpacing.xxl` (24px)
- [ ] `horizontalMargin: AppSpacing.l` (16px)

---

## 🔧 Phase 3: Integration

### ⬜ 3.1 Update main.dart
- [ ] Import `AppTheme` from `lib/core/themes/app_theme.dart`
- [ ] Set `theme: AppTheme.lightTheme` in MaterialApp
- [ ] Verify Czech locale configuration:
  - [ ] `locale: const Locale('cs', 'CZ')`
  - [ ] `supportedLocales: [Locale('cs', 'CZ')]`
  - [ ] All localization delegates imported

### ⬜ 3.2 Test Theme Application
- [ ] Run app and verify no errors
- [ ] Check FilledButton renders with blue.shade600
- [ ] Check OutlinedButton renders with grey borders
- [ ] Check TextFormField has blue.shade200 borders
- [ ] Check Czech diacritics render correctly (ě, š, č, ř, ž, ý, á, í, é, ú, ů, ď, ť, ň)
- [ ] Check spacing looks better (not edge-to-edge)

---

## 🛠️ Phase 4: Fix Critical Screen Issues

### ⬜ 4.1 ParticipantRegistrationForm - Add Padding

**Priority:** CRITICAL
**Reference:** APP_DESIGN_FEEL.md lines 183-184, SCREEN_ANALYSIS.md

**File:** `lib/screens2/participant_registration_form.dart`

- [ ] Wrap entire Form in Padding widget
- [ ] Use `padding: AppSpacing.screenPadding` (20px) or `screenPaddingGenerous` (24px)
- [ ] Test on desktop (should not be edge-to-edge)
- [ ] Test on mobile (should have breathing room)
- [ ] Verify 3-column → 1-column responsive still works

**User quote:** "Completely edge to edge [on horizontal] — spills to take whole screen"

---

### ⬜ 4.2 EventList - Add Padding

**Priority:** HIGH
**Reference:** SCREEN_ANALYSIS.md

**File:** `lib/screens2/event_list.dart`

- [ ] Wrap ListView.builder in Padding
- [ ] Use `padding: AppSpacing.screenPadding` (20px)
- [ ] Fix toast stacking issue (batch multiple pin changes)
- [ ] Consider using themed ListTile or custom component

---

### ⬜ 4.3 EventRegistrationForm - Increase Padding

**Priority:** HIGH
**Reference:** APP_DESIGN_FEEL.md line 341, LINE_BY_LINE_VERIFICATION.md Gap #1

**File:** `lib/screens2/event_registration_form.dart`

**Current state:** Line 100 has `EdgeInsets.all(16.0)` - not enough

- [ ] Change `EdgeInsets.all(16.0)` → `AppSpacing.screenPadding` (20px)
- [ ] Test on desktop (should not stretch full width)
- [ ] Verify form still creates events correctly

**User quote:** "streches full width of screen -- no margins"

**Note:** This was identified as a gap during line-by-line verification - form currently has 16px padding but needs 20-24px

---

### ⬜ 4.4 EventDetail - Verify Padding (Likely OK)

**Priority:** LOW
**Reference:** APP_DESIGN_FEEL.md line 304, LINE_BY_LINE_VERIFICATION.md Gap #2

**File:** `lib/screens2/event_detail.dart`

**Current state:** Line 107 has `EdgeInsets.all(20.0)` - already correct!

- [ ] Verify visual spacing looks good on desktop
- [ ] Replace hardcoded `EdgeInsets.all(20.0)` → `AppSpacing.screenPadding`
- [ ] Verify participant list items have proper spacing
- [ ] Test that search and filters still work correctly

**User quote:** "spacing from side of screens feels off"

**Note:** This was identified as a gap during line-by-line verification, but code inspection shows it already has 20px padding. May just need visual verification.

---

### ⬜ 4.5 ParticipantListScreen - Fix Search & Clickability

**Priority:** HIGH
**Reference:** APP_DESIGN_FEEL.md lines 135-139, SCREEN_ANALYSIS.md

**File:** `lib/screens2/participant_list_screen.dart`

- [ ] Fix search behavior (should filter list directly, not use dropdown)
- [ ] Make entire list item clickable (not just "Detail" button)
- [ ] Ensure user can return to full list after searching
- [ ] Consider removing separate "Detail" button if whole item is clickable

**User feedback:** "Search feels broken", "List items should be clickable"

---

### ⬜ 4.6 IntakeForm - Add Inline Participant Creation

**Priority:** CRITICAL (HUGE MISS)
**Reference:** APP_DESIGN_FEEL.md line 389, FIXME.md #1

**File:** `lib/screens2/intake_form_improved.dart`

- [ ] Add "+ Create New Participant" option to PersonAutocomplete
- [ ] Open participant creation dialog/modal inline
- [ ] Auto-select newly created participant
- [ ] User never leaves intake flow

**User feedback:** "No way to create participant from selector - must EXIT form, create, come back"

---

### ⬜ 4.7 IntakeForm - Add Arrived Counter

**Priority:** CRITICAL (HUGE MISS)
**Reference:** APP_DESIGN_FEEL.md line 390, FIXME.md #2

**File:** `lib/screens2/intake_form_improved.dart`

- [ ] Add counter widget at top showing: "23/56 arrived"
- [ ] Update in real-time as participants marked
- [ ] Use theme colors for styling

**User feedback:** "No arrived counter (23/56 arrived)"

---

## 📝 Phase 5: Apply Theme Consistently Across Screens

### ⬜ 5.1 Replace Hardcoded Colors

**Priority:** HIGH
**Reference:** APP_DESIGN_FEEL.md line 872 (priority 9/10)

**Screens to update:**
- [ ] NewRecordPage - replace `Colors.blue.shade200` with `AppColors.blueBorder`
- [ ] CSV screens - replace hardcoded colors with AppColors
- [ ] AppDrawer - replace `Colors.orange.shade100` with `AppColors.orangeBackground`
- [ ] All screens - use `Theme.of(context).colorScheme.*` instead of hardcoded

**Pattern:**
```dart
// Before:
color: Colors.blue.shade200

// After:
color: AppColors.blueBorder
// OR
color: Theme.of(context).colorScheme.outline
```

---

### ⬜ 5.2 Replace Hardcoded Spacing

**Priority:** HIGH

**All screens:**
- [ ] Replace `EdgeInsets.all(20)` → `AppSpacing.screenPadding`
- [ ] Replace `EdgeInsets.all(16)` → `AppSpacing.containerPadding`
- [ ] Replace `SizedBox(height: 24)` → `AppSpacing.largeGap`
- [ ] Replace `SizedBox(height: 12)` → `AppSpacing.smallGap`
- [ ] Replace `SizedBox(width: 16)` → `AppSpacing.buttonGap`

---

### ⬜ 5.3 Replace Button Types

**Priority:** MEDIUM
**Reference:** APP_DESIGN_FEEL.md line 872, IntakeForm "LOVE buttons"

**Pattern:**
- [ ] **Primary actions:** Use `FilledButton` (auto-themed)
- [ ] **Secondary actions:** Use `OutlinedButton` (auto-themed)
- [ ] **Tertiary actions:** Use `TextButton` (auto-themed)

**Files to update:**
- [ ] ParticipantRegistrationForm - change ElevatedButton → FilledButton
- [ ] EventList - theme IconButtons
- [ ] All screens - verify button consistency

---

### ⬜ 5.4 Replace Border Radius

**Priority:** MEDIUM

**All screens:**
- [ ] Replace `BorderRadius.circular(12)` → `AppRadii.containerRadius`
- [ ] Replace `BorderRadius.circular(8)` → `AppRadii.inputRadius` or `buttonRadius`
- [ ] Ensure consistency across all Container/Card widgets

---

### ⬜ 5.5 Fix Empty State Hardcoded Colors

**Priority:** MEDIUM
**Reference:** LINE_BY_LINE_VERIFICATION.md Gap #3

**Files to update:**
- [ ] `participant_list_screen.dart` - Empty state icons and text
- [ ] `event_list.dart` - Empty state (if applicable)
- [ ] Any other screens with empty states

**Pattern to replace:**
```dart
// Before:
Icon(Icons.people_outline, size: 48, color: Colors.grey)
Text('Žádní účastníci', style: TextStyle(fontSize: 18, color: Colors.grey))

// After:
Icon(Icons.people_outline,
  size: 48,
  color: Theme.of(context).colorScheme.onSurfaceVariant)
Text('Žádní účastníci',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant))
```

**Note:** This was identified as a gap during line-by-line verification

---

## ✅ Phase 6: Testing & Verification

### ⬜ 6.1 Visual Testing

**Test all screens:**
- [ ] EventList - padding visible, no edge-to-edge
- [ ] ParticipantListScreen - search works, items clickable
- [ ] ParticipantRegistrationForm - 20-24px padding, not cramped
- [ ] IntakeFormImproved - inline creation works, counter visible
- [ ] NewRecordPage - maintains current good design
- [ ] CSV import - maintains current good design
- [ ] AppDrawer - maintains current good design

### ⬜ 6.2 Consistency Testing

**Cross-screen checks:**
- [ ] All screens use same padding (20-24px)
- [ ] All buttons styled consistently
- [ ] All form fields have same borders (blue.shade200)
- [ ] All font sizes match theme (13-15px body)
- [ ] All colors from theme (no hardcoded Colors.blue)

### ⬜ 6.3 Responsive Testing

**Test at different widths:**
- [ ] 375px (mobile) - Forms stack to 1 column
- [ ] 768px (tablet) - Forms adapt
- [ ] 1440px (desktop) - Forms use 3 columns (where applicable)
- [ ] No horizontal overflow at any width
- [ ] Padding visible at all widths

### ⬜ 6.4 Czech Localization Testing

**Verify diacritics:**
- [ ] ě, š, č, ř, ž render correctly
- [ ] ý, á, í, é, ú render correctly
- [ ] ů, ď, ť, ň render correctly
- [ ] Date formats use cs_CZ (dd.MM.yyyy)
- [ ] All TextStyles have `locale: Locale('cs', 'CZ')`

### ⬜ 6.5 User Acceptance Testing

**Reference APP_DESIGN_FEEL.md:**
- [ ] CSV import flow still feels good (line 424)
- [ ] NewRecord page still feels themed (line 232)
- [ ] IntakeForm buttons still loved (line 374)
- [ ] No edge-to-edge forms (line 183-184)
- [ ] More whitespace, not cramped (line 697)
- [ ] Font sizes feel appropriate (line 694)

---

## 📚 Documentation Updates

### ⬜ 7.1 Update THEME_IMPLEMENTATION.md
- [ ] Change file paths from `lib/design_system/` → `lib/core/`
- [ ] Update to reflect actual implemented structure
- [ ] Add "implemented" badges to completed sections

### ⬜ 7.2 Create Usage Examples
- [ ] Document how to use AppSpacing constants
- [ ] Document how to use AppColors constants
- [ ] Document button type selection guide
- [ ] Create widget templates for common patterns

### ⬜ 7.3 Update UI_AUDIT_DOCUMENTATION.md
- [ ] Mark fixed issues as resolved
- [ ] Update with new theme references
- [ ] Add "After Theme" screenshots/notes

---

## 🎯 Success Criteria

**Theme implementation is complete when:**

### Must-Have (Blocking):
- [ ] All 4 constant files created (colors, spacing, typography, radii)
- [ ] AppTheme created with all component themes
- [ ] main.dart integrated with theme
- [ ] ParticipantRegistrationForm has padding (NOT edge-to-edge)
- [ ] All HUGE MISSES from FIXME.md addressed
- [ ] No hardcoded `Colors.blue.shade*` in UI code
- [ ] All screens tested on mobile + desktop

### Should-Have (Important):
- [ ] All screens use themed buttons (FilledButton, OutlinedButton)
- [ ] All screens use AppSpacing constants
- [ ] Czech diacritics render correctly everywhere
- [ ] Responsive design works (375px, 768px, 1440px)

### Nice-to-Have (Polish):
- [ ] Dark theme created (optional for v2)
- [ ] Usage documentation complete
- [ ] Before/after screenshots
- [ ] Performance benchmarks

---

## 🚫 What NOT to Change

**From APP_DESIGN_FEEL.md (lines 848-862):**

### Do NOT:
- [ ] ❌ Move buttons around
- [ ] ❌ Remove or reorder form fields
- [ ] ❌ Change navigation structure
- [ ] ❌ Change offline support
- [ ] ❌ Remove any existing functionality
- [ ] ❌ Change field count on any form

### Only Change:
- [ ] ✅ Spacing (add padding where missing)
- [ ] ✅ Colors (make consistent)
- [ ] ✅ Buttons (make consistent styling)
- [ ] ✅ Typography (smaller, consistent)
- [ ] ✅ Fix broken features (search, clickability)

---

## 📞 When to Ask User

**Stop and ask if:**
- [ ] Not sure which button type to use for a specific action
- [ ] Unsure about spacing amount for a specific screen
- [ ] Conflicting preferences found in APP_DESIGN_FEEL.md
- [ ] Need to change functionality to fix UX (e.g., search behavior)
- [ ] Dark theme is needed or just light theme
- [ ] Any FIXME.md item requires significant architecture change

---

**Created:** 2025-11-15
**Last Updated:** 2025-11-15
**Est. Implementation Time:** 8-12 hours
**Priority:** HIGH (User priority 9/10 for consistency)

**Next Steps:**
1. Create `lib/core/` folder structure
2. Start with Phase 1 (constants)
3. Test each constant file as created
4. Proceed to Phase 2 (theme composition)
5. Fix critical screens in Phase 4
6. Apply consistently in Phase 5
