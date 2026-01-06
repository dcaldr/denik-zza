# Responsive Intake Form Refactor - Master Planning Document

> **Created:** 2026-01-06  
> **Last Updated:** 2026-01-06 v2  
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

### Template

```markdown
### Decision: [Title]
**Date:** YYYY-MM-DD vX  
**Context:** Why this decision was needed  
**Options Considered:**
1. Option A - pros/cons
2. Option B - pros/cons  
**Chosen:** Option X  
**Rationale:** Why this option  
**Dependencies:** What this affects  
```

### Decisions Made

_No decisions recorded yet - document created for fresh start_

---

## 4. Thinking Process Log

> Use this section to document reasoning and prevent circular logic.

### Current Understanding of the Problem Space

#### Target Screen Sizes (Research Completed 2026-01-06 v2)

| Size | Dimensions | Notes |
|------|------------|-------|
| **Flutter Test Default** | 800 x 600 | Minimum viable - must work here |
| **Preferred/Common PC** | 1920 x 1080 (Full HD) | Should look optimal here |
| **Secondary PC** | 1366 x 768 | Common laptop size |
| **Large Monitor** | 2560 x 1440 | Should use extra space, not waste it |

**Key insight:** Flutter test default (800x600) falls in "tablet" range (600-900px) based on current AppBreakpoints. This means tests run with 2 columns, not 3.

#### Column Strategy (Clarified 2026-01-06 v2)

**Context:** User clarified that "3 columns" refers to form fields layout, not screen sections.

Within the **ParticipantRegistrationForm** (the left portion of IntakeMainContent):
- **Desktop (≥900px):** 3 columns of form fields per row
  - Row 1: Jméno | Příjmení | Číslo pojištěnce (3 fields)
  - Row 2: [Datum narození + Pohlaví] | Zdravotní pojišťovna | Adresa (3 logical fields, where birthday+gender = 1)
  - Row 3: Jméno rodiče | Email rodiče | Telefon rodiče (3 fields)
- **Tablet (600-899px):** 2 columns
- **Mobile (<600px):** 1 column

**Current implementation:** `_buildFormRow()` and `_buildGridView()` in `participant_registration_form.dart` already does this correctly. The issue is the OUTER layout and constraints, not the field rows themselves.

#### What Still Needs Analysis

1. **Minimum content sizes** - what is the minimum height for each section?
2. **Whether form-specific breakpoints are better than global breakpoints**
3. **How to handle very large screens** - scale up or cap and center?

### Primary Screen: Intake Form (`NewIntakeFormImproved`)

**Current Structure:**
```
Scaffold
└── Center
    └── ConstrainedBox (maxWidth: 1600) ← ⚠️ See Anti-patterns Section 5
        └── Column
            ├── IntakePersonRow (search widget)
            ├── Expanded → IntakeMainContent
            │   └── LayoutBuilder
            │       └── Row (desktop) or CustomScrollView (mobile)
            │           ├── ParticipantRegistrationForm (4 flex)
            │           └── FileViewer/Camera (3 flex)
            └── IntakeBottomRow (buttons)
```

**Identified Problems:**
1. On fullscreen, the rightmost column (potvrzení/file viewer) might disappear
2. The form input fields are too large for PC (optimized for touch, not mouse/keyboard)
3. Vertical space around search widget is not efficiently used
4. When screen gets very large, content doesn't scale up to use the space
5. Inconsistent wrapping behavior at different breakpoints

### Secondary Screen: Participant Registration Form (`ParticipantRegistrationForm`)

