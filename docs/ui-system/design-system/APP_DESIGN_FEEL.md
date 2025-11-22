# App Design Feel & Decision Log

**Deník ZZA - What to Keep, What to Change**

This document helps you make informed design decisions by documenting what you like and dislike about each screen.

> **Instructions:** Fill in the "Your Notes" sections with your thoughts. Be honest about what works and what doesn't!

---

## 🎯 Overall App Vision

### What is the core purpose of this app?
**Your Notes:**
```
[e.g., "Medical journal for camp medics - must be fast, reliable, work offline, easy to use under pressure"]
Medical jurnal for medic voulenteers, should simplify admin and paperwork;
 provide some structure since the ministry decree doesnt fully cover all that 
must have:
- offline support
- reliable data storage
- easy to use UI

```

### Who are the primary users?
**Your Notes:**
```
[e.g., "Camp medical staff, age 20-40, varying tech skills, use on tablets/laptops during camp"]
It is for a people that are voluteering to provide medical aid during summer camps 
this can be students(w basic curse), nurses, doctors, parents (w basic curse)
all can have varying tech skills, so the app must be intuitive and easy to use

MAIN USAGE DEVICES:
- notebooks (laptops) -- very mostly 
    - can be win10+ , linux  (and macOS but i cannot test for that one)
- tablets -- less recomended
 android mostly, some android flavours (Huawei, LineageOS, Graphene OS,   etc, if i manage to test it), ios -- less used but should work too
- phones -- not recomended but should work too
    - same as tablets for OSes
    - mostly for future use cases mainly sync to notebooks (not main use case now)
        - like seeing participants, adding newRecords


```

### What feeling should the app convey?
**Your Notes:**
```
[e.g., "Professional but not clinical, efficient, trustworthy, calm"]
- Professional but not clinical
- Efficient
- Trustworthy
 - feel that the app is realibe and resonse well and that the action work/ didn't work

```

### Key requirements that must NOT change:
**Your Notes:**
```
[List features/elements that are essential:]
- current offline support
- control items on screens for this change 
    - if form has 10 fields a b c d ... then after UI change the form must still have 10 fields (in same order) a b c d ...
- same for buttons and actions -- if not **DIRECTLY ASKED ** to change them, they must stay the same
- between page navigation also must stay the same


```

---

## 📱 Screen-by-Screen Design Feel

### 1. EventList (Akce / Event Management)

**Current Purpose:** Main landing page - list all medical camp events

#### What I LIKE about this screen:
**Your Notes:**
```
[e.g., "Simple list, easy to scan", "Pin button is useful"]
- simple list, easy to scan i like it this way 
- "action pinning" feature is useful
- num of participants visible right away
```

#### What I DISLIKE about this screen:
**Your Notes:**
```
[e.g., "Search button is disabled and confusing", "Empty state is boring"]
- multiple pin changes produce many toasts in a row 
-
-
```

#### Elements that MUST stay:
**Your Notes:**
```
[e.g., "Pin functionality", "Date display", "Participant count"]
- the entire current list functionality 
-
-
```

#### Ideas for improvement:
**Your Notes:**
```
[e.g., "Add event status badges", "Show date countdown for upcoming events"]
- action name probably could be more accented (?) 
- maybe the list UI isn't uniform from rest of app?
-
```

---

### 2. ParticipantListScreen (Seznam účastníků)

**Current Purpose:** View all participants in selected event

#### What I LIKE:
**Your Notes:**
```
- name is there and age also 
- detail button is nice to have
- search (there are some implementation issues but the idea is good)
- event detail at the top (but i belive wrong icon for it)
- adding aprticipant at the top right is good
```

#### What I DISLIKE:
**Your Notes:**
```
- ugly list items UI 
- search feels broken for given purpose (i know its reused component but still)
    - serch only narrows no wa to go back to full list
    - displays drop down options -> it could directly filter the list? 
    
- the list items are not clickable to go to detail (only the button)
-
```

