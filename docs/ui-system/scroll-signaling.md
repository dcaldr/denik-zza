# Scroll Signaling System

> [!IMPORTANT]
> The "Illusion of Completeness" is a critical UX failure where users believe content ends because it cuts off cleanly at a text line. This system provides consistent, visual cues to signal "there is more content below".

## Strategy: "Affordance First"

We use a dual-layer approach to signal scrollability:
1.  **Desktop/Tablet**: Visible Scrollbars (Industrial Affordance).
2.  **All Platforms**: Fading Edges (Visual Continuity).

---

## 1. Global Scrollbars (Desktop/Tablet)

Configured in `zza_theme.dart`.
On Desktop and Tablet platforms, scrollbars are **always visible** to provide immediate interaction context.

```dart
// zza_theme.dart
scrollbarTheme: ScrollbarThemeData(
  thumbVisibility: MaterialStateProperty.all(true), // Always show
  thickness: MaterialStateProperty.all(8.0),        // easy to grab
  radius: const Radius.circular(4.0),
),
```

---

## 2. The `ZzaScrollable` Widget (Fading Edge)

A generic wrapper widget that adds a gradient fade + visual hint when content overflows.

### When to use
Wrap any scrollable area (`ListView`, `CustomScrollView`, `SingleChildScrollView`) that might cut off content cleanly.

### Features
*   **Fading Bottom**: Signals more content below.
*   **Fading Top**: Signals content above.
*   **Chevron**: Optional visual anchor.
*   **Auto-Detection**: Listens to the `ScrollController` to show/hide signals automatically.

### Usage

```dart
final _scrollController = ScrollController();

@override
Widget build(BuildContext context) {
  return ZzaScrollable(
    controller: _scrollController, // Must match child's controller
    child: ListView(
      controller: _scrollController,
      children: [ ... ],
    ),
  );
}
```

### Applied Locations
*   **ParticipantRegistrationPage**: Wraps the entire form (Mobile view).
*   **RestrictionsWidget**: Wraps the internal list of restrictions.

---

## Best Practices
1.  **Always Pair Controllers**: The `ZzaScrollable` controller MUST be the same instance attached to the scroll view.
2.  **Avoid Nested Signals**: Do not wrap a `ZzaScrollable` inside another `ZzaScrollable` unless they scroll independently (e.g., a list inside a page).
3.  **Color Matching**: The fade defaults to `Scaffold` background. If used on a colored card, pass `fadeColor` explicitly.
