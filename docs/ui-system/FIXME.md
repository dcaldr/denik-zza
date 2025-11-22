# FIXME: Functional Issues & Missing Features

**Critical functional issues identified in APP_DESIGN_FEEL.md**

These are NOT UI/design issues - these are missing features and broken functionality that need to be fixed.

---

## 🚨 HUGE MISSES (Priority: Critical)

### 1. IntakeForm - No Way to Create Participant from Selector
**File:** APP_DESIGN_FEEL.md:389

**Problem:**
- User must EXIT intake form → create participant → come back
- Very bad workflow interruption

**Expected Behavior:**
- Participant selector should have "+ Create New Participant" option inline
- Opens participant creation dialog/modal
- After creation, automatically selects new participant in intake form
- User never leaves the intake flow

**Impact:** 10/10 - Breaks main workflow

---

### 2. IntakeForm - No Arrived Counter
**File:** APP_DESIGN_FEEL.md:390

**Problem:**
- No counter showing arrived participants (e.g., "23/56 arrived")

**Expected Behavior:**
- Counter at top of IntakeForm showing: `[arrived count] / [total participants] arrived`
- Updates in real-time as participants are marked
- Helps track intake progress

**Impact:** 10/10 - Missing critical information

---

### 3. CSV Import - Wrong Navigation Destination
**File:** APP_DESIGN_FEEL.md:435

**Problem:**
- "Zpět na výběr CSV" button goes to EventList screen
- Should go back to CSV import start screen

**Expected Behavior:**
- Button navigates to CsvImportScreen (start of flow)
- NOT to EventList

**Impact:** 7/10 - Confusing navigation

---

### 4. ParticipantDetail - Needs Complete Redesign
**File:** APP_DESIGN_FEEL.md:522, 556

**Problem:**
- Uses old/earliest prototype data model
- Missing data fields (meds, restrictions, parents contacts)
- Shows null values
- Feels detached from rest of app
- UI feels forgotten and not updated as app grew

**Expected Behavior:**
- Complete UI/UX redo using existing patterns from other screens
- Show current data model (not prototype model)
- Hide null values
- Consistent with rest of app

**Impact:** 9/10 - Screen is broken/outdated

---

## ⚠️ Important Functional Issues (Priority: High)

### 5. ParticipantListScreen - Missing Participant Detail Click
**File:** APP_DESIGN_FEEL.md:139

**Problem:**
- List items are not clickable to go to detail
- Only the "Detail" button works
- Inconsistent with expected behavior

**Expected Behavior:**
- Entire list item clickable to open ParticipantDetail
- "Detail" button can be removed or kept for clarity

---

### 6. ParticipantListScreen - Search Feels Broken
**File:** APP_DESIGN_FEEL.md:135-137

**Problems:**
- Search only narrows list, no way to go back to full list
- Displays dropdown options instead of directly filtering the list

**Expected Behavior:**
- Search directly filters the visible list
- Clearing search text shows full list again
- No unnecessary dropdown

---

### 7. NewRecordPage - Účastník Section Missing Click-to-Detail
**File:** APP_DESIGN_FEEL.md:241-242

**Problem:**
- Účastník section is not clickable to open participant detail
- Missing box grouping icon showing účastník + jméno

**Expected Behavior:**
- Entire účastník section clickable to open ParticipantDetail
- Visual affordance (icon) showing it's clickable

---

### 8. NewRecordPage - Blocking Popups (Age to Birthdate)
**File:** APP_DESIGN_FEEL.md:247

**Problem:**
- Age-to-birthdate conversion uses blocking popup
- Feels intrusive

**Expected Behavior:**
- Less intrusive, more smooth interaction
- Maybe inline tooltip or gentle highlight instead of popup

---

### 9. NewRecordPage - Save/Close Button Positions Feel Backwards
**File:** APP_DESIGN_FEEL.md:244

**Problem:**
- Save button feels like it should be on right side
- Close button on left

**Expected Behavior:**
- Verify button order follows common UX patterns
- Save (primary action) typically on right in Western UIs

---

### 10. EventList - Multiple Pin Changes Produce Many Toasts
**File:** APP_DESIGN_FEEL.md:92

**Problem:**
- Pinning multiple events shows many toasts stacking up
- Overwhelming

**Expected Behavior:**
- Group toast messages or debounce
- Show single message: "3 events pinned" instead of 3 separate toasts

---

## 📋 Missing Features (Priority: Medium)

### 11. IntakeForm - File Upload Issues
**File:** APP_DESIGN_FEEL.md:386-388

**Problems:**
- User must commit to first uploaded file (no back feature)
- PDF viewer doesn't take full height
- No filter for PDF/image only

**Expected Behavior:**
- Allow changing uploaded file before final submit
- PDF viewer should fill available space
- File picker should filter to PDF/image formats only

---

### 12. CSV Import Summary - Poor "Sell" of Inserted Items
**File:** APP_DESIGN_FEEL.md:433-434

