# Responsive Intake Form Refactor - Master Planning Document

> **Created:** 2026-01-06
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
| **Starting work on intake form layout** | Read Sections 2 & 5 to avoid repeating past mistakes |
| **Hit a constraint error** | Check Section 2 for similar patterns |
| **Planning a new approach** | Add to Section 4 (Thinking Process) |
| **Making implementation decisions** | Document in Section 3 |
| **Trying a specific widget/pattern** | Log result in Section 2 |

### Critical Rules

1. **NO implementation without completed planning** - all approaches must be documented first
2. **Check Section 2 before trying any approach** - don't repeat failures
3. **Document ALL attempts and outcomes** - even if they seem unrelated
4. **Update thinking process** - keep track of reasoning to prevent circular logic

---

## 2. Attempted Solutions Log

> Add entries here using the format below. This prevents re-trying failed approaches.

### Template

```markdown
### [Approach Name]
**Date:** YYYY-MM-DD  
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
**Date:** Pre-2026-01  
**Problem Addressed:** Making the form fit on screen  
**What We Tried:** Using hardcoded heights for sections  
**Result:** ❌ Failed  
**Why It Failed:** Doesn't adapt to different screen sizes; causes overflow on small screens, wastes space on large screens  
**Lesson Learned:** Never use fixed pixel heights for main layout containers

#### Nested ScrollViews
**Date:** Pre-2026-01  
**Problem Addressed:** Overflow when content exceeds screen  
**What We Tried:** Multiple ScrollViews nested (CustomScrollView containing Column containing RestrictionsWidget with internal ListView)  
**Result:** ⚠️ Partial  
**Why It Failed:** "Scroll wiggle" effect; conflicting scroll controllers; unbounded constraints passed to children  
**Lesson Learned:** Need clear scroll scope - either page scrolls OR internal widgets scroll (not both competing)

#### Expanded Without Bounded Parent
**Date:** Pre-2026-01  
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
**Date:** YYYY-MM-DD  
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

#### Primary Screen: Intake Form (`NewIntakeFormImproved`)

**Current Structure:**
```
Scaffold
└── Center
    └── ConstrainedBox (maxWidth: 1600)
        └── Column
            ├── IntakePersonRow (search widget)
            ├── Expanded → IntakeMainContent
            │   └── LayoutBuilder
            │       └── Row (desktop) or CustomScrollView (mobile)
            │           ├── ParticipantRegistrationForm (4 flex)
            │           └── FileViewer/Camera (3 flex)
            └── IntakeBottomRow (buttons)
```

**Current Problems Identified:**
1. On fullscreen, the rightmost column (potvrzení/file viewer) might disappear
2. The form input fields are too large for PC (optimized for touch, not mouse/keyboard)
3. Vertical space around search widget is not efficiently used
4. When screen gets very large, content doesn't scale up to use the space
5. Inconsistent wrapping behavior at different breakpoints

#### Secondary Screen: Participant Registration Form (`ParticipantRegistrationForm`)

**Current Structure:**
```
ParticipantRegistrationForm
└── LayoutBuilder
    └── ZzaScrollable (with stickyFooter handling)
        └── Column
            ├── _buildGridView (name/surname/insurance/etc)
            ├── _buildCheckboxSection
            └── _buildRestrictionsSection
                ├── RestrictionsWidget
                └── MemoryRestrictionWidget
```

**Known Issues:**
- RestrictionsWidget height is complex (needs 3 items visible, plus scroll indicators)
- Form doesn't adapt well to very small or very large screens
- Constraint errors when embedding in IntakeMainContent

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

### Questions We Need To Answer Before Implementation

1. **What are the exact target screen sizes?**
   - Flutter test default: 800 x 600
   - Minimum viable: ?
   - Maximum tested: ?
   - Primary usage: 1920x1080? 1366x768?

2. **What are the priority breakpoints for the intake form?**
   - Current `AppBreakpoints`: mobile (600), tablet (900), desktop (1200)
   - Do we need intake-form-specific breakpoints?

3. **What should happen at each breakpoint?**
   - < 600px: Mobile layout (stacked, scrollable)
   - 600-900px: 2 columns? Which columns?
   - 900-1200px: All 3 columns? Compact?
   - > 1200px: Spacious 3 columns

4. **What constitutes the 3 "columns" for PC view?**
   - Column 1: Form fields (jméno, příjmení, etc.)
   - Column 2: Restrictions/medications
   - Column 3: Potvrzení (file upload/camera)
   
   OR
   
   - Column 1: All form including restrictions
   - Column 2: File upload
   - Column 3: ??? (restriction switches? validation status?)

5. **What is the minimum content size for each area?**
   - Needed to calculate breakpoints where columns must collapse

### What We Need To Understand Better

1. **RestrictionsWidget constraints** - How does it size itself? What does it need from its parent?
2. **Form field sizing** - Can we use `VisualDensity` to make fields smaller on desktop?
3. **IntakeMainContent** - Is the current Row/CustomScrollView approach correct?
4. **ParticipantRegistrationForm** - Can it accept bounded height? Or must it always define its own size?

---

## 5. Implementation Phases (To Be Planned)

> This section will be populated after research phase is complete

### Phase 0: Deep Analysis (Current)
- [ ] Understand complete constraint flow from Scaffold to RestrictionsWidget
- [ ] Document minimum sizes for each component
- [ ] Identify exact breakpoints needed
- [ ] Create constraint flow diagram

### Phase 1: Foundation
- [ ] (To be defined after Phase 0)

### Phase 2: Form Layout
- [ ] (To be defined after Phase 0)

### Phase 3: Responsive Adaptation
- [ ] (To be defined after Phase 0)

### Phase 4: Polish
- [ ] (To be defined after Phase 0)

---

## 6. Resources & References

### Project Files

| File | Purpose |
|------|---------|
| `lib/screens2/intake_form_improved.dart` | Main intake screen (191 lines) |
| `lib/screens2/participant_registration_form.dart` | Form widget (706 lines) |
| `lib/screens2/widgets/intake_main_content.dart` | Layout for form + file viewer (147 lines) |
| `lib/screens2/widgets/restrictions_widget.dart` | Restrictions list |
| `lib/design_system/tokens/app_breakpoints.dart` | Breakpoint definitions (137 lines) |

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

## 7. Notes & Observations

_Add ad-hoc notes, observations, and insights here during the process_

### Initial Observations (2026-01-06)

1. **IntakeMainContent** already uses `AppBreakpoints.isMobile()` and `isCompactHeight()` - foundation exists
2. **SliverFillRemaining** is used in IntakeMainContent for desktop - this is a good pattern
3. **ParticipantRegistrationForm** has its own `LayoutBuilder` inside - potential constraint conflicts?
4. The form uses `ZzaScrollable` which has `stickyFooter` support - need to understand this
5. **ConstrainedBox(maxWidth: 1600)** on the outer level - ensures content doesn't stretch infinitely

---

## Changelog

| Date | Author | Change |
|------|--------|--------|
| 2026-01-06 | AI | Document created with initial structure and problem analysis |

