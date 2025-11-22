# Deep Investigation: Hidden Issues & Misunderstandings

**CRITICAL PRE-IMPLEMENTATION ANALYSIS**

**Purpose:** Find ANYTHING that might cause problems later or create misunderstandings

**Investigation Date:** 2025-11-15
**Status:** 🔴 **CRITICAL ISSUES FOUND** - Must address before implementation

---

## 🚨 CRITICAL ISSUES FOUND

### 🔴 ISSUE #1: Button Color Scheme Confusion

**Problem:** Conflicting requirements for button colors

**Evidence:**
1. **APP_DESIGN_FEEL.md line 674:**
   - "love the butttons from intake form <-- those should stand as example for rest of app"

2. **APP_DESIGN_FEEL.md lines 681-682:**
   - "for bigger actions next to each other its good to have vibrant like intake form"
   - "for small actions or single actions newest material standard is ok"

3. **IntakeForm actual code:**
   - Primary: GREEN ("uložit a přišel")
   - Secondary: BLUE ("uložit")
   - Tertiary: RED ("neukládat")

4. **NewRecord actual code:**
   - Primary: BLUE (FilledButton "Uložit")
   - Secondary: GREY outline (OutlinedButton "Zavřít")

**Current THEME_CHECKLIST.md assumption:**
```dart
filledButtonTheme: FilledButtonThemeData(
  style: FilledButton.styleFrom(
    backgroundColor: Colors.blue.shade600,  // ❌ WRONG
  ),
),
```

**What user ACTUALLY wants:**
- **Big actions** (multiple buttons together): Vibrant colors (GREEN primary, BLUE secondary, RED tertiary)
- **Small/single actions**: Material standard (BLUE)

**RESOLUTION NEEDED:**
User must clarify:
1. Do you want GREEN or BLUE for FilledButton theme default?
2. Or do you want NO global theme (each screen chooses)?
3. Or do you want two button styles (vibrant vs standard)?

**Impact:** HIGH - Affects all buttons across entire app

---

### 🔴 ISSUE #2: Responsive Font Sizes - TWO Different Systems

**Problem:** App uses BOTH vertical compact AND horizontal responsive sizing

**Evidence:**

**System 1: Vertical Compact** (new_record_page.dart:744)
```dart
final isCompact = constraints.maxHeight <= 600;  // SHORT screens
fontSize: isCompact ? 14 : 15,
```

**System 2: Horizontal Width** (Various files)
```dart
BoxConstraints(maxWidth: 1600)  // IntakeForm
BoxConstraints(maxWidth: 800)   // ParticipantEditPage
if (constraints.maxWidth < 600) { ... }  // Grid responsive
```

**THEME_CHECKLIST.md assumption:**
```dart
bodyMedium: TextStyle(fontSize: 14),  // ❌ ALWAYS 14px
```

**What user wants:**
- "some screens already pretty well packed csv; new record page" (line 695)
- NewRecord uses 14-15px depending on vertical space
- Theme should SUPPORT existing responsive logic, not override it

**MISUNDERSTANDING:**
Theme constant `fontSize: 14` will OVERRIDE existing responsive `isCompact ? 14 : 15` logic!

**RESOLUTION NEEDED:**

**Option A:** Theme uses 15px default, screens use `.copyWith(fontSize: isCompact ? 14 : 15)`
```dart
// In theme
bodyMedium: TextStyle(fontSize: 15),  // Default

// In NewRecord (keeps existing logic)
Text(
  ...,
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    fontSize: isCompact ? 14 : 15,
  ),
)
```

**Option B:** Create two text styles (compact and regular)
```dart
// In theme
bodyMedium: TextStyle(fontSize: 15),       // Regular
bodyMediumCompact: TextStyle(fontSize: 14), // Compact (via ThemeExtension)
```

**Option C:** Don't use theme for responsive text (keep manual control)

**User requested:** "on phones lets have separate value to be sure but for now fill it with 14px also"

**CORRECT IMPLEMENTATION:**
```dart
// lib/core/constants/app_typography.dart
class AppTypography {
  // Desktop/tablet default
  static const double bodyMediumSize = 15.0;

  // Phone/compact default
  static const double bodyMediumSizeCompact = 14.0;

  // Vertical compact (short screens)
  static const double bodyMediumSizeVerticalCompact = 14.0;

  static TextTheme textTheme = TextTheme(
    bodyMedium: TextStyle(
      fontSize: bodyMediumSize,  // 15px default
      // Screens override with: isCompact ? 14 : 15
    ),
  );
}
```

