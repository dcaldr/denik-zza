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

## 13. Target Specification (2026-01-06 v5)

> **Purpose:** Define exactly "what" the layout should look like and behave at all screen sizes.  
> **Key Principle:** Smooth scaling, not just breakpoint jumps.

### 13.1 Smooth Scaling Principles

| Principle | Description |
|-----------|-------------|
| **Fluid widths** | Elements should grow/shrink proportionally as window resizes |
| **Progressive enhancement** | Add columns/features as space allows, don't suddenly remove on resize |
| **No jarring jumps** | Transitions between breakpoints should feel natural |
| **Content always fits** | Primary content (form) should always be visible, never disappear |

### 13.2 Screen Size Behavior Matrix

```
Window Width (px):   600   800   900   1000  1200  1400  1600  1920  2560
                     ─────────────────────────────────────────────────────
Form field columns:   1     2     2     3     3     3     3     3     3
Form:FileViewer:     100%  70:30 60:40 60:40 60:40 60:40 60:40 55:45 55:45
Page scroll needed:  Yes   Maybe No    No    No    No    No    No    No
Restrictions scroll: Yes   Yes   Int.  Int.  Int.  Int.  Int.  Int.  Int.
Input density:       Touch Touch PC    PC    PC    PC    PC    PC    PC
                     
Legend:
- Int. = Internal scroll only (RestrictionsWidget scrolls, page does not)
- Touch = VisualDensity.standard (larger touch targets)
- PC = VisualDensity.compact (dense, mouse-optimized)
```

### 13.3 Scroll Expectations by Screen Size

| Screen | Behavior | Rationale |
|--------|----------|-----------|
| **< 600px (mobile)** | Full page scrolls, form stacks above file viewer | Touch-optimized, single column |
| **600-800px (small tablet)** | Page may scroll slightly, internal lists scroll | Transition zone |
| **≥ 800px (desktop)** | **NO page scroll**; only RestrictionsWidget lists scroll internally | Form should fit on screen |

### 13.4 Column Transition Logic

**Form field columns (within ParticipantRegistrationForm):**

| Form Available Width | Columns | Trigger |
|---------------------|---------|---------|
| < 600px | 1 column | Mobile stacked layout |
| 600-899px | 2 columns | Tablet/compact |
| ≥ 900px | 3 columns | Desktop full |

**Important:** Column count is based on the **FORM's actual width**, not the screen width. Since form is ~60% of screen, this means:
- Screen 900px → Form ~540px → 1 column ❌ (this is the bug!)
- Screen 1500px → Form ~900px → 3 columns ✅

### 13.5 Density Scaling ("Bell Curve" Pattern)

> **User Requirement (Explicit):** "Mobile big due to touchscreen, tablet/small notebook compact, big screens again bigger because of empty space."

| Screen Type | Dimension Check | VisualDensity | Input Heights | Rationale |
|-------------|-----------------|---------------|---------------|-----------|
| **Mobile** | Width < 600 | `.standard` | ~56px | Touch-friendly tap targets |
| **Tablet/Laptop** | Width >= 600 AND Height < 800 | `.compact` | ~40px | Max density, min scroll |
| **Desktop** | Height >= 800 | `.standard` | ~56px | Breathing room on big screens |

**Implementation:**
```dart
final screenWidth = MediaQuery.sizeOf(context).width;
final screenHeight = MediaQuery.sizeOf(context).height;
final isMobile = screenWidth < 600;
final isDesktop = screenWidth >= 1400 && screenHeight >= 800;
final useStandardDensity = isMobile || isDesktop;

final density = useStandardDensity 
    ? VisualDensity.standard 
    : VisualDensity.compact;
```

---

## 14. Solution Ideas Evaluation (2026-01-06 v5)

> **Process:** Each idea goes through: understand → analyze widget interaction → analyze impact → evaluate code style → decide finish/iterate

---

### Idea 1: Remove nested CustomScrollView, use pure Column+Expanded

**Understanding:**
The current structure has nested CustomScrollViews (IntakeMainContent has one, and _buildLeftColumn creates another). This nesting may cause constraint issues.

**Websearch findings:**
- Nested CustomScrollViews with same scroll direction cause "scroll wiggle"
- SliverFillRemaining behaves unexpectedly with certain constraint combinations

**Proposed change:**
```dart
// Instead of CustomScrollView with SliverFillRemaining
// Just return the form directly and let parent handle scroll
Widget _buildLeftColumn(...) {
  return participantRegistrationForm; // No CustomScrollView wrapper
}
```

**Widget interaction analysis:**
- ParticipantRegistrationForm already has its own LayoutBuilder
- Form uses `constraints.hasBoundedHeight` to adapt
- If parent provides bounded constraints (from Expanded in Row), form should work
- Problem: Form has Expanded widgets internally that need bounded height

**Impact analysis:**
- ✅ Simplifies constraint flow
- ❌ Form's internal Expanded (RestrictionsWidget) will crash if height unbounded
- ❌ Doesn't solve the fundamental problem

**Code style:**
- Clean, simple
- But doesn't fix root cause

**Result:** ❌ **REJECTED** - Doesn't address form's internal Expanded widgets needing bounded height

---

### Idea 2: Use `Wrap` widget for automatic field wrapping

**Understanding:**
Instead of manually calculating columns with Row, use Wrap which automatically wraps children.

**Proposed change:**
```dart
Widget _buildGridView(int columnCount) {
  return Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      SizedBox(width: 300, child: _buildTextField('jmeno', ...)),
      SizedBox(width: 300, child: _buildTextField('prijmeni', ...)),
      // etc
    ],
  );
}
```

**Widget interaction analysis:**
- Wrap has unbounded width expectation (children determine total width)
- Works inside constrained parent
- Children need explicit width or will shrink

**Impact analysis:**
- ✅ Automatic wrapping based on available space
- ✅ Smooth transitions as window resizes
- ⚠️ Need to calculate child widths properly (percentage or flex-like)
- ❌ Wrap doesn't give equal sizing - some rows might have 2 items, others 3
- ❌ Doesn't solve the fullscreen disappearing bug

**Code style:**
- Simple concept
- But loses the "even column" guarantee

**Result:** ⚠️ **PARTIAL** - Good for field wrapping, but doesn't solve main layout issues

---

### Idea 3: Replace Row with GridView for form+fileviewer split

**Understanding:**
Instead of Row with Expanded children, use a GridView-like approach.

**Websearch findings:**
- GridView is designed for unknown number of items
- Not ideal for exactly 2 children (form and file viewer)
- `Row` with `Expanded` is the right tool for 2-column layout

**Widget interaction analysis:**
- GridView adds unnecessary complexity for 2 fixed items
- Row with Expanded is semantically correct

**Impact analysis:**
- ❌ Overengineered for the use case
- ❌ Doesn't solve the constraint propagation issue

**Result:** ❌ **REJECTED** - Wrong tool for the job

---

### Idea 4: Use flex-based layout with min/max constraints

**Understanding:**
Add minimum width constraints to form column to prevent collapse.

**Proposed change:**
```dart
return Row(
  children: [
    ConstrainedBox(
      constraints: BoxConstraints(minWidth: 400, maxWidth: 900),
      child: Expanded(flex: 4, child: _buildLeftColumn(...)),
    ),
    // ...
  ],
);
```

**Widget interaction analysis:**
- ❌ Can't wrap Expanded in ConstrainedBox - Expanded must be direct child of Row
- Alternative: Use Flexible instead?

**Revised approach:**
```dart
return Row(
  children: [
    Flexible(
      flex: 4,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 400),
        child: _buildLeftColumn(...),
      ),
    ),
    // ...
  ],
);
```

**Impact analysis:**
- ⚠️ Flexible allows shrinking below flex ratio, but minWidth prevents collapse
- ✅ Form guaranteed minimum space
- ❌ Still doesn't explain why form disappears entirely at fullscreen

**Code style:**
- Acceptable complexity
- Defensive programming

**Result:** ⚠️ **PARTIAL** - Good defensive measure, but doesn't identify root cause

---

### Idea 5: Flatten CustomScrollView nesting (single scroll context)

**Understanding:**
Have only ONE scrollable context at the IntakeMainContent level, pass bounded constraints to form.

**Proposed change:**
```dart
// IntakeMainContent.build()
return CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: IntakePersonRow(...)),
    SliverToBoxAdapter(
      child: Row(
        children: [
          Expanded(flex: 4, child: participantRegistrationForm),
          Expanded(flex: 3, child: fileViewer),
        ],
      ),
    ),
    SliverToBoxAdapter(child: IntakeBottomRow(...)),
  ],
);
```

**Widget interaction analysis:**
- SliverToBoxAdapter gives UNBOUNDED height to its child
- Row with Expanded children in SliverToBoxAdapter → children get unbounded height
- ParticipantRegistrationForm has Expanded internals → CRASH (unbounded flex)

