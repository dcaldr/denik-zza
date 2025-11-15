# Flutter UI Audit & Design Guidelines Documentation

**Project:** Deník ZZA (Medical Camp Journal)
**Initial Audit Date:** 2025-11-05
**Updated:** 2025-11-06
**Scope:** screens2/ and print_ops2/ folders
**Purpose:** UI standardization and responsive design audit

## Update Notes (2025-11-06)
✅ **Verification Complete:** Confirmed all active screens in screens2/ and print_ops2/ have been documented
✅ **2 Additional Screens Documented:** CsvImportSummaryScreen, FileViewerScreen
✅ **Old Folder Verification:** Confirmed lib/screens/ and lib/print_ops/ are NOT actively used (no imports found)
✅ **Total Screens Audited:** 16 screens + navigation components
⚠️ **Recommendation:** Archive or remove old folders (screen/, print_ops/) and deprecated intake_form.dart

---

## Table of Contents
1. [Screen-by-Screen Analysis](#screen-by-screen-analysis)
2. [Cross-Screen Consistency Analysis](#cross-screen-consistency-analysis)
3. [General Improvements & Lessons Learned](#general-improvements--lessons-learned)
4. [Standardization Rules](#standardization-rules)
5. [Technical Implementation Details](#technical-implementation-details)

---

## Screen-by-Screen Analysis

### 1. ParticipantListScreen
**File:** `lib/screens2/participant_list_screen.dart`

#### Layout Description
- **Structure:** Single-column vertical layout with search bar at top, scrollable list below
- **Components:**
  - AppBar with title and action buttons (event detail, add participant)
  - Search field using `PersonAutocomplete` widget
  - Scrollable ListView with `ParticipantListItem` widgets
  - Drawer navigation

#### Responsiveness Analysis
✅ **GOOD:** Flexible height - uses `Expanded` for list
✅ **GOOD:** Column-based layout adapts well to width changes
⚠️ **CONCERN:** No specific handling for very narrow screens (<400px)
✅ **GOOD:** Search field expands to fill available width

#### Consistency Issues
- ✅ Uses standard AppBar pattern (matches other screens)
- ✅ Uses shared `AppDrawer` widget
- ✅ Empty state has icon + text + action button (good pattern)
- ❌ **INCONSISTENCY:** Search implementation differs from EventDetail (uses `PersonAutocomplete` vs plain `TextField`)

#### Design Issues Found
1. **No loading indicator** - List loads but no spinner shown during async operation
2. **Search UX** - Autocomplete dropdown might be confusing when user just wants to filter visible list
3. **No refresh pull gesture** - Mobile users expect pull-to-refresh
4. **Empty state button position** - Centered button feels disconnected from app bar add button

---

### 2. EventList
**File:** `lib/screens2/event_list.dart`

#### Layout Description
- **Structure:** Simple vertical scrollable list
- **Components:**
  - AppBar with title, add button, disabled search button
  - FutureBuilder-wrapped ListView
  - ListTile items with date, participant count, pin button

#### Responsiveness Analysis
✅ **GOOD:** Fully responsive ListView
⚠️ **CONCERN:** No minimum/maximum item width constraints
❌ **BAD:** Pin button + participant count + name can overflow on narrow screens
✅ **GOOD:** Uses DateFormat for consistent date display

#### Consistency Issues
- ✅ Standard AppBar pattern
- ❌ **INCONSISTENCY:** Search button is disabled (placeholder) - confusing UX
- ❌ **INCONSISTENCY:** No empty state handling (just empty list)
- ⚠️ Pin icon behavior differs from modern UX patterns (no visual feedback on tap)

#### Design Issues Found
1. **Trailing widget overflow risk** - Row with Text + Icon + IconButton can overflow
2. **No loading state** - CircularProgressIndicator shows but with no context
3. **Error handling weak** - Just shows error text, no retry action
4. **Disabled search button** - Should be hidden instead of disabled if not functional
5. **Date formatting inconsistency** - Uses manual padding instead of standard DateFormat pattern

---

### 3. ParticipantRegistrationForm
**File:** `lib/screens2/participant_registration_form.dart`

#### Layout Description
- **Structure:** Complex multi-section scrollable form
- **Sections:**
  - 3-column grid layout for basic fields (name, birth, insurance)
  - Guardian contact info (3 columns)
  - Poznámka field (full width, multi-line)
  - Checkboxes (2-column)
  - Restrictions & medications (2-column with custom widgets)
  - Submit button at bottom

#### Responsiveness Analysis
⚠️ **MAJOR CONCERN:** Fixed 3-column grid layout will break on narrow screens
❌ **CRITICAL:** No `LayoutBuilder` or `MediaQuery` to adjust column count
❌ **CRITICAL:** Form will be unusable on phone portrait (<600px width)
✅ **GOOD:** Scrollable container handles vertical overflow
⚠️ Row-based layout with `Expanded(flex: X)` will create tiny fields on small screens

#### Consistency Issues
- ✅ Reusable form component (used in multiple places)
- ❌ **INCONSISTENCY:** Submit button at bottom (other forms use AppBar action)
- ❌ **INCONSISTENCY:** No cancel button (other forms have one)

#### Design Issues Found
1. **CRITICAL: Non-responsive grid** - 3-column layout needs breakpoints (desktop: 3, tablet: 2, phone: 1)
2. **Field sizing** - Birth date + gender combined in nested Row can be cramped
3. **Visual hierarchy weak** - All fields same visual weight, no grouping borders/cards
4. **Auto-fill UX issue** - `guessAndFillFields` triggers on every keystroke (performance concern)
5. **Checkbox section styling** - Plain list, needs card/border for visual grouping
6. **Restrictions section** - Side-by-side layout will break on narrow screens
7. **No field labels abbreviation strategy** - Long labels cause alignment issues

---

### 4. NewRecordPage
**File:** `lib/screens2/new_record_page.dart`

#### Layout Description
- **Structure:** Complex multi-section layout with LayoutBuilder
- **Sections (top to bottom):**
  - Participant info card (horizontal, blue gradient, with inline search)
  - Medical history panel (collapsible with health chips)
  - Record history list (bordered container)
  - Form fields (scrollable: date/time, title, description, poznámka)
  - Action buttons (pinned at bottom)

#### Responsiveness Analysis
✅ **EXCELLENT:** Uses `LayoutBuilder` to detect compact mode (height <= 600px)
✅ **EXCELLENT:** Adjusts spacing based on `isCompact` flag
✅ **GOOD:** Health chips use `Wrap` for responsive wrapping
✅ **GOOD:** Description+poznámka fields use flexible ratio (4:1)
⚠️ **CONCERN:** Participant info section is complex horizontal Row - might squeeze on very narrow screens
✅ **GOOD:** Uses `Expanded` and `Flexible` appropriately

#### Consistency Issues
- ❌ **INCONSISTENCY:** Uses inline search within colored box (unique pattern)
- ❌ **INCONSISTENCY:** Action buttons styled differently (FilledButton + Outlined)
- ✅ **GOOD:** Reuses `PersonAutocomplete` widget
- ✅ **GOOD:** Print buttons follow consistent icon-only pattern

#### Design Issues Found
1. **Complexity overload** - Too many sections compete for attention
2. **Participant box horizontal squeeze** - On narrow screens, participant name truncates heavily
3. **Health info collapse logic** - Threshold values (4/6/8) are magic numbers, should be dynamic
4. **DateTime picker UX** - Separate date/time pickers are tedious, should be combined
5. **Poznámka styling** - Yellow sticky-note styling is creative but may look unprofessional
6. **Print buttons position** - Buttons on far right of date section feel disconnected
7. **Record history takes too little space** - `flex: 2` vs form's `flex: 7` makes history tiny
8. **Opacity on disabled form** - Greying out entire form (opacity 0.4) is too subtle

---

### 5. EventDetail
**File:** `lib/screens2/event_detail.dart`

#### Layout Description
- **Structure:** SingleChildScrollView with padded content
- **Sections:**
  - Event title and metadata (dates, participant count)
  - Description text
  - Search field + add button row
  - Participant list (mapped from filtered array)

#### Responsiveness Analysis
✅ **GOOD:** Scrollable content handles any screen size
⚠️ **CONCERN:** Manual date formatting with `padLeft` is brittle
❌ **BAD:** Search field + IconButton Row has no wrap - will break on very narrow screens
⚠️ **CONCERN:** No minimum/maximum content width constraint

#### Consistency Issues
- ❌ **MAJOR INCONSISTENCY:** Uses plain `TextField` for search (vs `PersonAutocomplete` elsewhere)
- ❌ **INCONSISTENCY:** Empty/no-results states use different widgets than ParticipantListScreen
- ✅ **GOOD:** Disabled edit button explicitly noted with TODO comment

#### Design Issues Found
1. **Search UX confusion** - TextField for search but no clear/reset button
2. **Layout structure weak** - Everything in one Column, no Cards or visual grouping
3. **Date formatting repetition** - Manual date string construction repeated (DT1/DT2 TODOs)
4. **Focus management** - Uses separate FocusNode but could cause issues if not properly disposed
5. **No loading state between searches** - Filtering happens instantly but on larger lists might lag
6. **FIXME comment at top** - "heavily refactor" indicates acknowledged design debt

---

### 6. EventRegistrationForm
**File:** `lib/screens2/event_registration_form.dart`

#### Layout Description
- **Structure:** Simple vertical form in ListView
- **Components:**
  - Title field
  - Description field (multi-line with counter)
  - Date range (two DatePickers in Row)
  - Submit button

#### Responsiveness Analysis
✅ **GOOD:** ListView handles any screen size
✅ **GOOD:** Row with two DatePickers wraps gracefully (uses Expanded)
⚠️ **CONCERN:** No explicit breakpoint handling for very narrow screens
✅ **GOOD:** Padding consistent (16.0 all around)

#### Consistency Issues
- ✅ Uses `CustomDatePicker` widget (shared component)
- ✅ Standard form validation pattern
- ❌ **INCONSISTENCY:** Uses `TextField` for description (vs `TextFormField` for title)
- ❌ **INCONSISTENCY:** Button text changes "Odeslat" vs "Aktualizovat" but label doesn't match other forms

#### Design Issues Found
1. **Description counter behavior** - TextField with maxLength shows counter, but TextFormField doesn't
2. **Date pickers in Row** - No label above Row, just labels on each picker (feels cramped)
3. **No visual hierarchy** - All fields same size, no grouping
4. **Submit button placement** - Floating in ListView (should be pinned bottom or use SliverFillRemaining)
5. **Validation inconsistency** - Title has validator, description doesn't (but has maxLength)

---

### 7. IntakeFormImproved
**File:** `lib/screens2/intake_form_improved.dart`

#### Layout Description
- **Structure:** Column with three main sections
- **Sections:**
  1. `IntakePersonRow` - Person search/selection
  2. `IntakeMainContent` - Scrollable form (ParticipantRegistrationForm + file upload)
  3. `IntakeBottomRow` - Action buttons

#### Responsiveness Analysis
✅ **EXCELLENT:** Uses `ConstrainedBox(maxWidth: 1600)` for desktop optimization
✅ **GOOD:** Sections stack vertically in Column
✅ **GOOD:** Uses `Expanded` for scrollable middle section
⚠️ **CONCERN:** No mobile-specific layout (maxWidth constraint might be too wide)

#### Consistency Issues
- ✅ **EXCELLENT:** Well-architected with controller pattern
- ✅ Uses shared `ParticipantRegistrationForm` component
- ✅ Consistent with "form + actions" pattern

#### Design Issues Found
1. **MaxWidth too large** - 1600px is very wide, content will look stretched on large monitors
2. **No breakpoint handling** - Should have different layouts for mobile/tablet/desktop
3. **Middle section might scroll unnecessarily** - File upload + form is long, could split differently
4. **Regenerating form widget** - Creates new `ParticipantRegistrationForm` instance on state changes (potential performance issue)

---

### 8. CsvImportScreen
**File:** `lib/screens2/csv/import_screen.dart`

#### Layout Description
- **Structure:** Simple vertical layout with SafeArea
- **Components:**
  - Instruction text
  - Help text
  - Selectable file box (clickable, shows selected filename)
  - Button row (Pick file + Continue)

#### Responsiveness Analysis
✅ **GOOD:** Simple vertical layout adapts to any width
✅ **GOOD:** Text wraps naturally
✅ **GOOD:** Buttons in Row are properly sized
✅ **GOOD:** SafeArea handles notches/system UI

#### Consistency Issues
- ✅ Clean, focused UI
- ✅ Standard button elevation and colors
- ✅ Uses FilledButton for primary action (consistent)

#### Design Issues Found
1. **File box UX** - InkWell on entire container but only filename is SelectableText (confusing)
2. **No drag-and-drop** - TODO comment indicates planned feature
3. **Error message placement** - Appears between file box and buttons (might get buried)
4. **Loading state on picker** - CircularProgressIndicator inside button is tiny (16x16)
5. **TODO comment in UI code** - Should be tracked in issue tracker, not inline

---

### 9. CsvReviewTableOverviewScreen
**File:** `lib/screens2/csv/table_overview_screen.dart`

#### Layout Description
- **Structure:** Complex Scaffold with sticky header + scrollable table
- **Sections:**
  - Sticky header (file info, summary panel, filter chips)
  - DataTable with custom sticky column headers
  - Synchronized horizontal scroll (header + body)
  - Bottom action bar (select all, deselect, finalize)

#### Responsiveness Analysis
⚠️ **MAJOR CONCERN:** Forces minimum table width (960px) - will cause horizontal scroll on tablets
✅ **GOOD:** Uses `LayoutBuilder` to measure and sync header widths
✅ **EXCELLENT:** Dual scrollbar setup (vertical + horizontal)
❌ **BAD:** No mobile layout - DataTable is desktop-only pattern
✅ **GOOD:** Summary section uses Wrap for responsive badge layout
⚠️ Column widths are calculated but complex - potential precision errors

#### Consistency Issues
- ❌ **MAJOR INCONSISTENCY:** Completely different UI pattern from rest of app
- ❌ DataTable + sticky headers + dual scroll is advanced pattern not used elsewhere
- ✅ Uses standard buttons (FilledButton, OutlinedButton, TextButton) with correct hierarchy

#### Design Issues Found
1. **CRITICAL: No mobile support** - DataTable requires 960px minimum width
2. **Complex scroll sync** - Two controllers + listeners + postFrameCallback is fragile
3. **RenderTable traversal** - Reading render tree for column widths is hacky (TODO comment acknowledges)
4. **Header width calculation** - `_fallbackHeaderColumnWidths` is 120+ lines of math (overly complex)
5. **Editable cells pattern** - Each cell creates FocusNode + TextEditingController (performance concern for large tables)
6. **Tooltip management complexity** - Manual GlobalKey management for warnings
7. **Sticky header overlay** - Positioned widget overlaying scroll view can have z-index issues
8. **Summary badges clickable but not obvious** - InkWell with borderRadius but no visual affordance

---

### 10. PrintCenterPage
**File:** `lib/print_ops2/print_center.dart`

#### Layout Description
- **Structure:** ListView with FeatureCard widgets
- **Sections:**
  - Title
  - Feature cards (Print person, Print selected, Manage state)
  - Info box (notes)

#### Responsiveness Analysis
✅ **GOOD:** ListView adapts to any screen size
✅ **GOOD:** FeatureCard uses Row with Expanded for text
✅ **GOOD:** Padding consistent (16.0)
⚠️ **CONCERN:** No maximum card width - cards will be very wide on desktop

#### Consistency Issues
- ✅ **EXCELLENT:** Uses Provider for state management
- ✅ Disabled features clearly marked (lock icon + gray + Opacity)
- ✅ Emphasize flag for primary action (elevated card)

#### Design Issues Found
1. **No max width constraint** - Cards stretch to full screen on desktop (looks unprofessional)
2. **Feature cards all same size** - No visual hierarchy beyond elevation
3. **Lock icon small** - 18px lock icon is subtle, disabled state could be clearer
4. **Info box at bottom** - Important notes buried below cards

---

### 11. PersonAndModeFlowPage (PrintCenter sub-screen)
**File:** `lib/print_ops2/print_center.dart`

#### Layout Description
- **Structure:** Multi-step wizard with AnimatedSwitcher
- **Sections:**
  - Step badges (horizontal scroll)
  - Content area (changes per step: person list → mode selection + preview → confirmation)

#### Responsiveness Analysis
✅ **EXCELLENT:** Uses `LayoutBuilder` to switch vertical/horizontal layout (breakpoint: 700px)
✅ **GOOD:** Scrollable step badges handle overflow
✅ **GOOD:** Preview pane + controls adapt to vertical stacking on narrow screens
⚠️ **CONCERN:** PDF preview might be too small on narrow screens

#### Consistency Issues
- ✅ **EXCELLENT:** Step-by-step flow is clear
- ✅ Uses RadioListTile for mode selection (standard pattern)
- ✅ Dialog for print confirmation (standard pattern)

#### Design Issues Found
1. **Step badges all same size** - Active step could be larger/bolder
2. **PDF preview in card** - Card wrapping preview adds unnecessary padding
3. **Mode selection subtitle dynamic** - Complex conditional text (hard to maintain)
4. **TODO notes in UI** - Multiple TODO comments in build method (should be in separate doc)
5. **Dialog content scrollable** - Good, but might be too much content for mobile

---

### 12. AppDrawer (Navigation)
**File:** `lib/screens2/widgets/app_drawer.dart`

#### Layout Description
- **Structure:** Drawer with FutureBuilder for state-dependent menu
- **Sections:**
  - Header (gradient with title)
  - Main workflow section (highlighted orange, always visible)
  - Collapsible "Příprava akce" (ExpansionTile)
  - Collapsible "Zdravotnický filtr" (ExpansionTile)

#### Responsiveness Analysis
✅ **GOOD:** Drawer is fixed width by Flutter design
✅ **GOOD:** ListView handles vertical overflow
✅ **GOOD:** Subtitle text wraps in ListTile
⚠️ **CONCERN:** Long menu items might wrap poorly on small phones

#### Consistency Issues
- ✅ **EXCELLENT:** Consistent navigation pattern throughout app
- ✅ Disabled items clearly indicated (gray color + warning subtitle)
- ✅ Icons consistent with material design

#### Design Issues Found
1. **FutureBuilder for state** - Drawer rebuilds on every open (could cache state)
2. **Main workflow section styling** - Orange gradient + shadow is unique (not reused elsewhere)
3. **Disabled state explanation** - "Vyžaduje akci" subtitle is helpful but verbose
4. **ExpansionTile styling** - No customization, uses default (inconsistent with highlighted main section)
5. **Icon color on disabled** - Gray is subtle but might be too subtle for accessibility

---

### 13. ParticipantDetailPage
**File:** `lib/screens2/participant_detail.dart`

#### Layout Description
- **Structure:** Scrollable ListView with Cards
- **Sections:**
  - Info cards (personal data, insurance, confirmations)
  - Medical records section (list of record cards)
  - Action buttons row

#### Responsiveness Analysis
✅ **GOOD:** Cards stack vertically
✅ **GOOD:** ListView handles scrolling
⚠️ **CONCERN:** Action button row can overflow on narrow screens
⚠️ **CONCERN:** No max width constraint - cards very wide on desktop

#### Consistency Issues
- ✅ Uses Card pattern (consistent with material design)
- ❌ **INCONSISTENCY:** Info rows use `_buildInfoRow` pattern (not used elsewhere)
- ❌ **INCONSISTENCY:** Date formatting uses manual string building (should use DateFormat)

#### Design Issues Found
1. **Row overflow risk** - Two ElevatedButtons in Row with no wrap
2. **No empty state for info** - If data is null, shows "N/A" (could be more helpful)
3. **Medical records date format** - Inconsistent with other screens
4. **No loading state** - FutureBuilder but CircularProgressIndicator not styled
5. **TODO comment** - PrinterWoodoo should be in service (acknowledged tech debt)

---

### 14. ParticipantEditPage
**File:** `lib/screens2/participant_edit_page.dart`

#### Layout Description
- **Structure:** Wrapper screen containing ParticipantRegistrationForm
- **Components:**
  - AppBar with Save action
  - Centered ConstrainedBox (maxWidth: 800)
  - Form in scrollable area
  - Duplicate action buttons at bottom

#### Responsiveness Analysis
✅ **GOOD:** ConstrainedBox limits width on desktop
✅ **GOOD:** Form scrolls in `Expanded` widget
⚠️ **CONCERN:** Max width 800px might be too narrow for 3-column form inside

#### Consistency Issues
- ❌ **INCONSISTENCY:** Has both AppBar "Uložit" button AND bottom "Uložit změny" button (redundant)
- ❌ **INCONSISTENCY:** Bottom button row not present in other forms

#### Design Issues Found
1. **Duplicate save buttons** - AppBar + bottom (confusing UX)
2. **Cancel button styling** - `backgroundColor: Colors.grey` is too flat (should be outlined)
3. **Max width conflict** - Constraining to 800px but form expects more space for 3 columns
4. **Form regeneration** - Creates new form instance in initState (can't update dynamically)

---

### 15. CsvImportSummaryScreen
**File:** `lib/screens2/csv/summary_screen.dart`

#### Layout Description
- **Structure:** Simple vertical layout with summary badges and result list
- **Components:**
  - AppBar with title
  - Drawer navigation
  - File label text
  - Wrap widget with summary badges (Approved, Rejected, Saved, Failed)
  - Result message text
  - Scrollable failure list (if failures exist)
  - Bottom action buttons (Return, Export placeholder)

#### Responsiveness Analysis
✅ **EXCELLENT:** Simple vertical layout adapts to all screen sizes
✅ **GOOD:** Wrap widget for badges handles responsive wrapping
✅ **GOOD:** SafeArea handles system UI properly
✅ **GOOD:** Bottom buttons in separate SafeArea (prevents overlap with system UI)
✅ **GOOD:** Scrollable ListView for failure list

#### Consistency Issues
- ✅ **GOOD:** Uses standard AppDrawer (matches other main screens)
- ✅ **GOOD:** Uses theme colorScheme colors instead of hardcoded colors
- ✅ **GOOD:** Uses Material 3 buttons (TextButton, OutlinedButton)
- ✅ **GOOD:** Has proper test keys for widget testing

#### Design Issues Found
1. **Export button disabled** - "TODO" placeholder but should either implement or hide
2. **No retry/back to review option** - If failures occur, user can't go back to fix them
3. **Failure cards minimal** - Only shows index + message, no context about what data failed
4. **Success state underserved** - When all succeed, just shows text (could be more celebratory)
5. **Badge interaction unclear** - Badges use InkWell but don't do anything (misleading affordance)

---

### 16. FileViewerScreen
**File:** `lib/screens2/widgets/file_viewer_screen_widget.dart`

#### Layout Description
- **Structure:** Full-screen viewer with conditional rendering based on file type
- **Components:**
  - PDF viewer (using PdfPreview widget from printing package)
  - Image viewer (using InteractiveViewer with zoom support)
  - Fallback message for unsupported types

#### Responsiveness Analysis
⚠️ **MAJOR CONCERN:** PDF viewer uses hardcoded fractions (height/1.3, width/2)
❌ **CRITICAL:** maxPageWidth calculation is nonsensical (width * 4)
✅ **GOOD:** InteractiveViewer provides zoom/pan for images
⚠️ **CONCERN:** No AppBar means no way to close the viewer (needs parent navigation)
❌ **BAD:** PDF Container constraints will break on small screens
⚠️ **CONCERN:** No orientation change handling

#### Consistency Issues
- ❌ **MAJOR INCONSISTENCY:** No AppBar (all other screens have one)
- ❌ **MAJOR INCONSISTENCY:** No Drawer (even though it's a full screen)
- ❌ **INCONSISTENCY:** Uses Logger().i() instead of proper logging pattern
- ❌ **INCONSISTENCY:** File extension check is case-insensitive but limited to specific formats

#### Design Issues Found
1. **CRITICAL: No close button** - No way to dismiss the viewer without back gesture/button
2. **CRITICAL: No error handling** - File.readAsBytesSync() will crash if file doesn't exist
3. **PDF constraints nonsensical** - Division by magic numbers (1.3, 2) makes no sense
4. **maxPageWidth bug** - width * 4 is way too large and serves no purpose
5. **No loading indicator** - PDF might take time to load, no feedback
6. **updateFilePath method unused** - Public method but never called (dead code?)
7. **Scaffold without AppBar** - Breaks expected UI pattern
8. **No file size limit** - Could crash on very large files
9. **Logger in production code** - Should use proper logging service
10. **No fallback for corrupted files** - readAsBytesSync will throw exception

---

## Verification Findings

### Old Folder Status (screen/ and print_ops/)
✅ **VERIFIED:** Old folders `lib/screens/` and `lib/print_ops/` are **NOT actively used**
- **Finding:** No imports from these folders exist in the codebase
- **Recommendation:** These folders should be:
  1. Archived (moved to a `/deprecated` or `/legacy` folder)
  2. Or completely removed if version control history is sufficient
  3. Or clearly marked with a DEPRECATED.md file explaining they're obsolete

**Files in old folders include:**
- Login screens (login_page, register_page, forgot_password_page)
- Profile management (profile, change_profile)
- Old action screens (all_actions, action_detail, add_action, edit_action_page)
- Old participant screens (add_participant_page, participant_detail_page)
- Old record screens (new_record_page, record_detail_page, dev_save_new_record)
- Old print UI (printer_ui, printer_woodoo, various print selection screens)
- Old drawer (our_drawer)

**Deprecated screen in screens2:**
- `lib/screens2/intake_form.dart` - Marked with `@Deprecated('Use ImprovedIntakeForm instead')`
  - **Recommendation:** Remove this file or move to deprecated folder

### Active Screen Count
**Total active screens documented:** 16
- 14 from previous audit
- 2 newly documented (CsvImportSummaryScreen, FileViewerScreen)

### Missing UI Components
The following are widget components (not full screens) and are appropriately not documented as screens:
- Various intake widgets (intake_person_row, intake_main_content, intake_bottom_row, intake_action_buttons)
- CSV widgets (summary_section, unparsed_columns_section)
- Print widgets (append_analysis_widget)
- Shared widgets (custom_date_picker, person_autocomplete, participant_list_item, etc.)

These are reusable components called by the main screens and follow good component architecture.

---

## Cross-Screen Consistency Analysis

### Navigation Patterns
| Screen | Navigation Method | Back Button | Drawer | Issues |
|--------|------------------|-------------|--------|--------|
| EventList | AppDrawer | Standard | ✅ | None |
| ParticipantList | AppDrawer | Standard | ✅ | None |
| EventDetail | Manual navigator.push | Standard | ❌ | No drawer |
| NewRecordPage | Manual push | Standard | ❌ | No drawer |
| ParticipantDetail | Manual push | Standard | ❌ | No drawer |
| PrintCenter | AppDrawer | Standard | ❌ | Inconsistent |

**Finding:** Detail screens don't have drawer access - user must back out to main screen to navigate elsewhere.

### Search/Filter Implementations
| Screen | Search Widget | Behavior | Consistency |
|--------|---------------|----------|-------------|
| ParticipantListScreen | PersonAutocomplete | Dropdown with autocomplete | Unique |
| EventDetail | TextField | In-memory filter | Unique |
| EventList | Disabled IconButton | Not functional | Broken |
| CsvReviewTable | ChoiceChips | Status filter | Unique |

**Finding:** Four different search patterns - no reusable component.

### Button Hierarchy (Primary Actions)
| Screen | Primary Button Style | Secondary Button | Cancel Button | Consistency |
|--------|---------------------|------------------|---------------|-------------|
| EventRegistrationForm | ElevatedButton | - | - | Inconsistent (old style) |
| ParticipantRegistrationForm | ElevatedButton | - | - | Inconsistent (old style) |
| CsvReview | FilledButton | OutlinedButton | TextButton | ✅ M3 Correct |
| PrintCenter | FilledButton | OutlinedButton | - | ✅ M3 Correct |
| NewRecordPage | FilledButton | OutlinedButton | - | ✅ M3 Correct |

**Finding:** Mix of ElevatedButton (M2) and FilledButton (M3) - should standardize on M3.

### Form Layouts
| Screen | Layout Type | Columns | Responsive | Mobile-Friendly |
|--------|-------------|---------|-----------|-----------------|
| EventRegistrationForm | Vertical | 1 | ✅ | ✅ |
| ParticipantRegistrationForm | Grid | 3 | ❌ | ❌ |
| EventDetail | Vertical | 1 | ✅ | ✅ |
| IntakeForm | Nested | Variable | ⚠️ | ⚠️ |

**Finding:** ParticipantRegistrationForm's fixed 3-column grid is the main responsive design failure.

### Empty States
| Screen | Empty State Pattern | Icon | Action Button | Consistency |
|--------|-------------------|------|---------------|-------------|
| ParticipantListScreen | Center + Icon + Text + Button | ✅ | ✅ | ✅ Good |
| EventList | No empty state | ❌ | ❌ | ❌ Missing |
| NewRecordPage | Center + Icon + Text | ✅ | ❌ | ⚠️ Partial |
| EventDetail | Center + Icon + Text | ✅ | ❌ | ⚠️ Partial |

**Finding:** Inconsistent empty state patterns - need standard reusable widget.

### Loading States
| Screen | Loading Pattern | Style | Issues |
|--------|----------------|-------|--------|
| EventList | CircularProgressIndicator | Default | No context message |
| ParticipantDetail | CircularProgressIndicator | Default | No context message |
| CsvImportScreen | CircularProgressIndicator in button | Tiny (16x16) | Too small |
| PrintCenter | FutureBuilder | Clean | ✅ Good |

**Finding:** No standardized loading indicator component.

### Date Formatting
| Screen | Date Format Method | Pattern | Issues |
|--------|------------------|---------|--------|
| EventList | DateFormat('dd.MM.yyyy') | ✅ | Consistent |
| EventDetail | Manual .padLeft() | ❌ | Error-prone |
| ParticipantDetail | Manual string concat | ❌ | Inconsistent |
| EventRegistrationForm | DateFormat('dd.MM.yyyy') | ✅ | Consistent |

**Finding:** Mix of DateFormat and manual string building - manual should be eliminated.

### Color & Theming Usage
| Element | Implementation | Issues |
|---------|---------------|--------|
| Primary actions | Mix of hardcoded colors and theme | Inconsistent |
| Backgrounds | `Colors.blue.shade50` etc. | Not using theme |
| Participant box in NewRecordPage | `Colors.blue.shade50` gradient | Hardcoded |
| Status colors in CSV | Hardcoded per status | Not in theme |
| Poznámka field | `Colors.yellow.shade50` | Creative but not thematic |

**Finding:** Heavy use of hardcoded Colors.x.shadeY - should use theme colorScheme.

---

## General Improvements & Lessons Learned

### Major Architectural Issues

#### 1. **Responsive Design Failures**
**Problem:** Many screens fail on mobile devices due to fixed layouts.

**Screens Affected:**
- ParticipantRegistrationForm (3-column grid)
- CsvReviewTableOverviewScreen (960px minimum)
- Participant info section in NewRecordPage (complex horizontal Row)

**Lesson Learned:** Always use LayoutBuilder or MediaQuery for complex layouts. Establish breakpoints:
- Mobile: < 600px (single column)
- Tablet: 600-900px (2 columns)
- Desktop: > 900px (3 columns)

#### 2. **No Design System**
**Problem:** Every screen implements common patterns differently (buttons, cards, spacing, colors).

**Evidence:**
- Mix of ElevatedButton (M2) and FilledButton (M3)
- Hardcoded colors instead of theme
- Inconsistent spacing (8, 10, 12, 16, 20, 24 all used randomly)
- Four different search implementations

**Lesson Learned:** Create shared component library BEFORE building features.

#### 3. **Performance Concerns**
**Problem:** Several performance anti-patterns found.

**Issues:**
- CSV table creates FocusNode + TextEditingController for every cell
- Forms recreated on state changes (not updated)
- RenderTree traversal for measurements
- FutureBuilder rebuilds drawer on every open

**Lesson Learned:** Profile before optimization, but avoid obvious anti-patterns (like creating controllers in build method).

#### 4. **State Management Inconsistency**
**Problem:** Mix of setState, Provider, FutureBuilder, and manual state.

**Evidence:**
- EventList: FutureBuilder in build method
- IntakeFormImproved: Provider + Controller
- ParticipantListScreen: StatefulWidget + setState
- PrintCenter: Provider + ChangeNotifier

**Lesson Learned:** Pick ONE pattern and stick to it. Provider seems to be the chosen pattern but not enforced.

#### 5. **Accessibility (A11y) Not Considered**
**Problem:** No semantic labels, poor contrast, tiny touch targets.

**Issues:**
- Health chips in NewRecordPage use 11px font
- Print icons without labels
- Disabled states barely visible (light gray)
- No screen reader support

**Lesson Learned:** Add Semantics widgets, test with TalkBack/VoiceOver, ensure 44x44 touch targets.

### Good Patterns Found

#### ✅ Things Done Right

1. **AppDrawer Navigation** - Well-architected drawer with state-dependent enabling
2. **PrintCenter Flow** - Step-based wizard is clear and well-structured
3. **Provider for PrintCenter** - Clean state management example
4. **PersonAutocomplete Widget** - Reusable component (should be used more)
5. **CustomDatePicker Widget** - Good abstraction
6. **Key attributes for testing** - Many widgets have Key() for test identification
7. **TODO comments with context** - Tech debt acknowledged inline
8. **Service layer separation** - Services in separate files (ParticipantService, RecordService, etc.)

### Quick Wins (Easy Improvements)

1. **Standardize buttons** - Replace all ElevatedButton with FilledButton/OutlinedButton
2. **Fix date formatting** - Use DateFormat everywhere, remove manual string building
3. **Add empty state widget** - Create `EmptyStateWidget(icon, message, action?)` component
4. **Add loading widget** - Create `LoadingIndicator(message?)` component
5. **Fix EventList search** - Either implement or remove the disabled button
6. **Add pull-to-refresh** - Use RefreshIndicator on all list screens
7. **Spacing constants** - Define `AppSpacing.small/medium/large` constants
8. **Remove duplicate buttons** - ParticipantEditPage has two save buttons
9. **Add max width to cards** - Constrain cards to 800-1200px on desktop
10. **Theme colors** - Move all hardcoded colors to ThemeData

---

## Standardization Rules

### 1. Layout Rules

#### Breakpoints
```dart
class AppBreakpoints {
  static const double mobile = 600;    // < 600: mobile
  static const double tablet = 900;    // 600-900: tablet
  static const double desktop = 1200;  // > 900: desktop

  static bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= desktop;
}
```

#### Form Grid Columns
```dart
// RULE: Forms must adapt column count based on screen width
int getFormColumns(BuildContext context) {
  if (AppBreakpoints.isMobile(context)) return 1;
  if (AppBreakpoints.isTablet(context)) return 2;
  return 3; // desktop
}
```

#### Content Max Width
```dart
class AppConstraints {
  static const double maxContentWidth = 1200;
  static const double maxFormWidth = 800;
  static const double maxCardWidth = 600;

  // RULE: All main content must be constrained
  static Widget constrainContent(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }
}
```

### 2. Spacing Rules

```dart
class AppSpacing {
  // RULE: Use these constants, never hardcode spacing
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // RULE: Consistent padding patterns
  static const EdgeInsets screenPadding = EdgeInsets.all(medium);
  static const EdgeInsets cardPadding = EdgeInsets.all(medium);
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(
    vertical: small,
    horizontal: 0,
  );
}
```

### 3. Button Rules

```dart
// RULE: Always use Material 3 button types
// PRIMARY ACTION: FilledButton
// SECONDARY ACTION: OutlinedButton
// TERTIARY/CANCEL: TextButton

// Example:
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  spacing: AppSpacing.medium,
  children: [
    TextButton(onPressed: () {}, child: Text('Cancel')),    // Tertiary
    OutlinedButton(onPressed: () {}, child: Text('Save')),  // Secondary
    FilledButton(onPressed: () {}, child: Text('Submit')),  // Primary
  ],
)
```

### 4. Color Rules

```dart
// RULE: NEVER use Colors.blue.shade50 etc. directly
// ALWAYS use theme colors

// ❌ BAD
Container(color: Colors.blue.shade50)

// ✅ GOOD
Container(color: Theme.of(context).colorScheme.primaryContainer)

// Define semantic colors in theme:
class AppColors {
  static ColorScheme lightScheme = ColorScheme.light(
    primary: Color(0xFF1976D2),
    primaryContainer: Color(0xFFE3F2FD),
    secondary: Color(0xFFFFA726),
    secondaryContainer: Color(0xFFFFE0B2),
    error: Color(0xFFD32F2F),
    errorContainer: Color(0xFFFFCDD2),
    surface: Colors.white,
    background: Color(0xFFF5F5F5),
    // ... etc
  );
}
```

### 5. Typography Rules

```dart
// RULE: Use theme text styles, never hardcode fontSize
// Define app-specific text styles in theme

class AppTextStyles {
  static TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
  );
}

// Usage:
Text('Title', style: Theme.of(context).textTheme.titleLarge)
```

### 6. Component Rules

#### Empty State Component
```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          SizedBox(height: AppSpacing.medium),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: AppSpacing.medium),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(Icons.add),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
```

#### Loading Indicator Component
```dart
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: AppSpacing.medium),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
```

### 7. Date Formatting Rules

```dart
// RULE: Use DateFormat, never manual string building

// ❌ BAD
'${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}'

// ✅ GOOD
class AppDateFormats {
  static final DateFormat short = DateFormat('dd.MM.yyyy', 'cs_CZ');
  static final DateFormat long = DateFormat('d. MMMM yyyy', 'cs_CZ');
  static final DateFormat time = DateFormat('HH:mm', 'cs_CZ');
  static final DateFormat dateTime = DateFormat('dd.MM.yyyy HH:mm', 'cs_CZ');
}

// Usage:
Text(AppDateFormats.short.format(date))
```

### 8. Form Validation Rules

```dart
// RULE: Centralize validators

class AppValidators {
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Toto pole'} je povinné';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'Pole'} nesmí být delší než $max znaků';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Zadejte platnou emailovou adresu';
    }
    return null;
  }
}
```

### 9. Navigation Rules

```dart
// RULE: All list/index screens must have drawer
// Detail screens don't need drawer (user can back out)

// RULE: Use named routes for main screens
class AppRoutes {
  static const String eventList = '/events';
  static const String participantList = '/participants';
  static const String newRecord = '/record/new';
  static const String printCenter = '/print';

  static Map<String, WidgetBuilder> routes = {
    eventList: (context) => EventList(),
    participantList: (context) => ParticipantListScreen(),
    newRecord: (context) => NewRecordPage(),
    printCenter: (context) => PrintCenterPage(),
  };
}
```

### 10. Accessibility Rules

```dart
// RULE: Minimum touch target size
const double minTouchTarget = 44.0;

// RULE: Minimum font size
const double minFontSize = 12.0;

// RULE: Always add semantic labels to icon buttons
IconButton(
  icon: Icon(Icons.add),
  tooltip: 'Přidat účastníka',
  onPressed: () {},
  // Also add semanticsLabel for screen readers
  semanticLabel: 'Přidat účastníka',
)

// RULE: Use Semantics widget for complex interactions
Semantics(
  button: true,
  enabled: true,
  label: 'Vybrat soubor CSV',
  child: InkWell(...),
)
```

---

## Technical Implementation Details

### Screen-Specific Technical Issues

#### ParticipantRegistrationForm: Responsive Grid Fix

**Problem:** Fixed 3-column grid breaks on mobile.

**Current Code:**
```dart
Row(
  children: [
    Expanded(child: _buildTextField('jmeno', ...)),
    Expanded(child: _buildTextField('prijmeni', ...)),
    Expanded(child: _buildTextField('cisloPojisteni', ...)),
  ],
)
```

**Solution:**
```dart
class _ResponsiveFormGrid extends StatelessWidget {
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final columns = AppBreakpoints.isMobile(context) ? 1 :
                   (AppBreakpoints.isTablet(context) ? 2 : 3);

    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += columns) {
          final rowChildren = children.skip(i).take(columns).toList();
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren
                .map((child) => Expanded(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: child,
                )))
                .toList(),
            ),
          );
          rows.add(SizedBox(height: AppSpacing.small));
        }
        return Column(children: rows);
      },
    );
  }
}
```

#### CsvReviewTableOverviewScreen: Mobile Alternative

**Problem:** DataTable requires 960px minimum width - unusable on mobile.

**Solution:** Implement alternative mobile view with Card-based list:

```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < AppBreakpoints.mobile) {
        return _buildMobileCardList();
      }
      return _buildDesktopTable();
    },
  );
}

Widget _buildMobileCardList() {
  return ListView.builder(
    itemCount: rows.length,
    itemBuilder: (context, index) {
      final row = rows[index];
      return Card(
        child: ExpansionTile(
          title: Text('${row.fields['jmeno']} ${row.fields['prijmeni']}'),
          subtitle: _buildStatusChip(row.status),
          children: [
            _buildFieldRow('Číslo pojištění', row.fields['cislo_pojisteni']),
            _buildFieldRow('Datum narození', row.fields['datum_narozeni']),
            // ... all fields as list
            _buildActionButtons(row),
          ],
        ),
      );
    },
  );
}
```

#### NewRecordPage: Participant Info Squeeze Fix

**Problem:** Participant info box horizontal Row squeezes on narrow screens.

**Current Code:**
```dart
Row(
  children: [
    Container(...), // Icon
    SizedBox(width: 12),
    Expanded(flex: 2, child: Column(...)), // Info
    SizedBox(width: 12),
    Expanded(flex: 1, child: Column(...)), // Search
  ],
)
```

**Solution:** Stack vertically on mobile:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return Column(
        children: [
          _buildParticipantInfo(),
          SizedBox(height: 8),
          _buildSearchField(),
        ],
      );
    }
    return Row(...); // Keep horizontal on desktop
  },
)
```

### State Management Migration

**Recommendation:** Standardize on Provider + ChangeNotifier pattern.

**Implementation Guide:**

1. **Create ViewModel/Controller classes:**
```dart
class ParticipantListController extends ChangeNotifier {
  List<MemoryOsoba> _participants = [];
  List<MemoryOsoba> _filteredParticipants = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<MemoryOsoba> get participants => _filteredParticipants;
  bool get isLoading => _isLoading;

  Future<void> loadParticipants() async {
    _isLoading = true;
    notifyListeners();

    _participants = await _database.getParticipantsByCurrentEvent();
    _applyFilter();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredParticipants = _participants;
    } else {
      _filteredParticipants = _participants.where((p) =>
        p.jmeno.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.prijmeni.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }
}
```

2. **Use in widget:**
```dart
class ParticipantListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParticipantListController()..loadParticipants(),
      child: _ParticipantListView(),
    );
  }
}

class _ParticipantListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ParticipantListController>();

    if (controller.isLoading) {
      return LoadingIndicator();
    }

    return ListView.builder(
      itemCount: controller.participants.length,
      itemBuilder: (context, index) {
        return ParticipantListItem(
          participant: controller.participants[index],
        );
      },
    );
  }
}
```

### Performance Optimizations

#### 1. CSV Table Cell Controllers

**Problem:** Creating TextEditingController + FocusNode for every cell.

**Current:** O(rows × columns) controllers created upfront.

**Solution:** Lazy initialization + pooling:

```dart
class _ControllerPool {
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController getController(String key, String initialValue) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialValue);
    } else if (_controllers[key]!.text != initialValue) {
      _controllers[key]!.text = initialValue;
    }
    return _controllers[key]!;
  }

  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    _controllers.clear();
  }
}
```

#### 2. Form Widget Recreation

**Problem:** ParticipantRegistrationForm recreated on every state change.

**Solution:** Use `didUpdateWidget` to update existing form:

```dart
class _ParticipantRegistrationFormState extends State<...> {
  @override
  void didUpdateWidget(covariant ParticipantRegistrationForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.osoba != oldWidget.osoba) {
      _updateFieldsFromOsoba(widget.osoba);
    }
  }

  void _updateFieldsFromOsoba(MemoryOsoba? osoba) {
    if (osoba != null) {
      _controllers['jmeno']!.text = osoba.jmeno;
      _controllers['prijmeni']!.text = osoba.prijmeni;
      // ... update all fields
      setState(() {}); // Trigger rebuild with new values
    }
  }
}
```

### Theme Implementation

**Complete theme definition:**

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.lightScheme,
    textTheme: AppTextStyles.textTheme,

    // Button themes
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: AppSpacing.medium,
        ),
        minimumSize: Size(120, 44),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: AppSpacing.medium,
        ),
        minimumSize: Size(120, 44),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.medium,
        ),
        minimumSize: Size(88, 44),
      ),
    ),

    // Card theme
    cardTheme: CardTheme(
      elevation: 1,
      margin: EdgeInsets.symmetric(
        vertical: AppSpacing.small,
        horizontal: 0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.medium,
      ),
      filled: true,
    ),

    // App bar theme
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AppColors.lightScheme.primary,
      foregroundColor: AppColors.lightScheme.onPrimary,
    ),
  );
}
```