**Impact:** HIGH - Affects readability and responsive behavior

---

### 🔴 ISSUE #3: Spacing Conflicts - Edge Cases Not Covered

**Problem:** Theme assumes all screens need same padding, but some screens have special needs

**Evidence:**

**IntakeForm** (intake_form_improved.dart:122):
```dart
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 1600),  // Max width limit
  child: Column(...),  // NO EdgeInsets.all() wrapper
)
```

**ParticipantEditPage** (participant_edit_page.dart:91):
```dart
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 800),   // Max width limit
  child: Padding(...),
)
```

**CSV Table** (table_overview_screen.dart):
```dart
// Horizontal scrolling table - NEEDS edge-to-edge for scroll bar
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: DataTable(...),  // Padding would break scrolling
)
```

**THEME_CHECKLIST.md assumption:**
```
Phase 4.1: ParticipantRegistrationForm - Add padding
Phase 4.2: EventList - Add padding
```

**MISUNDERSTANDING:**
Some screens INTENTIONALLY have no padding because:
1. They use max width constraints (center content, don't need side padding)
2. They have horizontal scrolling (padding breaks scroll bar)
3. They use internal padding on child widgets

**RESOLUTION NEEDED:**

**Screens that NEED padding added:**
- ✅ ParticipantRegistrationForm (0px → 20px)
- ✅ EventList (0px → 20px)

**Screens that DON'T need padding (already handled):**
- ❌ IntakeForm (uses maxWidth: 1600 constraint)
- ❌ CSV Table (horizontal scroll needs edge-to-edge)
- ❌ NewRecord (already has 20px padding)

**Action:** Update THEME_CHECKLIST.md to clarify which screens get padding

**Impact:** MEDIUM - Could break horizontal scrolling or duplicate padding

---

### ⚠️ ISSUE #4: Czech Locale - Incomplete Specification

**Problem:** `locale: Locale('cs', 'CZ')` in TextStyle may conflict with DateFormat

**Evidence:**

**THEME_CHECKLIST.md:**
```dart
bodyMedium: TextStyle(
  fontSize: 14,
  locale: Locale('cs', 'CZ'),  // ✅ Good for diacritics
),
```

**Existing code** (event_list.dart:94):
```dart
final dateFormat = DateFormat('dd.MM.yyyy', 'cs_CZ');  // Uses 'cs_CZ' string
```

**MISUNDERSTANDING:**
- TextStyle uses `Locale('cs', 'CZ')` (object)
- DateFormat uses `'cs_CZ'` (string)
- Both are correct but inconsistent notation

**Also missing:**
- Number formatting locale (1.234,56 vs 1,234.56)
- Currency formatting (not used yet, but future)
- Collation/sorting for Czech (ř comes after r, not separate)

**RESOLUTION NEEDED:**

**Phase 1:** Set app-wide locale in main.dart (already planned)
```dart
MaterialApp(
  locale: const Locale('cs', 'CZ'),  // ✅ Already in checklist
  ...
)
```

**Phase 2:** Verify all DateFormat uses 'cs_CZ' string
**Phase 3:** Document Czech-specific formatting rules

**Impact:** LOW - Current implementation works, but document for future

---

### ⚠️ ISSUE #5: Form Field Borders - Responsive Border Width Not Specified

**Problem:** NewRecord uses responsive border width, theme doesn't

**Evidence:**

**NewRecord actual code** (inferred from design):
```dart
enabledBorder: OutlineInputBorder(
  borderSide: BorderSide(
    color: Colors.blue.shade200,
    width: 1.0,  // Thin border
  ),
),
focusedBorder: OutlineInputBorder(
  borderSide: BorderSide(
    color: Colors.blue.shade600,
    width: 2.0,  // Thicker when focused
  ),
),
```

**THEME_CHECKLIST.md:**
```dart
enabledBorder: OutlineInputBorder(
  borderSide: BorderSide(
    color: AppColors.blueBorder,
    width: 1.0,  // ✅ Specified
  ),
),
focusedBorder: OutlineInputBorder(
  borderSide: BorderSide(
    color: Colors.blue.shade600,
    width: 2,  // ✅ Specified
  ),
),
```

**Good news:** THEME_CHECKLIST already correct!

**But missing:** Mobile border width consideration
- Desktop/tablet: 1px/2px works well
- Phone touch: May need thicker borders for visibility (1.5px/2.5px?)

**User requested:** "on phones lets have separate value to be sure"

**RESOLUTION NEEDED:**

**Option A:** Keep same border width (1px/2px) on all devices
- Pro: Consistent
- Con: May be hard to see on small screens

**Option B:** Responsive border width
```dart
final borderWidth = MediaQuery.of(context).size.width < 600 ? 1.5 : 1.0;
```
- Pro: Better visibility on phones
- Con: More complex

**Recommendation:** Start with Option A (consistent), only add Option B if user reports visibility issues

**Impact:** LOW - Border width unlikely to cause major issues

---

### ⚠️ ISSUE #6: AppDrawer - Disabled State Tooltip Missing

**Problem:** User wants tooltips on disabled menu items, not in theme scope

**Evidence:**

**APP_DESIGN_FEEL.md line 641:**
- "disable elements should have some explanation tooltip on hover or click (somewhere in app already used -- can be reused)"

**Current AppDrawer** (app_drawer.dart:237-250):
```dart
subtitle: !hasEvent
    ? Row(
        children: [
          Icon(Icons.warning_amber, size: 16, color: Colors.orange.shade700),
          Text('Vytvořte akci nejdříve', style: TextStyle(fontSize: 11)),
        ],
      )
    : null,
```

**MISUNDERSTANDING:**
- User wants TOOLTIP (on hover/click)
- Current implementation: Subtitle text (always visible)
- Theme checklist: Doesn't address this

**RESOLUTION NEEDED:**

**This is NOT a theme issue** - This is a functional enhancement

**Action:** Move to FIXME.md as enhancement (not theme work)

**Correct implementation:**
```dart
Tooltip(
  message: 'Vytvořte akci nejdříve. Akci vytvoříte v "Nová akce".',
  child: ListTile(
    enabled: false,
    ...
  ),
)
```

**Impact:** LOW - Not blocking theme implementation, separate task

---

### ⚠️ ISSUE #7: Padding Values - Inconsistent Across Platforms?

**Problem:** Material Design suggests different padding for different platforms

**Evidence:**

**Material Design 2025 guidelines:**
- Desktop: 24-32dp recommended side padding
- Tablet: 16-24dp recommended
- Phone: 16dp recommended

**Our theme:**
```dart
static const double xl = 20.0;       // NewRecord page padding
static const double xxl = 24.0;      // CSV import padding
```

**User wants:** Consistent spacing (priority 9/10)

**CONFLICT:**
- Material Design: Adaptive padding (24dp desktop, 16dp phone)
- User wants: Consistent (same on all devices)

**Current THEME_CHECKLIST.md:**
- Uses `AppSpacing.screenPadding` (20px) everywhere

**RESOLUTION NEEDED:**

**Option A:** Platform-adaptive padding
```dart
static EdgeInsets get screenPadding {
  // Responsive padding
  return EdgeInsets.all(
    Platform.isAndroid || Platform.isIOS ? 16.0 : 20.0,
  );
}
```

**Option B:** Consistent padding (user preference)
```dart
static const EdgeInsets screenPadding = EdgeInsets.all(20.0);  // Same everywhere
```

**User explicitly said:** "APP UI CONSISTENCY ACROSS THE APP" (line 872)

**Recommendation:** Option B (consistent 20px everywhere)

**BUT:** Phone content area concern
- 375px - 40px = 335px (89% of width)
- May need more scrolling
- User said "not recommended" for phones anyway

**Final decision:** Use 20px everywhere (consistency priority)

**Impact:** LOW - User priority is consistency, not platform conventions

---

### ⚠️ ISSUE #8: Dark Theme - Future Breaking Change Risk

**Problem:** Theme hardcodes light colors, dark theme later will require refactor

**Evidence:**

**THEME_CHECKLIST.md:**
```dart
class AppColors {
  static final Color blueBackground = Colors.blue.shade50;  // Light theme only
  static final ColorScheme lightColorScheme = ColorScheme.light(...);
}
```

**No dark theme defined**

**Risk:** If dark theme needed later:
1. Can't just add `darkColorScheme` - colors are hardcoded for light
2. Would need to refactor ALL color constants to have light/dark versions
3. Potentially breaking changes to existing code

**RESOLUTION NEEDED:**

**Option A:** Future-proof now
```dart
class AppColors {
  // Light theme colors
  static final Color lightBlueBackground = Colors.blue.shade50;
  static final Color lightBlueBorder = Colors.blue.shade200;

  // Dark theme colors (even if not used yet)
  static final Color darkBlueBackground = Colors.blue.shade900;
  static final Color darkBlueBorder = Colors.blue.shade700;

  // Semantic getters (adapt to theme)
  static Color blueBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBlueBackground
        : lightBlueBackground;
  }
}
```

**Option B:** Simple now, refactor later
```dart
class AppColors {
  static final Color blueBackground = Colors.blue.shade50;  // Light only
  // If dark theme needed: add new class AppColorsDark
}
```

**User hasn't requested dark theme**

**Recommendation:** Option B (simple now)
- User preference: "Keep current" background colors (line 667)
- No dark theme mentioned
- Can refactor later if needed

**Impact:** LOW - No dark theme required, but document as future work

---

### ⚠️ ISSUE #9: Responsive Breakpoints - Gap Between Medium and Expanded

**Problem:** Unclear behavior at exactly 840dp (Material Design breakpoint boundary)

**Evidence:**

**Material Design breakpoints:**
- Medium: 600-839dp (8 columns)
- Expanded: 840dp+ (12 columns)

**What happens at EXACTLY 840dp?**
- Is it Medium or Expanded?
- Material Design doesn't specify

**Existing code** (participant_registration_form.dart):
```dart
if (constraints.maxWidth > 1200)  // 3 columns
  _buildThreeColumnRow(...)
else if (constraints.maxWidth > 600)  // 2 columns
  _buildTwoColumnRow(...)
else  // 1 column
  _buildSingleColumn(...),
```

**Uses > 600, not >= 600**
- At exactly 600px: Uses 1 column (mobile)
- At 601px: Uses 2 columns (tablet)

**Edge case:** Device with exactly 840px width
- iPad Air (landscape): 1180px ✅ No issue
- Small laptop: 1366px ✅ No issue
- Odd resolution: 840px ⚠️ Unclear

**RESOLUTION NEEDED:**

**Standard practice:** Use >= for upper bound
```dart
if (width >= 840) { /* Expanded */ }
else if (width >= 600) { /* Medium */ }
else { /* Compact */ }
```

**Theme doesn't directly affect this** - It's in widget layout logic

**Action:** Document recommended breakpoint checks for consistency

**Impact:** VERY LOW - Unlikely anyone has exactly 840px screen

---

### ⚠️ ISSUE #10: Button Sizes - No Touch Target Verification on Real Devices

**Problem:** Theme assumes 48px minimum, but not verified on actual tablets/phones

**Evidence:**

**THEME_CHECKLIST.md:**
```dart
minimumSize: Size(120, 48),  // Assumes 48px height sufficient
```

**Material Design guidelines:**
- Minimum touch target: 48x48dp
- Recommended: 48x48dp (phones), 40x40dp (desktop with mouse)

**Our theme:** 48px height ✅

**BUT:** No verification on real devices
- Different screen densities (1x, 2x, 3x)
- Different user finger sizes
- Different platforms (iOS vs Android touch sizing)

**User's devices:**
- Notebooks (mouse/trackpad): 48px MORE than enough ✅
- Tablets: 48px should be fine ✅ (standard)
- Phones: 48px should be fine ✅ (standard)

**RESOLUTION NEEDED:**

**Action:** Test on real tablet/phone after implementation
- Verify buttons are tappable
- Verify no accidental taps on adjacent buttons

**Mitigation:** If too small, increase to 56px
```dart
minimumSize: Size(120, 56),  // Larger touch target
```

**Impact:** LOW - 48px is standard, but test to be sure

---

## ⚠️ MODERATE CONCERNS

### ⚠️ CONCERN #11: Form Field Content Padding - May Cause Text Cutoff

**Problem:** `contentPadding: EdgeInsets.all(16)` may cut off descenders on small fonts

**Evidence:**

**THEME_CHECKLIST.md:**
```dart
contentPadding: EdgeInsets.all(AppSpacing.l),  // 16px all sides
```

**Font size:** 14px body text

**Typography metrics:**
- 14px font has descenders (g, j, p, q, y) that extend ~3px below baseline
- With 16px padding, descenders may be cut off if TextFormField height is constrained

**Existing code** (new_record_page.dart):
```dart
contentPadding: EdgeInsets.all(isCompact ? 12 : 16),
```

**Already uses responsive padding!**

**RESOLUTION NEEDED:**

**Verify:** Text doesn't get cut off in TextFormFields
- Test with "ggjjppqqyy" text
- Check on different screen sizes

**If cut off:** Increase vertical padding
```dart
contentPadding: EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 18,  // Extra vertical space for descenders
),
```

**Impact:** LOW - Unlikely with 16px padding, but test

---

### ⚠️ CONCERN #12: Card Elevation - Accessibility Contrast

**Problem:** Card elevation: 1 may not have enough contrast on white background

**Evidence:**

**THEME_CHECKLIST.md:**
```dart
cardTheme: CardTheme(
  elevation: 1,
  shadowColor: Colors.black.withOpacity(0.1),
),
```

**Elevation: 1 creates very subtle shadow**
- May be invisible on some screens
- Accessibility issue for low vision users

**Material Design recommendation:**
- Elevation 0: Flush with surface
- Elevation 1: Slightly raised (subtle)
- Elevation 2: Clearly raised

**CSV summary cards** (from actual code):
```dart
Card(
  margin: const EdgeInsets.only(bottom: 8),
  elevation: 1,  // Uses elevation: 1 (current practice)
)
```

**RESOLUTION NEEDED:**

**Option A:** Keep elevation: 1 (minimal shadow)
- Pro: Clean, minimalist look
- Con: May not be visible to everyone

**Option B:** Increase to elevation: 2
- Pro: More visible separation
- Con: May feel too "heavy"

**Option C:** Add border instead of relying on shadow
```dart
shape: RoundedRectangleBorder(
  borderRadius: AppRadii.cardRadius,
  side: BorderSide(
    color: Colors.grey.shade200,
    width: 1,
  ),
),
```

**Recommendation:** Test elevation: 1 first, increase if not visible

**Impact:** LOW - Aesthetic choice, not functional

---

### ⚠️ CONCERN #13: Z-Index / Stacking - AppBar vs Dialogs

**Problem:** No explicit z-index defined, may cause stacking issues

**Evidence:**

**THEME_CHECKLIST.md sets:**
- AppBar elevation: 0 (scrolledUnderElevation: 2)
- Dialog elevation: 6
- SnackBar: floating
- Card elevation: 1

**Potential conflict:** If scrolling under AppBar, what happens?
- scrolledUnderElevation: 2 means AppBar gets elevation when scrolled
- But cards have elevation: 1
- Visual: Cards should slide UNDER AppBar (correct behavior)

**Material Design stacking order:**
1. Scrim (overlay) - Highest
2. Modal (dialogs, bottom sheets)
3. App bars (when scrolled)
4. Cards, buttons
5. Background - Lowest

**Our theme follows this** ✅

**BUT:** No explicit documentation of stacking expectations

**RESOLUTION NEEDED:**

**Action:** Document expected stacking order in theme file
```dart
// Z-index expectations (elevation order):
// - Dialog: 6 (top modal layer)
// - AppBar scrolled: 2 (above content)
// - Card: 1 (content layer)
// - Background: 0 (base layer)
```

**Impact:** VERY LOW - Material Design handles this automatically

---

## 📋 HIDDEN ASSUMPTIONS (Must Clarify)

### ASSUMPTION #1: All Screens Use Material Scaffold

**Assumption:** All screens use Scaffold widget with AppBar
**Verification needed:** Are there any full-screen overlays or custom layouts?

**Check:** FileViewerScreen (marked as "crashes" in UI audit)

**Action:** Verify FileViewerScreen layout before applying theme

---

### ASSUMPTION #2: No Custom Painters or Canvas Drawing

**Assumption:** All UI uses Material widgets, no custom painting
**Risk:** Custom painters won't automatically use theme colors

**Known custom widgets:**
- PersonAutocomplete (uses Material widgets ✅)
- CustomDatePicker (uses Material widgets ✅)
- RestrictionsWidget (uses Material widgets ✅)

**Action:** Grep for CustomPaint to verify

---

### ASSUMPTION #3: No Third-Party UI Libraries

**Assumption:** All UI is pure Flutter Material
**Risk:** Third-party libraries may not respect theme

**Check:** Does app use any UI libraries?
- Webview?
- PDF viewer?
- Charts/graphs?
- Image pickers?

**Action:** Review pubspec.yaml dependencies

---

### ASSUMPTION #4: Single Language (Czech) Only

**Assumption:** App is Czech-only, no i18n switching

**From APP_DESIGN_FEEL.md:**
- Must support Czech diacritics ✅
- No mention of other languages

**Risk:** If multi-language added later, font sizes may need adjustment
- German: Longer words, may need smaller fonts
- English: Shorter, may look too spacious

**Current state:** Czech-only ✅
**Future-proofing:** Document if multi-language planned

---

### ASSUMPTION #5: Desktop is Primary, Mobile is Secondary

**Verified:** User explicitly said (line 35-40):
- Notebooks: "very mostly"
- Tablets: "less recommended"
- Phones: "not recommended but should work too"

**Theme correctly prioritizes desktop** ✅
- 20-24px padding (good for large screens)
- 14-15px fonts (readable on desktop)
- 3-column layouts (desktop-first)

**No issues here** ✅

---

## 🔍 EDGE CASES TO TEST

### Edge Case #1: Very Long Czech Words

**Problem:** Czech can have very long compound words
- Example: "nejneobhospodařovatelnější" (28 characters)

**Risk:** Text overflow in fixed-width components
- Buttons with long labels
- Table headers
- Form field labels

**Current handling:** `overflow: TextOverflow.ellipsis` (in some places)

**Action:** Test with long Czech words after theme implementation

---

### Edge Case #2: Empty States

**Problem:** How do empty states look with new theme?
- Empty EventList
- Empty ParticipantList
- No search results

**Current implementation** (participant_list_screen.dart:64-85):
```dart
Center(
  child: Column(
    children: [
      Icon(Icons.people_outline, size: 48, color: Colors.grey),  // Hardcoded color!
      Text('Žádní účastníci', style: TextStyle(fontSize: 18, color: Colors.grey)),  // Hardcoded!
    ],
  ),
)
```

**Issue:** Hardcoded colors won't match theme

**Resolution:** Replace with theme colors
```dart
Icon(Icons.people_outline,
  size: 48,
  color: Theme.of(context).colorScheme.onSurfaceVariant,  // Theme color
),
```

**Impact:** MEDIUM - Affects user experience, should fix

---

### Edge Case #3: Print Preview

**Problem:** PrintCenter may have different layout requirements
- PDF generation uses different rendering
- May not use Material widgets
- May need different font sizes for print

**Current state:** User marked "must be revisited" (APP_DESIGN_FEEL.md line 473)

**Action:** Exclude PrintCenter from initial theme application
- PrintCenter is separate task (in FIXME.md)
- Apply theme to print screens later

**Impact:** LOW - PrintCenter is separate enhancement

---

### Edge Case #4: Offline Mode Banner/Indicator

**Problem:** Does app show offline state?
- If yes: How does it look with new theme?
- If no: Should it?

**Not mentioned in documentation**

**Action:** Check if app has offline indicator, test with theme

---

### Edge Case #5: Loading States

**Problem:** How do loading spinners look with theme?

**Current code** (event_list.dart:64):
```dart
if (snapshot.connectionState == ConnectionState.waiting) {
  return const CircularProgressIndicator();  // Uses primary color by default
}
```

**Theme impact:** CircularProgressIndicator will use `colorScheme.primary` (blue) ✅

**No issues** - Automatically themed

---

## 📊 CROSS-DOCUMENT CONTRADICTIONS

### CONTRADICTION #1: RESOLVED ✅

**SCREEN_ANALYSIS.md says:**
- "Font sizes: 13-15px" (extracted from code)

**THEME_CHECKLIST.md says:**
- "bodyMedium: 14px"

**Resolution:** Use 14-15px range, not fixed 14px
- Default: 15px
- Compact: 14px

---

### CONTRADICTION #2: Button Colors (Already Flagged)

**APP_DESIGN_FEEL.md line 674:**
- "love the buttons from intake form"

**THEME_CHECKLIST.md:**
- Uses blue.shade600 (NewRecord style)

**Status:** Awaiting user decision

---

## ✅ FINAL CHECKLIST: Pre-Implementation Verification

### Must Resolve Before Implementation:

- [ ] **Button color scheme decision** (GREEN vs BLUE)
  - [ ] Ask user: Big actions GREEN, small BLUE? Or all BLUE?

- [ ] **Font size responsive behavior**
  - [ ] Confirm: Theme uses 15px, screens override with `isCompact ? 14 : 15`
  - [ ] Add phone-specific constant (14px for now)

- [ ] **Padding scope clarification**
  - [ ] Update THEME_CHECKLIST: Only add padding to screens that need it
  - [ ] Don't add padding to IntakeForm (has maxWidth constraint)
  - [ ] Don't add padding to CSV table (horizontal scroll)

- [ ] **Empty state colors**
  - [ ] Add to THEME_CHECKLIST: Fix hardcoded grey in empty states

### Should Verify After Implementation:

- [ ] Test long Czech words (overflow handling)
- [ ] Test on real tablet (touch targets OK?)
- [ ] Test on real phone (text readable at 14px?)
- [ ] Test vertical compact mode (height <= 600)
- [ ] Test horizontal scroll (CSV table)
- [ ] Test form field descenders (text cutoff?)
- [ ] Test card visibility (elevation: 1 enough?)

### Document for Future:

- [ ] Document: If dark theme needed, refactor AppColors
- [ ] Document: If multi-language needed, review font sizes
- [ ] Document: PrintCenter excluded from initial theme
- [ ] Document: FileViewerScreen needs verification (crashes)

---

## 🎯 RECOMMENDED ACTIONS

### IMMEDIATE (Before writing any code):

1. **ASK USER:**
   ```
   Button colors - Please choose ONE:

   A) GREEN primary (like IntakeForm "uložit a přišel")
      - Big action buttons: GREEN
      - Secondary buttons: BLUE
      - Keep this across entire app

   B) BLUE primary (like NewRecord "Uložit")
      - All primary buttons: BLUE
      - Secondary buttons: GREY outline
      - IntakeForm stays special (exception)

   C) Context colors
      - Medical/arrival actions: GREEN
      - Data/save actions: BLUE
      - Complex, but matches workflow
   ```

2. **UPDATE THEME_CHECKLIST.md:**
   - Change bodyMedium from 14px → 15px default
   - Add phone-specific fontSize constant (14px)
   - Clarify which screens get padding
   - Add task: Fix empty state hardcoded colors

3. **UPDATE THEME_IMPLEMENTATION.md:**
   - Add section: "Responsive Font Sizes"
   - Explain: Theme provides default, screens override for responsive
   - Example: `fontSize: isCompact ? 14 : 15`

### DURING IMPLEMENTATION:

1. Test after EACH phase (don't batch)
2. Verify responsive logic still works
3. Check horizontal scrolling not broken
4. Verify Czech diacritics render

### AFTER IMPLEMENTATION:

1. Test on longest Czech words
2. Test on actual tablet if available
3. Test on phone simulator (375px width)
4. Test vertical compact mode (600px height)
5. Document any issues found

---

## 📈 RISK ASSESSMENT SUMMARY

| Issue | Severity | Likelihood | Impact | Status |
|-------|----------|------------|--------|--------|
| Button color confusion | 🔴 HIGH | 100% | App-wide | Needs decision |
| Font responsive override | 🔴 HIGH | 80% | Readability | Fix before impl |
| Padding breaks scroll | 🟡 MEDIUM | 30% | UX issue | Clarify scope |
| Empty state colors | 🟡 MEDIUM | 100% | Visual inconsistency | Add to checklist |
| Czech locale inconsistency | 🟢 LOW | 10% | Works anyway | Document |
| Border width on mobile | 🟢 LOW | 20% | Minor visibility | Test after |
| Touch target size | 🟢 LOW | 10% | Usability | Test after |
| Dark theme refactor | 🟢 LOW | 0% | Future work | Document |
| Card elevation visibility | 🟢 LOW | 20% | Aesthetic | Test after |
| Z-index stacking | 🟢 VERY LOW | 5% | Material handles | Document |

**Overall Risk:** 🟡 **MEDIUM** (manageable with decisions + testing)

---

## 🚀 CONCLUSION

**Can we proceed?** ⚠️ **YES, AFTER USER DECISIONS**

**Critical blockers (must decide before coding):**
1. Button color scheme (GREEN or BLUE?)
2. Confirm font size approach (15px default, responsive override)

**Important clarifications (update docs):**
1. Which screens get padding (not all)
2. Empty states need theme colors

**Everything else:** Can be tested and fixed during implementation

**Confidence after decisions:** 95% → Will increase to 99% after Phase 1 testing

---

**Created:** 2025-11-15
**Status:** 🔴 AWAITING USER DECISIONS
**Next:** User answers button color question → Update checklist → BEGIN Phase 1

