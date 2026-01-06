# Responsive Intake Form Refactor - Master Planning Document

> **Created:** 2026-01-06  
> **Last Updated:** 2026-01-06 v3  
> **Status:** 🔄 Active Planning  
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
| **Starting work on intake form layout** | Read Sections 2, 5, & 8 to avoid repeating past mistakes |
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
**Options Considered:**
1. Replace with `contentMaxWidth` (1200px) - narrower, more consistent
2. Add `wideContentMaxWidth: 1600.0` to design system - explicit, documented
3. Remove constraint entirely - might look bad on ultra-wide monitors  
**Chosen:** Option 2 - Add to design system  
**Rationale:** User confirmed 1600px should be kept and made part of design system  
**Dependencies:** Requires update to `app_breakpoints.dart`

### Decision: Defer micro-spacing tokenization
**Date:** 2026-01-06 v3  
**Context:** Scattered 2px, 4px spacing values in forms  
**Chosen:** Defer until solution is implemented  
**Rationale:** Decide what's "right" based on final implementation needs  
**Dependencies:** None

### Decision: Large screens - prefer scaling, but not mandatory
**Date:** 2026-01-06 v3  
**Context:** How should content behave on >1920px screens?  
**Chosen:** Prefer scaling content up, but acceptable if solution caps and centers  
**Rationale:** Nice-to-have, not a hard requirement  
**Dependencies:** Will influence approach selection

---

## 4. Thinking Process Log

> Use this section to document reasoning and prevent circular logic.

### Current Understanding of the Problem Space

#### Target Screen Sizes (Finalized 2026-01-06 v3)

| Size | Dimensions | Notes | Priority |
|------|------------|-------|----------|
| **Flutter Test Default** | 800 x 600 | Must work - tests run here | Must Pass |
| **Common Laptop** | 1366 x 768 | Common PC size | High |
| **Full HD** | 1920 x 1080 | Should look optimal | Primary |
| **QHD+** | 2560 x 1440+ | Should scale up (preferred) or center | Nice-to-have |

#### Column Strategy (Finalized 2026-01-06 v3)

Within the **ParticipantRegistrationForm** (the left portion of IntakeMainContent):
- **Desktop (≥900px):** 3 columns of form fields per row
- **Tablet (600-899px):** 2 columns
- **Mobile (<600px):** 1 column

**Current implementation is CORRECT** - `_buildFormRow()` already adapts. The problem is constraint propagation.

### Key Components We Must Understand

#### 1. IntakeMainContent Structure
```
IntakeMainContent
└── LayoutBuilder
    ├── if (isNarrow): CustomScrollView [Right, Left] (stacked)  
    └── else: Row [Left(flex:4), Gap(24), Right(flex:3)]
                ├── Left: ParticipantRegistrationForm (in CustomScrollView)
                └── Right: FileViewer/Camera
```

**Current Issue:** The Row layout gives 4+3 = 7 flex units. Left gets 4/7 (~57%), Right gets 3/7 (~43%).  
On very wide screens, the file viewer grows too large while form might not need that much space.

#### 2. RestrictionsWidget Sizing Behavior (Analyzed 2026-01-06 v3)

**Key insight: RestrictionsWidget has TWO modes:**

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Bounded** | `isBounded: true` | `Column(MainAxisSize.max)` with `Expanded(child: list)` - fills available space |
| **Unbounded** | `isBounded: false` (default) | `Column(MainAxisSize.min)` with `SizedBox(height: listHeight)` - fixed height based on screen |

**The widget already adapts!** It just needs the correct `isBounded` flag from its parent.

**In unbounded mode (lines 143-163):**
```dart
final screenHeight = MediaQuery.sizeOf(context).height;
final isBrief = screenHeight < 800;  // ⚠️ Another magic number!
final targetItems = isBrief ? 2.7 : 3.7;
final listHeight = AppBreakpoints.getListHeight(context, itemCount: 1) * targetItems;
```

This uses a **local threshold of 800px** (not the global 600px compactHeight). This is intentional for 720p optimization.

#### 3. ParticipantRegistrationForm Constraint Handling

**Already implemented correctly (lines 318-352):**
```dart
mainAxisSize: constraints.hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
// ...
if (constraints.hasBoundedHeight)
  Expanded(child: _buildRestrictionsSection(isBounded: true))
else
  _buildRestrictionsSection(isBounded: false)
```

