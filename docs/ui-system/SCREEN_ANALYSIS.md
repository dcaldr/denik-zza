# Screen Analysis: Actual Code vs APP_DESIGN_FEEL.md

**Comprehensive analysis of current screen implementations cross-referenced with user preferences**

Last analyzed: 2025-11-15

---

## 📊 Summary of Findings

### Screens Analyzed:
1. ✅ EventList
2. ✅ ParticipantListScreen
3. ✅ ParticipantRegistrationForm
4. ✅ IntakeFormImproved
5. ✅ NewRecordPage
6. ✅ CSV Import Flow (import_screen, summary_screen)
7. ✅ AppDrawer

### Overall Pattern Assessment:

| Aspect | Status | Notes |
|--------|--------|-------|
| **Spacing** | ⚠️ Inconsistent | 0px (edge-to-edge) to 24px padding |
| **Font Sizes** | ⚠️ Mixed | No consistent sizing system |
| **Colors** | ⚠️ Hardcoded | Many direct `Colors.blue.shade600` calls |
| **Buttons** | ❌ Inconsistent | ElevatedButton, FilledButton, IconButton mixed |
| **Borders** | ⚠️ Varies | No consistent border styling |
| **Forms** | ❌ Edge-to-edge | Forms stretch full width (user dislikes) |

---

## 🔍 Screen-by-Screen Analysis

### 1. EventList (List of Medical Camps)

**File:** `lib/screens2/event_list.dart`

**Actual Implementation:**
```dart
// NO padding - uses ListView.builder directly
body: _buildActionList()  // No EdgeInsets

// ListTile (Material default styling)
ListTile(
  title: Text(action.nadpis),
  subtitle: Text('${dateFormat...}'),
  trailing: Row(...),
)
```

**Design Patterns Found:**
- ❌ No screen padding (edge-to-edge list)
- ✅ Uses AppBar with actions
- ✅ AppDrawer integration
- ❌ No consistent spacing between items
- ❌ Uses default Material ListTile (not themed)

**From APP_DESIGN_FEEL.md (lines 75-114):**

**User LIKES:**
- ✅ Simple list, easy to scan
- ✅ Action pinning feature
- ✅ Participant count visible

**User DISLIKES:**
- ⚠️ Multiple pin changes → many toasts (line 92)
- ❓ Action name could be more accented (line 110)
- ❓ List UI not uniform with rest of app (line 111)

**Status:** ⚠️ **Needs consistency improvements** - list items should use themed components, toasts need batching

---

### 2. ParticipantListScreen

**File:** `lib/screens2/participant_list_screen.dart`

**Actual Implementation:**
```dart
// Fixed padding for search
Padding(
  padding: const EdgeInsets.all(16.0),  // ← 16px padding
  child: PersonAutocomplete(...),
)

// List padding
ListView.builder(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),  // ← 16px horizontal
  itemBuilder: ...
)
```

**Design Patterns Found:**
- ✅ Screen has padding (16px)
- ✅ Consistent horizontal padding for list
- ❌ Uses PersonAutocomplete (dropdown behavior)
- ❌ List items not clickable (only detail button)

**From APP_DESIGN_FEEL.md (lines 118-160):**

**User LIKES:**
- ✅ Name and age displayed
- ✅ Detail button
- ✅ Search feature (conceptually)
- ✅ Event detail at top

**User DISLIKES:**
- ❌ Ugly list items UI (line 134)
- ❌ Search feels broken (line 135-137)
  - Narrows list, no way back to full list
  - Displays dropdown instead of filtering directly
- ❌ List items not clickable (line 139)

**Status:** ❌ **Major UX issues** - search broken, list items not clickable, needs themed list components

---

### 3. ParticipantRegistrationForm (3-Column Grid)

**File:** `lib/screens2/participant_registration_form.dart`

**Actual Implementation:**
```dart
Form(
  child: SingleChildScrollView(
    child: Column(
      children: [
        _buildGridView(),  // ← 3-column grid
        _buildTextField('poznamka', ...),
        _buildCheckboxSection(),
        _buildRestrictionsSection(),
        ElevatedButton(onPressed: _submitForm, ...)
      ],
    ),
  ),
)

// NO padding wrapper - form goes edge-to-edge
// Grid uses SizedBox(height: 4) between rows
```

**Design Patterns Found:**
- ❌ **NO screen padding** - edge-to-edge form
- ✅ 3-column grid layout (responsive)
- ✅ Minimal spacing between rows (4px)
- ❌ Form uses ElevatedButton (not themed)
- ❌ No consistent field spacing

**From APP_DESIGN_FEEL.md (lines 163-218):**

