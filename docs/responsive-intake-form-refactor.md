# Responsive Intake Form Refactor - Master Planning Document

> **Created:** 2026-01-06  
> **Last Updated:** 2026-01-06 v4  
> **Status:** 🔄 Active Planning - Gap Analysis Complete  
> **Priority:** High - Core workflow screen

---

## 1. Purpose & Usage Guidelines

### Why This Document Exists

This document tracks our efforts to properly implement responsive/adaptive design for the **Intake Form** (and secondarily, the Participant Registration Form). Previous attempts have suffered from:

1. **Circular problem-solving** - fixing one constraint issue breaks another
2. **Shallow understanding of Flutter layout** - using `Container` without understanding constraints flow
3. **One-issue-at-a-time approach** - losing sight of the complete solution when focusing on individual problems
4. **Going in circles** - repeatedly trying approaches that have already been proven not to work

### When To Use This Document

| Situation | Action |
|-----------|--------|
| **Starting work on intake form layout** | Read Sections 2, 5, & 11 to avoid repeating past mistakes |
| **Hit a constraint error** | Check Section 2 for similar patterns |
| **Planning a new approach** | Add to Section 4 (Thinking Process) |
| **Making implementation decisions** | Document in Section 3 |
| **Trying a specific widget/pattern** | Log result in Section 2 |
| **Considering design system changes** | Check Section 8 for approval status |

### Critical Rules

1. **NO implementation without completed planning** - all approaches must be documented first
2. **Check Section 2 before trying any approach** - don't repeat failures
3. **Document ALL attempts and outcomes** - even if they seem unrelated
4. **Update thinking process** - keep track of reasoning to prevent circular logic
5. **Design system changes require explicit approval** - flag in Section 8

---

## 2. Attempted Solutions Log

> Add entries here using the format below. This prevents re-trying failed approaches.  
> **Use Date + Version (e.g., 2026-01-06 v1, 2026-01-06 v2) to track multiple attempts per day.**

### Template

```markdown
### [Approach Name]
**Date:** YYYY-MM-DD vX  
**Files Modified:** list of files  
**Problem Addressed:** what we tried to fix  
**What We Tried:** technical description  
**Result:** ✅ Success | ⚠️ Partial | ❌ Failed  
**Why It Failed/Worked:** root cause analysis  
**Lesson Learned:** what to remember  
```

### Previous Attempts (Pre-Document)

**Note:** These are reconstructed from conversation history. Add details as discovered.

#### Raw Container/SizedBox with Fixed Heights
**Date:** Pre-2026-01 v1  
**Problem Addressed:** Making the form fit on screen  
**What We Tried:** Using hardcoded heights for sections  
**Result:** ❌ Failed  
**Why It Failed:** Doesn't adapt to different screen sizes; causes overflow on small screens, wastes space on large screens  
**Lesson Learned:** Never use fixed pixel heights for main layout containers

#### Nested ScrollViews
**Date:** Pre-2026-01 v2  
**Problem Addressed:** Overflow when content exceeds screen  
**What We Tried:** Multiple ScrollViews nested (CustomScrollView containing Column containing RestrictionsWidget with internal ListView)  
**Result:** ⚠️ Partial  
**Why It Failed:** "Scroll wiggle" effect; conflicting scroll controllers; unbounded constraints passed to children  
**Lesson Learned:** Need clear scroll scope - either page scrolls OR internal widgets scroll (not both competing)

#### Expanded Without Bounded Parent
**Date:** Pre-2026-01 v3  
**Problem Addressed:** Making RestrictionsWidget fill available space  
**What We Tried:** Using `Expanded` on RestrictionsWidget  
**Result:** ❌ Failed  
**Why It Failed:** Parent had unbounded height (was inside a Column without fixed height) → RenderFlex children have non-zero flex but incoming height constraints are unbounded  
**Lesson Learned:** `Expanded` only works when parent HAS a finite size to expand INTO

---

## 3. Decisions Log

> Record major design decisions here with rationale.

### Decision: Keep 1600px and add to Design System
**Date:** 2026-01-06 v3  
**Context:** `ConstrainedBox(maxWidth: 1600)` is used in intake form but isn't in design system  
**Chosen:** Add `wideContentMaxWidth: 1600.0` to design system  
**Status:** ✅ Approved

### Decision: Defer micro-spacing tokenization
**Date:** 2026-01-06 v3  
**Context:** Scattered 2px, 4px spacing values in forms  
**Chosen:** Defer until solution is implemented  
**Status:** ✅ Approved

### Decision: Large screens - prefer scaling, but not mandatory
**Date:** 2026-01-06 v3  
**Context:** How should content behave on >1920px screens?  
**Chosen:** Prefer scaling content up, acceptable if solution caps and centers  
**Status:** ✅ Approved

### Decision: Use adaptive input density
**Date:** 2026-01-06 v4  
**Context:** Form inputs look too large/spacious for PC mouse+keyboard use  
**Chosen:** Implement smart density system - compact on PC, standard on touch devices  
**Constraints:** Must prevent extremes (e.g., font size 5px)  
**Status:** 🔶 Needs deeper analysis during implementation