### Testing Recommendations

**Widget tests should verify responsive behavior:**

```dart
testWidgets('ParticipantRegistrationForm adapts to mobile', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(375, 667)), // iPhone SE size
        child: ParticipantRegistrationForm(),
      ),
    ),
  );

  // Verify fields stack vertically
  final formRows = find.byType(Row);
  expect(formRows, findsNWidgets(1)); // Should be single column
});

testWidgets('ParticipantRegistrationForm shows 3 columns on desktop', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(1200, 800)), // Desktop size
        child: ParticipantRegistrationForm(),
      ),
    ),
  );

  // Verify 3-column grid
  final firstRow = find.byType(Row).first;
  final row = tester.widget<Row>(firstRow);
  expect(row.children.length, 3);
});
```

---

## Implementation Priority

### Phase 1: Critical Fixes (Week 1-2)
1. Fix ParticipantRegistrationForm responsive grid ❗
2. **FIX FileViewerScreen** ❗❗ - Add error handling, AppBar, proper constraints (currently will crash on missing files)
3. Standardize all buttons to Material 3 (FilledButton/OutlinedButton)
4. Create and use AppSpacing constants
5. Fix date formatting (remove all manual string building)
6. Add max width constraints to all screens
7. Remove or implement Export button in CsvImportSummaryScreen
8. **Archive/remove old folders** - lib/screens/ and lib/print_ops/ (not in use)

