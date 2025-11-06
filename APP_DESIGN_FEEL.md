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



```

### Who are the primary users?
**Your Notes:**
```
[e.g., "Camp medical staff, age 20-40, varying tech skills, use on tablets/laptops during camp"]



```

### What feeling should the app convey?
**Your Notes:**
```
[e.g., "Professional but not clinical, efficient, trustworthy, calm"]



```

### Key requirements that must NOT change:
**Your Notes:**
```
[List features/elements that are essential:]
-
-
-


```

---

## 📱 Screen-by-Screen Design Feel

### 1. EventList (Akce / Event Management)

**Current Purpose:** Main landing page - list all medical camp events

#### What I LIKE about this screen:
**Your Notes:**
```
[e.g., "Simple list, easy to scan", "Pin button is useful"]
-
-
-
```

#### What I DISLIKE about this screen:
**Your Notes:**
```
[e.g., "Search button is disabled and confusing", "Empty state is boring"]
-
-
-
```

#### Elements that MUST stay:
**Your Notes:**
```
[e.g., "Pin functionality", "Date display", "Participant count"]
-
-
-
```

#### Ideas for improvement:
**Your Notes:**
```
[e.g., "Add event status badges", "Show date countdown for upcoming events"]
-
-
-
```

---

### 2. ParticipantListScreen (Seznam účastníků)

**Current Purpose:** View all participants in selected event

#### What I LIKE:
**Your Notes:**
```
-
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
-
-
-
```

#### Must-keep elements:
**Your Notes:**
```
-
-
-
```

#### Improvement ideas:
**Your Notes:**
```
-
-
-
```

---

### 3. ParticipantRegistrationForm (Registrace účastníka)

**Current Purpose:** Add/edit participant details, restrictions, medications

#### What I LIKE:
**Your Notes:**
```
[e.g., "Auto-fill feature saves time", "All info on one screen"]
-
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
[e.g., "Too cramped on laptop", "Hard to see on mobile", "Restriction section confusing"]
-
-
-
```

#### Must-keep elements:
**Your Notes:**
```
[e.g., "All form fields are necessary", "Restriction and medication tracking"]
-
-
-
```

#### Improvement ideas:
**Your Notes:**
```
[e.g., "Split into sections with tabs?", "Better visual grouping", "Mobile-friendly layout"]
-
-
-
```

**Special Note on Layout:**
```
Current: 3-column grid (breaks on mobile)

Preferred layout:
[ ] Keep 3 columns on desktop, adapt to 1 column on mobile
[ ] Use 2-column layout everywhere
[ ] Other: ___________________________

```

---

### 4. NewRecordPage (Nový záznam / Medical Record Entry)

**Current Purpose:** Create new medical records for participants

#### What I LIKE:
**Your Notes:**
```
[e.g., "All context visible (participant info + history)", "Record history is helpful"]
-
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
[e.g., "Too cluttered", "Participant selection box takes too much space", "Poznámka yellow is odd"]
-
-
-
```

#### Must-keep elements:
**Your Notes:**
```
[e.g., "Health history chips", "Recent records list", "Print buttons"]
-
-
-
```

#### Improvement ideas:
**Your Notes:**
```
[e.g., "Collapsible sections", "Cleaner participant selection", "Better date/time picker"]
-
-
-
```

**Special Notes:**
```
Participant info box (blue gradient):
[ ] Like it, keep it
[ ] Dislike it, remove gradient
[ ] It's okay, could be better

Poznámka field (yellow sticky note style):
[ ] Like it, creative
[ ] Dislike it, unprofessional
[ ] Neutral