**User LIKES:**
- ✅ Autofill feature (rodné číslo)
- ✅ Doesn't force field completion
- ✅ 3-column layout on desktop
- ✅ One screen for all info

**User DISLIKES:**
- ❌ **Completely edge-to-edge** (line 183)
- ❌ **Spills to take whole screen** (line 184)

**Must-keep:**
- All form fields necessary (line 192)
- 3-column → 1-column responsive (line 213)

**Status:** ❌ **CRITICAL: NO MARGINS** - user explicitly dislikes edge-to-edge, needs 20-32px padding

---

### 4. IntakeFormImproved

**File:** `lib/screens2/intake_form_improved.dart`

**Actual Implementation:**
```dart
// Main wrapper - max width constraint
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 1600),  // ← Limits width
    child: Column(...),
  ),
)

// NO EdgeInsets.all() padding
```

**Design Patterns Found:**
- ✅ MaxWidth constraint (1600px)
- ❌ No explicit padding
- ✅ Uses IntakePersonRow widget (modular)
- ✅ Uses IntakeBottomRow for action buttons

**From APP_DESIGN_FEEL.md (lines 364-411):**

**User LIKES:**
- ✅ Document upload options (line 371)
- ✅ Changing participant data before submission (line 372)
- ✅ Marking arrived (line 373)
- ✅ **LOVE** the main action button (colors!) (line 374)
- ✅ PDF/image viewer zoom and scroll (line 375)

**User DISLIKES:**
- ❌ Spacing off - two columns, too much space on sides (line 382)
- ❌ How it takes space is off (line 384)
- ❌ **HUGE MISS: No way to create participant inline** (line 389)
- ❌ **HUGE MISS: No arrived counter** (line 390)

**Status:** ⚠️ **Good buttons, bad spacing** - action buttons are perfect (reference for theme), but spacing/layout needs fixing

---

### 5. NewRecordPage (Medical Record Entry)

**File:** `lib/screens2/new_record_page.dart`

**Actual Implementation:**
```dart
// Main padding wrapper
Padding(
  padding: const EdgeInsets.all(20.0),  // ← 20px all sides
  child: Column(...),
)

// Participant container
Container(
  padding: const EdgeInsets.all(16.0),  // ← 16px internal padding
  decoration: BoxDecoration(
    gradient: LinearGradient(...),
    borderRadius: BorderRadius.circular(12.0),  // ← 12px radius
    border: Border.all(color: Colors.blue.shade200, width: 1),
  ),
)

// Form fields
TextFormField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),  // ← 8px radius
      borderSide: BorderSide(color: Colors.blue.shade200),
    ),
    contentPadding: EdgeInsets.all(isCompact ? 12 : 16),  // ← 12-16px padding
  ),
)

// Font sizes (actual from code)
fontSize: isCompact ? 13 : 14,  // Body text
fontSize: isCompact ? 12 : 13,  // Labels
fontSize: isCompact ? 14 : 15,  // Title fields
fontSize: 11,  // Small text (health chips)
```