**Impact analysis:**
- ❌ Unbounded height propagates to form
- ❌ Form's internal Expanded will crash

**Result:** ❌ **REJECTED** - Creates unbounded height problem

---

### Idea 6: Use SliverLayoutBuilder for responsive sliver sizing

**Understanding:**
SliverLayoutBuilder provides constraints to sliver children, might help size things properly.

**Websearch:**
- SliverLayoutBuilder is for building slivers based on constraints
- Still operates in sliver context, not box context

**Widget interaction analysis:**
- Complex, specialized tool
- Form is a box widget, not a sliver
- Would need significant refactoring

**Result:** ❌ **REJECTED** - Overengineered, wrong abstraction level

---

### Idea 7: Restructure to Column[Fixed, Expanded, Fixed] with LayoutBuilder sizing

**Understanding:**
The most robust pattern for "fit to screen" layouts is the classic:
```
Scaffold
└── Column
    ├── Header (intrinsic height)
    ├── Expanded(child: Content) ← bounded height
    └── Footer (intrinsic height)
```

This guarantees content gets `screen - header - footer` height.

**Current implementation ALREADY does this:**
```dart
// intake_form_improved.dart build()
Column(
  children: [
    IntakePersonRow(...),        // Header
    Expanded(child: IntakeMainContent(...)), // Content - BOUNDED
    IntakeBottomRow(...),        // Footer
  ],
)
```

**So why does it fail?**

**Deep analysis of IntakeMainContent:**
```dart
// IntakeMainContent receives BOUNDED height from Expanded
// Then uses LayoutBuilder to get constraints
builder: (context, constraints) {
  final isNarrow = AppBreakpoints.isMobile(constraints.maxWidth);
  final isCompact = AppBreakpoints.isCompactHeight(constraints.maxHeight);

  if (isNarrow) { /* mobile layout */ }

  // Desktop: Row with Expanded children
  return Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(flex: 4, child: _buildLeftColumn(...)),
      Expanded(flex: 3, child: _buildRightColumn(...)),
    ],
  );
}
```

**The Row gets bounded height (CrossAxisAlignment.stretch)**
**Each Expanded child gets bounded width**
**Height flows through!**

**Then in _buildLeftColumn:**
```dart
if (isCompact) {
  return CustomScrollView(slivers: [SliverToBoxAdapter(...)]);
}
// Default Desktop:
return CustomScrollView(
  slivers: [
    SliverFillRemaining(
      hasScrollBody: false,
      child: participantRegistrationForm,
    ),
  ],
);
```

**HYPOTHESIS CONFIRMED:** `isCompact` check uses `AppBreakpoints.isCompactHeight(constraints.maxHeight)` where `compactHeight = 600`.

At fullscreen (1920x1080), height is definitely > 600, so `isCompact` is FALSE.
Therefore we use `SliverFillRemaining`.

**But wait - screenshot shows height is LARGE, not compact!**

**New insight:** Let me check what SliverFillRemaining actually does when there's NO preceding content...

According to my websearch: "If there are no preceding slivers, `SliverFillRemaining` fills the entire viewport."

**The CustomScrollView has ONLY `SliverFillRemaining` as its child!**

This should work... unless the form returns zero size.

**Root cause theory update:**
The form might be returning zero height because it's using `MainAxisSize.MAX` but receiving ZERO remaining space after... wait, no.

**Let me trace constraints more carefully:**
1. Scaffold body height: ~1000px (1080 - appbar)
2. Column distributes: IntakePersonRow ~60px, IntakeBottomRow ~60px → Expanded gets ~880px
3. IntakeMainContent's LayoutBuilder receives: maxHeight = 880px, maxWidth = 1600px (ConstrainedBox)
4. Row with CrossAxisAlignment.stretch → children get bounded height 880px
5. Expanded(flex:4) → child gets width = 4/7 * 1600 = ~914px, height = 880px
6. _buildLeftColumn receives bounded 914x880
7. CustomScrollView fills 914x880
8. SliverFillRemaining fills 914x880
9. Form should receive 914x880...

**BUT in desktop mode, the form uses SliverFillRemaining, which should pass bounded constraints!**

**What if the bug is in the form's internal LayoutBuilder?**

```dart
// participant_registration_form.dart build()
return LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : MediaQuery.sizeOf(context).width;
```

If `constraints.maxWidth` is infinite (from SliverFillRemaining?), it falls back to MediaQuery...

**CRITICAL DISCOVERY:**
`SliverFillRemaining` might pass infinite constraints in certain cases!

From Flutter docs: "SliverFillRemaining is a sliver that fills the remaining space in the viewport... **its child receives constraints with an infinite cross-axis extent**" when the sliver's scroll direction is vertical.

**Cross-axis (width) is INFINITE** for slivers!

So the form's LayoutBuilder receives: `maxWidth: infinity`, `maxHeight: bounded`

The form's code does:
```dart
final width = constraints.maxWidth.isFinite
    ? constraints.maxWidth
    : MediaQuery.sizeOf(context).width;
```

So it correctly falls back to MediaQuery width. But then columnCount is based on that width...

**THIS SHOULD STILL WORK.** The fallback is correct.

**Let me check column count calculation:**
At 1920px screen, with 1600px constraint and 4:3 split, form area should be ~914px.
But MediaQuery gives SCREEN width = 1920px, not the constrained width.
So columnCount = getColumnCount(1920) = 3 ✅

**Wait, but the screenshot shows 2 columns!**

**ACTUAL ROOT CAUSE FOUND:**
The form's LayoutBuilder fallback uses `MediaQuery.sizeOf(context).width` (full screen width) instead of the actual constrained width from the parent!

When using SliverFillRemaining, the cross-axis constraint is infinite, so the form can't know its actual width from constraints. It falls back to MediaQuery which is WRONG.

But that would give MORE columns, not fewer...

**Actually the issue is the opposite:**
- MediaQuery gives screen width (1920px)
- This triggers 3 columns
- But the ACTUAL available width is only 914px
- 3 fields at 914px = ~305px each = TOO CRAMPED

**The 2 columns in screenshot might actually be correct for the available space!**

Let me recalculate:
- At default window (smaller than fullscreen), say 1000px wide
- ConstrainedBox limits to 1000px
- Row 4:3 split → form gets 4/7 * 1000 = 571px
- 571px < 600px → 1 column? No wait, mobile breakpoint is 600, this would be 2 columns

**New calculation:**
- Form gets ~571px → getColumnCount(571) = 1 column? No, 571 < 600 is mobile.
- Wait, but screenshot shows 2 columns!

**The column count IS correct based on actual available width!**
- Form ~571px → mobile (<600) → should be 1 column, but shows 2?

**I'm confusing myself. Let me re-examine the screenshot:**
Screenshot 2 shows "Jméno" and "Příjmení" SIDE BY SIDE = 2 columns.
Window size looks like ~800-900px wide.

At 900px:
- ConstrainedBox(1600) doesn't constrain (900 < 1600)
- Row 4:3 → form gets 4/7 * 900 = ~514px
- 514px < 600px → 1 column... but we see 2!

**There's something wrong with my understanding.**

**ACTUAL ISSUE:** The padding reduces available width further!
- AppSpacing.screenPadding = 20px on each side = 40px total
- AppSpacing.containerPadding in form = 16px on each side = 32px total
- Total: 72px less

At 900px: 900 - 72 = 828px for Row
Form gets 4/7 * 828 = ~473px
473px < 600 → should be 1 column

**But screenshot shows 2 columns!**

**The column calculation must use a DIFFERENT width.**

I need to actually trace through the code...

The form's build:
```dart
return LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : MediaQuery.sizeOf(context).width;
    final columnCount = AppBreakpoints.getColumnCount(width);
```

If constraints.maxWidth is finite (which it should be from Row->Expanded), it uses that.
If infinite (SliverFillRemaining cross-axis), it uses MediaQuery.

**The finite case:**
Form gets ~473px → getColumnCount(473) → 473 < 600 → return 1

But we see 2 columns! So either:
1. constraints.maxWidth is infinite (SliverFillRemaining), and MediaQuery fallback is used = 900px → 2 columns ✅
2. Or there's a bug in my analysis

**Most likely:** SliverFillRemaining passes infinite width, form uses MediaQuery = 900px screen width → 2 columns.

This explains the "2 columns instead of 3" issue!
- Form uses SCREEN width, not AVAILABLE width
- Screen 900px → 2 columns
- But form only has 473px → fields are cramped

**AND for the disappearing bug:**
At fullscreen (1920px), SliverFillRemaining might behave differently?

**Let me check one more thing about SliverFillRemaining:**

From Flutter source: `SliverFillRemaining` sizes itself to fill remaining space, but if there's no remaining space (viewport is full), it might return zero size.