Health history collapse behavior:
[ ] Works well
[ ] Collapses too aggressively
[ ] Should show more by default
```

---

### 5. EventDetail (Detail akce)

**Current Purpose:** View event details and participants

#### What I LIKE:
**Your Notes:**
```
-
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
-
-
-
```

#### Must-keep elements:
**Your Notes:**
```
-
-
-
```

#### Improvement ideas:
**Your Notes:**
```
-
-
-
```

---

### 6. EventRegistrationForm (Vytvoření akce)

**Current Purpose:** Create/edit medical camp events

#### What I LIKE:
**Your Notes:**
```
-
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
-
-
-
```

#### Must-keep elements:
**Your Notes:**
```
-
-
-
```

#### Improvement ideas:
**Your Notes:**
```
-
-
-
```

---

### 7. IntakeFormImproved (Přijímací formulář)

**Current Purpose:** Complete intake process with document upload

#### What I LIKE:
**Your Notes:**
```
-
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
-
-
-
```

#### Must-keep elements:
**Your Notes:**
```
-
-
-
```

#### Improvement ideas:
**Your Notes:**
```
-
-
-
```

---

### 8. CSV Import Flow (Hromadný import)

**Screens:** CsvImportScreen → CsvReviewTable → CsvImportSummaryScreen

#### What I LIKE about CSV import:
**Your Notes:**
```
[e.g., "Saves tons of time", "Review step prevents errors", "Summary is clear"]
-
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
[e.g., "Table is hard to use", "Can't fix errors in the review step", "Export button doesn't work"]
-
-
-
```

#### Must-keep elements:
**Your Notes:**
```
[e.g., "Column mapping", "Row-by-row approval", "Error reporting"]
-
-
-
```

#### Improvement ideas:
**Your Notes:**
```
[e.g., "Allow editing in review table", "Better mobile view", "Template download"]
-
-
-
```

**Special Notes on CSV Table:**
```
Current table (960px minimum width, doesn't work on mobile):

Preferred solution:
[ ] Keep table on desktop, create card-based view for mobile
[ ] Make table scrollable horizontally on mobile
[ ] Simplify table to work on all screens
[ ] Other: ___________________________

```

---

### 9. PrintCenter (Tisk dokumentů)

**Current Purpose:** Print medical forms, participant lists, etc.

#### What I LIKE:
**Your Notes:**
```
[e.g., "Feature cards are clear", "Print preview is helpful"]
-
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
[e.g., "Cards too wide on desktop", "Disabled features confusing", "Too many steps"]
-
-
-
```

#### Must-keep elements:
**Your Notes:**
```
[e.g., "PDF preview", "Mode selection", "Person selection"]
-
-
-
```

#### Improvement ideas:
**Your Notes:**
```
[e.g., "Quick print button", "Recent prints history", "Print templates"]
-
-
-
```

---

### 10. ParticipantDetail (Detail účastníka)

**Current Purpose:** View detailed participant information

#### What I LIKE:
**Your Notes:**
```
-
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
-
-
-
```

#### Must-keep elements:
**Your Notes:**
```
-
-
-
```

#### Improvement ideas:
**Your Notes:**
```
-
-
-
```

---

### 11. FileViewerScreen (Prohlížeč souborů)

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
-
-
-
```

#### What I DISLIKE:
**Your Notes:**
```
[e.g., "Orange section too prominent", "Too many menu items", "Confusing organization"]
-
-
-
```

#### Must-keep elements:
**Your Notes:**
```
[e.g., "All current menu items", "Disabled state indicators"]
-
-
-
```

#### Improvement ideas:
**Your Notes:**
```
[e.g., "Icons for all items", "Search in menu", "Recently used section"]
-
-
-
```

---

## 🎨 Visual Design Preferences

### Colors

#### Primary color (currently blue):
**Your Notes:**
```
[ ] Love it, keep blue
[ ] It's okay
[ ] Would prefer: ___________________________
```

#### Background colors:
**Your Notes:**
```
Current: White backgrounds, light blue/grey accents

Preference:
[ ] Keep current
[ ] Want darker mode
[ ] Want more color
[ ] Other: ___________________________
```

#### Accent colors (warning, error, success):
**Your Notes:**
```
Currently: Standard Material colors

Preference:
[ ] Keep standard Material colors
[ ] Want custom medical-themed colors
[ ] Other: ___________________________
```

---

### Typography

#### Font size:
**Your Notes:**
```
[ ] Current sizes are good
[ ] Too small, increase default size
[ ] Too large, decrease default size
[ ] Mixed - some screens need adjustment: ___________________________
```

#### Font weight:
**Your Notes:**
```
[ ] Current weights are good
[ ] Want bolder headings
[ ] Want lighter body text
[ ] Other: ___________________________
```

---

### Spacing & Density

#### Overall information density:
**Your Notes:**
```
[ ] Too cramped, need more whitespace
[ ] Good balance
[ ] Too spacious, show more info per screen
[ ] Varies by screen: ___________________________
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
**Your Notes:**
```
Current: Material 3 filled/outlined buttons

Preference:
[ ] Keep Material 3 style
[ ] Want more rounded buttons
[ ] Want flatter design
[ ] Other: ___________________________
```

#### Form fields:
**Your Notes:**
```
Current: Outlined input fields

Preference:
[ ] Keep outlined style
[ ] Want filled/underlined style
[ ] Want more prominent borders
[ ] Other: ___________________________
```

---

## 🔀 User Flow Preferences

### CSV Import Flow

Current steps: Select file → Review table → Finalize → Summary

**Your Notes:**
```
This flow is:
[ ] Perfect, don't change
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
[ ] Missing steps (which?): ___________________________

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
[ ] Perfect, don't change
[ ] Too many steps
[ ] Should auto-save drafts
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
[ ] Should have "quick print" shortcut
[ ] Other: ___________________________

Suggested flow:
___________________________
___________________________
```

---

## 📊 Priority Matrix

Rank these improvements from 1-10 (1 = not important, 10 = critical):

### Technical Fixes
- [ ] `/10` Fix FileViewerScreen crashes
- [ ] `/10` Make ParticipantRegistrationForm work on mobile
- [ ] `/10` Make CSV table work on mobile
- [ ] `/10` Consistent spacing across app
- [ ] `/10` Consistent colors across app
- [ ] `/10` Consistent buttons across app

### UX Improvements
- [ ] `/10` Better empty states
- [ ] `/10` Better loading indicators
- [ ] `/10` Pull-to-refresh on lists
- [ ] `/10` Better error messages
- [ ] `/10` Keyboard shortcuts
- [ ] `/10` Dark mode

### Features
- [ ] `/10` Offline support
- [ ] `/10` Auto-save drafts
- [ ] `/10` Search functionality
- [ ] `/10` Advanced filtering
- [ ] `/10` Bulk operations
- [ ] `/10` Data export

---

## 🚀 Action Items

Based on your notes above, what are the TOP 3 things to improve?

### 1. Most Important:
**Your Notes:**
```
___________________________
___________________________
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

**Last Updated:** 2025-11-06
**Version:** 1.0

💡 **Tip:** Keep this document updated as you work through improvements. Your future self will thank you!