#### Must-keep elements:
**Your Notes:**
```
- all from like section
- fixed searchbar 
- routes to other screens (detail, add participant)
- the list (obviously:)
```

#### Improvement ideas:
**Your Notes:**
```
- might also display rodne cislo if present     
- icons for persons with  restrictions/medications etc
- (lot later) option for seeing  group/unit number/name; and room/cabin/... number or marker  <--- this feature is completelly missing now but in future should be added
-
```

---

### 3. ParticipantRegistrationForm (Registrace účastníka)

**Current Purpose:** Add/edit participant details, restrictions, medications

#### What I LIKE:
**Your Notes:**
```
[e.g., "Auto-fill feature saves time", "All info on one screen"]
- autofill feature from rodne cislo to datum narozeni and gender is great
    - supporting order of form items that rodne cislo is before datum and gender
- that it doesn't force to fill (most of)  the fields 
- the 3 column layout of form (on desktop) with "double field" for birthday and gender
- one screen for all main info
-
```

#### What I DISLIKE:
**Your Notes:**
```
[e.g., "Too cramped on laptop", "Hard to see on mobile", "Restriction section confusing"]
- its completely form side of window to side of window (no margins)  
- spills to take whole screen (even in situations where it feels unnecesarry)
-
```

#### Must-keep elements:
**Your Notes:**
```
[e.g., "All form fields are necessary", "Restriction and medication tracking"]
- All form fields are necessary (and all other data points)
- all from like section 
- BEware its reused on intake form 
```

#### Improvement ideas:
**Your Notes:**
```
[e.g., "Split into sections with tabs?", "Better visual grouping", "Mobile-friendly layout"]
- some visual grouping of form fields ?? probably dont overuse?? 
- *gentle* animation for auto-fill action (and gentle highlight the filled fields ) ?
    - maybe glowing outline for a second or so (where the light circles around the filled fields) <-- but **gentle** 
    - it is mostly for new users to notice that something happened, but baware this can run 100 times so it must be **gentle** 
-
```

**Special Note on Layout:**
```
Current: 3-column grid (breaks on mobile)

Preferred layout:
[x] Keep 3 columns on desktop, adapt to 1 column on mobile
[ ] Use 2-column layout everywhere
[ ] Other: ___________________________
and somehow manage "potvrzení" and "omezení a léky" sections on mobile
```

---

### 4. NewRecordPage (Nový záznam / Medical Record Entry)

**Current Purpose:** Create new medical records for participants

#### What I LIKE:
**Your Notes:**
```
[e.g., "All context visible (participant info + history)", "Record history is helpful"]
- current actions are great 
- icon panel above the form 
- all context visible (participant info + history)
- that it is themed (but i dont know if fully to go but some notes can be made)
-
```

#### What I DISLIKE:
**Your Notes:**
```
[e.g., "Too cluttered", "Participant selection box takes too much space", "Poznámka yellow is odd"]
- účastník section
    - could be clickable to open participant detail ? with hidden box grouping icon účastník + jméno **HUGE MISS**
    - could add info similar to list item ( rodne cislo if present 
- analyse if it still uses mockups as badge suggests 
- the uložit and zavřít buttons are switched positions ? like feels save should be on right side ?
- spaceing is off form -> huge space --> bottom buttons
- blocking popups (age to birthdate) - should be less intrusive and more smooth 
```

#### Must-keep elements:
**Your Notes:**
```
[e.g., "Health history chips", "Recent records list", "Print buttons"]
- all from like section
- all that are now present
- beware huge fight in icon panel above the form -- putting something to the left and something to the right was extreme pain - dont break it 
-
```

#### Improvement ideas:
**Your Notes:**
```
[e.g., "Collapsible sections", "Cleaner participant selection", "Better date/time picker"]
- the identified missing go to participant detail 
- maybe more unified UI across app
-
```