At fullscreen, if previous slivers (none in this case, it's the ONLY sliver)... wait, there are no previous slivers.

**The disappearing bug is likely a completely different issue:**
Maybe at fullscreen, `isNarrow` becomes true (mobile mode)?

At fullscreen 1920px:
- LayoutBuilder in IntakeMainContent gets maxWidth = 1600 (ConstrainedBox limits it)
- isNarrow = isMobile(1600) = 1600 < 600? → FALSE ✅

**isNarrow is definitely false at fullscreen.**

So we go to the Row layout, not the mobile CustomScrollView.

**New hypothesis for disappearing bug:**
Maybe the participantRegistrationForm is null or not rendering?

From the code:
```dart
Expanded(
  child: IntakeMainContent(
    ...
    participantRegistrationForm: _participantRegistrationForm!,
  ),
),
```

It uses `!` so it can't be null (would crash).

**What if the form IS there but has zero visual size?**

The form's build returns LayoutBuilder → Padding → Form → Column.

If the Column has zero children (unlikely since we see it in other screenshots)...

**I think I need to actually debug to confirm.**

**RECOMMENDATION FOR IDEA 7:**
The fundamental structure (Column[Fixed, Expanded, Fixed]) is correct.
The problem is constraint propagation through SliverFillRemaining.

**Proposed fix:**
Instead of SliverFillRemaining, use simple widget placement with LayoutBuilder HEIGHT:

```dart
Widget _buildLeftColumn(...) {
  // For desktop with enough height, just return the form with bounded constraints
  // The form already adapts to hasBoundedHeight
  return participantRegistrationForm;
}
```

But this removes scroll capability if form is too tall...

**Better approach:**
Pass the actual available dimensions to the form explicitly:

```dart
// IntakeMainContent
return LayoutBuilder(
  builder: (context, constraints) {
    // Calculate actual form width
    final formWidth = isNarrow 
        ? constraints.maxWidth 
        : constraints.maxWidth * (4/7);
    
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: ParticipantRegistrationForm(
            // Pass explicit width for column calculation
            availableWidth: formWidth,
            ...
          ),
        ),
        ...
      ],
    );
  },
);
```

Then in ParticipantRegistrationForm:
```dart
final int columnCount = widget.availableWidth != null
    ? AppBreakpoints.getColumnCount(widget.availableWidth!)
    : AppBreakpoints.getColumnCount(constraints.maxWidth);
```

**Result:** ✅ **ACCEPTED with modifications**
- Keep Column[Fixed, Expanded, Fixed] structure
- Remove nested CustomScrollView in _buildLeftColumn
- Pass explicit width from parent to child for column calculation
- Let scroll capability come from ParticipantRegistrationPage pattern (SliverFillRemaining at page level)

---

### Idea 8: Remove CustomScrollView from _buildLeftColumn entirely

**Understanding:**
The nested CustomScrollView in `_buildLeftColumn` might be causing constraint issues.

**Proposed change:**
```dart
Widget _buildLeftColumn(...) {
  // Just return the form - let the form handle its own layout
  return participantRegistrationForm;
}
```

**Widget interaction analysis:**
- Row with CrossAxisAlignment.stretch gives bounded height
- Form's LayoutBuilder receives bounded constraints
- Form's Column with hasBoundedHeight → MainAxisSize.max → WORKS
- Form's Expanded(RestrictionsSection) receives bounded height → WORKS

**BUT:**
- Form's internal constraints.maxWidth would be FINITE (not infinite from sliver)
- Column calculation would use actual parent width
- This should give CORRECT column count!

**Impact analysis:**
- ✅ Simpler constraint flow
- ✅ Correct column calculation
- ✅ Form's Expanded works with bounded height
- ⚠️ Loses scroll if form content exceeds available height
- ⚠️ At very small heights (compact), might cause overflow

**Handling scroll:**
- For compact/small screens, wrap in SingleChildScrollView
- For desktop (tall screens), no scroll needed

```dart
Widget _buildLeftColumn(...) {
  if (isCompact) {
    // Small height: allow scroll
    return SingleChildScrollView(
      child: participantRegistrationForm,
    );
  }
  // Tall screens: form fits, no scroll
  return participantRegistrationForm;
}
```

**BUT:** SingleChildScrollView gives UNBOUNDED height!
Form's Expanded will crash.

**Solution:** Tell form it's in "unbounded" mode:
```dart
ParticipantRegistrationForm(
  isBounded: !isCompact, // bounded = fits on screen, unbounded = scrolls
  ...
)
```

Form already handles this with enableStickyFooter... but that's different.

Actually, the form already checks `constraints.hasBoundedHeight`:
```dart
mainAxisSize: constraints.hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
if (constraints.hasBoundedHeight)
  Expanded(child: ...)
else
  _buildRestrictionsSection(isBounded: false)
```

So as long as we pass correct constraints, the form adapts!

**Final approach:**
```dart
Widget _buildLeftColumn(...) {
  // For very small heights, use scroll with unbounded constraints
  // Form will detect unbounded and adapt
  if (isCompact) {
    return SingleChildScrollView(
      child: participantRegistrationForm,
    );
  }
  // For tall screens, pass bounded constraints directly
  return participantRegistrationForm;
}
```

**Result:** ✅ **ACCEPTED** - Simplest solution that leverages form's existing adaptation

---

### Idea 9: Fix column calculation by using parent width context

**Understanding:**
The column count issue stems from form not knowing its actual available width.

**Current problem:**
```dart
// When in SliverFillRemaining, constraints.maxWidth is infinite
// Fallback to MediaQuery gives SCREEN width, not FORM width
```

**Solution:**
Pass the calculated width from parent:

**In IntakeMainContent:**
```dart
// After calculating isNarrow and knowing Row layout
final formAvailableWidth = constraints.maxWidth * (4.0 / 7.0);

return Row(
  children: [
    Expanded(
      flex: 4,
      child: _buildLeftColumn(context, constraints, isNarrow, formAvailableWidth),
    ),
    ...
  ],
);
```

**In ParticipantRegistrationForm:**
Add optional parameter:
```dart
final double? availableWidth; // Hint from parent about actual width
```

In build():
```dart
final width = widget.availableWidth ?? 
    (constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.sizeOf(context).width);
final columnCount = AppBreakpoints.getColumnCount(width);
```

**Impact analysis:**
- ✅ Correct column count based on actual available space
- ✅ Minimal code change
- ✅ Backward compatible (optional parameter)
- ⚠️ Requires parent to calculate and pass width

**Result:** ✅ **ACCEPTED** - Complements Idea 8

---

## 15. Recommended Solution (2026-01-06 v5)

Based on the 9 ideas evaluated:

### Selected Approach: Combine Ideas 7, 8, and 9

**Core changes:**

1. **Remove nested CustomScrollView in `_buildLeftColumn`** (Idea 8)
   - Use SingleChildScrollView only for compact heights
   - Otherwise pass form directly to get bounded constraints

2. **Pass explicit available width from parent** (Idea 9)
   - IntakeMainContent calculates form width
   - Passes to ParticipantRegistrationForm as hint

3. **Keep existing form adaptation logic** (Idea 7)
   - Form already adapts based on constraints.hasBoundedHeight
   - Just ensure it receives correct constraints

### Expected Results:
- ✅ Form visible at all screen sizes (no disappearing)
- ✅ Correct 3-column layout on wide screens
- ✅ Smooth scaling as window resizes
- ✅ Proper scroll behavior (page scroll on small, internal scroll on large)

### Files to Modify:
1. `intake_main_content.dart` - Remove/simplify CustomScrollView nesting
2. `participant_registration_form.dart` - Add availableWidth parameter
3. `app_breakpoints.dart` - Add wideContentMaxWidth constant

---

## 16. Critical Analysis of Proposed Solution (2026-01-06 v5)

> **Purpose:** Identify weak spots, container interaction problems, and potential failures before implementation.

### 16.1 Summary of Proposed Changes

| Change | File | Description |
|--------|------|-------------|
| Remove CustomScrollView in `_buildLeftColumn` | intake_main_content.dart | Replace CustomScrollView+SliverFillRemaining with direct form placement |
| Pass explicit width | intake_main_content.dart → form | New parameter `availableWidth: double?` |
| Add availableWidth parameter | participant_registration_form.dart | Use for column calculation instead of MediaQuery fallback |

### 16.2 Weak Spots Identified

#### ⚠️ WEAK SPOT 1: Height Constraint in Mobile Mode Still Problematic

**Current mobile path:**
```dart
if (isNarrow) {
  return CustomScrollView(
    slivers: [
      SliverToBoxAdapter(child: _buildRightColumn(...)),
      SliverToBoxAdapter(child: _buildLeftColumn(...)), // Form here
    ],
  );
}
```

**Problem:** `SliverToBoxAdapter` gives **UNBOUNDED height** to its child.  
**Impact:** Form's `constraints.hasBoundedHeight` will be FALSE → form uses `MainAxisSize.min` and non-Expanded restrictions → OK for mobile.

**BUT:** We're NOT changing the mobile path. The proposal only changes `_buildLeftColumn` for desktop.

**Question:** Is mobile mode actually working correctly? The screenshots didn't show mobile mode issues.

**Risk Level:** 🟡 Low - Mobile mode seems to work, we're only fixing desktop.

---

#### ⚠️ WEAK SPOT 2: Width Calculation Doesn't Account for Padding

**Proposed calculation in IntakeMainContent:**
```dart
final formAvailableWidth = constraints.maxWidth * (4.0 / 7.0);
```

**Problem:** This doesn't account for:
- `AppSpacing.screenPadding` (EdgeInsets affecting IntakeMainContent)
- The `SizedBox(width: 24)` gap between columns
- `AppSpacing.containerPadding` inside the form

**Actual form width should be:**
```dart
final totalPadding = AppSpacing.screenPadding.horizontal; // 40px
final gap = 24.0; // SizedBox between columns
final availableForRow = constraints.maxWidth - totalPadding;
// Row splits remaining space, form gets 4/7, file viewer gets 3/7
// BUT the gap is OUTSIDE the flex calculation
final formWidth = (availableForRow - gap) * (4.0 / 7.0);
// Wait, no - Expanded handles this differently...
```

**Actually:** Expanded widgets split the available space AFTER fixed children (gap). So:
```dart
final availableForRow = constraints.maxWidth; // Already padded by LayoutBuilder parent
final flexibleSpace = availableForRow - 24; // Minus gap
final formWidth = flexibleSpace * (4.0 / 7.0);
```

**But wait:** The LayoutBuilder in IntakeMainContent is INSIDE the Padding, so `constraints.maxWidth` is already the padded width.

**Corrected calculation:**
```dart
final gap = 24.0;
final flexibleSpace = constraints.maxWidth - gap;
final formWidth = flexibleSpace * (4.0 / 7.0);
```

**Risk Level:** 🟠 Medium - Wrong width calculation = wrong column count at edge cases.

---

#### ⚠️ WEAK SPOT 3: Form's Internal Padding Not Considered

Even with correct parent width, the form applies its own `AppSpacing.containerPadding`:
```dart
return Padding(
  padding: AppSpacing.containerPadding, // 16px horizontal
  child: Form(...)
)
```

So form FIELDS have even less width:
```dart
final formContentWidth = formWidth - AppSpacing.containerPadding.horizontal;
```

**Question:** Should column calculation use `formWidth` or `formContentWidth`?

Currently the form's LayoutBuilder gets constraints AFTER the Padding, so it would use the already-reduced width. This is CORRECT for column calculation.

**But our proposal passes width FROM PARENT, before form's internal padding!**

**Risk Level:** 🔴 High - Column calculation might use wrong width!

**Solution:** Either:
1. Subtract form padding from passed width
2. OR let form calculate columns from its own LayoutBuilder (if we fix the infinite width issue)

---

#### ⚠️ WEAK SPOT 4: Removal of CustomScrollView Loses Scroll on Tall Content

**Current behavior:** CustomScrollView with SliverFillRemaining allows scrolling if content exceeds viewport.

**Proposed behavior:** Direct form placement without scroll wrapper.

**What if form content exceeds available height?** 
- Form has many fields + restrictions
- User adds 20 restrictions
- Content overflows

**Current handling (in proposal):**
```dart
if (isCompact) {
  return SingleChildScrollView(child: form);
} else {
  return form; // No scroll
}
```

**Problem:** `isCompact` uses `AppBreakpoints.compactHeight = 600px`. A 768px screen is NOT compact, so no scroll wrapper. But if content is 900px tall and screen is 768px, we have **overflow crash**.

**Risk Level:** 🔴 High - Potential overflow on medium-height screens with lots of content.

**Solution:** Need fallback scroll behavior when content exceeds height. Options:
1. Use `SizedBox` with `ClipRect` to clip overflow (bad UX, hides content)
2. Always use scroll but with bounded page-fit behavior
3. Use `SingleChildScrollView` with `physics: ClampingScrollPhysics()` always, but size child to fill if smaller

---

#### ⚠️ WEAK SPOT 5: Right Column (File Viewer) Dependency on CrossAxisAlignment.stretch

**Current code:**
```dart
return Row(
  crossAxisAlignment: CrossAxisAlignment.stretch, // CRITICAL
  children: [
    Expanded(flex: 4, child: _buildLeftColumn(...)),
    Expanded(flex: 3, child: _buildRightColumn(...)),
  ],
);
```

**In _buildRightColumn:**
```dart
return Column(
  mainAxisSize: MainAxisSize.max, // Uses full height
  children: [
    Text('Second Column'),
    if (!isNarrow) Expanded(child: _buildFileViewer()), // Uses remaining height
    // ...
  ],
);
```

**This works ONLY because:**
1. Row gets bounded height from Expanded parent
2. CrossAxisAlignment.stretch passes that height to children
3. Each Expanded child (including right column) fills that height
4. Right column's internal Expanded works

**If we break the Row's bounded height, the file viewer also breaks.**

**Risk Level:** 🟡 Low - We're not changing the Row, just the left column content.

---

#### ⚠️ WEAK SPOT 6: Form Widget is Passed as Parameter, Not Created Fresh

**Current pattern:**
```dart
// In intake_form_improved.dart
_participantRegistrationForm = _createParticipantForm(); // Created once

// Later passed to IntakeMainContent
IntakeMainContent(
  participantRegistrationForm: _participantRegistrationForm!,
);
```

**If we add `availableWidth` parameter to form, we need to:**
1. Recreate form when width changes, OR
2. Store width in state and update form, OR
3. Pass width differently (via InheritedWidget?)

**Problem:** Width changes on window resize. Form would need to rebuild with new width.

**Current form creation:**
```dart
ParticipantRegistrationForm(
  key: _participantFormKey,
  osoba: _controller.selectedPerson,
  // ... no width parameter
);
```

**If we add width, form is recreated on every build? No, because we use a key.**

**Actually:** The form is recreated in `_onControllerStateChanged`:
```dart
_participantRegistrationForm = _createParticipantForm();
```

**But `_createParticipantForm` doesn't know the available width!** It's called from state, not from build.

**Risk Level:** 🔴 High - Can't easily pass width from IntakeMainContent to the form that's created in intake_form_improved.

**Alternative:** Instead of passing width as constructor parameter, use `InheritedWidget` or have form query parent via `LayoutBuilder` (which it already does, but gets infinite width from sliver).

---

### 16.3 Container Interaction Problems

#### Problem A: Nested LayoutBuilder Constraint Confusion

```
intake_form_improved.dart
└── Column
    └── Expanded  ← BOUNDED height
        └── IntakeMainContent
            └── LayoutBuilder  ← constraints = bounded
                └── Row
                    └── Expanded  ← BOUNDED width (4/7)
                        └── _buildLeftColumn
                            └── CustomScrollView  ← WE REMOVE THIS
                                └── SliverFillRemaining
                                    └── Form
                                        └── LayoutBuilder  ← constraints from sliver (width=∞, height=bounded)
```

**After our change:**
```
_buildLeftColumn
└── participantRegistrationForm (directly)
    └── LayoutBuilder  ← constraints from Row's Expanded (width=FINITE, height=FINITE)
```

**This SHOULD work!** Form gets finite constraints, uses them for column calculation.

**BUT:** The form is created in `intake_form_improved`, not in `IntakeMainContent`. When passed down, it's just a widget reference. The form's `LayoutBuilder` will query its ACTUAL parent at runtime, which would be the Row's Expanded.

**This is actually CORRECT!** The form will get the right constraints.

---

#### Problem B: Form Already Handles hasBoundedHeight

The form already checks `constraints.hasBoundedHeight`:
```dart
mainAxisSize: constraints.hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
if (constraints.hasBoundedHeight)
  Expanded(child: _buildRestrictionsSection(...))
else
  _buildRestrictionsSection(...)
```

**After our change:** 
- Row → Expanded → form gets BOUNDED height ✅
- Form sees `hasBoundedHeight = true`
- Form uses `MainAxisSize.max` and `Expanded` restrictions ✅

**This should work correctly!**

---

#### Problem C: isCompact Branch Still Uses CustomScrollView

In `_buildLeftColumn`:
```dart
if (isCompact) {
  return CustomScrollView(
    slivers: [SliverToBoxAdapter(child: form)],
  );
}
```

**This gives form UNBOUNDED height** (SliverToBoxAdapter).

If we DON'T change this branch,---

### 22.1 Vector 1: Focus vs. GlobalKey Scope

**Problem:** We assume `GlobalKey<FormState>` saves the focus of input fields.
**Sequence:**
1.  **Search:** Confirmed. Focus is attached to the *Element*. When `GlobalKey` reparents the Element, the `FocusNode` (if owned by that Element/State) stays attached.
2.  **Risk:** If `FocusNode`s were owned by an *ancestor* of the Form that gets destroyed, focus would be lost.
3.  **Check:** Our `FocusNode`s are inside `ParticipantRegistrationFormState`. They travel WITH the form.
4.  **Verdict:** **SAFE**.

### 22.2 Vector 2: Keyboard Snap Jitter

**Problem:** When keyboard opens, height shrinks. If it crosses 500px, layout "snaps" to scroll view. Does this look glitchy?
**Sequence:**
1.  **Behavior:** Android resizes view. `LayoutBuilder` sees new height.
2.  **Transition:** 700px -> 400px. Snap occurs.
3.  **Visual:** The user sees the form instantly switch to scrollable.
4.  **Verdict:** **ACCEPTABLE**. This is the intended behavior. Better to snap than to overflow.

### 22.3 Vector 4: RestrictionsWidget Expansion Logic

**Problem:** Does switching `hasBoundedHeight` actually work for `Expanded`?
**Sequence:**
1.  **Code Check:** `ParticipantRegistrationForm` uses `if (constraints.hasBoundedHeight) Expanded... else ...`.
2.  **Verification:**
    - **Desktop:** Height is bounded (pass-through from Row). `hasBoundedHeight` = true. Uses Expanded. ✅
    - **Mobile/Scroll:** Height is unbounded (`SingleChildScrollView`). `hasBoundedHeight` = false. Uses `SizedBox(height: calculated)`. ✅
3.  **Verdict:** **SAFE**. Logic is robust.

### 22.4 Vector 7: Nested Scrolling (ZzaScrollable)

**Problem:** `RestrictionsWidget` has a list. `Mobile Mode` wraps the whole form in a ScrollView.
**Sequence:**
1.  **Conflict:** Scrollable inside Scrollable.
2.  **Mitigation:** `RestrictionsWidget` list uses `ShrinkWrap` or fixed height?
    - **Current Code:** In unbounded mode, it uses a fixed `SizedBox` height.
    - **Result:** It is a small scrollable window inside the main scrollable page.
    - **Behavior:** User scrolls page to get to restrictions, then scrolls restrictions list. (Standard Flutter behavior).
3.  **Verdict:** **SAFE**. No unbounded height crash.

---

### 16.4 Scaling Problem Assessment

**Q: Does the proposed solution solve smooth scaling?**

**Width scaling:** 
- ✅ Form gets correct width from Row constraints
- ✅ Column count calculation uses actual width
- ✅ Fields resize proportionally (Expanded in Row within form)

**Height scaling:**
- ⚠️ Form fits exactly if hasBoundedHeight = true
- ⚠️ RestrictionsWidget gets Expanded and fills remaining space
- ⚠️ NO scroll fallback if content exceeds height

**Density scaling:**
- ❌ NOT addressed in proposal - requires separate theme change

**Transition smoothness:**
- ✅ No jarring layout changes (same structure, just different constraints)
- ⚠️ Column count might jump (1→2→3) based on thresholds

---

### 16.5 Revised Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Width calculation ignores gap/padding | 🟠 Medium | Calculate width correctly: `(constraints.maxWidth - gap) * ratio` but this might not be needed if form gets correct constraints from LayoutBuilder |
| No scroll on tall content | 🔴 High | Need scroll fallback for medium-height screens |
| Can't easily pass width via constructor | 🔴 High | Don't pass width; let form use its LayoutBuilder constraints (which will be correct after our change) |
| Form padding not in calculation | 🟡 Low | Form's LayoutBuilder is inside Padding, so it already sees reduced width |

---

### 16.6 Revised Recommendation

Based on this critique, the solution should be **simplified**:

**Original proposal:** Pass `availableWidth` from parent to form.

**Revised proposal:** DON'T pass width at all. Just remove the CustomScrollView/SliverFillRemaining wrapper.

**Why this works:**
1. Remove `CustomScrollView` in `_buildLeftColumn` → form placed directly
2. Form sits inside Row → Expanded → gets BOUNDED width
3. Form's LayoutBuilder receives finite constraints
4. Form calculates columns from `constraints.maxWidth` (finite!) rather than MediaQuery fallback
5. Form's hasBoundedHeight works correctly

**Key remaining issue:** Scroll fallback for tall content.

**Proposed addition:**
```dart
Widget _buildLeftColumn(...) {
  // Always use LayoutBuilder to check if form might overflow
  // For now, trust that desktop has enough height
  // TODO: Add scroll fallback if needed
  return participantRegistrationForm;
}
```

**This is simpler and addresses the root cause directly.**

---

## 17. Second Round Critique (2026-01-06 v7)

> **Focus:** 5 new areas not covered in first critique.  
> **User preference:** Solutions that actively fit content to screen to avoid scroll wiggle.

---

### 17.1 Area 1: Test Compatibility (800x600)

**Context:** Flutter widget tests run at default 800x600 logical pixels.

**Current test files referencing intake form:**
- `test/robots/intake_robot_test.dart` - Uses IntakeRobot
- `test/first_use/first_use_test.dart` - Tests first use scenarios
- `test/intake_duplicate_prevention_test.dart` - Logic tests (no UI)

**Will our changes break tests at 800x600?**

At 800x600:
- IntakeMainContent's LayoutBuilder receives ~760x500 (after padding/appbar)
- `isNarrow = AppBreakpoints.isMobile(760)` → 760 > 600 → **FALSE** (not mobile)
- Goes to Row layout, NOT mobile CustomScrollView
- Form gets 4/7 * 760 = ~434px width
- `getColumnCount(434)` → 434 < 600 → **1 column**

**After our change:**
- Form receives bounded constraints from Row → Expanded
- Form's LayoutBuilder sees 434px width (finite)
- Column count = 1 ✅
- hasBoundedHeight = true → Expanded restrictions ✅

**Risk assessment:**
- ✅ Should work correctly at 800x600
- ⚠️ BUT: RestrictionsWidget in bounded mode uses `Expanded` → needs space
- ⚠️ At 500px height, form + footer + restrictions might not fit

**Test at 800x600 minimum height calculation:**
```
Available height: 600 - 56 (appbar) - 60 (IntakePersonRow) - 60 (IntakeBottomRow) = 424px for IntakeMainContent
Form padding: 20px top/bottom = 384px for form content
Form fields (9 rows @ ~48px): 432px ❌ OVERFLOW
```

**CRITICAL ISSUE:** At 800x600, form content (~432px) exceeds available height (~384px)!

**Current solution:** SliverFillRemaining allows scroll inside form area.
**After our change:** Direct placement → OVERFLOW crash.

**Risk Level:** 🔴 **CRITICAL** - Tests will fail with layout overflow!

**Mitigation needed:** Either:
1. Keep scroll wrapper for `isCompact` (height < 600)
2. OR use LayoutBuilder to detect when content exceeds height and add scroll

---

### 17.2 Area 2: RestrictionsWidget Internal Sizing

**Current behavior in bounded mode:**
```dart
// restrictions_widget.dart
if (widget.isBounded)
  Expanded(child: _buildListContent()) // Take remaining space
else
  _buildBoundedList() // Fixed height based on screen
```

**`_buildBoundedList()` logic:**
```dart
final screenHeight = MediaQuery.sizeOf(context).height;
final isBrief = screenHeight < 800;  // Local threshold!
final targetItems = isBrief ? 2.7 : 3.7;
final listHeight = getListHeight(context, itemCount: 1) * targetItems;
```

**Problem:** In unbounded mode, RestrictionsWidget uses `MediaQuery.sizeOf(context).height` (SCREEN height), not available container height.

**After our change:**
- Desktop: isBounded = true → Expanded → fills remaining space ✅
- BUT if remaining space is tiny (user adds many form fields or small screen), restrictions list is cramped

**Interaction with ZzaScrollable:**
```dart
// restrictions_widget.dart _buildListContent()
return Scrollbar(
  controller: _scrollController,
  child: ZzaScrollable(
    controller: _scrollController,
    child: ListView.builder(...)
  ),
);
```

**ZzaScrollable** adds gradient overlays for scroll indication. If list is very short (< 3 items), gradients might look odd.

**Risk Level:** 🟡 Medium - Visual polish issue, not functional failure.

**Observation for "fit to screen" goal:**
- RestrictionsWidget in bounded mode WILL fill remaining space
- This helps avoid page-level scroll
- List scrolling is internal (with scroll indicators) ✅

---

### 17.3 Area 3: VisualDensity / Input Density

**User complaint:** Form inputs look too large/spacious for PC.

**Current state:** No adaptive density implemented.

**Our proposal doesn't address this.** We should note it as a separate issue.

**Recommended approach (from web search):**
```dart
// In theme or form
visualDensity: VisualDensity.adaptivePlatformDensity
// OR explicitly:
visualDensity: MediaQuery.sizeOf(context).width >= 900 
    ? VisualDensity.compact 
    : VisualDensity.standard
```

**This reduces input height by ~8-16px, making form more PC-friendly.**

**Risk Level:** 🟡 Separate issue - Not blocking for current refactor.

**Recommendation:** Add as Phase 3 task in implementation plan.

---

### 17.4 Area 4: Root Cause of Disappearing Bug (Unconfirmed)

**Important:** We proposed a fix based on hypothesis, but haven't CONFIRMED the root cause.

**Our hypothesis:**
- SliverFillRemaining passes infinite cross-axis width
- Form falls back to MediaQuery, gets wrong column count
- At certain combinations, form might render with zero visible content

**But we don't know WHY the form COMPLETELY DISAPPEARS at fullscreen.**

**Screenshot analysis:**
- "Second Column" header IS visible
- File uploader IS visible  
- Form (left column) is GONE

**This suggests the LEFT side of the Row is the issue, not the form itself.**

**Alternative hypotheses not yet explored:**

**Hypothesis D: `_buildLeftColumn` returns something that collapses**
```dart
Widget _buildLeftColumn(...) {
  if (isNarrow) { return participantRegistrationForm; }
  if (isCompact) { return CustomScrollView(...); }
  // Default Desktop:
  return CustomScrollView(
    slivers: [
      SliverFillRemaining(hasScrollBody: false, child: form)
    ],
  );
}
```

At fullscreen:
- isNarrow = false (width > 600) ✅
- isCompact = false (height > 600) ✅
- Goes to default path → CustomScrollView with SliverFillRemaining

**What if SliverFillRemaining with `hasScrollBody: false` and very large viewport behaves unexpectedly?**

**Hypothesis E: CustomScrollView gets zero scroll extent**---

### 21.5 Strategy 4: Reparenting via "KeyedSubtree"

**Concept:**
Wrap the form in `KeyedSubtree` with a unique key, instead of passing key to the widget itself.

**Cycle Analysis:**
1.  **Mechanism:** Similar to GlobalKey, but usually used with local keys to keep state *if* the widget stays in the same subtree.
2.  **Limitation:** If we move the widget to a completely new parent (Row vs ScrollView), local keys often fail unless the framework sees them as the "same" element in a compatible location.
3.  **Verdict:**
    - **Status:** **Riskier than GlobalKey**. `GlobalKey` guarantees matching anywhere.

---

### 21.6 Strategy 5: The "Offstage Stack" (KeepAlive)

**Concept:**
Use `Stack` with two children: `Offstage(child: ScrollableForm)` and `Offstage(child: FixedForm)`. Toggle visibility.

**Cycle Analysis:**
1.  **State:** Both widgets are alive. State is preserved.
2.  **Focus:** When Toggling, you must manually transfer focus from "Fixed Form field A" to "Scrollable Form field A".
3.  **Fatal Flaw:** The User doesn't want to lose what they typed. Syncing text between two separate form instances is a nightmare.
4.  **Verdict:**
    - **Status:** **REJECTED**. Syncing state between two active widgets is harder than moving one widget.

---

### 21.7 Strategy 6: SliverLayoutBuilder Switching

**Concept:**
Stay purely in a `CustomScrollView`. Use `SliverLayoutBuilder`.
- If tall: `SliverToBoxAdapter` (constrained height).
- If short: `SliverToBoxAdapter` (unconstrained height) + Scroll Physics?

**Cycle Analysis:**
1.  **Complexity:** Slivers are powerful but "Fill Remaining" logic is hard to toggle conditionally without breaking `Expanded` children.
2.  **Verdict:**
    - **Status:** **REJECTED**. Valid in theory, but complexity is 10x higher than GlobalKey.

---

### 21.8 Final Implementation Verdict

**Winner:** **Strategy 1: GlobalKey**.

**Why?**
- **Simplicity:** Least amount of code.
- **Robustness:** Guarantees state preservation during the critical "Keyboard Up" event.
- **Safety:** We verified cleanup (automatic) and uniqueness (local instantiation).

**Refined Plan Actions:**
1.  Instantiate `final GlobalKey<FormState> _formKey = GlobalKey<FormState>();` in `_IntakeMainContentState`.
2.  Pass this key to `ParticipantRegistrationForm`.
3.  Use `LayoutBuilder` to switch parents based on 500px threshold.

---
| Form fields section | Intrinsic height | None |
| RestrictionsWidget | Expanded, fills remaining | Internal list only |
| Right column (file viewer) | Fills 3/7 of Row via Expanded | None |

**Result:** ✅ Page-level scroll is AVOIDED in desktop mode.

**But:** This only works if form content fits within available height.

**Edge case:** If form content (fields + checkboxes + restrictions header + input) exceeds available height, we have OVERFLOW.

**Minimum content height estimate:**
- Form fields (9 text fields @ ~56px dense or ~48px compact): ~450-500px
- Checkboxes section: ~60px
- Poznámka textarea: ~80px
- Restrictions headers (2 sections): ~80px
- Restrictions inputs (2 rows): ~100px
- **Minimum form height: ~770-820px**

**Available at 1080p:**
- 1080 - 56 (appbar) - 60 (person row) - 60 (bottom row) - 40 (padding) = **864px**

864px > 770px ✅ **Fits at Full HD!**

**Available at 768p (720p laptop):**
- 768 - 56 - 60 - 60 - 40 = **552px**

552px < 770px ❌ **Doesn't fit! Need scroll.**

**Conclusion:**
- At 1080p+: Form fits, no scroll needed ✅
- At 720p: Form doesn't fit, MUST have scroll fallback ⚠️
- At 600px (test): Form won't fit at all, definitely needs scroll ⚠️

---

### 17.7 Second Round Summary

| Area | Finding | Risk | Action |
|------|---------|------|--------|
| 1. Test compatibility | 800x600 height insufficient for form | 🔴 Critical | Keep scroll for small heights |
| 2. RestrictionsWidget | Works correctly in bounded mode | 🟢 OK | None |
| 3. VisualDensity | Not addressed, separate issue | 🟡 Medium | Add to Phase 3 |
| 4. Root cause | Not confirmed, hypotheses only | 🟠 Medium | Add debug step |
| 5. ZzaScrollable | No conflicts | 🟢 OK | None |

---

### 17.8 Revised Solution (v3)

Based on both critiques, the solution needs adjustment:

**Original v1:** Remove CustomScrollView, pass width parameter.  
**Revised v2:** Remove CustomScrollView, don't pass width (use LayoutBuilder).  
**Revised v3:** Keep conditional scroll based on **actual content vs available height**.

**Proposed implementation:**

```dart
Widget _buildLeftColumn(...) {
  // For narrow screens (mobile), use CustomScrollView (existing path)
  if (isNarrow) {
    return participantRegistrationForm;
  }

  // For desktop: Check if content will fit
  // Use LayoutBuilder approach - if height is bounded AND sufficient, no scroll needed
  // If height is bounded but insufficient, need scroll fallback
  
  // Simple approach: Just remove nested CustomScrollView, trust form's adaptation
  // Form already handles hasBoundedHeight correctly
  
  return participantRegistrationForm;
}
```

**But this still causes overflow at small heights!**

**Better approach:**

```dart
Widget _buildLeftColumn(...) {
  if (isNarrow) {
    return participantRegistrationForm;
  }
  
  // Desktop/Tablet: Form directly receives bounded constraints
  // Form's internal logic handles MainAxisSize and Expanded
  // BUT: If height is too small, form WILL overflow
  
  // Solution: Wrap in SingleChildScrollView only when needed
  // We can't easily know "needed" without measuring, so...
  
  // Pragmatic approach: Trust the form's design
  // Form was designed to work with bounded height (Expanded restrictions)
  // At small heights, user must resize window or accept cramped restrictions
  
  return participantRegistrationForm;
}
```

**Risk acceptance:**
- At 1080p+: Works perfectly (fits to screen) ✅
- At 720p: RestrictionsWidget gets ~80px (small but usable) ⚠️
- At 600px (test): RestrictionsWidget gets ~30px (very cramped, might overflow) ⚠️

**If 600px test height is critical, we need different strategy.**

---

## 18. Final Decision: Compact-First + Scroll Fallback (2026-01-06 v8)

> **User Decision:** "Try to cramp it more but also the scroll might be needed"

### 18.1 Approach

**Primary goal:** Make form as compact as possible to fit on screen.  
**Fallback:** Keep scroll for cases where it still doesn't fit.

### 18.2 Compact Strategies

| Strategy | Reduction | Implementation |
|----------|-----------|----------------|
| **VisualDensity.compact** | ~8-16px per input | Theme or InputDecoration |
| **Reduce SizedBox gaps** | ~20-40px total | Use AppSpacing.xs instead of s |
| **isDense: true on inputs** | Additional ~4px per input | InputDecoration.isDense |
| **Compact checkboxes** | ~10-20px | Use smaller checkbox variant |

**Estimated total height reduction:** ~80-120px

**Revised minimum height:** ~650-700px (down from ~770px)

### 18.3 Height Thresholds

| Available Height | Mode | Form Behavior |
|-----------------|------|---------------|
| ≥700px | **Fit to screen** | No page scroll, RestrictionsWidget fills remaining |
| 500-699px | **Compact scroll** | Light scroll, cramped restrictions |
| <500px | **Full scroll** | SliverToBoxAdapter, form determines own height |

### 18.4 Refined Solution (v4)

```dart
Widget _buildLeftColumn(BuildContext context, BoxConstraints constraints, bool isNarrow) {
  if (isNarrow) {
    // Mobile: Just return form, parent handles scroll
    return participantRegistrationForm;
  }

  // Desktop/Tablet: Check available height
  final availableHeight = constraints.maxHeight;
  
  if (availableHeight >= 700) {
    // Tall enough: Form fits directly, RestrictionsWidget fills remaining
    return participantRegistrationForm;
  } else if (availableHeight >= 500) {
    // Medium: Try to fit, but form might scroll internally
    // Form still gets bounded constraints, but may not fit all content
    return participantRegistrationForm;
  } else {
    // Very short: Use scroll wrapper
    return SingleChildScrollView(
      child: participantRegistrationForm,
    );
  }
}
```

**Wait - this still has the problem:** At < 500px, `SingleChildScrollView` gives unbounded height, form's `Expanded(RestrictionsWidget)` will crash.

**Better approach:**

```dart
Widget _buildLeftColumn(...) {
  if (isNarrow) {
    return participantRegistrationForm;
  }
  
  // Desktop/Tablet: Always pass form directly
  // Form handles MainAxisSize adaptation via hasBoundedHeight
  // 1. If bounded & tall: Expanded restrictions, fits on screen
  // 2. If bounded & short: Expanded restrictions, cramped but works
  // 3. If unbounded: MainAxisSize.min, fixed-height restrictions
  
  // For very short heights where overflow is likely, wrap in scroll
  // But scroll = unbounded = form adapts to MainAxisSize.min
  
  if (constraints.maxHeight < 500) {
    return SingleChildScrollView(
      child: participantRegistrationForm,
    );
  }
  
  // For ≥500px: Direct placement, form gets bounded constraints
  return participantRegistrationForm;
}
```

**This works because:**
- At ≥500px: Form receives bounded height, uses `Expanded` restrictions
- At <500px: Form receives unbounded height, uses fixed-height restrictions (shrink-wrap)

### 18.5 Compact Form Changes (Phase 3)

To reduce form height, implement in Phase 3:

```dart
// In participant_registration_form.dart or theme

// Option 1: Apply at form level
return Theme(
  data: Theme.of(context).copyWith(
    visualDensity: VisualDensity.compact,
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  ),
  child: existingFormContent,
);

// Option 2: Apply globally in zza_theme.dart
// This would affect all forms in the app
```

### 18.6 Implementation Phases (Final)

#### Phase 1: Fix Critical Layout Issue
- [ ] Debug to confirm root cause of disappearing form
- [ ] Remove nested CustomScrollView in `_buildLeftColumn`
- [ ] Add height threshold check for scroll fallback
- [ ] Test at multiple screen sizes

#### Phase 2: Breakpoint Consistency  
- [ ] Add `wideContentMaxWidth: 1600.0` to design system
- [ ] Replace hardcoded gap with `AppSpacing.xxl`
- [ ] Verify column calculation works correctly

#### Phase 3: Compact Form
- [ ] Implement `VisualDensity.compact` for PC
- [ ] Reduce spacing between form elements
- [ ] Add `isDense: true` to inputs
- [ ] Test height reduction

#### Phase 4: Polish
- [ ] Test at all target screen sizes
- [ ] Ensure 800x600 tests pass
- [ ] Visual review

### 18.7 Files to Modify

| File | Changes | Phase |
|------|---------|-------|
| `intake_main_content.dart` | Remove CustomScrollView wrapper, add height check | 1 |
| `app_breakpoints.dart` | Add wideContentMaxWidth constant | 2 |
| `intake_main_content.dart` | Use AppSpacing.xxl for gap | 2 |
| `participant_registration_form.dart` or `zza_theme.dart` | Compact density | 3 |

---

## 19. Container Behavior Verification (2026-01-06 v9)

> **Purpose:** Verify all assumptions about widget behavior via web search. This prevents implementation failures due to incorrect assumptions.

### 19.1 Verified Container Behaviors

#### ✅ VERIFIED: Row + CrossAxisAlignment.stretch + Expanded

**Assumption:** Row passes bounded height to Expanded children when CrossAxisAlignment.stretch is used.

**Web Search Result:** ✅ CONFIRMED
- `CrossAxisAlignment.stretch` propagates **tight vertical constraints** to children
- Children are forced to match the maximum height provided to the Row
- **CRITICAL REQUIREMENT:** Row itself MUST have bounded height from its parent
- If Row has unbounded height → "BoxConstraints forces an infinite height" error

**Impact on our solution:**
- ✅ Our structure works: Scaffold → Column → Expanded → IntakeMainContent gives Row bounded height
- ✅ Row's Expanded children (form, file viewer) will receive bounded height

---

#### ✅ VERIFIED: SingleChildScrollView passes UNBOUNDED height

**Assumption:** SingleChildScrollView gives unbounded height constraints to its child.

**Web Search Result:** ✅ CONFIRMED
- SingleChildScrollView provides **unbounded height** to its child
- Child can be infinitely tall (that's the point - it scrolls)
- **Expanded inside will CRASH** - cannot expand into infinite space
- Using Expanded/Flexible directly inside SingleChildScrollView causes errors

**Impact on our solution:**
- ⚠️ At <500px height, we wrap form in SingleChildScrollView
- ⚠️ Form receives unbounded height → `hasBoundedHeight = false`
- ✅ Form already handles this: uses `MainAxisSize.min` and non-Expanded restrictions
- ✅ This is CORRECT behavior for scroll mode

---

#### ✅ VERIFIED: Column + Expanded constraint behavior

**Assumption:** Expanded in Column receives tight constraints for remaining space.

**Web Search Result:** ✅ CONFIRMED
- Column first lays out non-flexible children
- Calculates remaining space after non-flexible children
- Expanded receives **tight constraints** for that remaining space
- Child of Expanded is forced to fill exactly that space
- Multiple Expanded widgets split space by flex ratio

**Impact on our solution:**
- ✅ Form's `Expanded(RestrictionsWidget)` will fill remaining space correctly
- ✅ RestrictionsWidget internal list will take available space

---

#### ✅ VERIFIED: LayoutBuilder reports parent constraints

**Assumption:** LayoutBuilder accurately reports constraints from its parent.

**Web Search Result:** ✅ CONFIRMED
- LayoutBuilder doesn't create constraints, it **reports** them
- It receives constraints from immediate parent
- `constraints.maxWidth/maxHeight` reflect what parent allows
- Can be infinity if parent provides unbounded constraints

**Impact on our solution:**
- ✅ Form's LayoutBuilder will report FINITE width from Row → Expanded
- ✅ No need to pass width explicitly - just remove the sliver wrapper
- ✅ Column calculation will use correct constrained width

---

#### ✅ VERIFIED: MainAxisSize.max vs MainAxisSize.min

**Assumption:** MainAxisSize.min shrink-wraps children and is safe with unbounded constraints.

**Web Search Result:** ✅ CONFIRMED
- `MainAxisSize.max`: Column fills all available space (fails with Expanded + unbounded)
- `MainAxisSize.min`: Column shrink-wraps to children's size (safe with unbounded)
- **Expanded inside MainAxisSize.min + unbounded = ERROR** (still crashes)
- Solution: Don't use Expanded when receiving unbounded constraints

**Impact on our solution:**
- ✅ Form's logic is correct:
  ```dart
  mainAxisSize: constraints.hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min
  if (constraints.hasBoundedHeight)
    Expanded(RestrictionsWidget)  // Only if bounded
  else
    RestrictionsWidget  // No Expanded if unbounded
  ```
- ✅ This handles both bounded and unbounded correctly

---

#### ✅ VERIFIED: constraints.hasBoundedHeight behavior

**Assumption:** hasBoundedHeight correctly indicates if maxHeight is finite.

**Web Search Result:** ✅ CONFIRMED
- `hasBoundedHeight = true`: maxHeight has finite value
- `hasBoundedHeight = false`: maxHeight is `double.infinity`
- Widgets should check this before using Expanded
- Common errors when ignoring this check

**Impact on our solution:**
- ✅ Form already checks `constraints.hasBoundedHeight`
- ✅ Correctly adapts layout based on constraint type

---

### 19.2 Container Combinations in Our Solution

#### Combination A: Bounded Path (Desktop ≥500px height)

```
Scaffold (screen height)
└── Column (receives screen height)
    ├── IntakePersonRow (~60px)
    ├── Expanded → IntakeMainContent (remaining height)
    │   └── LayoutBuilder (bounded width × bounded height)
    │       └── Row (CrossAxisAlignment.stretch)
    │           ├── Expanded(flex:4) → Form
    │           │   └── form gets: width=4/7 of Row, height=Row height (BOUNDED)
    │           │   └── hasBoundedHeight=TRUE
    │           │   └── MainAxisSize.max, Expanded(RestrictionsWidget)
    │           └── Expanded(flex:3) → FileViewer
    └── IntakeBottomRow (~60px)
```

**Verification:** ✅ All assumptions confirmed by web search

---

#### Combination B: Unbounded Path (Compact <500px height)

```
Scaffold (screen height)
└── Column
    ├── IntakePersonRow
    ├── Expanded → IntakeMainContent
    │   └── LayoutBuilder
    │       └── Row
    │           ├── Expanded(flex:4) → SingleChildScrollView
    │           │   └── Form
    │           │       └── form gets: width=BOUNDED, height=UNBOUNDED
    │           │       └── hasBoundedHeight=FALSE
    │           │       └── MainAxisSize.min, RestrictionsWidget (no Expanded)
    │           └── Expanded(flex:3) → FileViewer
    └── IntakeBottomRow
```

**Verification:** ✅ All assumptions confirmed

---

#### Combination C: Mobile Path (width <600px)

```
IntakeMainContent
└── LayoutBuilder (bounded)
    └── CustomScrollView (existing mobile path)
        └── SliverToBoxAdapter (form) - UNBOUNDED height
        └── SliverToBoxAdapter (file viewer)
```

**Status:** 🟡 Not changing mobile path - assumed working

---

### 19.3 Assumption Critique Summary

| Assumption | Source | Status | Notes |
|------------|--------|--------|-------|
| Row+stretch passes bounded height | web search | ✅ Confirmed | Requires Row to have bounded height |
| SingleChildScrollView = unbounded | web search | ✅ Confirmed | Expanded crashes inside |
| Column+Expanded = tight constraints | web search | ✅ Confirmed | Fills remaining space |
| LayoutBuilder reports parent constraints | web search | ✅ Confirmed | Just reports, doesn't create |
| MainAxisSize.min shrink-wraps | web search | ✅ Confirmed | Safe with unbounded |
| hasBoundedHeight checks infinity | web search | ✅ Confirmed | Correct behavior |
| Form adapts via hasBoundedHeight | code review | ✅ Confirmed | Already implemented correctly |

---

### 19.4 Critical Finding

**All container behavior assumptions are CORRECT.**

The proposed solution should work because:
1. Desktop path: Form receives bounded constraints → uses Expanded → fits to screen ✅
2. Compact path: Form receives unbounded constraints → shrink-wraps → scrolls ✅
3. Form's existing `hasBoundedHeight` check handles both cases ✅

**No changes needed to the form's internal constraint handling logic.**

Only change needed: Remove the nested `CustomScrollView` wrapper in `_buildLeftColumn` so form receives proper bounded constraints from Row→Expanded.

---

## 20. Strict Solution Design Loop (2026-01-06 v10)

> **Methodology:** Deep rigour. 
> Loop: Problem → Search → Idea → Alt Search → Container Analysis → Impact Analysis → Refine → Code Quality → Finish.
> **Goal:** 7 Fully vetted ideas.

---

### 20.1 Problem Definition (Refined)
**"The Scroll Wiggle & Layout Paradox"**
- **Goal:** Form should "fit to screen" (no scroll) on large devices to avoid wiggle and varying layout processing.
- **Constraint:** Must scroll on small devices/content overflow.
- **Context:** Form is inside `IntakeMainContent` → `Row` (on desktop) OR `CustomScrollView` (on mobile).
- **Current Bug:** `SliverFillRemaining` passes infinite constraints logic, causing LayoutBuilder anomalies (disappearing form, wrong column count).
- **Core Challenge:** Detecting *when* to scroll without causing layout oscillations or "unbounded height" crashes in `Expanded` children.

---


| Date | Version | Author | Change |
|------|---------|--------|--------|
| 2026-01-06 | v1 | AI | Document created |
| 2026-01-06 | v2 | AI | Added version tracking, anti-patterns |
| 2026-01-06 | v3 | AI | Added decisions, constraint analysis |
| 2026-01-06 | v4 | AI | Added visual analysis with screenshots, root cause hypotheses |
| 2026-01-06 | v5 | AI | Added target spec, 9 idea evaluations, recommended solution |
| 2026-01-06 | v6 | AI | First critique: 6 weak spots, container interaction problems |
| 2026-01-06 | v7 | AI | Second critique: test compatibility, height calculations |
| 2026-01-06 | v8 | AI | Final decision: Compact-first + scroll fallback |
| 2026-01-06 | v9 | AI | **Container behavior verification: All 6 assumptions confirmed via web search** |

### 21. Dynamic Sizing Proposal (Phase 6)
**User Feedback:** "Dynamic compactness should be possible - standard size on full screen, compact on small."

**Analysis:**
- **Current State:** Compact theme hardcoded in `ParticipantRegistrationForm`.
- **Proposed Change:** Decouple Theme density from the form widget.
- **Solution:**
    1. Remove `Theme` wrapper from `ParticipantRegistrationForm`.
    2. Move `Theme` logic to parent widgets (`IntakeMainContent`, `ParticipantRegistrationPage`).
    3. Conditionally apply `visualDensity: compact` ONLY when `isCompact` (height < 600px) is true.
    4. Otherwise, use standard density (larger touch targets, more readability).

**Benefit:** optimizes detailed data entry on desktops while preserving the "fit-to-screen" fix for smaller laptops.


### 22. Deep Dive Analysis: Dynamic Sizing Strategies (2026-01-06)

**Goal:** Optimize form readability on large screens (Standard Sizing) while ensuring it fits without scrolling on small screens (Compact Sizing).

**Critical Risk Analysis:** "The In-Between Zone"
If we switch to Standard Sizing too early (e.g., at 600px height), but the Standard Form actually requires 750px, we trigger overflow/scrolling on screens between 600px and 750px. This violates the "Fit to Screen" objective and causes the dreaded "enlarging UI when space is not there."

#### Idea Loop Analysis (7 Strategies)

**1. The Naive Threshold (Status Quo)**
- **Concept:** `height < 600 ? Compact : Standard`.
- **Failure Mode:** On a 650px screen, it switches to Standard. Standard requires ~780px. Result: **OVERFLOW**.
- **Verdict:** ❌ **FAIL**. Unsafe.

**2. The "Scientific" Threshold (Safe Harbor)**
- **Concept:** Measure the *actual* height required by Standard Sizing (estimated ~800px) and use THAT as the safety threshold.
- **Logic:** `height < 800 ? Compact : Standard`.
- **Scenario:** 13" Laptop (768px) -> `< 800` -> **Compact** -> Fits perfectly (~570px).
- **Scenario:** 24" Monitor (1080px) -> `> 800` -> **Standard** -> Fits perfectly (~780px).
- **Verdict:** ✅ **STRONG CANDIDATE**. Safe, predictable.

**3. Three-Tier System**
- **Concept:** Ultra Compact (<600), Hybrid (600-900), Spacious (>900).
- **Critique:** Adds significant maintenance complexity.
- **Verdict:** ⚠️ **Valid but Complex**.

**4. Gradual Scaling**
- **Concept:** Scale text/padding linearly based on height.
- **Critique:** Non-integer pixel snapping leads to blurry text and "wiggle". Breaks Material Grid.
- **Verdict:** ❌ **FAIL**.

**5. Scroll-Aware Feedback**
- **Concept:** Render Standard -> Check Overflow -> Retry Compact.
- **Critique:** Infinite layout loop risk (Compact fits -> Standard -> Overflow -> Compact...).
- **Verdict:** ❌ **FAIL**. Unstable.

**6. User Toggle ("Comfort Mode")**
- **Concept:** Manual button for user to choose density.
- **Critique:** Good fallback, but puts burden on user.
- **Verdict:** ⚠️ **Fallback Choice**.

**7. Aspect-Ratio Driven**
- **Concept:** Use 16:9 vs 4:3 ratios.
- **Critique:** A 13" laptop and 32" monitor have same ratio (16:9) but vastly different heights.
- **Verdict:** ❌ **FAIL**. Misleading signal.

#### Final Recommendation: Idea 2 (Scientific Threshold)
We must treat "Standard Sizing" as a **luxury** for tall screens, not the default for "Desktop".
**Revised Plan:**
1.  **Safety Buffer:** Determine that Standard Form needs approx 800px.
2.  **Threshold:** Set `isCompact = height < 800` (NOT 600).
3.  **Result:** Eliminates the "In-Between Zone" risk entirely. Standard is only used when we are 100% sure it fits.
