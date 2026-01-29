# New Record Page Layout Interactions (Detailed)

## Scope

This document describes container relationships, constraints, and scroll behavior for the New Record page. It maps the widget tree, parent/child constraint flows, and compares against the provided layout cheat sheets and Flutter references.

## Primary Widget Tree (High-Level)

- `Scaffold`
  - `AppBar`
  - `Drawer`
  - `bottomNavigationBar`: fixed action buttons container
  - `body`: `LayoutBuilder`
    - `Padding` (screen padding)
      - `Column` (main vertical stack)
        - **Participant header** (top card)
        - **History section** (records)
        - **Form section** (record creation)

## Detailed Container Relationships

### 1) Scaffold → AppBar / Drawer / bottomNavigationBar / body

- **Parent constraints**: The `Scaffold` provides bounded constraints to its body (screen size minus app bar, system insets, and bottomNavigationBar height).
- **Side effects**:
  - `bottomNavigationBar` reduces available height for `body`.
  - The body is not inherently scrollable; any vertical overflow must be handled inside the body.

### 2) Body LayoutBuilder → Padding → Column

- **Constraints**:
  - `LayoutBuilder` receives the bounded body height.
  - `Padding` reduces available size by `AppSpacing.screenPadding`.
  - `Column` receives tight max height from parent.
- **Column children** (ordered):
  1) Participant header (fixed height)
  2) History section (flexible height)
  3) Form section (intrinsic height)
- **Rule**: The Column is the main vertical allocator. If any child exceeds available height, overflow will occur unless a scrollable or flexible layout is used.

### 3) Participant Header (top card)

- **Widget**: `Container` with gradient background and internal `Row`.
- **Constraints**: Tight width, loose height determined by content.
- **Children**:
  - Left icon (fixed)
  - Middle info `Expanded` (text + badges)
  - Right `Expanded` (search autocomplete)
- **Behavior**:
  - Uses `Expanded` within a `Row` → width distribution is safe and bounded.
  - Height determined by text + badges.

### 4) History Section (records)

- **Wrapper**: `Flexible(fit: FlexFit.loose)` + `ConstrainedBox(min/max height)`
- **Purpose**: Limit history height while still showing at least 1.x items.
- **Constraints**:
  - Min height: `historyHeaderHeight + listHeight(1 item + peek)`
  - Max height: either full list height (if fits without page scroll) or capped height for 5 items.
- **Internal layout**:
  - `Container` (background + border)
  - Internal `Column`
    - History header row (icon + title + count)
    - `Expanded` list area (records)

### 5) Record List Widget

- **Widget**: `RecordListWidget` (Stateful)
- **Container**: `Column(mainAxisSize: min)`
- **Children**:
  - Optional refresh header
  - The list content (shrink-wrap ListView inside `ZzaScrollable`)
- **Constraints**:
  - In history section, the list area is constrained by `Expanded` inside the history container → bounded height.
- **Potential overflow risk**:
  - If the parent gives extremely small height (e.g., smaller than list header + list area), internal Column can overflow.

### 6) ZzaScrollable wrapper

- **Widget**: `Stack` overlay on top of list
- **Children**:
  - Scrollable list
  - Top fade overlay (optional)
  - Bottom fade overlay (optional)
- **Constraints**:
  - Inherits tight height from list area.
- **Compact mode**:
  - Uses shorter fades and lower opacity when available height is small.

### 7) Form Section

- **Wrapper**: `SizedBox` → `Opacity` → `Form` → `Column(mainAxisSize: min)`
- **Children**:
  - `SingleChildScrollView` with form fields (title + description + note)
  - Action buttons removed from form content
- **Constraints**:
  - Intrinsic height content, not forced to expand

### 8) Action Buttons (bottomNavigationBar)

- **Widget**: `Container` with Row of buttons
- **Behavior**:
  - Always pinned to bottom of page
  - Removes button height from body layout constraints

## Constraints Flow (Cheat Sheet Mapping)

### Rules from cheat sheets applied

- **Constraints go down / sizes go up / parent positions**:
  - `Scaffold` → `LayoutBuilder` → `Column`: height is bounded and distributed.
- **Expanded/Flexible**:
  - History section uses `Flexible(fit: loose)` to shrink-wrap up to max height.
  - List area inside history uses `Expanded` because its parent is bounded.
- **SingleChildScrollView**:
  - Form fields are scrollable in their own subtree to avoid page-level scrolling.
- **Avoid Expanded inside unbounded parent**:
  - No `Expanded` used inside `SingleChildScrollView`.
- **ListView with shrinkWrap**:
  - Used inside a bounded area; OK, but expensive if large counts.

## Comparison with Flutter References

### Flutter layout constraints (official docs)

- Constraints passed by parent must be respected; a child cannot exceed max constraints.
- `Column` overflow typically occurs when children exceed available height.

### RenderFlex overflow guidance

- Ensure children are constrained (via `Expanded`/`Flexible`) or made scrollable.
- Avoid mixing shrink-wrap and tight flex constraints when height is tiny.

### ConstrainedBox in scrollable context