**Special Notes:**
```
Participant info box (blue gradient):
[ ] Like it, keep it
[ ] Dislike it, remove gradient
[x] It's okay, could be better

Poznámka field (yellow sticky note style):
[x] Like it, creative
[ ] Dislike it, unprofessional
[ ] Neutral

Health history collapse behavior:
[ ] Works well
[ ] Collapses too aggressively
[x] Should show more by default
```

---

### 5. EventDetail (Detail akce)

**Current Purpose:** View event details and participants

#### What I LIKE:
**Your Notes:**
```
- top overview part is good
- searching and adding participant is good (not even having the problem like in participant list screen -- here it filters the list direcly correcly it seems))
- button for adding participant at top right is good
```

#### What I DISLIKE:
**Your Notes:**
```
- the list of participants is not clickable (reused component mentioned above) 
- spacing from side of screens feels off and different from rest of app
-
```

#### Must-keep elements:
**Your Notes:**
```
- what i like section
- to have the list be same as participantList (in its screen) so it is consistent
-
```

#### Improvement ideas:
**Your Notes:**
```
- maybe some connection to intake form ? now generally it feels the app isn't naurally connected for the main workflow 
-
-
```

---

### 6. EventRegistrationForm (Vytvoření akce)

**Current Purpose:** Create/edit medical camp events

#### What I LIKE:
**Your Notes:**
```
- creates a new event and its simple
- ready for other structures in future (per event settings...) 
-
```

#### What I DISLIKE:
**Your Notes:**
```
- streches full width of screen -- no margins
- no edits (but that is missing feature not ui/design problem)
- entire spacing and layout feels off 
```

#### Must-keep elements:
**Your Notes:**
```
- the entire form functionality (critical) 
-
-
```

#### Improvement ideas:
**Your Notes:**
```
- edit functionality (now mising but should be added later)
-
-
```

---

### 7. IntakeFormImproved (Přijímací formulář)

**Current Purpose:** Complete intake process with document upload

#### What I LIKE:
**Your Notes:**
```
- options for uploading documents is great
- changeing participant data before submission is great
- marking arrived is great
- **love** the main action button at bottom right (colors etc) 
- zoom and scroll for pdf/image viewer is great
-
```

#### What I DISLIKE:
**Your Notes:**
```
- spacing is off two columns and probably too much space on both sides
- dev markers (but that is temporary)
- how it takes space is off 
- second column file upload section
    - user must commit to first updated file (no back feat) 
    - at least the pdf viewer doesnt take full height
    - doesnt have filter for pdf/image only
- **HUGE MISS** in select person no way to have new participant created from there (only way is to exit the form, create participant, then come back -- very bad flow)
- **HUGE MISS** no counter of arrived participants (should be somewhere at top) ! 
```

#### Must-keep elements:
**Your Notes:**
```
- what i like section
- two column layout on desktop (mobile adapts to one column with step per section)
-
```

#### Improvement ideas:
**Your Notes:**
```
-HUGE MISSES -- all must asap :
    - in select participant a way to create new participant directly from there
    - somewhere at top a counter of arrived participants (like 23/56 arrived)
- mobile adapts to one column with step per section and something to tell there is second section 
- (future feature) rotate images before upload
- (future feature) stich multiple images into one pdf before upload
-
```

---

### 8. CSV Import Flow (Hromadný import)

**Screens:** CsvImportScreen → CsvReviewTable → CsvImportSummaryScreen

#### What I LIKE about CSV import:
**Your Notes:**
```
[e.g., "Saves tons of time", "Review step prevents errors", "Summary is clear"]
- the flow is intuitive 
- has ist own deisgn language that is consistent across the flow -- good job, not sure about rest of app but here it is good
- manages bit malformed data well
- gives user overview and control before finalizing, in a non overwhelming way
```

#### What I DISLIKE:
**Your Notes:**
```
[e.g., "Table is hard to use", "Can't fix errors in the review step", "Export button doesn't work"]
- shrnutí importu could have better "sell" the items inserted - now its empty with schváleno 4 uloženo 4 
    - maybe inserted participants list (similar to participant list screeen search and all that but only for this import?) 
- zpět na výběr csv **wrong destination** it goes to event list not to csv import start screen
- confirm table missing back button
```