---

## 4. Thinking Process Log

> Use this section to document reasoning and prevent circular logic.

### Target Screen Sizes (Finalized)

| Size | Dimensions | Notes | Priority |
|------|------------|-------|----------|
| **Flutter Test Default** | 800 x 600 | Must work - tests run here | Must Pass |
| **Common Laptop** | 1366 x 768 | Common PC size | High |
| **Full HD** | 1920 x 1080 | Should look optimal | Primary |
| **QHD+** | 2560 x 1440+ | Should scale up (preferred) or center | Nice-to-have |

### Column Strategy (Finalized)

**IntakeMainContent Structure:**
- Left column: **ParticipantRegistrationForm** (all form fields)
- Right column: **FileViewer** ("Second Column" area)

**Within ParticipantRegistrationForm:**
- Desktop (≥900px): 3 fields per row
- Tablet (600-899px): 2 fields per row
- Mobile (<600px): 1 field per row

---

## 5. Visual Problem Analysis (2026-01-06 v4)

> **CRITICAL: Screenshots provided by user showing actual bugs**

### Screenshot 1: Fullscreen - FORM COMPLETELY DISAPPEARS

![Fullscreen bug - form disappears](uploaded_image_0_1767724052494.png)

**Observations:**
- ❌ **LEFT COLUMN (form) is completely invisible** - only "Second Column" header and file upload button remain
- The entire ParticipantRegistrationForm content vanishes on fullscreen
- This is a **CRITICAL BUG** - the primary content is not rendering

**Root Cause Hypothesis:**
- Constraint propagation failure at fullscreen widths
- Possibly related to flex values (4+3) causing the left column to get 0 width?
- Or the form's internal sizing is collapsing

---

### Screenshot 2: Default Window Size - Form Visible

![Default size - form visible](uploaded_image_1_1767724052494.png)

**Observations:**
- ✅ Form IS visible with form fields showing
- ⚠️ Only **2 columns** of fields visible (Jméno | Příjmení, not 3)
- ⚠️ Window appears wide enough for 3 columns, but getting 2
- The form fills left side, "Second Column" fills right

**Spacing Issues Noted:**
- Large vertical gap between search widget and first form row
- Input fields appear tall/spacious (touch-optimized, not PC-optimized)

---

### Screenshot 3: Scrolled View - Bottom of Form

![Scrolled view - bottom of form](uploaded_image_2_1767724052494.png)

**Observations:**
- ⚠️ "Potvrzení" section visible, but cramped at bottom
- ⚠️ "Omezení a alergie" and "Léky" labels visible but input area cut off
- Still only 2 columns (Jméno rodiče | Email rodiče)
- Excessive space between search bar and form content visible

---

### Summary of Visual Issues

| Issue | Severity | Location |
|-------|----------|----------|
| Form disappears on fullscreen | 🔴 Critical | IntakeMainContent |
| Only 2 columns instead of 3 on desktop | 🟠 Medium | ParticipantRegistrationForm |
| Excessive vertical spacing below search | 🟡 Low | IntakePersonRow / gap |
| Input fields too tall for PC | 🟡 Low | Form field styling |
| Restrictions section cramped | 🟠 Medium | _buildRestrictionsSection |

---

## 6. Anti-Patterns & Bad Practices Analysis

### ✅ Approved Changes

| Item | Location | Change | Status |
|------|----------|--------|--------|
| `ConstrainedBox(maxWidth: 1600)` | intake_form_improved.dart:153 | Add to design system | ✅ Approved |
| `SizedBox(width: 24)` | intake_main_content.dart:65 | Use `AppSpacing.xxl` | ✅ Approved |

### 🔶 Pending Discussion

| Item | Location | Issue | Status |
|------|----------|-------|--------|
| `BoxConstraints(maxHeight: 400)` | intake_main_content.dart:122 | Magic number for mobile file viewer | 🔶 Discuss |
| `screenHeight < 800` | restrictions_widget.dart:150 | Local threshold vs design system | 🔶 Tolerable |
| Micro-spacing (4px, 2px) | Various | Not tokenized | 🔶 Deferred |

---

## 7. Questions - All Answered ✅

| # | Question | Answer | Date |
|---|----------|--------|------|
| 1 | Target screen sizes? | 800x600 (test), 1920x1080 (primary), scale for larger | v3 |
| 2 | Column strategy? | 3 form fields per row on desktop | v3 |
| 3 | 1600px constraint? | Keep, add to design system | v3 |
| 4 | Micro-spacing? | Defer until implementation | v3 |
| 5 | Large screens? | Prefer scale, acceptable to cap | v3 |
| 6 | Disappearing column? | **Form content completely vanishes on fullscreen** (see screenshot) | v4 |
| 7 | Form fields too large? | Yes, height and "feel" - need adaptive density | v4 |
| 8 | 3-column layout? | Yes, within the form itself (left side of intake page) | v4 |
| 9 | Vertical space waste? | Yes, gap between search bar and form start is excessive | v4 |
| 10 | Input density adaptation? | Yes, needs smart system with min/max limits | v4 |