**Current Structure (706 lines):**
```
ParticipantRegistrationForm
└── LayoutBuilder
    └── Padding (containerPadding)
        └── Form
            └── Column (MainAxisSize: max if bounded, min if unbounded)
                ├── _buildSuccessMessage (if present)
                ├── _buildGridView (9 fields in 3 rows) ← COLUMN LOGIC LIVES HERE
                ├── SizedBox(AppSpacing.s)
                ├── _buildTextField('poznamka')
                ├── SizedBox(AppSpacing.s)
                ├── _buildCheckboxSection
                ├── SizedBox(AppSpacing.xs)
                ├── if (bounded) Expanded(_buildRestrictionsSection)
                │   else _buildRestrictionsSection
                └── if (!stickyFooter) FilledButton
```

**Key Discovery (2026-01-06 v2):**
- The form uses `constraints.hasBoundedHeight` to decide whether to use `Expanded` or not
- This is a **correct pattern** - it adapts to its parent's constraint mode
- But it requires the PARENT to pass correct constraints

### Flutter Layout Principles We Must Remember

> Reference: `docs/architecture/flutter-ui summaries/flutter-adaptive-responsive-guide.md`

1. **Constraints flow DOWN, sizes flow UP**
   - Parent tells child its constraints (min/max width/height)
   - Child reports its size back to parent
   - If parent has unbounded constraint → child MUST have intrinsic size

2. **LayoutBuilder vs MediaQuery**
   - `LayoutBuilder` gives you PARENT constraints (what YOU have available)
   - `MediaQuery` gives you SCREEN size (NOT what you have available)
   - **Use LayoutBuilder for responsive layout decisions**

3. **Expanded/Flexible Requirements**
   - ONLY work in Row/Column with BOUNDED main axis
   - If parent is unbounded, Expanded WILL crash
   - Must have a finite size to "expand into"

4. **Common Patterns That Work:**
   - `Scaffold + Column [Fixed, Expanded, Fixed]` - header, content, footer
   - `LayoutBuilder → if wide then Row else Column`
   - `SliverFillRemaining(hasScrollBody: false)` for filling remaining space in CustomScrollView
   
5. **Common Patterns That FAIL:**
   ```dart
   // ❌ ListView with shrinkWrap: true in Expanded → ignores expand
   // ❌ Expanded inside SingleChildScrollView → unbounded
   // ❌ Column inside Column without height constraints → unbounded
   ```

---

## 5. Anti-Patterns & Bad Practices Analysis

> **Purpose:** Identify problematic patterns in current code that need fixing.  
> **Rule:** Changes to design system values require explicit user approval.

### ⚠️ `ConstrainedBox(maxWidth: 1600)` in `intake_form_improved.dart`

**Location:** Line 153 `intake_form_improved.dart`

**Current Code:**
```dart
child: ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 1600),
  ...
)
```

**Problem Analysis:**
| Aspect | Assessment |
|--------|------------|
| **Is it in Design System?** | ❌ NO - hardcoded magic number |
| **Design System Values** | `contentMaxWidth: 1200.0`, `formMaxWidth: 800.0` |
| **Gap** | 1600 > 1200 (33% larger than design system max) |

**Issues:**
1. Inconsistent with `AppBreakpoints.contentMaxWidth` (1200px)
2. Magic number not documented
3. On 1920px screen, leaves only 160px margins each side (may be intentional?)

**Questions for User:**
- Should this use `AppBreakpoints.contentMaxWidth` (1200)?
- Or should we add a new design system constant for "wide content" (1600)?
- Or is 1600 wrong and should be removed entirely?

**Status:** 🔶 Needs Discussion

---

### ⚠️ Hardcoded `SizedBox(width: 24)` in `intake_main_content.dart`

**Location:** Line 65 `intake_main_content.dart`

**Current Code:**
```dart
const SizedBox(width: 24),
```

**Problem:**
- Not using `AppSpacing` tokens
- Design system has `AppSpacing.xxl = 24.0` for this purpose

**Fix (when approved):**
```dart
SizedBox(width: AppSpacing.xxl),
// OR
AppSpacing.largeGap, // if horizontal gap exists
```

**Status:** 🔶 Easy Fix - needs approval

---

