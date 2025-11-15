# User Flows & Journey Analysis

**Deník ZZA - Complete User Journey Documentation**

This document maps all major user flows through the app with UI/UX analysis for each step.

---

## 📚 Table of Contents

1. [Flow 1: Event Management](#flow-1-event-management)
2. [Flow 2: Individual Participant Registration](#flow-2-individual-participant-registration)
3. [Flow 3: CSV Bulk Import](#flow-3-csv-bulk-import)
4. [Flow 4: Medical Record Creation](#flow-4-medical-record-creation)
5. [Flow 5: Document Printing](#flow-5-document-printing)
6. [Flow 6: Participant Management](#flow-6-participant-management)
7. [Cross-Flow Analysis](#cross-flow-analysis)
8. [Navigation Architecture](#navigation-architecture)

---

## Flow 1: Event Management

**User Goal:** Create and manage medical camp events (táborové akce)

### Flow Diagram

```
EventList (Main Screen)
    ↓
    [+ Nová akce]
    ↓
EventRegistrationForm
    ↓ [Uložit]
    ↓
EventList (updated)
    ↓ [Click event]
    ↓
EventDetail
```

### Step-by-Step Journey

#### Step 1.1: View All Events (EventList)
**Screen:** `lib/screens2/event_list.dart`
**Entry Point:** App launch (default home screen)

**What user sees:**
- List of all medical camp events
- Each event shows: date range, participant count, pin status
- "+ Nová akce" button in AppBar
- Drawer menu for navigation

**UI/UX Analysis:**
- ✅ **GOOD:** Simple, scannable list
- ✅ **GOOD:** Pin button for quick access to active event
- ❌ **BAD:** Disabled search button (confusing - should be hidden or implemented)
- ❌ **BAD:** No empty state when no events exist
- ⚠️ **CONCERN:** Date formatting uses manual padding (should use DateFormat)
- ⚠️ **CONCERN:** No visual distinction between past, current, and future events

**User Actions:**
- Click "+ Nová akce" → Go to EventRegistrationForm
- Click event item → Go to EventDetail
- Click pin icon → Set as active event
- Open drawer → Navigate to other sections

---

#### Step 1.2: Create New Event (EventRegistrationForm)
**Screen:** `lib/screens2/event_registration_form.dart`

**What user sees:**
- Simple vertical form
- Fields: Title, Description, Start date, End date
- "Odeslat" button to submit

**UI/UX Analysis:**
- ✅ **GOOD:** Simple, focused form
- ✅ **GOOD:** Two-column date picker layout (start/end dates side by side)
- ⚠️ **CONCERN:** Description field has maxLength counter (good) but Title doesn't (inconsistent)
- ⚠️ **CONCERN:** No cancel button (what if user changes mind?)
- ⚠️ **CONCERN:** Uses `TextField` for description but `TextFormField` for title (inconsistent)
- ❌ **BAD:** No confirmation dialog before submitting

**User Actions:**
- Fill in event details
- Select dates using date pickers
- Click "Odeslat" → Save event and return to EventList

**Improvements Needed:**
1. Add cancel button
2. Add confirmation dialog ("Vytvořit akci?")
3. Standardize field types (use TextFormField consistently)
4. Add max length to title field

---

#### Step 1.3: View Event Details (EventDetail)
**Screen:** `lib/screens2/event_detail.dart`

**What user sees:**
- Event title and metadata (dates, participant count)
- Description text
- Search field to filter participants
- List of participants in this event
- "+ Add participant" button

**UI/UX Analysis:**
- ✅ **GOOD:** All event context visible at once
- ✅ **GOOD:** Search/filter functionality for participants
- ❌ **BAD:** Manual date formatting with TODO comments (DT1, DT2)
- ❌ **BAD:** Search field + button Row can overflow on narrow screens
- ❌ **BAD:** No max width constraint (stretches too wide on desktop)
- ⚠️ **CONCERN:** Different search pattern than ParticipantListScreen (plain TextField vs PersonAutocomplete)
- ⚠️ **CONCERN:** Edit button is disabled with TODO comment

**User Actions:**
- Type in search field → Filter visible participants
- Click "+ Add participant" → Go to Participant RegistrationForm
- Click participant → Go to ParticipantDetail

**Improvements Needed:**
1. Fix date formatting (use AppDateFormats)
2. Add responsive layout for search row
3. Add max width constraint
4. Implement or remove edit button
5. Standardize search pattern

---

### Flow Metrics

**Total Steps:** 3 screens
**Estimated Time:** 1-2 minutes to create new event
**Success Rate:** High (simple flow)
**Drop-off Points:** None identified

### UX Issues Summary

| Issue | Severity | Screen | Impact |
|-------|----------|--------|--------|
| Disabled search button | Medium | EventList | Confusion |
| No empty state | Low | EventList | Poor first-run experience |
| No cancel button | Medium | EventRegistrationForm | Users feel trapped |
| Date formatting TODO | Low | EventDetail | Inconsistent display |
| Search overflow risk | High | EventDetail | Breaks on mobile |

---

## Flow 2: Individual Participant Registration

**User Goal:** Add a single participant with full details including medical info

### Flow Diagram

```
ParticipantListScreen OR EventDetail
    ↓
    [+ Add Participant]
    ↓
IntakeFormImproved
    ↓ [Select participant OR create new]
    ↓
ParticipantRegistrationForm (embedded)
    ↓ [Fill details, upload docs]
    ↓
    [Uložit]
    ↓
ParticipantListScreen (updated)
```

### Step-by-Step Journey

#### Step 2.1: View Participants (ParticipantListScreen)
**Screen:** `lib/screens2/participant_list_screen.dart`
**Entry Point:** Drawer menu → "Seznam účastníků"

**What user sees:**
- PersonAutocomplete search bar
- Scrollable list of participants
- Each participant shows: name, basic info
- "+ Přidat účastníka" button in AppBar

**UI/UX Analysis:**
- ✅ **GOOD:** Clean, simple list
- ✅ **GOOD:** Good empty state (icon + message + action button)
- ✅ **GOOD:** Search/autocomplete for quick finding
- ⚠️ **CONCERN:** PersonAutocomplete might be confusing (dropdown suggests auto-completion, not filtering)
- ❌ **BAD:** No loading indicator during fetch
- ❌ **BAD:** No pull-to-refresh

**User Actions:**
- Type in search → Filter participants
- Click "+ Přidat účastníka" → Go to IntakeFormImproved
- Click participant → Go to ParticipantDetail

---

#### Step 2.2: Intake Process (IntakeFormImproved)
**Screen:** `lib/screens2/intake_form_improved.dart`

**What user sees:**
- Top section: Person search/selection row
- Middle section: Full participant registration form + file upload
- Bottom section: Action buttons (Cancel, Save)

**UI/UX Analysis:**
- ✅ **EXCELLENT:** Well-organized three-section layout
- ✅ **EXCELLENT:** Controller pattern keeps state clean
- ✅ **GOOD:** Max width constraint (1600px) prevents extreme stretching
- ✅ **GOOD:** Reuses ParticipantRegistrationForm component
- ⚠️ **CONCERN:** 1600px max width is very wide (consider 1200px)
- ⚠️ **CONCERN:** No mobile-specific layout
- ❌ **BAD:** Form regenerated on state changes (performance concern)

**User Actions:**
- Option A: Search existing person → Auto-fill form
- Option B: Start typing new name → Create new participant
- Fill in all form fields
- Upload documents (optional)
- Click "Uložit" → Save and return

---

#### Step 2.3: Fill Participant Form (ParticipantRegistrationForm)
**Screen:** `lib/screens2/participant_registration_form.dart`
**Context:** Embedded in IntakeFormImproved

**What user sees:**
- Basic info section (3 columns): First name, Last name, Insurance number
- Birth info row: Birth date + gender
- Guardian info section (3 columns): Contact details
- Poznámka field (full width, multiline)
- Checkboxes (2 columns): Confirmations
- Restrictions & Medications section (2 columns)
- Submit button at bottom

**UI/UX Analysis:**
- ✅ **GOOD:** Comprehensive form captures all necessary data
- ✅ **GOOD:** Reusable component (used in multiple places)
- ✅ **GOOD:** Auto-fill feature (guessAndFillFields) saves time
- ❌ **CRITICAL:** Fixed 3-column grid breaks completely on mobile
- ❌ **CRITICAL:** No responsive layout (no LayoutBuilder or MediaQuery)
- ❌ **CRITICAL:** Form unusable in portrait mode on phones
- ⚠️ **CONCERN:** Auto-fill triggers on every keystroke (performance issue)
- ⚠️ **CONCERN:** No visual grouping (all fields same weight)
- ❌ **BAD:** Restrictions section side-by-side layout breaks on narrow screens
- ❌ **BAD:** Submit button at bottom (inconsistent with other forms that use AppBar actions)

**User Actions:**
- Fill required fields (name, birth date, insurance)
- Optionally fill guardian info
- Check applicable confirmation boxes
- Add restrictions/medications if needed
- Click submit button

**Improvements Needed:**
1. **URGENT:** Implement responsive grid (1/2/3 columns based on width)
2. Throttle auto-fill function
3. Add visual grouping (Cards or Dividers)
4. Fix restrictions section layout for mobile
5. Move submit to AppBar or add cancel button

---

### Flow Metrics

**Total Steps:** 3 screens
**Estimated Time:** 3-5 minutes per participant
**Success Rate:** Medium (mobile users struggle with form)
**Drop-off Points:** ParticipantRegistrationForm on mobile (unusable)

### UX Issues Summary

| Issue | Severity | Screen | Impact |
|-------|----------|--------|--------|
| Form not responsive | CRITICAL | ParticipantRegistrationForm | Unusable on mobile |
| No loading indicator | Medium | ParticipantListScreen | Users don't know if loading |
| Auto-fill performance | Medium | ParticipantRegistrationForm | Sluggish typing |
| Max width too wide | Low | IntakeFormImproved | Poor desktop UX |

---

## Flow 3: CSV Bulk Import

**User Goal:** Import multiple participants from CSV file at once

### Flow Diagram

```
Drawer Menu
    ↓
    [CSV Import]
    ↓
CsvImportScreen
    ↓ [Select File]
    ↓
CsvReviewTableOverviewScreen
    ↓ [Review, approve/reject rows]
    ↓ [Finalize]
    ↓
CsvImportSummaryScreen
    ↓ [Return]
    ↓
EventList or ParticipantList
```

### Step-by-Step Journey

#### Step 3.1: Select CSV File (CsvImportScreen)
**Screen:** `lib/screens2/csv/import_screen.dart`
**Entry Point:** Drawer menu → "CSV Import"

**What user sees:**
- Instructions text
- Help text
- Clickable file selection box
- "Vybrat soubor" button
- "Pokračovat" button (disabled until file selected)

**UI/UX Analysis:**
- ✅ **GOOD:** Clean, simple interface
- ✅ **GOOD:** Clear instructions
- ✅ **GOOD:** Responsive vertical layout
- ⚠️ **CONCERN:** File box is InkWell but doesn't clearly look clickable
- ⚠️ **CONCERN:** Loading indicator tiny (16x16) when picking file
- ❌ **BAD:** No drag-and-drop support (TODO comment)
- ❌ **BAD:** TODO comment in UI code (should be in issue tracker)

**User Actions:**
- Click "Vybrat soubor" → Open file picker
- Select CSV file → File name displays in box
- Click "Pokračovat" → Go to CsvReviewTable

**Improvements Needed:**
1. Add drag-and-drop support
2. Make file box more obviously clickable
3. Larger loading indicator
4. Move TODOs to issue tracker

---

#### Step 3.2: Review & Edit Data (CsvReviewTableOverviewScreen)
**Screen:** `lib/screens2/csv/table_overview_screen.dart`

**What user sees:**
- Sticky header: File info, summary badges, status filter chips
- DataTable with all imported rows
- Each row: Editable fields, status indicator, warnings
- Synchronized horizontal scroll (header + body)
- Bottom action bar: Select all, Deselect all, Finalize

**UI/UX Analysis:**
- ✅ **EXCELLENT:** Dual scrollbar (vertical + horizontal) well implemented
- ✅ **EXCELLENT:** LayoutBuilder for responsive header widths
- ✅ **GOOD:** Summary badges show import status at a glance
- ✅ **GOOD:** Filter chips let you focus on specific status
- ❌ **CRITICAL:** Requires 960px minimum width (unusable on mobile)
- ❌ **CRITICAL:** No mobile layout alternative
- ❌ **BAD:** Complex scroll synchronization is fragile
- ❌ **BAD:** RenderTable traversal for column widths is hacky (TODO comment)
- ⚠️ **CONCERN:** Editable cells create FocusNode + TextEditingController for EVERY cell (performance issue for large CSVs)
- ⚠️ **CONCERN:** Manual GlobalKey management for tooltips
- ⚠️ **CONCERN:** Sticky header overlay can have z-index issues
- ⚠️ **CONCERN:** Summary badges clickable but don't do anything (misleading)

**User Actions:**
- Review each row for correctness
- Edit inline if needed
- Click status filter chips → Show only rows with that status
- Check/uncheck rows for import
- Click "Dokončit" → Finalize import

**Improvements Needed:**
1. **URGENT:** Create mobile-friendly alternative (Card-based list with ExpansionTile)
2. Simplify scroll synchronization
3. Lazy-load TextEditingControllers
4. Remove misleading click affordance from badges
5. Fix or document RenderTable hack

---

#### Step 3.3: View Results (CsvImportSummaryScreen)
**Screen:** `lib/screens2/csv/summary_screen.dart`

**What user sees:**
- File name
- Summary badges: Approved, Rejected, Saved, Failed counts
- Result message (success or failure)
- Failure list (if any) with row number and error message
- "Zpět na výběr CSV" button
- "Exportovat výsledky" button (disabled/TODO)

**UI/UX Analysis:**
- ✅ **EXCELLENT:** Simple, responsive layout
- ✅ **EXCELLENT:** Uses theme colors (not hardcoded)
- ✅ **GOOD:** Wrap widget for badges adapts to width
- ✅ **GOOD:** Clear success/failure messaging
- ✅ **GOOD:** Has test keys for widget testing
- ❌ **BAD:** Export button disabled with TODO (should be hidden or implemented)
- ❌ **BAD:** No way to retry/fix failures (user must start over)
- ⚠️ **CONCERN:** Failure cards minimal (only index + message, no data context)
- ⚠️ **CONCERN:** Success state bland (could be more celebratory)

**User Actions:**
- Review results
- Click "Zpět na výběr CSV" → Return to EventList
- (Optional) Click export button → Export results (TODO)

**Improvements Needed:**
1. Implement or hide export button
2. Add "Back to review" option for fixing failures
3. Show more context in failure cards
4. Enhance success state (confetti animation?)

---

### Flow Metrics

**Total Steps:** 3 screens
**Estimated Time:** 5-10 minutes depending on CSV size
**Success Rate:** Low on mobile (table unusable), High on desktop
**Drop-off Points:** CsvReviewTable on mobile (completely broken)

### UX Issues Summary

| Issue | Severity | Screen | Impact |
|-------|----------|--------|--------|
| Table not mobile-friendly | CRITICAL | CsvReviewTable | Unusable on mobile |
| No drag-and-drop | Medium | CsvImportScreen | Extra clicks required |
| Cell controller performance | High | CsvReviewTable | Slow with large CSVs |
| No retry option | Medium | CsvImportSummaryScreen | Frustrating for users |
| Export button disabled | Low | CsvImportSummaryScreen | Misleading |

---

## Flow 4: Medical Record Creation

**User Goal:** Document a medical intervention/injury for a participant

### Flow Diagram

```
EventDetail OR ParticipantDetail
    ↓
    [New Record button]
    ↓
NewRecordPage
    ↓ [Select participant]
    ↓ [Fill record details]
    ↓ [Save OR Print]
    ↓
ParticipantDetail (with new record)
```

### Step-by-Step Journey

#### Step 4.1: Open Record Entry (NewRecordPage)
**Screen:** `lib/screens2/new_record_page.dart`
**Entry Point:** Drawer menu → "Nový záznam" OR ParticipantDetail → "New Record"

**What user sees:**
- Top: Participant info card (blue gradient) with inline search
- Medical history panel: Health chips (collapsible)
- Record history list: Recent records for this participant
- Form section: Date/time, Title, Description, Poznámka (yellow)
- Bottom: Action buttons (Save, Cancel) + Print buttons

**UI/UX Analysis:**
- ✅ **EXCELLENT:** Uses LayoutBuilder for compact mode (height ≤ 600px)
- ✅ **EXCELLENT:** Adjusts spacing based on available height
- ✅ **GOOD:** Health chips use Wrap for responsive wrapping
- ✅ **GOOD:** All context visible (participant + history + form)
- ✅ **GOOD:** Print buttons integrated into workflow
- ⚠️ **CONCERN:** Participant info section complex horizontal Row (squeezes on narrow screens)
- ⚠️ **CONCERN:** Health info collapse thresholds (4/6/8) are magic numbers
- ⚠️ **CONCERN:** Record history takes too little space (flex: 2 vs form flex: 7)
- ❌ **BAD:** Separate date/time pickers tedious (should be combined)
- ❌ **BAD:** Poznámka yellow sticky-note styling may look unprofessional
- ❌ **BAD:** Print buttons positioned far right feel disconnected
- ❌ **BAD:** Disabled form opacity 0.4 too subtle

**User Actions:**
1. Search and select participant (if not pre-selected)
2. View medical history and recent records
3. Select date and time
4. Fill in title, description, poznámka
5. Click "Uložit" → Save record
6. OR click print button → Go to print flow

**Improvements Needed:**
1. Stack participant info vertically on mobile
2. Make health collapse thresholds dynamic
3. Combine date/time picker into single component
4. Reconsider poznámka yellow styling
5. Increase disabled form opacity

---

### Flow Metrics

**Total Steps:** 1 screen (streamlined!)
**Estimated Time:** 2-3 minutes per record
**Success Rate:** High (well-designed screen)
**Drop-off Points:** None major (participant search can be confusing)

### UX Issues Summary

| Issue | Severity | Screen | Impact |
|-------|----------|--------|--------|
| Participant info squeeze | Medium | NewRecordPage | Hard to read on narrow screens |
| Date/time pickers separate | Low | NewRecordPage | Extra steps |
| Poznámka styling | Low | NewRecordPage | May look unprofessional |
| Print button position | Low | NewRecordPage | Discoverability |

---

## Flow 5: Document Printing

**User Goal:** Print medical forms, participant lists, or specific documents

### Flow Diagram

```
Drawer Menu OR NewRecordPage
    ↓
    [Print Center]
    ↓
PrintCenterPage (feature selection)
    ↓ [Select print type]
    ↓
PersonAndModeFlowPage (wizard)
    ↓ Step 1: Select person/people
    ↓ Step 2: Select mode + preview
    ↓ Step 3: Confirm details
    ↓ [Print dialog]
    ↓
PrintCenterPage (return)
```

### Step-by-Step Journey

#### Step 5.1: Select Print Type (PrintCenterPage)
**Screen:** `lib/print_ops2/print_center.dart`
**Entry Point:** Drawer menu → "Tisk" OR NewRecordPage → Print button

**What user sees:**
- Title: "Print Center"
- Feature cards:
  - "Print person" (emphasized, elevated)
  - "Print selected" (lock icon if disabled)
  - "Manage state" (lock icon if disabled)
- Info box with notes

**UI/UX Analysis:**
- ✅ **EXCELLENT:** Uses Provider for state management
- ✅ **GOOD:** Clean card-based interface
- ✅ **GOOD:** Disabled features clearly marked
- ✅ **GOOD:** Emphasize flag for primary action
- ❌ **BAD:** No max width constraint (cards stretch full width on desktop)
- ⚠️ **CONCERN:** Lock icon small (18px) - disabled state could be clearer
- ⚠️ **CONCERN:** Info box buried at bottom
- ⚠️ **CONCERN:** All cards same size (no visual hierarchy beyond elevation)

**User Actions:**
- Click "Print person" → Go to PersonAndModeFlowPage
- (If enabled) Click other features → Go to respective flows

**Improvements Needed:**
1. Add max width constraint (600-800px)
2. Move important notes to top
3. Larger/clearer disabled state indicator
4. Add visual hierarchy to cards

---

#### Step 5.2: Select Person & Mode (PersonAndModeFlowPage)
**Screen:** `lib/print_ops2/print_center.dart` (sub-screen)

**What user sees:**
- Step badges showing progress (horizontal scroll)
- Step 1: Person list with search
- Step 2: Mode selection (RadioListTile) + PDF preview
- Step 3: Confirmation details + dialog

**UI/UX Analysis:**
- ✅ **EXCELLENT:** Uses LayoutBuilder to switch vertical/horizontal layout (700px breakpoint)
- ✅ **EXCELLENT:** Step-by-step flow is clear
- ✅ **GOOD:** Scrollable step badges handle overflow
- ✅ **GOOD:** Preview pane + controls adapt to screen size
- ✅ **GOOD:** RadioListTile for mode selection (standard pattern)
- ⚠️ **CONCERN:** PDF preview might be too small on narrow screens
- ⚠️ **CONCERN:** Step badges all same size (active could be larger/bolder)
- ❌ **BAD:** Mode selection subtitle uses complex conditional text (hard to maintain)
- ❌ **BAD:** Multiple TODO comments in build method

**User Actions:**
1. Step 1: Search and select person from list
2. Step 2: Choose print mode (full records, restrictions only, etc.) → Preview updates
3. Step 3: Review details → Click confirm → Print dialog

**Improvements Needed:**
1. Make active step badge more prominent
2. Simplify mode selection subtitle logic
3. Move TODOs to issue tracker
4. Ensure PDF preview readable on mobile

---

### Flow Metrics

**Total Steps:** 2 main screens (+ wizard steps within)
**Estimated Time:** 1-2 minutes per print job
**Success Rate:** High (clear flow)
**Drop-off Points:** None major

### UX Issues Summary

| Issue | Severity | Screen | Impact |
|-------|----------|--------|--------|
| Cards too wide | Medium | PrintCenterPage | Poor desktop UX |
| PDF preview small | Low | PersonAndModeFlowPage | Hard to verify |
| Complex subtitle logic | Low | PersonAndModeFlowPage | Maintenance burden |

---

## Flow 6: Participant Management

**User Goal:** View, edit, or delete existing participant information

### Flow Diagram

```
ParticipantListScreen
    ↓
    [Click participant]
    ↓
ParticipantDetail
    ↓ [Edit button]
    ↓
ParticipantEditPage
    ↓ [Save]
    ↓
ParticipantDetail (updated)
```

### Step-by-Step Journey

#### Step 6.1: View Details (ParticipantDetail)
**Screen:** `lib/screens2/participant_detail.dart`

**What user sees:**
- Info cards: Personal data, insurance, confirmations
- Medical records section: List of record cards
- Action button row: Edit, Print

**UI/UX Analysis:**
- ✅ **GOOD:** Card-based layout groups related info
- ✅ **GOOD:** ListView handles scrolling
- ⚠️ **CONCERN:** Action button row can overflow on narrow screens
- ⚠️ **CONCERN:** No max width constraint (cards very wide on desktop)
- ❌ **BAD:** Manual date formatting (should use DateFormat)
- ❌ **BAD:** No loading state styling
- ❌ **BAD:** _buildInfoRow pattern not used elsewhere (inconsistent)

**User Actions:**
- Review participant information
- Click "Edit" → Go to ParticipantEditPage
- Click "Print" → Go to PrintCenter

**Improvements Needed:**
1. Wrap action buttons or use Wrap widget
2. Add max width constraint
3. Use AppDateFormats for dates
4. Style loading indicator
5. Standardize info row pattern

---

#### Step 6.2: Edit Participant (ParticipantEditPage)
**Screen:** `lib/screens2/participant_edit_page.dart`

**What user sees:**
- AppBar with "Uložit" action button
- Centered form (maxWidth: 800px)
- ParticipantRegistrationForm (same as add flow)
- Bottom button row: Cancel, "Uložit změny"

**UI/UX Analysis:**
- ✅ **GOOD:** Max width constraint for desktop
- ✅ **GOOD:** Form scrolls in Expanded widget
- ❌ **BAD:** Duplicate save buttons (AppBar + bottom)
- ❌ **BAD:** Cancel button uses `Colors.grey` directly (should be theme)
- ⚠️ **CONCERN:** Max width 800px might be too narrow for 3-column form
- ⚠️ **CONCERN:** Form regenerated in initState (can't update dynamically)

**User Actions:**
- Edit form fields
- Click "Uložit" (AppBar OR bottom button) → Save and return
- Click "Zrušit" → Return without saving

**Improvements Needed:**
1. Remove duplicate save button (keep only AppBar)
2. Use OutlinedButton style for cancel
3. Adjust max width to accommodate form
4. Fix form regeneration issue

---

### Flow Metrics

**Total Steps:** 2 screens
**Estimated Time:** 1-2 minutes to edit
**Success Rate:** High
**Drop-off Points:** None

### UX Issues Summary

| Issue | Severity | Screen | Impact |
|-------|----------|--------|--------|
| Button overflow risk | Medium | ParticipantDetail | Breaks on mobile |
| Duplicate save buttons | Medium | ParticipantEditPage | Confusing UX |
| Max width conflict | Low | ParticipantEditPage | Form cramped |

---

## Cross-Flow Analysis

### Common Pain Points Across All Flows

1. **Responsive Design Failures**
   - ParticipantRegistrationForm: Breaks on mobile (multiple flows affected)
   - CsvReviewTable: Unusable on mobile
   - Participant info sections: Squeeze on narrow screens

2. **Inconsistent Patterns**
   - Search implementations vary (PersonAutocomplete vs TextField)
   - Date formatting inconsistent (manual vs DateFormat)
   - Button styles mixed (ElevatedButton vs FilledButton)
   - Empty states vary across screens

3. **Missing Features**
   - No pull-to-refresh on any list
   - No loading indicators on several screens
   - No max width constraints on many screens

4. **Navigation Issues**
   - Detail screens lack drawer (user must back out to navigate)
   - No breadcrumbs or clear "where am I" indicator
   - Some flows hard to exit (no cancel buttons)

---

## Navigation Architecture

### Primary Navigation (AppDrawer)

**Structure:**
```
Main Workflow (orange highlighted)
├─ Nový záznam (New Record)

Příprava akce (Event Preparation) [Collapsible]
├─ Seznam akcí (Event List)
├─ Registrace účastníka (Participant Registration)
└─ CSV Import

Zdravotnický filtr (Medical Filter) [Collapsible]
├─ Seznam účastníků (Participant List)
├─ Detail účastníka (Participant Detail - context dependent)
└─ Tisk (Print Center)
```

**UX Analysis:**
- ✅ **EXCELLENT:** State-dependent enabling (items disabled until event selected)
- ✅ **GOOD:** Expansion tiles organize related items
- ✅ **GOOD:** Clear disabled state explanations
- ⚠️ **CONCERN:** Main workflow section styling (orange gradient) not reused elsewhere
- ⚠️ **CONCERN:** Drawer rebuilds on every open (performance concern)

### Secondary Navigation

**Methods:**
- Direct navigation: Click items in lists
- Contextual actions: Buttons on screens lead to related screens
- Back button: Standard Android/iOS back

**Issues:**
- Detail screens don't have drawer (must back out)
- No quick way to jump between participant details
- Print flow navigation separate from main flow

---

## Recommendations

### High Priority (Fix These First)

1. **Make ParticipantRegistrationForm responsive**
   - Impacts: Individual registration, Intake, CSV import, Edit participant
   - Solution: Implement ResponsiveFormGrid

2. **Create mobile-friendly CSV review**
   - Impacts: CSV import flow
   - Solution: Card-based list view for mobile

3. **Fix FileViewerScreen crashes**
   - Impacts: Document viewing
   - Solution: Add error handling + AppBar

4. **Standardize empty states**
   - Impacts: All list screens
   - Solution: Create EmptyState component

5. **Add max width constraints**
   - Impacts: All screens
   - Solution: Use AppConstraints.constrainContent()

### Medium Priority

1. Add pull-to-refresh on all lists
2. Standardize search implementations
3. Fix all date formatting
4. Replace all ElevatedButton with Material 3
5. Add loading indicators consistently

### Low Priority (Polish)

1. Enhance success states (animations, confetti)
2. Add keyboard shortcuts
3. Implement breadcrumb navigation
4. Add recently viewed section in drawer
5. Dark mode support

---

## Flow Quality Matrix

| Flow | Mobile | Tablet | Desktop | Overall |
|------|--------|--------|---------|---------|
| Event Management | ✅ Good | ✅ Good | ⚠️ OK | ✅ 8/10 |
| Individual Registration | ❌ Broken | ⚠️ OK | ✅ Good | ❌ 4/10 |
| CSV Import | ❌ Broken | ⚠️ OK | ✅ Good | ❌ 3/10 |
| Medical Record | ⚠️ OK | ✅ Good | ✅ Excellent | ✅ 8/10 |
| Printing | ⚠️ OK | ✅ Good | ✅ Good | ✅ 7/10 |
| Participant Management | ⚠️ OK | ✅ Good | ✅ Good | ✅ 7/10 |

**Legend:**
- ✅ Excellent: Works perfectly, great UX
- ✅ Good: Works well, minor issues
- ⚠️ OK: Usable but has issues
- ❌ Broken: Major issues, unusable

---

## Related Documentation

- **Technical Details:** `UI_AUDIT_DOCUMENTATION.md`
- **Design Rules:** `DESIGN_RULES_QUICK_REF.md`
- **Implementation Steps:** `UI_STANDARDS_CHECKLIST.md`
- **Design Preferences:** `APP_DESIGN_FEEL.md`
- **Quick Overview:** `UI_AUDIT_OVERVIEW.md`

---

**Last Updated:** 2025-11-06
**Version:** 1.0

💡 **Use this document to understand the complete user experience and identify cross-flow improvements!**
