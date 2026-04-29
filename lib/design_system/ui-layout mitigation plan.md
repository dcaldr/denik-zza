# Responsive Layout Mitigation Plan

## Scope

This document establishes app-wide patterns and guardrails for building responsive layouts in Deník ZZA. It prevents the class of responsive layout bugs that caused regressions in NewRecordPage and other screens.

**Target Audience**: Developers building new screens or refactoring existing responsive UI.  
**Applies To**: All screens in the application.  
**Status**: Foundational guidelines (individual screen implementations will follow this framework).

## Track A: General Mitigation (App-wide)

### Objective
Prevent recurring responsive regressions by enforcing one layout decision pattern across screens, strictly utilizing the existing `AppBreakpoints` design tokens.

### General Architecture Standard
1. Single decision layer per screen.
- At screen root, compute responsive mode once from one source.
- Pass decision down; do not recompute global mode in leaf widgets.

2. Immutable layout decision object.
- Include size class and scroll strategy flags in one object.
- Children consume decision; they do not invent their own breakpoints.

3. Component fallback ladder contract.
- Every dense horizontal component must define fallback tiers:
  1. Full row (Desktop/Tablet)
  2. Compact row (Tablet/Mobile)
  3. Stacked column (Mobile)

4. Strict no-mask testing policy.
- Do not silence layout exceptions.
- Assert structure and visibility directly across viewport matrix sizes.

---

## Framework: When to Use MediaQuery vs LayoutBuilder

**MediaQuery (Global Screen Constraints)**  
Use `MediaQuery.sizeOf(context)` for:
- App-level decisions that affect the entire screen layout
- One-time decisions at screen root that should apply everywhere
- Window size changes that require major layout shifts

**LayoutBuilder (Local Component Constraints)**  
Use `LayoutBuilder` for:
- Component-level decisions based on available width from parent
- Nested layout decisions within subcomponents
- Multiple independent responsive areas within same screen

**Anti-pattern**: Mixing both at the same nesting level or calling `MediaQuery` deep within leaf widgets. Each screen should have one "decision source" that answers: "Is this a mobile/tablet/desktop layout?" All children consume that decision rather than asking again.

---

## Single Source of Truth Pattern

### Problem This Solves
When multiple parts of a screen compute "mobile mode" independently, they can disagree. Example: title row decides to wrap, but footer scroll strategy decides to force page-scroll because it computed narrowness differently.

### Pattern

1. **At screen root** (in `build()` or in `initState()` via controller):
   - Compute responsive decision ONE TIME from ONE SOURCE using `AppBreakpoints`.
   - Create immutable decision object with all layout flags.
   - Pass object down to all children that need it.