---

## 8. Design System Change Requests

| File | Proposed Change | Status |
|------|-----------------|--------|
| `app_breakpoints.dart` | Add `wideContentMaxWidth: 1600.0` | ✅ Approved |
| `app_spacing.dart` | Add micro-spacing tokens? | 🔶 Deferred |
| Theme/Typography | Add adaptive `VisualDensity` based on platform | 🔶 Needs Analysis |

---

## 9. Root Cause Hypotheses for Critical Bugs

### Bug 1: Form Disappears on Fullscreen

**Hypothesis A: Flex Ratio Issue**
```dart
// intake_main_content.dart
Expanded(flex: 4, child: _buildLeftColumn(...)),  // Form
Expanded(flex: 3, child: _buildRightColumn(...)), // FileViewer
```
At very wide widths, maybe the form's _buildLeftColumn is returning something that collapses?

**Hypothesis B: CustomScrollView + SliverFillRemaining Failure**
```dart
// intake_main_content.dart _buildLeftColumn
CustomScrollView(
  slivers: [
    SliverFillRemaining(
      hasScrollBody: false,
      child: participantRegistrationForm,
    ),
  ],
)
```
Maybe `SliverFillRemaining` with specific constraint combinations returns zero height?

**Hypothesis C: The `isCompact` Check**
```dart
if (isCompact) {
  return CustomScrollView(slivers: [SliverToBoxAdapter(...)]);
}
```
Maybe at fullscreen the `isCompact` condition is triggering incorrectly?

**Investigation Needed:**
- Add debug prints in `_buildLeftColumn` to see what branch executes
- Check if `constraints.maxHeight` is valid at fullscreen
- Verify `SliverFillRemaining` behavior with very large viewports

---

### Bug 2: Only 2 Columns Instead of 3

**Current breakpoint logic:**
```dart
// app_breakpoints.dart
static int getColumnCount(double width) {
  if (width >= tablet) return 3;  // tablet = 900
  if (width >= mobile) return 2;  // mobile = 600
  return 1;
}
```

**Hypothesis:** The form is receiving constrained width < 900px even on wide screens because:
- Parent Row splits space (4:3 ratio)
- At 1920px screen → form gets ~1097px
- That SHOULD trigger 3 columns (1097 > 900)

**But screenshot shows 2 columns!** So either:
- The width reaching the form is actually < 900px
- Or there's another issue in `_buildFormRow`

**Investigation Needed:**
- Add debug print of `columnCount` and actual width in `build()`
- Verify the actual constraints being passed to form

---

## 10. Implementation Phases

### Phase 0: Deep Analysis ✅ COMPLETE
- [x] Document minimum viable screen size
- [x] Clarify column strategy
- [x] Get screenshots of actual bugs
- [x] Identify root cause hypotheses

### Phase 1: Debug & Investigate (NEXT)
- [ ] Add debug logging to identify constraint flow
- [ ] Reproduce the fullscreen disappearance
- [ ] Identify exact point of failure
- [ ] Test hypotheses A, B, C

### Phase 2: Foundation Fixes
- [ ] Add `wideContentMaxWidth: 1600.0` to design system
- [ ] Fix critical fullscreen bug
- [ ] Fix 2-column vs 3-column issue

### Phase 3: Layout Improvements
- [ ] Reduce vertical spacing around search
- [ ] Implement adaptive input density
- [ ] Optimize for PC usage

### Phase 4: Polish & Test
- [ ] Test at all target screen sizes
- [ ] Ensure Flutter test (800x600) still works
- [ ] Visual review

---

## 11. Notes & Observations

### 2026-01-06 v1-v3
1-8. (Previous observations - see earlier versions)

### 2026-01-06 v4 - Visual Analysis Complete
9. **Critical Bug Discovered:** Form content COMPLETELY DISAPPEARS at fullscreen widths
10. **Column count bug:** 2 columns showing instead of 3, even at wide widths
11. **Spacing issues:** Excessive gap between search bar and form content clearly visible
12. **Density issue:** Input fields look large and spacious - not optimized for PC+mouse
13. All questions are now answered - ready for Phase 1 investigation

---

## 12. Attached Screenshots

> Reference images for the bugs analyzed in Section 5

````carousel
![Fullscreen Bug - Form Disappears](uploaded_image_0_1767724052494.png)
<!-- slide -->
![Default Size - Form Visible (2 columns)](uploaded_image_1_1767724052494.png)
<!-- slide -->
![Scrolled View - Bottom of Form](uploaded_image_2_1767724052494.png)
````

---

## Changelog

| Date | Version | Author | Change |
|------|---------|--------|--------|
| 2026-01-06 | v1 | AI | Document created |
| 2026-01-06 | v2 | AI | Added version tracking, anti-patterns |
| 2026-01-06 | v3 | AI | Added decisions, constraint analysis |
| 2026-01-06 | v4 | AI | **Added visual analysis with screenshots, root cause hypotheses, all questions answered** |