#### Must-keep elements:
**Your Notes:**
```
[e.g., "Column mapping", "Row-by-row approval", "Error reporting"]
- all i like section
- the table on confirmation step (**must stay as is**) only UI can be improved no new logic no less logic
- both way scroll of table (vert and horz)
```

#### Improvement ideas:
**Your Notes:**
```
[e.g., "Allow editing in review table", "Better mobile view", "Template download"]
- doesnt need to be mobile frinendly - only nice to have 
-
-
```

**Special Notes on CSV Table:**
```
Current table (960px minimum width, doesn't work on mobile):

Preferred solution:
[ ] Keep table on desktop, create card-based view for mobile
[x] Make table scrollable horizontally on mobile see other
[ ] Simplify table to work on all screens
[x] Other: now some vertical and horizonal scroll is present but for very small screens cannot be used well,
i belive entire page should be redesigned for mobile support changing elements to take less space etc. <-- see very very later 

```

---

### 9. PrintCenter (Tisk dokumentů)
This must be revisited after most is implemented now its half done so feel is incomplete

**Current Purpose:** Print medical forms, participant lists, etc.

#### What I LIKE:
**Your Notes:**
```
[e.g., "Feature cards are clear", "Print preview is helpful"]
- step approach is good
- preview is good
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
[e.g., "Cards too wide on desktop", "Disabled features confusing", "Too many steps"]
- i know its not finished 
- tisk vybraných description uses wrong language tone (tykání instead of pasivní) 
- i belvie there is now mishap between what should tisk vybraných do and what is commented it does -- needs clarification and investigation 
- the confirmation "jak dopadl tisk" screen it feels off long texts maybe language "referenční stav" 
   - maybe two step confirm ie if all good dont ask more? (and just hint what are other options)
```

#### Must-keep elements:
**Your Notes:**
```
[e.g., "PDF preview", "Mode selection", "Person selection"]
- tisk osoby 
- the multistep flow
-
```

#### Improvement ideas:
**Your Notes:**
```
[e.g., "Quick print button", "Recent prints history", "Print templates"]
- shortcuts 
- per peron / per event selection (now its only per person) and related logic
- tisk vybraných (více osob naráz) needs better selectors and filers
    - ie. name, all medication sel, restrictions sel, age range sel, group/unit sel, room/cabin/... sel
- can reuse pdf viewver from intake form - the zoom and scroll is great there
-
```

---

### 10. ParticipantDetail (Detail účastníka)
 Needs **complete** UI/UX redo even for actionable items -- seems forgotten, try to rewrite using existing patterns and parts 
**Current Purpose:** View detailed participant information

#### What I LIKE:
**Your Notes:**
```
- quick get to new record button is great
- quick get to tisk button is great (?if works?- seems not -- > produces different type of print confirm ?! ) 
-
```

#### What I DISLIKE:
**Your Notes:**
```
- the ui feels off -- spacing and layout
- feels too much boxy 
- some info missing (parents contacts etc) 
- null values shown 
- feels detached from the rest if app and not updated as it growed 
- pojišťovací údaje can be with osobní údaje section ?
- missing meds and restrictions 
```

#### Must-keep elements:
**Your Notes:**
```
- the buttons tisk and nový záznam
- records list
- osobní údaje section when complete 
```

#### Improvement ideas:
**Your Notes:**
```
- **URGENT** **complete** redesign of entire screen using existing patterns and parts from rest of app
- needs showing  current data we now have (now uses earliest prototype data model)
-
```

---

### 11. FileViewerScreen (Prohlížeč souborů)
 Did not find attached to the screen file viewer is part of some screens in intake form it was dicussed 
**Current Purpose:** View uploaded PDFs and images