**Design Patterns Found:**
- ✅ **20px screen padding** (matches user's "more whitespace" request)
- ✅ **12px border radius** for containers (rounder than Material 3)
- ✅ **8px border radius** for form fields
- ✅ **Blue gradient** background for participant section
- ✅ **Smaller font sizes** (13-15px body, not 16px)
- ✅ Uses FilledButton for save (blue.shade600)
- ✅ Uses OutlinedButton for cancel (grey.shade400 border)

**From APP_DESIGN_FEEL.md (lines 220-285):**

**User LIKES:**
- ✅ Current actions are great (line 229)
- ✅ Icon panel above form (line 230)
- ✅ All context visible (line 231)
- ✅ Themed appearance (line 232)

**User DISLIKES:**
- ❌ Účastník section could be clickable (line 241)
- ❌ Save/Close button positions feel backwards (line 244)
- ❌ Spacing off: form → huge space → bottom buttons (line 245)
- ❌ Blocking popups (age to birthdate) (line 247)

**Status:** ✅ **BEST REFERENCE** - This screen has the closest to desired patterns (20px padding, 12/8px radius, proper fonts)

---

### 6. CSV Import Flow

**Files:** `lib/screens2/csv/import_screen.dart`, `summary_screen.dart`

**Actual Implementation:**

**import_screen.dart:**
```dart
// Main padding
Padding(
  padding: const EdgeInsets.all(24),  // ← 24px padding
  child: Column(...),
)

// File preview box
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),  // ← 16/20 padding
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),  // ← 12px radius
    border: Border.all(color: borderColor),
  ),
)

// Buttons
Row(
  children: [
    ElevatedButton(...),  // "Vybrat soubor"
    const SizedBox(width: 16),  // ← 16px gap
    FilledButton(...),  // "Pokračovat"
  ],
)
```

**summary_screen.dart:**
```dart
// Padding
ListView(
  padding: const EdgeInsets.all(16),  // ← 16px padding
  children: [
    Text(..., style: theme.textTheme.titleMedium),  // Uses theme!
    const SizedBox(height: 12),  // ← 12px vertical gap
    Wrap(spacing: 16, runSpacing: 16, ...),  // ← 16px badge spacing
  ],
)

// Cards (failure list)
Card(
  margin: const EdgeInsets.only(bottom: 8),  // ← 8px between cards
  child: Padding(
    padding: const EdgeInsets.all(12),  // ← 12px card padding
    ...
  ),
)
```

**Design Patterns Found:**
- ✅ **24px screen padding** (generous, open feel)
- ✅ **12px border radius** consistently
- ✅ **16px spacing** between buttons
- ✅ **12px vertical gaps** between sections
- ✅ Uses **theme.textTheme** (good!)
- ✅ FilledButton for primary action
- ✅ ElevatedButton for secondary action

**From APP_DESIGN_FEEL.md (lines 414-469):**

**User LIKES:**
- ✅ Flow is intuitive (line 423)
- ✅ **Has its own design language** that is consistent (line 424)
- ✅ Manages malformed data well (line 425)
- ✅ Gives user overview/control before finalizing (line 426)

**User DISLIKES:**
- ❌ Summary "sell" is poor - empty with just counts (line 433)
- ❌ "Zpět na výběr CSV" goes to wrong screen (line 435)
- ❌ Confirm table missing back button (line 437)

**Status:** ✅ **EXCELLENT REFERENCE** - User explicitly likes this flow's design language

---

### 7. AppDrawer (Main Navigation)

**File:** `lib/screens2/widgets/app_drawer.dart`

**Actual Implementation:**
```dart
// Header
DrawerHeader(
  child: Text(
    'Deník ZZA',
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
  ),
)

// Main workflow section (highlighted)
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),  // ← 16/12 padding
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.orange.shade100, Colors.orange.shade50],
    ),
    borderRadius: BorderRadius.circular(8),  // ← 8px radius
    boxShadow: [...],
  ),
  child: Text(
    'HLAVNÍ: BĚHEM AKCE',
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),  // ← 13px font
  ),
)

// Menu items
ListTile(
  title: Text('...', style: TextStyle(fontSize: 15)),  // ← 15px font
  subtitle: Text('...', style: TextStyle(fontSize: 11)),  // ← 11px small text
)
```

**Design Patterns Found:**
- ✅ **8px border radius** for section headers
- ✅ **13px font** for section headers
- ✅ **15px font** for menu items
- ✅ **11px font** for subtitle/hints
- ✅ Orange gradient for main workflow (visual hierarchy)
- ✅ Disabled state with explanation (grey + warning icon)
- ✅ Uses expansion tiles for collapsible sections

**From APP_DESIGN_FEEL.md (lines 606-644):**

**User LIKES:**
- ✅ Great looking now (line 613)
- ✅ Main workflow at top with highlight (line 614)
- ✅ UI good looking and stylish (line 615)

**User DISLIKES:**
- ⚠️ Menu/back button inconsistency across screens (line 623-624)

**Improvement ideas:**
- ❌ Missing: Disabled elements need explanation tooltips (line 641)

**Status:** ✅ **GOOD** - Well-designed, needs tooltip addition

---

## 📐 Extracted Design Patterns (Actual Code)

### Spacing Values Used:

| Location | Value | Notes |
|----------|-------|-------|
| CSV import | `24px` | Screen padding - most generous |
| NewRecord | `20px` | Screen padding - good |
| ParticipantList | `16px` | Screen padding - minimal |
| **ParticipantRegistration** | `0px` | ❌ Edge-to-edge (user hates) |
| EventList | `0px` | ❌ No padding |
| CSV cards | `12px` | Internal card padding |
| Buttons gap | `16px` | Between action buttons |
| Field spacing | `4-12px` | Vertical between fields |

**Recommendation:** Use `20-24px` screen padding consistently

---

### Font Sizes Used:

| Element | NewRecord | AppDrawer | CSV | Recommendation |
|---------|-----------|-----------|-----|----------------|
| Body text | 13-14px | - | - | **14px** |
| Form labels | 12-13px | - | - | **13px** |
| Title fields | 14-15px | 15px | - | **15px** |
| Section headers | - | 13px | - | **13px** |
| Small text | 11px | 11px | - | **11px** |
| Tiny text | 9-10px | - | - | **10px** |

**Recommendation:** Use **13-15px** body text (NOT 16px Material 3 default)

---

### Border Radius Used:

| Element | NewRecord | CSV | AppDrawer | Recommendation |
|---------|-----------|-----|-----------|----------------|
| Containers | 12px | 12px | 8px | **12px** |
| Form fields | 8px | - | - | **8px** |
| Buttons | 8px | - | - | **8px** |
| Cards | - | - | - | **12px** |

**Recommendation:** **8-12px** radius (rounder than Material 3's 4px)

---

### Colors Used (Actual Shades):

| Color | Usage | Code Location |
|-------|-------|---------------|
| `Colors.blue.shade50` | Light backgrounds | NewRecord participant box |
| `Colors.blue.shade100` | Icon button backgrounds | NewRecord |
| `Colors.blue.shade200` | Form borders | NewRecord, CSV |
| `Colors.blue.shade600` | Primary buttons | NewRecord FilledButton |
| `Colors.blue.shade700` | Text/icons | NewRecord |
| `Colors.grey.shade50` | Secondary backgrounds | NewRecord history section |
| `Colors.grey.shade400` | Outline button borders | NewRecord cancel button |
| `Colors.orange.shade100` | Highlight backgrounds | AppDrawer main section |
| `Colors.amber.shade300` | Poznámka field borders | NewRecord |
| `Colors.yellow.shade50` | Poznámka background | NewRecord |

**Recommendation:** Use these **exact shades** in theme constants

---

### Button Types Used:

| Screen | Primary Action | Secondary Action | Notes |
|--------|---------------|------------------|-------|
| NewRecord | FilledButton (blue.shade600) | OutlinedButton (grey) | ✅ Perfect |
| CSV import | FilledButton | ElevatedButton | ✅ Good |
| IntakeForm | "Love the buttons!" | - | ✅ **User's favorite** |
| ParticipantReg | ElevatedButton | - | ⚠️ Should use FilledButton |
| EventList | IconButton | - | ⚠️ Needs theming |

**Recommendation:**
- **Major actions:** FilledButton (like IntakeForm/NewRecord)
- **Secondary actions:** OutlinedButton or ElevatedButton
- Consistent styling via ThemeData

---

## ❌ Gaps: What's NOT in APP_DESIGN_FEEL.md

### Missing Screen Coverage:

1. **EventRegistrationForm** - Not documented in design feel
2. **EventDetail** - Minimal notes (lines 287-323)
3. **PrintCenter** - Marked "must be revisited" (line 473)
4. **FileViewerScreen** - "Did not find attached" (line 564)
5. **CsvReviewTable** - No design feedback

**Action:** These screens need user feedback before creating theme

---

## ✅ Priority Correspondence Check

**From APP_DESIGN_FEEL.md Priority Matrix (lines 836-862):**

### User's Top Priorities (9/10):
1. ✅ Consistent spacing → **Documented** (0px to 24px range found)
2. ✅ Consistent colors → **Documented** (blue/grey shades extracted)
3. ✅ Consistent buttons → **Documented** (FilledButton vs ElevatedButton vs OutlinedButton)

### Technical Fixes:
- ⚠️ ParticipantRegistrationForm edge-to-edge (7/10) → **Confirmed in code**
- ✅ CSV table mobile (2/10) → Not priority
- ❌ FileViewerScreen crashes (6/10) → **Not analyzed (missing screen)**

---

## 📋 Recommendations for Theme Implementation

### Phase 1: Extract Patterns from Best Screens
**Reference:** CSV import + NewRecord (user likes these)

1. **Spacing:** 20-24px screen padding
2. **Font sizes:** 13-15px body text
3. **Border radius:** 8-12px
4. **Colors:** Exact blue/grey shades from code
5. **Buttons:** FilledButton style from IntakeForm

### Phase 2: Fix Critical Issues
**Reference:** APP_DESIGN_FEEL.md HUGE MISSES

1. ❌ ParticipantRegistrationForm - add 20px padding
2. ❌ EventList - add padding, fix toast stacking
3. ❌ ParticipantList - fix search, make items clickable

### Phase 3: Apply Theme Consistently
**Reference:** All screens

1. Replace hardcoded colors with theme references
2. Replace ElevatedButton with FilledButton for primary actions
3. Unify spacing using theme constants
4. Apply consistent border radius

---

**Created:** 2025-11-15
**Last Updated:** 2025-11-15
**Status:** Complete - Ready for theme implementation
**Next Step:** Create THEME_CHECKLIST.md with actionable items