**Problem:**
- Summary shows "schváleno 4 uloženo 4" but feels empty
- No list of actually inserted participants

**Expected Behavior:**
- Show inserted participants list (similar to participant list screen)
- Include search if many participants imported
- Better visual feedback of success

---

### 13. CSV Confirm Table - Missing Back Button
**File:** APP_DESIGN_FEEL.md:437

**Problem:**
- Table confirmation step has no back button

**Expected Behavior:**
- Add back button to return to file selection

---

### 14. ParticipantRegistrationForm - No Upload File Popup
**File:** APP_DESIGN_FEEL.md:788

**Problem:**
- Missing file upload popup on registration page
- Only available in intake form

**Expected Behavior:**
- Add file upload capability to participant registration

---

### 15. EventDetail - No Connection to Intake Form
**File:** APP_DESIGN_FEEL.md:319

**Problem:**
- EventDetail doesn't naturally connect to intake form
- App doesn't promote main workflow

**Expected Behavior:**
- Add prominent "Start Intake" or similar button on EventDetail
- Guide users through natural workflow

---

### 16. App-Wide - Menu vs Back Button Inconsistency
**File:** APP_DESIGN_FEEL.md:623-624

**Problem:**
- Some screens have menu when they shouldn't
- Some screens have back button when they should have menu
- Confusing navigation

**Expected Behavior:**
- Establish consistent pattern:
  - Top-level screens: Menu (hamburger)
  - Detail/child screens: Back button
- Document and apply across all screens

---

### 17. AppDrawer - Disable Elements Need Explanation Tooltips
**File:** APP_DESIGN_FEEL.md:641

**Problem:**
- Disabled menu items don't explain why they're disabled

**Expected Behavior:**
- Add tooltip on hover/click explaining why item is disabled
- Reuse existing tooltip component from elsewhere in app

---

### 18. PrintCenter - Tisk Description Wrong Language Tone
**File:** APP_DESIGN_FEEL.md:492

**Problem:**
- "Tisk vybraných" uses tykání instead of pasivní tone

**Expected Behavior:**
- Fix to use consistent passive/formal tone

---

### 19. PrintCenter - Confirm Screen Language Issue
**File:** APP_DESIGN_FEEL.md:494

**Problem:**
- "Jak dopadl tisk" screen uses odd language ("referenční stav")
- Long texts feel off

**Expected Behavior:**
- Simplify language
- Maybe two-step confirm: if all good, don't ask more (just hint other options)

---

### 20. PrintCenter - Tisk Functionality Mismatch
**File:** APP_DESIGN_FEEL.md:493

**Problem:**
- Mishap between what "tisk vybraných" should do and what is commented it does

**Expected Behavior:**
- Investigate and clarify intended behavior
- Fix implementation or comments

---

### 21. ParticipantDetail - Tisk Button Produces Different Print Confirm
**File:** APP_DESIGN_FEEL.md:530

**Problem:**
- Tisk button on ParticipantDetail produces different type of print confirm
- Seems not to work correctly

**Expected Behavior:**
- Investigate why print flow is different
- Unify print flow across app

---

## 📊 Priority Summary

| Priority | Count | Issues |
|----------|-------|--------|
| **Critical (HUGE MISSES)** | 4 | #1, #2, #3, #4 |
| **High** | 10 | #5-#14 |
| **Medium** | 7 | #15-#21 |

---

## 🚀 Recommended Action Order

### Phase 1: HUGE MISSES (Immediate)
1. IntakeForm: Add participant creation inline (#1)
2. IntakeForm: Add arrived counter (#2)
3. ParticipantDetail: Complete redesign (#4)
4. CSV: Fix navigation destination (#3)

### Phase 2: High Priority Functional Fixes
5. Make list items clickable (#5, #7)
6. Fix search behavior (#6)
7. Fix popup intrusiveness (#8)
8. Fix toast stacking (#10)
9. Add missing file upload (#11, #14)

### Phase 3: Medium Priority & Polish
10. Improve CSV summary (#12)
11. Fix navigation consistency (#16)
12. Add tooltips for disabled items (#17)
13. Fix print flow issues (#18-#21)
14. Connect EventDetail to Intake (#15)

---

## ⚠️ Important Notes

**Consistency work (UI) should happen AFTER functional fixes:**
- User's top priority is "APP UI CONSISTENCY" (#1 in action items)
- BUT consistency work should NOT delay critical functional fixes
- Many functional issues (#1-#4) block main workflow

**Don't change during consistency work:**
- All form fields must stay in same order
- All buttons must stay in same positions (unless explicitly fixing like #9)
- Navigation structure must stay the same (except fixing broken nav like #3, #16)

---

**Created:** 2025-11-15
**Source:** APP_DESIGN_FEEL.md (user feedback)
**Status:** Documented, awaiting prioritization and implementation

💡 **Note:** This file tracks functional issues only. UI/consistency issues are tracked in `design-system/CONSISTENCY_PLAN.md`