#### What I LIKE:
**Your Notes:**
```
[e.g., "Full-screen view is good", "Zoom works well for images"]
-
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
[e.g., "No close button!", "Crashes if file missing", "PDF rendering weird"]
-
-
-
```

#### Must-keep elements:
**Your Notes:**
```
[e.g., "PDF support", "Image support", "Zoom capability"]
-
-
-
```

#### Improvement ideas:
**Your Notes:**
```
[e.g., "Add close button", "Better error handling", "Add AppBar"]
-
-
-
```

---

### 12. AppDrawer (Hlavní menu)

**Current Purpose:** Navigate between main sections

#### What I LIKE:
**Your Notes:**
```
[e.g., "Clear sections", "Disabled state explanation", "Main workflow highlighted"]
- great looking now
- main workflow items at top with new record highlighted -- perfect
- UI good looking and stylish and general feel good
-
```

#### What I DISLIKE:
**Your Notes:**
```
[e.g., "Orange section too prominent", "Too many menu items", "Confusing organization"]
- sometimes its confusing in screeens that have menu and should not have and some screens have back button and should have had menu 
    - this menu/back button dilema needs to be resolved and unified across app
-
```

#### Must-keep elements:
**Your Notes:**
```
[e.g., "All current menu items", "Disabled state indicators"]
- keep current menu items and structure 
-
-
```

#### Improvement ideas:
**Your Notes:**
```
[e.g., "Icons for all items", "Search in menu", "Recently used section"]
- disable elements should have some explanation tooltip on hover or click (somewhere in app already used -- can be reused) 
-
-
```

---

## 🎨 Visual Design Preferences
need for open feel across app, slight medical but simple and clean
generally between csv import flow and newRecord page with elements from intake form (buttons)
### Colors

#### Primary color (currently blue):
**Your Notes:**
```
[ ] Love it, keep blue
[x] It's okay
[ ] Would prefer: ___________________________
```

#### Background colors:
something that feels open and clean
```
Current: White backgrounds, light blue/grey accents

Preference:
[x] Keep current
[ ] Want darker mode
[ ] Want more color
[x] Other: ___________________________
```

#### Accent colors (warning, error, success):
love the butttons from intake form <-- those should stand as example for rest of app
```
Currently: Standard Material colors

Preference:
[x] Keep standard Material colors
[ ] Want custom medical-themed colors
[x] Other: if for buttons and actions (might be misunderstanding this question) -- for bigger actions next to each otehr its good to have vibrant like intake form,
for small actions or single actions newest material standard is ok
```

---

### Typography
must support czech diacritics well
#### Font size:
need for more "packed" approach on some screens 
```
[ ] Current sizes are good
[ ] Too small, increase default size
[x] Too large, decrease default size
[x] Mixed - some screens need adjustment: some screens already are pretty well packed csv; new  record page
```

#### Font weight:
**Your Notes:**
```
[x] Current weights are good
[ ] Want bolder headings
[ ] Want lighter body text
[ ] Other: ___________________________
```

---

### Spacing & Density

#### Overall information density:
need for more open feel on most screens
```
[x] Too cramped, need more whitespace
[ ] Good balance
[ ] Too spacious, show more info per screen
[x] Varies by screen: csv import good and some others as well
```

#### Card/section spacing:
**Your Notes:**
```
[ ] Current spacing is good
[ ] Want tighter spacing
[ ] Want looser spacing
```

---

### Interactive Elements

#### Button style:
dont take away intake form buttons :) but for some screens they are too vibrant
```
Current: Material 3 filled/outlined buttons

Preference:
[x] Keep Material 3 style as default
[ ] Want more rounded buttons
[ ] Want flatter design
[x] Other: if for buttons and actions (might be misunderstanding this question) -- for bigger actions next to each otehr its good to have vibrant like intake form,
for small actions or single actions newest material standard is ok
```

#### Form fields:
more open feel -- minimalistic approach based on material 3- but minimalistic 
```
Current: Outlined input fields

Preference:
[ ] Keep outlined style
[ ] Want filled/underlined style
[ ] Want more prominent borders
[x] Other: less intrusive borders 
```