### Phase 2: Component Library (Week 3-4)
1. Create EmptyState component
2. Create LoadingIndicator component
3. Create ResponsiveFormGrid component
4. Create StandardAppBar component
5. Implement complete AppTheme

### Phase 3: Consistency Refactor (Week 5-6)
1. Standardize all search implementations
2. Add pull-to-refresh to all lists
3. Implement consistent empty states
4. Fix navigation (drawer on list screens only)
5. Migrate to Provider pattern consistently

### Phase 4: Mobile Support (Week 7-8)
1. Create mobile layout for CsvReviewTable
2. Add mobile-specific layouts to NewRecordPage
3. Test all screens on actual devices
4. Implement accessibility improvements
5. Add responsive image/icon sizing

---

## Conclusion

This Flutter app has **solid architecture** (service layer, state management attempts) but suffers from **lack of design system** and **insufficient responsive design**.

### Critical Issues (Must Fix Immediately)
1. **FileViewerScreen will crash** - No error handling for file operations ❗❗
2. **ParticipantRegistrationForm is unusable on mobile** - Fixed 3-column grid ❗
3. **CsvReviewTable requires 960px width** - No mobile support ❗

### Major Issues
4. **No design system** - Every screen reinvents common patterns
5. **Hardcoded colors and spacing** throughout
6. **Mix of Material 2 and Material 3** components
7. **Old code not cleaned up** - lib/screens/ and lib/print_ops/ folders unused

### Audit Summary
- **Total Screens Audited:** 16 active screens
- **Screens with Critical Issues:** 3 (FileViewerScreen, ParticipantRegistrationForm, CsvReviewTable)
- **Screens with Major Concerns:** 7
- **Well-Designed Screens:** 6 (CsvImportSummaryScreen, IntakeFormImproved, PrintCenter, etc.)

Following the standardization rules in this document will resolve these issues and create a maintainable, professional Flutter application.

**Estimated effort:** 8 weeks for one developer to implement all improvements.

**Quick wins** (Phases 1-2) can be completed in 3-4 weeks and will significantly improve app quality.

**URGENT:** FileViewerScreen should be fixed immediately before production use to prevent crashes.