2. **In all child components**:
   - Receive decision object as parameter.
   - Consume it (don't recompute screen mode).
   - Use it to determine local layout tier (full/compact/stack).

### Example Decision Object Template

```dart
@immutable
class LayoutDecision {
  final double screenWidth;
  final double screenHeight;
  final bool isMobile;        // width < AppBreakpoints.mobile (600)
  final bool isTablet;        // 600 <= width < AppBreakpoints.tablet (900)
  final bool isDesktop;       // width >= AppBreakpoints.tablet (900)
  final bool isCompactHeight; // height <= AppBreakpoints.compactHeight (800)
  final bool shouldScroll;    
  
  // Optional diagnostics
  final String reason;
  
  const LayoutDecision({
    required this.screenWidth,
    required this.screenHeight,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isCompactHeight,
    required this.shouldScroll,
    this.reason = '',
  });
  
  // Factory leveraging existing AppBreakpoints
  factory LayoutDecision.from(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    
    final isMobile = AppBreakpoints.isMobile(width);
    final isTablet = AppBreakpoints.isTablet(width);
    final isDesktop = AppBreakpoints.isDesktop(width);
    final isCompactHeight = AppBreakpoints.isCompactHeight(height);
    
    // Example: Determine scroll logic using existing typography-aware helpers
    final requiredHeight = AppBreakpoints.getListHeight(context, itemCount: 5);
    final shouldScroll = isCompactHeight || height < requiredHeight;
    
    return LayoutDecision(
      screenWidth: width,
      screenHeight: height,
      isMobile: isMobile,
      isTablet: isTablet,
      isDesktop: isDesktop,
      isCompactHeight: isCompactHeight,
      shouldScroll: shouldScroll,
      reason: 'width=$width, height=$height, reqHeight=$requiredHeight',
    );
  }
}
```

---

## Component Fallback Ladder Contract

### Problem This Solves
Dense components (title rows, action buttons, health info chips) have different width requirements. They need explicit "Plan B" and "Plan C" layouts for progressively constrained viewports. Without explicit fallbacks, they either overflow or hide critical controls.

### Pattern: Three-Tier Fallback System

Every dense horizontal component must define composition tiers aligned with `AppBreakpoints`. **Note: Mobile (Tier 3) is a low priority globally, but HIGH priority for `NewRecordPage`**.

**Tier 1: Full Layout** (Desktop, width ≥ 900px) - *Mandatory everywhere*
- All content visible
- Comfortable spacing
- Multi-line text allowed

**Tier 2: Compact Layout** (Tablet, 600px ≤ width < 900px) - *Mandatory everywhere*
- Reduced spacing/padding
- Abbreviated text or icons-only for non-critical elements
- Keep critical controls visible

**Tier 3: Stacked Layout** (Mobile, width < 600px) - *Optional (Mandatory ONLY for `NewRecordPage`)*
- Vertical stack instead of row
- One item per row
- All text and controls fully readable
- No overflow possible

### Example: Action Buttons Component

```dart
class ActionButtons extends StatelessWidget {
  final LayoutDecision decision;
  
  const ActionButtons({required this.decision});
  
  @override
  Widget build(BuildContext context) {
    if (decision.isMobile) {
      // Tier 3: Stack (Mobile)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPrimaryButton(),
          SizedBox(height: AppSpacing.sm),
          _buildSecondaryButton(),
          SizedBox(height: AppSpacing.sm),
          _buildTertiaryButton(),
        ],
      );
    } else if (decision.isTablet) {
      // Tier 2: Compact row with overflow handling (Tablet)
      return OverflowBar(
        spacing: AppSpacing.sm,
        children: [
          _buildPrimaryButton(),
          _buildSecondaryButton(),
          _buildTertiaryButton(),
        ],
      );
    } else {
      // Tier 1: Full layout (Desktop)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPrimaryButton(),
          _buildSecondaryButton(),
          _buildTertiaryButton(),
        ],
      );
    }
  }
}
```

### OverflowBar Widget
For action button rows, prefer Flutter's built-in `OverflowBar`:
- Lays out children in row while they fit
- Automatically switches to column when overflow detected
- No manual breakpoint calculation needed

---

## Breakpoint Centralization & Typography-Aware Sizing

### Anti-Pattern: Magic Numbers
Hardcoding `width < 600` or `height < 800` completely bypasses the design system and causes inconsistent layouts. 

### Pattern: Use `AppBreakpoints`
Always use the centralized design system tokens in `lib/design_system/tokens/app_breakpoints.dart`.

```dart
// ✅ Good
if (AppBreakpoints.isMobile(width)) { ... }
if (AppBreakpoints.isCompactHeight(height)) { ... }

// ❌ Bad
if (width < 600) { ... }
if (height < 800) { ... }
```

### Pattern: Typography-Aware Heights
Do not hardcode pixel heights for scroll decisions. Use `AppBreakpoints.getListHeight` or `AppBreakpoints.getItemHeight` to ensure layout adapts if the user changes system font sizes.

```dart
// ✅ Good
final requiredHeight = AppBreakpoints.getListHeight(context, itemCount: 5);
if (availableHeight < requiredHeight) { ... }

// ❌ Bad
if (availableHeight < 500) { ... }
```

---

## Exception-Strict Testing Policy

### Problem This Solves
When tests mask layout exceptions (e.g., `tester.takeException()`), you hide the very bugs you're trying to prevent. A layout overflow error silently ignored means the screen is broken in production but tests pass.

### Pattern: Explicit Verification

**Rule 1: Never mask layout exceptions**
*(Note: Asserting `takeException() == null` is fine as it ensures no exceptions exist, but calling it just to clear the queue without asserting is forbidden).*
```dart
// ❌ FORBIDDEN: Silencing errors
test('renders without error', () {
  tester.takeException();  // Ignored error!
  expect(find.byType(MyWidget), findsOneWidget);
});

// ✅ GOOD: Verify explicitly
test('renders vertically in narrow mode', () {
  tester.binding.window.physicalSizeTestValue = const Size(360, 640);
  await tester.pumpWidget(MyApp());
  expect(tester.takeException(), isNull); // Verify NO errors occurred
  
  // Assert explicit structure
  expect(find.byType(Column), findsOneWidget);
});
```

**Rule 2: Multi-size matrix testing**
Test across the thresholds defined by `AppBreakpoints`:
```dart
test('renders correctly at all viewport sizes', () async {
  final sizes = [
    const Size(360, 640),   // Mobile (< 600)
    const Size(800, 1024),  // Tablet (600 - 900)
    const Size(1280, 720),  // Desktop (>= 900)
  ];
  // ... loop and assert
});
```

---

## Code Review Guardrails

When reviewing responsive/layout changes, enforce:

1. **Single decision source**: "Where is the width/height decision made? Only one place?"
2. **Decision object consistency**: "Are all children consuming the same decision object, or re-querying `MediaQuery`?"
3. **Fallback ladder completeness**: "Does this dense row have explicit fallback layouts (e.g. `OverflowBar`)?"
4. **No magic numbers**: "Are all thresholds using `AppBreakpoints.isMobile`, `isTablet`, etc.?"
5. **Typography scaling**: "Are heights determined by `AppBreakpoints.getListHeight` rather than fixed pixels?"
6. **Multi-size evidence**: "Are matrix test results included in PR?"

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Child Re-computes Global Decision
```dart
// ❌ BAD: Leaf widget queries MediaQuery directly
class MyChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600; // Double sin: re-query + magic number
    return isMobile ? verticalLayout() : horizontalLayout();
  }
}

// ✅ GOOD: Parent passes decision
class MyChild extends StatelessWidget {
  final LayoutDecision decision;
  const MyChild({required this.decision});
  
  @override
  Widget build(BuildContext context) {
    return decision.isMobile ? verticalLayout() : horizontalLayout();
  }
}
```

### Anti-Pattern 2: Scroll Strategy Forced by Static Condition
```dart
// ❌ BAD: Scroll based purely on device size, ignoring content
bool shouldUsePageScroll = AppBreakpoints.isMobile(width);

// ✅ GOOD: Measure actual content requirement using typography helpers
final requiredHeight = AppBreakpoints.getListHeight(context, itemCount: 5);
bool shouldUsePageScroll = availableHeight < requiredHeight;
```

---

## Implementation Checklist: Building a Responsive Screen

### Planning Phase
- [ ] Identify target viewport sizes mapping to `AppBreakpoints` (Mobile < 600, Tablet < 900, Desktop >= 900)
- [ ] Define responsive decision points (when does layout change?)
- [ ] Sketch layout tiers for each dense component (Desktop Row → Tablet Compact). Include Mobile Stack if it's the `NewRecordPage`.
- [ ] Plan scroll strategy based on `AppBreakpoints.getListHeight`

### Implementation Phase
- [ ] Create `LayoutDecision` object at screen root
- [ ] Implement `LayoutBuilder` or `MediaQuery` at ONE decision point only
- [ ] Pass decision object to all children, never have them recompute it
- [ ] Implement tier-1/tier-2 layouts for every dense component (utilize `OverflowBar` where appropriate). Add tier-3 if high priority for this screen.
- [ ] Use `AppBreakpoints` methods for all width/height thresholds (no magic numbers!)

### Testing Phase
- [ ] Test multi-size matrix (Mobile, Tablet, Desktop)
- [ ] Verify critical controls visible in mobile mode
- [ ] Ensure NO `tester.takeException()` is used to mask layout overflows
- [ ] Assert `tester.takeException()` is null to guarantee clean renders

---

## Glossary

**LayoutDecision**: Immutable object holding responsive mode flags (isMobile, isTablet, shouldScroll, etc.) computed once at screen root and passed to children.

**Tier-1/Tier-2/Tier-3**: Explicit layout compositions for desktop/tablet/mobile viewports. 

**Single Decision Source**: Pattern where responsive mode is computed in exactly one place and never recomputed in leaf widgets.

**AppBreakpoints**: Centralized utility `lib/design_system/tokens/app_breakpoints.dart` that defines breakpoints (`isMobile`, `isTablet`, `isDesktop`) and typography-aware height calculations (`getListHeight`).

**OverflowBar**: Flutter widget that automatically wraps children from a Row to a Column when horizontal space is exhausted, serving as an ideal automatic fallback component.