- Using minHeight constraints avoids zero-height children and preserves layout in tight spaces.

## Observed Failure Pattern (from runtime errors)

- Overflow reported in `RecordListWidget` Column when parent height shrinks to ~21px.
- That indicates the **history container’s minHeight did not include its own header**, causing the list area to be too small.

## Risk Points & Watchlist

- **History header height not included in min/max calculations** → list area can be forced below its own minimum.
- **BottomNavigationBar height reduces body space** → history constraints must be re-evaluated on resize.
- **Two scrollables in vertical stack** (history list + form scroll) → both must remain bounded.

## Responsiveness & Adaptive Design Gaps (Deep Analysis)

### A) Single-column vertical stack with fixed bottom bar

- **Observation**: The page uses a single `Column` for header + history + form, plus a fixed `bottomNavigationBar`. When height shrinks, the bottom bar subtracts from available body height without any global scroll fallback.
- **Why this is a design problem**: The content stack is expected to fit into a progressively shrinking height without a defined priority system (what collapses first, what scrolls first, and what remains visible). This creates a hard failure mode when the sum of minimums exceeds the available height.
- **Responsiveness gap**: There is no *adaptive* restructuring of the layout between tall/short windows. Instead, it relies on min/max heights and ad‑hoc caps.

### B) Mixed local sizing sources (LayoutBuilder vs MediaQuery)

- **Observation**: Layout decisions are driven by `LayoutBuilder` height with a single `AppBreakpoints.isCompactHeight` gate, while `bottomNavigationBar` uses a separate `MediaQuery` height check.
- **Why it matters**: The same screen can yield different decisions if one widget uses global window size and another uses local constraints. Flutter’s adaptive guidance recommends choosing between global (`MediaQuery.sizeOf`) vs local (`LayoutBuilder`) intentionally and consistently per component.
- **Responsiveness gap**: The system lacks a unified adaptive rule set for *height*, causing inconsistencies during resizing.

### C) Height constraints computed from record list only

- **Observation**: The history section height is computed using record list height estimates, then a separate header is placed above it.
- **Why it matters**: When the history header is not fully included in the sizing logic, the list area can become smaller than its own minimum content, causing overflow.
- **Responsiveness gap**: Adaptive sizing requires *total section height* (header + list) to be used consistently, otherwise the constraints are under‑counted.

### D) Two vertical scrollables inside a non-scrollable page

- **Observation**: The page contains a scrollable list (history) and a scrollable form section, but no parent scrollable for the overall page.
- **Why it matters**: The cheat sheets warn against nested scrollables without bounded height. With two scrollables, one or both must be explicitly bounded or else the layout becomes brittle when height shrinks.
- **Responsiveness gap**: Without a global overflow strategy, reducing height forces hard constraints on both scrollables simultaneously.

### E) Width-first responsiveness, weak height adaptation

- **Observation**: Width breakpoints are well defined (`AppBreakpoints.mobile/tablet/desktop`), but height adaptation is binary (`isCompactHeight`).
- **Why it matters**: Height changes on desktop windows are common. A single binary breakpoint is insufficient for multiple layout states (tall, medium, short).
- **Responsiveness gap**: The design doesn’t provide a multi-step height adaptation strategy, leading to abrupt transitions and overflow in short windows.

### F) Intrinsic content growth vs. tight constraints

- **Observation**: Form fields use `SingleChildScrollView`, but the form container itself is intrinsic and non-flex.
- **Why it matters**: When window height shrinks, a non-flex form cannot yield space to the history section without a deterministic priority. The form grows based on content, while the history section is capped.
- **Responsiveness gap**: No explicit priority model exists (e.g., “history yields first, then form yields”), so constraints can conflict during resizing.

### G) Fixed height fields inside the form

- **Observation**: The description block uses fixed heights (100/120) with `expands: true`.
- **Why it matters**: Fixed heights do not adapt to vertical shrink; they resist compression and increase overflow risk.
- **Responsiveness gap**: Missing height-tier logic for the form (e.g., shorter fields or stacked layout in short windows).

### H) Header row density vs. narrow width

- **Observation**: Participant header packs icon, participant info, badges, and autocomplete in one row with two `Expanded` regions.
- **Why it matters**: At narrow widths, both sides compress simultaneously, causing truncation and layout pressure.
- **Responsiveness gap**: No width-based reflow (row → stacked column) for the header.

### I) Chip wrapping is width-only, not height-aware

- **Observation**: Health chips use `Wrap` with a width-based collapse threshold.
- **Why it matters**: On short windows, wraps still add vertical height, consuming critical space.
- **Responsiveness gap**: Missing height-tier override that forces compact badges or a single-line summary.

### J) Overlay fades are constant, not proportional

- **Observation**: Scroll overlays are height-constant (even in compact mode).
- **Why it matters**: On very small list heights, overlays can obscure too much content.
- **Responsiveness gap**: No proportional fade height or auto-disable overlay below a threshold.

### K) Text scale factor not handled