---

## 🔀 User Flow Preferences
discussed at later stage,  but probably neeeds to have natural flow across app to suport main workflow and promote next steps
### CSV Import Flow

Current steps: Select file → Review table → Finalize → Summary

**Your Notes:**
```
This flow is:
[x] Perfect, don't change
[ ] Too many steps
[ ] Missing steps (which?): ___________________________

Suggested flow:
___________________________
___________________________
```

---

### Participant Registration Flow

Current: Open intake form → Fill details → Upload docs → Submit

**Your Notes:**
```
This flow is:
[ ] Perfect, don't change
[ ] Too complex
[x] Missing steps (which?): upload file popup on registrtion page missing now (if not for intake form) 

Suggested flow:
___________________________
___________________________
```

---

### Medical Record Creation Flow

Current: Open NewRecordPage → Select participant → Fill record → Save → Optional print

**Your Notes:**
```
This flow is:
[x] Perfect, don't change
[ ] Too many steps
[x] Should auto-save drafts
[ ] Should integrate with print better

Suggested flow:
___________________________
___________________________
```

---

### Printing Flow

Current: PrintCenter → Select person → Choose mode → Preview → Confirm → Print

**Your Notes:**
```
This flow is:
[ ] Perfect, don't change
[ ] Too many steps
[x] Should have "quick print" shortcut
[ ] Other: ___________________________

Suggested flow:
___________________________
___________________________
```

---

## 📊 Priority Matrix

Rank these improvements from 1-10 (1 = not important, 10 = critical):

### Technical Fixes
- [6] `/10` Fix FileViewerScreen crashes
- [7] `/10` Make ParticipantRegistrationForm work on mobile
- [2] `/10` Make CSV table work on mobile
- [9] `/10` Consistent spacing across app
- [9] `/10` Consistent colors across app
- [9] `/10` Consistent buttons across app

### UX Improvements
- [7] `/10` Better empty states
- [6] `/10` Better loading indicators
- [5] `/10` Pull-to-refresh on lists
- [7] `/10` Better error messages
- [5] `/10` Keyboard shortcuts
- [4] `/10` Dark mode

### Features
- [10] `/10` Offline support
- [8] `/10` Auto-save drafts
- [8] `/10` Search functionality
- [7] `/10` Advanced filtering
- [6] `/10` Bulk operations
- [6] `/10` Data export

---

## 🚀 Action Items

Based on your notes above, what are the TOP 3 things to improve?

### 1. Most Important:
**Your Notes:**
```
APP UI CONSISTENCY ACROSS THE APP <-- JUST THIS FOR NOW
```

### 2. Second Priority:
**Your Notes:**
```
___________________________
___________________________
```

### 3. Third Priority:
**Your Notes:**
```
___________________________
___________________________
```

---

## 📝 Design Decisions Log

Use this section to document key decisions as you work through improvements.

### Decision 1: [Title]
**Date:** YYYY-MM-DD
**Decision:**
```
[What was decided]
```
**Reasoning:**
```
[Why this decision was made]
```
**Impact:**
```
[What screens/features are affected]
```

---

### Decision 2: [Title]
**Date:** YYYY-MM-DD
**Decision:**
```

```
**Reasoning:**
```

```
**Impact:**
```

```

---

## 🔗 Related Documentation

- **Full Technical Audit:** `UI_AUDIT_DOCUMENTATION.md`
- **Quick Rules:** `DESIGN_RULES_QUICK_REF.md`
- **Implementation Guide:** `UI_STANDARDS_CHECKLIST.md`
- **User Flows:** `USER_FLOWS.md`
- **Overview:** `UI_AUDIT_OVERVIEW.md`

---

**CREATED:** 2025-11-06
**Version:** 1.0

💡 **Tip:** Keep this document updated as you work through improvements. Your future self will thank you!

**UPDATED:** 2025-15-11
**version:** 1.1 - focus on app consistency