**The form passes `isBounded` to RestrictionsWidget based on whether IT received bounded constraints.**

### Constraint Flow Analysis

```
Scaffold (full screen height: bounded)
└── Column
    ├── IntakePersonRow (intrinsic height)
    ├── Expanded ← BOUNDED constraint to IntakeMainContent
    │   └── IntakeMainContent
    │       └── LayoutBuilder (receives bounded constraints)
    │           └── Row [Left, Right]
    │               └── Left: CustomScrollView
    │                   └── SliverFillRemaining(hasScrollBody: false)
    │                       └── ParticipantRegistrationForm
    │                           └── (receives bounded? DEPENDS on Sliver)
    └── IntakeBottomRow (intrinsic height)
```

**KEY QUESTION:** Does `SliverFillRemaining(hasScrollBody: false)` pass bounded constraints to its child?

According to Flutter docs: `SliverFillRemaining` with `hasScrollBody: false` will:
- Give child a **bounded** height = remaining viewport space
- Child can be smaller than viewport (will bottom-align)

So yes, `ParticipantRegistrationForm` SHOULD receive bounded constraints. But we need to verify this is working correctly.

---

## 5. Anti-Patterns & Bad Practices Analysis

> **Purpose:** Identify problematic patterns in current code that need fixing.  
> **Rule:** Changes to design system values require explicit approval.

### ⚠️ `ConstrainedBox(maxWidth: 1600)` in `intake_form_improved.dart`

**Location:** Line 153 `intake_form_improved.dart`  
**Status:** ✅ APPROVED - Add to design system as `wideContentMaxWidth: 1600.0`

---

### ⚠️ Hardcoded `SizedBox(width: 24)` in `intake_main_content.dart`

**Location:** Line 65 `intake_main_content.dart`  
**Status:** 🔶 Easy Fix - use `AppSpacing.xxl` (when implementing)

---

### ⚠️ Hardcoded `BoxConstraints(maxHeight: 400)` in `intake_main_content.dart`

**Location:** Lines 122-123 `intake_main_content.dart`  
**Analysis:** This constrains the file viewer to 400px max on mobile. On larger screens it uses Expanded.  
**Question:** Is 400px appropriate? Should this be responsive?  
**Status:** 🔶 Needs Discussion

---

### ⚠️ Hardcoded `screenHeight < 800` in `restrictions_widget.dart`

**Location:** Line 150 `restrictions_widget.dart`  
**Current Code:**
```dart
final isBrief = screenHeight < 800;
```
**Analysis:** This is DIFFERENT from `AppBreakpoints.compactHeight` (600px). Used specifically for 720p laptop optimization.  
**Question:** Should this be a design system constant? Or is local override acceptable?  
**Status:** 🔶 Tolerable - local optimization for specific use case

---

### ⚠️ Mixed micro-spacing in `participant_registration_form.dart`

**Locations:** Lines 428, 449, 468, 484, 491, 531  
**Examples:** `SizedBox(height: 4)`, `EdgeInsets.symmetric(vertical: 4)`  
**Status:** 🔶 Deferred - decide based on implementation needs

---

## 6. Questions Requiring Answers

### Answered ✅

| # | Question | Answer | Date |
|---|----------|--------|------|
| 1 | Target screen sizes? | 800x600 (min/test), 1920x1080 (primary), scale up for larger | 2026-01-06 v3 |
| 2 | Column strategy? | 3 form fields per row on desktop, 2 tablet, 1 mobile | 2026-01-06 v3 |
| 3 | 1600px constraint? | Keep and add to design system | 2026-01-06 v3 |
| 4 | Micro-spacing? | Defer until implementation | 2026-01-06 v3 |
| 5 | Large screens? | Prefer scale, acceptable to cap | 2026-01-06 v3 |

### Remaining Gaps 🔶

| # | Question | Why It Matters |
|---|----------|----------------|
| 6 | **What exactly is "disappearing column" problem?** | User mentioned rightmost column disappears on fullscreen - need to reproduce |
| 7 | **Are form fields too large on PC?** | User says inputs are too large for mouse/keyboard - is this sizing or density? |
| 8 | **What is the desired 3-column layout for intake page specifically?** | Is it Form \| Restrictions \| FileViewer? Or all form content in 2 columns + FileViewer? |
| 9 | **Should input density change based on screen size?** | PC could use `VisualDensity.compact` vs tablet `VisualDensity.standard` |
| 10 | **What is "vertical space around search widget"?** | User mentioned inefficient space - need specific example |