- **Observation**: Many text sizes are explicit and do not account for `MediaQuery.textScaleFactor`.
- **Why it matters**: Accessibility scaling can increase height and trigger overflow earlier.
- **Responsiveness gap**: No text-scale-aware compact mode or style adjustments.

## Evidence & Research Alignment

- Flutter adaptive guidance emphasizes using `LayoutBuilder` for local constraints and `MediaQuery.sizeOf` for global sizing decisions; mixing both without a shared strategy causes inconsistent behavior. See [Adaptive layout tutorial](https://docs.flutter.dev/learn/tutorial/adaptive-layout) and [General approach to adaptive apps](https://docs.flutter.dev/ui/adaptive-responsive/general).
- RenderFlex overflow guidance highlights that children must be constrained or scrollable when the total height exceeds available space. See [Common errors](https://docs.flutter.dev/testing/common-errors).
- The “Constraints go down, sizes go up” principle requires that min heights be computed using *all* child contributions (including headers, padding, and the bottom bar). See [Spaced items cookbook](https://docs.flutter.dev/cookbook/lists/spaced-items).

## Root Cause Summary (Design-Level)

The page is designed as a fixed vertical stack with a pinned bottom bar, while attempting to dynamically cap only one section (history). This creates an implicit assumption that the remaining sections always fit, which fails during vertical window shrink. The layout lacks an explicit adaptive hierarchy for height (which section compresses first, when to allow global scroll, and how to unify window size decisions). This is a design‑level responsiveness issue, not just a local overflow bug.

## Adaptive Strategy Proposal (Design-Level)

### 1) Define explicit height tiers

- **Tier A (Tall)**: Full layout, all sections visible, history expands to fit.
- **Tier B (Medium)**: History capped (3–5 items), form stays full, chips remain visible.
- **Tier C (Short)**: Compact header + compact badges, history 1–2 items, form scrolls; move optional info (chips/notes) into a modal.

## Breakpoint Mapping (Design System)

### Width breakpoints (from AppBreakpoints)

- **Mobile**: width < 600
- **Tablet**: 600 ≤ width < 900
- **Desktop**: width ≥ 900
- **Reference default window**: 1280×720 (desktop width)

### Height breakpoint (from AppBreakpoints)

- **Compact height**: height ≤ 800
- **Reference default window**: 720 height → compact height mode

### Practical mapping for this page

- **Default desktop window (1280×720)** → Desktop width + Compact height.
- **Tablet landscape (~800×600)** → Tablet width + Compact height.
- **Phone portrait (<600 width)** → Mobile width + Compact height.
- **Tall desktop (>900 width, >800 height)** → Desktop width + Non‑compact height.

### 2) Use a single size source per decision

- Use `LayoutBuilder` for local layout decisions.
- Use `MediaQuery.sizeOf` only for global app-level decisions.
- Avoid mixing both within a single layout decision.

### 3) Establish a priority model

1) Participant header stays visible.
2) Action buttons stay visible.
3) History yields next (cap items, internal scroll).
4) Form yields last (scrollable, compact fields in short tier).

### 4) Width-adaptive header layout

- Switch header `Row` → `Column` at a width breakpoint to avoid truncation and reduce row density.

### 5) Height-aware chip strategy

- In short tier, replace `Wrap` chips with compact badges or a single summary row + modal detail.

### 6) Proportional scroll indicators

- Set fade height as a percentage of list height, and disable overlays below a minimum height.

### 7) Text scale safeguards

- Use theme text styles and clamp or adjust styles in short tiers to avoid overflow on large text scales.

### 8) Optional unified scroll in short tier

- Switch to a single `CustomScrollView` with slivers in Tier C to remove competing scrollables.

## References Used (Required)

- Flutter constraints and RenderFlex overflow documentation:
  - [https://docs.flutter.dev/testing/common-errors](https://docs.flutter.dev/testing/common-errors)
  - [https://docs.flutter.dev/cookbook/lists/spaced-items](https://docs.flutter.dev/cookbook/lists/spaced-items)
- Flutter adaptive layout guidance:
  - [https://docs.flutter.dev/learn/tutorial/adaptive-layout](https://docs.flutter.dev/learn/tutorial/adaptive-layout)
  - [https://docs.flutter.dev/ui/adaptive-responsive/best-practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices)
  - [https://docs.flutter.dev/ui/adaptive-responsive/general](https://docs.flutter.dev/ui/adaptive-responsive/general)
- Web search notes on RenderFlex overflow and constraint management:
  - [https://www.dhiwise.com/post/how-to-fix-the-renderflex-overflowed-error-in-flutter](https://www.dhiwise.com/post/how-to-fix-the-renderflex-overflowed-error-in-flutter)
  - [https://www.reddit.com/r/flutterhelp/comments/kqkuc0/adding_singlechildscrollview_around_the_column/](https://www.reddit.com/r/flutterhelp/comments/kqkuc0/adding_singlechildscrollview_around_the_column/)

## Next Steps (No Code Changes Here)

- Use this mapping to validate any future changes against constraint flow rules.
- When adjusting sizes, update min/max constraints including headers and padding.