### ⚠️ Hardcoded Constraints in `intake_main_content.dart`

**Location:** Lines 122-123 `intake_main_content.dart`

**Current Code:**
```dart
ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 400),
  child: _buildFileViewer()),
```

**Problem:**
- Magic number 400px
- Not responsive to actual available space
- Not in design system

**Status:** 🔶 Needs Principle Decision - how should this area size?

---

### ⚠️ Mixed Usage of Hardcoded Values in `participant_registration_form.dart`

**Locations:** Lines 428, 449, 468, 484, 491, 531

**Examples:**
```dart
const SizedBox(height: 4),  // Should be AppSpacing.xs (4.0)?
const SizedBox(height: 8),  // Should be AppSpacing.s (8.0)?
const EdgeInsets.symmetric(vertical: 4),  // Tokenize?
const EdgeInsets.symmetric(horizontal: 2), // Tokenize?
```

**Assessment:**
- Some values ARE from design system (`AppSpacing.s = 8.0`)
- Others are ad-hoc micro-spacing (2px, 4px horizontal padding)

**Question:** Should micro-spacing (< 8px) be tokenized, or is ad-hoc acceptable for fine-tuning?

**Status:** 🔶 Needs Policy Decision

---

### ✅ Correct Pattern: `IntakeMainContent` Using `AppBreakpoints`

**Location:** `intake_main_content.dart` lines 32-35

```dart
final isNarrow = AppBreakpoints.isMobile(constraints.maxWidth);
final isCompact = AppBreakpoints.isCompactHeight(constraints.maxHeight);
```

**This is GOOD** - using design system breakpoints instead of magic numbers.

---

### ✅ Correct Pattern: `ParticipantRegistrationForm` constraints detection

**Location:** `participant_registration_form.dart` lines 319, 341

```dart
mainAxisSize: constraints.hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
// ...
if (constraints.hasBoundedHeight) Expanded(...) else ...
```

**This is GOOD** - form adapts to whether parent provides bounded or unbounded constraints.

---

## 6. Questions Requiring Answers

### Answered ✅

| # | Question | Answer | Date |
|---|----------|--------|------|
| 1 | Target screen sizes? | Default: 800x600 (Flutter test), Preferred: 1920x1080+, Min: 800x600 | 2026-01-06 v2 |
| 3 | What should happen at each breakpoint? | Same as registration: 3 cols desktop, 2 tablet, 1 mobile | 2026-01-06 v2 |
| 4 | What constitutes `columns`? | Form FIELDS, not screen sections. 3 fields per row on desktop. | 2026-01-06 v2 |

### Needs Analysis 🔶

| # | Question | Analysis Needed |
|---|----------|-----------------|
| 2 | Form-specific breakpoints vs global? | Compare field minimum widths to AppBreakpoints thresholds |
| 5 | Minimum content sizes for each section | Measure intrinsic sizes of each form section |
| 6 | How to handle very large screens (>1920px)? | Scale up, cap and center, or add side panels? |
| 7 | How should the file viewer/camera section size? | Fixed, percentage, or remaining space? |

---

## 7. Implementation Phases (To Be Planned)

> This section will be populated after research phase is complete

### Phase 0: Deep Analysis (Current)
- [x] Document minimum viable screen size (800x600)
- [x] Clarify column strategy (form fields, not screen sections)
- [ ] ~~Measure minimum intrinsic sizes for each section~~
- [ ] ~~Create constraint flow diagram~~
- [ ] Analyze if current breakpoints are appropriate
- [ ] Decide on anti-pattern fixes

### Phase 1: Foundation
- [ ] (To be defined after Phase 0)

### Phase 2: Form Layout
- [ ] (To be defined after Phase 0)

### Phase 3: Responsive Adaptation
- [ ] (To be defined after Phase 0)

### Phase 4: Polish
- [ ] (To be defined after Phase 0)

---

## 8. Design System Change Requests