---

## 7. Implementation Phases (To Be Planned)

> This section will be populated after all questions are answered

### Phase 0: Deep Analysis (Current)
- [x] Document minimum viable screen size (800x600)
- [x] Clarify column strategy (form fields, not screen sections)
- [x] Get approval on 1600px design system addition
- [x] Analyze RestrictionsWidget sizing behavior
- [x] Analyze ParticipantRegistrationForm constraint handling
- [ ] **Clarify remaining gaps (questions 6-10)**
- [ ] Create visual mockup of desired layout at different breakpoints

### Phase 1: Foundation
- [ ] Add `wideContentMaxWidth: 1600.0` to `app_breakpoints.dart`
- [ ] (More steps TBD after Phase 0 complete)

### Phase 2: Form Layout
- [ ] (TBD)

### Phase 3: Responsive Adaptation
- [ ] (TBD)

### Phase 4: Polish
- [ ] (TBD)

---

## 8. Design System Change Requests

> **Rule:** Any changes to files in `lib/design_system/` require explicit user approval.

| File | Proposed Change | Status | Approved By |
|------|-----------------|--------|-------------|
| `app_breakpoints.dart` | Add `wideContentMaxWidth: 1600.0` | ✅ Approved | User (2026-01-06 v3) |
| `app_spacing.dart` | Add micro-spacing tokens? | 🔶 Deferred | - |
| `app_breakpoints.dart` | Add `restrictionsCompactHeight: 800.0`? | 🔶 Optional | - |

---

## 9. Resources & References

### Project Files

| File | Purpose | Lines |
|------|---------|-------|
| `lib/screens2/intake_form_improved.dart` | Main intake screen | 191 |
| `lib/screens2/participant_registration_form.dart` | Form widget | 706 |
| `lib/screens2/widgets/intake_main_content.dart` | Layout for form + file viewer | 147 |
| `lib/screens2/widgets/restrictions_widget.dart` | Restrictions list (has bounded/unbounded modes) | 364 |
| `lib/design_system/tokens/app_breakpoints.dart` | Breakpoint definitions | 137 |
| `lib/design_system/tokens/app_spacing.dart` | Spacing tokens | 45 |

### Design System Current Values

**AppBreakpoints:**
- `mobile`: 600px (< 600 = mobile mode)
- `tablet`: 900px (600-899 = tablet, ≥900 = desktop)  
- `desktop`: 1200px (for extended desktop features)
- `compactHeight`: 600px
- `contentMaxWidth`: 1200px ← used for general content
- `formMaxWidth`: 800px ← used for standalone forms
- **TO ADD: `wideContentMaxWidth`: 1600px** ← for intake form

**AppSpacing:**
- `xs`: 4px, `s`: 8px, `m`: 12px, `l`: 16px, `xl`: 20px, `xxl`: 24px

---

## 10. Notes & Observations

### 2026-01-06 v1
1. IntakeMainContent already uses AppBreakpoints - foundation exists
2. SliverFillRemaining is used for desktop - good pattern
3. ParticipantRegistrationForm has its own LayoutBuilder - potential conflicts?
4. ConstrainedBox(maxWidth: 1600) - flagged, now approved for design system

### 2026-01-06 v2
5. Flutter test default is 800x600 - falls into "tablet" breakpoint
6. Registration form already has correct column logic
7. The problem is constraint propagation, not responsive logic
8. ParticipantRegistrationForm uses `constraints.hasBoundedHeight` - adaptive

### 2026-01-06 v3
9. RestrictionsWidget has two modes: bounded (Expanded) and unbounded (SizedBox)
10. The widget ALREADY adapts based on `isBounded` prop passed from parent
11. Current constraint flow SHOULD work: Scaffold → Column → Expanded → IntakeMainContent → Row → CustomScrollView → SliverFillRemaining → Form (bounded)
12. Need to verify actual behavior matches expected behavior
13. User mentions specific issues (disappearing column, large inputs, wasted space) - need specifics

---

## Changelog

| Date | Version | Author | Change |
|------|---------|--------|--------|
| 2026-01-06 | v1 | AI | Document created with initial structure |
| 2026-01-06 | v2 | AI | Added version tracking, anti-patterns, user answers |
| 2026-01-06 | v3 | AI | Added decisions log, deep constraint analysis, remaining gaps to clarify |