> **Rule:** Any changes to files in `lib/design_system/` require explicit user approval.

| File | Proposed Change | Status | Approved By |
|------|-----------------|--------|-------------|
| `app_breakpoints.dart` | Add `wideContentMaxWidth: 1600.0`? | 🔶 Pending Discussion | - |
| `app_spacing.dart` | Add micro-spacing tokens (xs=4, xxs=2)? | 🔶 Pending Discussion | - |

---

## 9. Resources & References

### Project Files

| File | Purpose | Lines |
|------|---------|-------|
| `lib/screens2/intake_form_improved.dart` | Main intake screen | 191 |
| `lib/screens2/participant_registration_form.dart` | Form widget | 706 |
| `lib/screens2/widgets/intake_main_content.dart` | Layout for form + file viewer | 147 |
| `lib/screens2/widgets/restrictions_widget.dart` | Restrictions list | ? |
| `lib/design_system/tokens/app_breakpoints.dart` | Breakpoint definitions | 137 |
| `lib/design_system/tokens/app_spacing.dart` | Spacing tokens | 45 |

### Design System Current Values

**AppBreakpoints:**
- `mobile`: 600px (< 600 = mobile mode)
- `tablet`: 900px (600-899 = tablet, ≥900 = desktop)  
- `desktop`: 1200px (for extended desktop features)
- `compactHeight`: 600px
- `contentMaxWidth`: 1200px
- `formMaxWidth`: 800px

**AppSpacing:**
- `xs`: 4px, `s`: 8px, `m`: 12px, `l`: 16px, `xl`: 20px, `xxl`: 24px

### Documentation

| File | Content |
|------|---------|
| `docs/architecture/flutter-ui summaries/flutter-adaptive-responsive-guide.md` | Flutter responsive design patterns (1223 lines) |
| `.agent/workflows/flutter-ui.md` | UI design workflow |
| `.agent/workflows/flutter-layout-debug.md` | Constraint debugging workflow |

### Related Conversations (from history)

| ID | Topic | Key Takeaways |
|----|-------|---------------|
| b9419799 | Optimize Form Scroll Visibility | Scroll indicators, visibility detection |
| e8ac0eac | Responsive Adaptive UI Refactor | Multi-column to single-column adaptation |
| 746c8b59 | Fix Participant Form Layout | Fit-to-page layout, hybrid LayoutBuilder |
| c1fb38b6 | Fixing Form Layout Issue | Bounded ListView in RestrictionsWidget |

---

## 10. Notes & Observations

_Add ad-hoc notes, observations, and insights here during the process_

### Initial Observations (2026-01-06 v1)

1. **IntakeMainContent** already uses `AppBreakpoints.isMobile()` and `isCompactHeight()` - foundation exists
2. **SliverFillRemaining** is used in IntakeMainContent for desktop - this is a good pattern
3. **ParticipantRegistrationForm** has its own `LayoutBuilder` inside - potential constraint conflicts?
4. The form uses `ZzaScrollable` which has `stickyFooter` support - need to understand this
5. **ConstrainedBox(maxWidth: 1600)** on the outer level - flagged as anti-pattern, needs discussion

### Updated Observations (2026-01-06 v2)

6. **Flutter test default is 800x600** - falls into "tablet" breakpoint range (600-900)
7. **Registration form already has correct column logic** - `_buildFormRow()` handles 1/2/3 columns
8. **The problem is constraint propagation**, not the responsive logic itself
9. **ParticipantRegistrationForm uses `constraints.hasBoundedHeight`** - this is a good adaptive pattern
10. **Hardcoded values scattered throughout** - need systematic tokenization pass

---

## Changelog

| Date | Version | Author | Change |
|------|---------|--------|--------|
| 2026-01-06 | v1 | AI | Document created with initial structure and problem analysis |
| 2026-01-06 | v2 | AI | Added version tracking, anti-patterns section, integrated user answers, updated questions |

