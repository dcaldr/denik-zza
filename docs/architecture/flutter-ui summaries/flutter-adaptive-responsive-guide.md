# Flutter Adaptive & Responsive Design Compilation
**Source:** Flutter Official Documentation v3.38.1  
**Last Updated:** 2025-10-30  
**Purpose:** Complete reference guide for building adaptive/responsive Flutter apps (PC/Android/Linux/macOS/Web)

---

## Table of Contents
1. [Fundamentals](#fundamentals)
2. [Key Definitions](#key-definitions)
3. [Design Considerations](#design-considerations)
4. [Implementation Best Practices](#implementation-best-practices)
5. [Large Screen Optimization](#large-screen-optimization)
6. [Foldable Device Support](#foldable-device-support)
7. [Adaptive Input Handling](#adaptive-input-handling)
8. [Code Patterns & Examples](#code-patterns--examples)
9. [Common Pitfalls to Avoid](#common-pitfalls-to-avoid)

---

## Fundamentals

### Core Principle
Flutter's primary goal is to create a framework that allows you to develop apps from a single codebase that look and feel great on **any platform**.

Your app must handle:
- **Screens of many different sizes**: watches → foldable phones → high-definition monitors
- **Multiple input devices**: physical keyboard, virtual keyboard, mouse, touchscreen, stylus
- **Various form factors**: phones, tablets, foldables, ChromeOS, desktop (Windows/Linux/macOS), web, iPads

### Single Codebase, Multiple Platforms
Build once for:
- **Mobile**: Android, iOS
- **Desktop**: Windows, macOS, Linux
- **Web**: Browser-based
- **Foldables**: Devices with multiple screens/hinges

---

## Key Definitions

### Responsive Design
**Definition:** Fitting the UI *into* the available space

**What it does:**
- Adjusts placement of design elements based on screen size
- Reflows layout to fit available dimensions
- Maintains functionality across different window sizes

**Example:** When screen width changes, elements reposition to fit

### Adaptive Design
**Definition:** Making the UI *usable* in the available space

**What it does:**
- Selects the appropriate layout for the platform
- Chooses optimal input devices for the context
- Prioritizes usability over uniform appearance
- Makes strategic decisions about features per platform

**Example:** 
- Tablet UI uses side-panel navigation vs. mobile bottom navigation
- Mobile focuses on content capture (camera) vs. desktop focuses on content organization
- Web leverages low-barrier sharing with deep links

### Key Insight
**Ideally, your app should be BOTH responsive AND adaptive**
- Responsive = fits the space
- Adaptive = usable in the space

---

## Design Considerations

### 1. Break Down Your Widgets ✨

**Why it matters:**
- Reduces complexity of adaptive UI adoption
- Shared core pieces of code across layouts
- Improves performance through small `const` widgets
- Better code organization and maintainability

**Benefits:**

| Aspect | Benefit |
|--------|---------|
| **Performance** | Small `const` widgets improve rebuild times; Flutter reuses `const` instances |
| **Scalability** | Large complex widgets must be set up for every rebuild |
| **Code Health** | Less-complex widgets are more readable, easier to refactor, less surprising behavior |

**Best Practice:** Organize UI into smaller, bite-sized pieces

---

### 2. Design to the Strengths of Each Form Factor 🎯

**Core Concept:**
> Don't force identical functionality everywhere. Leverage what each platform does best.

**Strategy:**
- Identify unique strengths of each device category
- Consider whether to focus on specific capabilities per platform
- Remove features if they don't make sense for the device

**Real-World Examples:**

#### Mobile vs. Desktop/Tablet
| Mobile | Tablet/Desktop |
|--------|--------|
| Portable, has camera | Suited for detailed creative work |
| **Focus:** Capturing content, tagging with location data | **Focus:** Organizing, manipulating, analyzing content |
| Input: Touch, occasional stylus | Input: Mouse, keyboard, stylus |

#### Web-Specific Leverage
- Web has extremely low barrier for sharing
- Design navigation routes with deep links in mind
- Optimize for discoverability and sharing flows

**Takeaway:** Think about what each platform does best and leverage unique capabilities

---

### 3. Solve Touch First 📱→🖥️

**Approach:**
1. **Start with touch UI first** - Most difficult input paradigm to master
2. **Reason:** Touch lacks input accelerators like:
   - Right-click context menus
   - Scroll wheel
   - Keyboard shortcuts
   - Hover states

3. **Testing Strategy:**
   - Do most iteration on desktop (faster dev loop)
   - **But frequently test on actual mobile devices**
   - Verify touch interactions feel right

4. **Then Layer Additional Inputs:**
   - After touch is polished, tweak visual density for mouse users
   - Add keyboard shortcuts as accelerators
   - Treat alternative inputs as **accelerators**, not requirements

**Key Insight:** 
> Build for touch first, optimize for precision input second. Consider what users expect from their input device. WE ARE PC FIRST.

---

## Implementation Best Practices

### ❌ DON'T: Lock Screen Orientation

**Why you shouldn't:**
- Accessibility issue for some users
- Android large format tiers require portrait AND landscape support at minimum
- Android devices can override locked orientation
- Apple guidelines recommend supporting both orientations
- Multi-window support is increasingly common
- Foldables have many use cases requiring landscape

**Problem with foldables:**
- App looks fine when folded (portrait mode)
- When unfolded → app becomes **letterboxed** (window locked to center with black bars)
- `MediaQuery` never receives larger window size needed for UI expansion

**If you absolutely must lock orientation (but don't):**
Use the `Display` API instead of `MediaQuery` to get physical screen dimensions

---

### ❌ DON'T: Use Orientation-Based Layouts

**Problematic Pattern:**
```dart
// ❌ AVOID: Using MediaQuery.orientation near top of widget tree
MediaQuery.of(context).orientation == Orientation.landscape
  ? LandscapeLayout()
  : PortraitLayout();

// ❌ AVOID: Using OrientationBuilder for main layout decisions
OrientationBuilder(
  builder: (context, orientation) {
    return orientation == Orientation.landscape
      ? Row(children: [...])
      : Column(children: [...]);
  },
)
```

**Why:**
- Device orientation doesn't necessarily inform you of actual available space
- App might be in multi-window mode or picture-in-picture
- Foldables break this assumption

**✅ DO: Use Size-Based Layouts Instead**
```dart
// ✅ CORRECT: Use MediaQuery.sizeOf() to get actual window size
final screenSize = MediaQuery.sizeOf(context);

// ✅ CORRECT: Use LayoutBuilder for layout decisions
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return WideLayout();
    } else {
      return NarrowLayout();
    }
  },
)

// ✅ CORRECT: Use Material 3 adaptive breakpoints
// See Material design guidelines for recommended breakpoints
```

---

### ❌ DON'T: Gobble Up All Horizontal Space

**Problem:**
- Apps using full window width with boxes/text fields look bad on large screens
- Violates Android Large Screen App Quality Guidelines
- Violates iOS equivalent guidelines

**Requirements from Guidelines:**
- Neither text boxes nor input fields should take 100% width
- Content should have max-width constraints

**✅ Solution: Use GridView**
See [Large Screen Optimization](#large-screen-optimization) section below

---

### ❌ DON'T: Check for Hardware Device Types

**Problematic Pattern:**
```dart
// ❌ AVOID: Checking for device type
if (isTablet()) { ... }
if (isPhone()) { ... }
if (isDesktop()) { ... }
```

**Why:**
- Device type isn't strongly connected to available window space
- App might run in:
  - Resizable window on ChromeOS
  - Side-by-side with another app (multi-window)
  - Picture-in-picture on phones
- Space available ≠ Device full screen size

**✅ DO: Check Available Window Space**
```dart
// ✅ CORRECT: Use MediaQuery to get actual window size
final size = MediaQuery.sizeOf(context);
if (size.width > 600) {
  // Wide layout
} else {
  // Narrow layout
}

// ✅ CORRECT: Use LayoutBuilder
LayoutBuilder(
  builder: (context, constraints) {
    return constraints.maxWidth > 600
      ? WideLayout()
      : NarrowLayout();
  },
)
```

---

### ✅ DO: Support Multiple Input Devices

**Minimum Requirements:**
- Basic mice and trackpads
- Keyboard shortcuts for main user flows
- Accessible keyboard navigation (especially on large devices)

**Implementation:**
- Material library widgets have excellent default input behavior
- For custom widgets: follow User input & accessibility guidelines
- Ensure common workflows support keyboard-only navigation

**Coverage:**
- Touch input (mobile/tablet)
- Mouse and trackpad (desktop)
- Keyboard navigation (all platforms)
- Stylus input (tablets/foldables)

---

### ✅ DO: Restore List State

**Purpose:** Maintain scroll position when device orientation or layout changes

**Solution: Use `PageStorageKey`**
```dart
// PageStorageKey persists widget state in storage
// When widget is destroyed and recreated, state is restored

SingleChildScrollView(
  key: PageStorageKey('listKey'),
  child: ListView.builder(...)
)
```

**When Layout Changes on Orientation:**
- List widget changes layout structure
- May need to adjust scroll position with math
- Reference: Wonderous app example

---

### ✅ DO: Save and Restore App State

**Scope:** Handle state retention across:
- Device rotation
- Window resizing
- Foldable unfolding/folding
- Multi-window state changes

**Default Behavior:** Apps should maintain state by default

**Important:** 
- Verify plugins and native extensions support the device type
- Some native plugins lose state on device configuration change
- Example: Folding/unfolding foldables causing state loss

**Reference:** "Developing Flutter apps for Large screens" article on Medium

---

## Large Screen Optimization

### Screen Size Definitions

**Flutter Large Screen Classification:**
- **Tablets**
- **Foldables**
- **ChromeOS devices running Android**
- **Web browsers**
- **Desktop (Windows, macOS, Linux)**
- **iPads**

---

### Problem: Full-Width Content on Large Screens

**Visual Issue:**
```
Mobile (fine):                Large Screen (problematic):
┌─────────────────┐          ┌───────────────────────────────────┐
│ ┌─────────────┐ │          │ ┌───────────────────────────────┐ │
│ │ Long text   │ │          │ │ Very very very long line of   │ │
│ │ line        │ │          │ │ text stretching across the    │ │
│ │ wrapping    │ │          │ │ entire screen width making    │ │
│ │ nicely      │ │          │ │ it hard to read              │ │
│ └─────────────┘ │          │ └───────────────────────────────┘ │
└─────────────────┘          └───────────────────────────────────┘
```

**Guidelines Violations:**
- Android Large Screen App Quality Guidelines
- iOS equivalent guidelines
- Text lines and input boxes shouldn't span full width

---

### Solution 1: GridView Layout

**Concept:**
Convert single-column layouts to multi-column grids on large screens

**Migration Path:**
```dart
// Change from ListView to GridView
// ListView.builder  →  GridView.builder
// ListView (default) → GridView.count

// Same parameters, add gridDelegate
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,  // 2 columns on large screens
  ),
  itemBuilder: (context, index) => ItemWidget(),
  itemCount: items.length,
)
```

**GridView Constructors:**
| Constructor | Use Case |
|-------------|----------|
| `GridView.count` | Fixed number of columns |
| `GridView.builder` | Large item lists (lazy loading) |
| Custom constructors | More flexible layouts |

**Available Delegates:**

#### `SliverGridDelegateWithFixedCrossAxisCount`
```dart
gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,  // Fixed number of columns
  childAspectRatio: 1.0,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
)
```

#### `SliverGridDelegateWithMaxCrossAxisExtent`
```dart
gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 300,  // Max width per item
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
)
```

**Performance Tip:** Use `.builder` constructor for large item counts to only build visible widgets

---

### Solution 2: ConstrainedBox with MaxWidth

**Approach:**
```dart
// Wrap GridView in ConstrainedBox with maxWidth
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 800),
  child: GridView.builder(...)
)

// OR use Container for additional functionality
Container(
  constraints: BoxConstraints(maxWidth: 800),
  color: Colors.white,  // Can add background, padding, etc.
  child: GridView.builder(...)
)
```

**For Maximum Width Selection:**
- Reference Material 3 Applying layout guide
- Common breakpoints: 600dp, 840dp, 1200dp (based on Material design)
- Adjust based on your app's specific needs

---

## Foldable Device Support

### Challenges with Foldable Devices

**Unique Characteristics:**
- Two screens connected by hinge
- Folded state: portrait mode (narrow)
- Unfolded state: landscape mode (wide)
- State transitions during app runtime

**Common Problem: Letterboxing**

When device unfolds:
1. App was in portrait mode with locked orientation
2. `setPreferredOrientations` puts Android in portrait compatibility mode
3. App window is **letterboxed** (centered with black bars)
4. `MediaQuery` never receives full unfolded window size
5. UI can't expand because it doesn't know the space is available

**Visual Result:**
```
Unfolded Device Window:
┌────────────────────────────────────┐
│                                    │
│  ┌──────────────────────────────┐  │
│  │  App (letterboxed)           │  │
│  │  Locked to portrait size     │  │
│  │                              │  │
│  └──────────────────────────────┘  │
│                                    │
│  [Black letterbox bars]            │
└────────────────────────────────────┘
```

---

### Solution 1: Support All Orientations

**Implementation:**
- Remove orientation locking
- Test layout in both portrait and landscape
- Use responsive layout techniques

**Benefits:**
- Foldable devices work properly
- Multi-window mode works
- Future-proofs your app

---

### Solution 2: Use Display API for Physical Dimensions

**When to use:** When you absolutely must lock orientation (rare cases)

**Advantage:** Get physical screen dimensions, not window dimensions

**API (Flutter 3.13+):**
```dart
// In State class
ui.FlutterView? _view;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _view = View.maybeOf(context);
}

void didChangeMetrics() {
  final ui.Display? display = _view?.display;
  
  // Access:
  // - display.size: Size of physical display
  // - display.devicePixelRatio: Pixel ratio
  // - display.refreshRate: Refresh rate
}
```

**Forward-Looking Design:**
- Creates API that handles current AND future multi-display/multi-view scenarios
- Finds correct display for the view you care about

---

## Adaptive Input Handling

### Input Types to Support

**Android Large Format Device Tiers:**
- Tier 3 (lowest): Mouse and stylus input support
- Higher tiers: Additional features and considerations

**Guidelines References:**
- Material 3 guidelines
- Apple guidelines

---

### Navigation Pattern Selection

**Challenge:** Large screens need different navigation than mobile

**Problem:**
```
Mobile (appropriate):          Large Screen (not ideal):
┌───────────────────┐         ┌─────────────────────────┐
│ Content Area      │         │ Content Area            │
│                   │         │                         │
├───────────────────┤         ├──────────┬──────────────┤
│ ⬜ ⬜ ⬜ ⬜ ⬜     │         │ Bottom   │ Would stretch │
│ Bottom Nav        │         │ Nav is   │ across entire │
└───────────────────┘         │ cramped  │ width        │
                              └──────────┴──────────────┘
```

**Solution: Adaptive Navigation Selection**

| Screen Size | Navigation Pattern | Widget |
|-------------|-------------------|--------|
| **Narrow** (width < 600) | Bottom navigation bar | `BottomNavigationBar` |
| **Wide** (width ≥ 600) | Side navigation rail | `NavigationRail` |

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return Scaffold(
        body: content,
        bottomNavigationBar: BottomNavigationBar(...),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(...),
            Expanded(child: content),
          ],
        ),
      );
    }
  },
)
```

**Reference:** "Developing Flutter apps for Large screens" article, section: "Problem: Navigation rail"

---

### Material Input Support

**Automatic Support:**
- Material 3 widgets include built-in support for touch, mouse, keyboard
- Buttons and selectors have appropriate input states

**Custom Widgets:**
- Implement input handlers manually
- Reference: User input & accessibility documentation
- Support states: hover, pressed, focused, disabled

---

## Code Patterns & Examples

### Pattern 1: Layout Builder for Responsive Layouts

```dart
import 'package:flutter/material.dart';

class AdaptiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoints based on available width
        if (constraints.maxWidth < 600) {
          // Mobile: single column layout
          return MobileLayout();
        } else if (constraints.maxWidth < 900) {
          // Tablet: two column layout
          return TabletLayout();
        } else {
          // Desktop: three column layout with sidebar
          return DesktopLayout();
        }
      },
    );
  }
}

class MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Header(), Expanded(child: Content()), Footer()],
    );
  }
}

class TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: Sidebar()),
        Expanded(flex: 2, child: Content()),
      ],
    );
  }
}

class DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(...),
        Expanded(flex: 2, child: Content()),
        Expanded(flex: 1, child: RightPanel()),
      ],
    );
  }
}
```

---

### Pattern 2: MediaQuery for Screen Size Detection

```dart
import 'package:flutter/material.dart';

class ResponsiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isPortrait = screenSize.height > screenSize.width;
    
    return Scaffold(
      appBar: AppBar(title: Text('Responsive App')),
      body: screenSize.width > 600
          ? WideLayout()
          : NarrowLayout(),
    );
  }
}
```

---

### Pattern 3: Adaptive Navigation

```dart
import 'package:flutter/material.dart';

class AdaptiveNavigationApp extends StatefulWidget {
  @override
  State<AdaptiveNavigationApp> createState() => _AdaptiveNavigationAppState();
}

class _AdaptiveNavigationAppState extends State<AdaptiveNavigationApp> {
  int _selectedIndex = 0;
  
  final List<NavigationDestination> _destinations = [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use NavigationRail for wide screens
        if (constraints.maxWidth >= 600) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  destinations: _destinations,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                ),
                Expanded(child: _buildContent()),
              ],
            ),
          );
        }
        // Use BottomNavigationBar for narrow screens
        else {
          return Scaffold(
            body: _buildContent(),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              destinations: _destinations,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen();
      case 1:
        return SearchScreen();
      case 2:
        return SettingsScreen();
      default:
        return HomeScreen();
    }
  }
}
```

---

### Pattern 4: GridView for Large Screens

```dart
import 'package:flutter/material.dart';

class GridLayoutExample extends StatelessWidget {
  final List<String> items = List.generate(100, (i) => 'Item $i');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic column count based on screen width
        int crossAxisCount = constraints.maxWidth < 600
            ? 1
            : constraints.maxWidth < 900
                ? 2
                : 3;

        return Padding(
          padding: EdgeInsets.all(8.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Card(
                child: Center(
                  child: Text(items[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
```

---

### Pattern 5: State Persistence with PageStorageKey

```dart
import 'package:flutter/material.dart';

class ListWithStateRestoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Persist scroll position across orientation changes
      key: PageStorageKey('myListScroll'),
      itemCount: 100,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          subtitle: Text('Scroll position is maintained'),
        );
      },
    );
  }
}
```

---

### Pattern 6: Display API for Physical Screen Size

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class FoldableAwareWidget extends StatefulWidget {
  @override
  State<FoldableAwareWidget> createState() => _FoldableAwareWidgetState();
}

class _FoldableAwareWidgetState extends State<FoldableAwareWidget> {
  ui.FlutterView? _view;
  ui.Display? _display;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _view = View.maybeOf(context);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (_view != null) {
      _display = _view!.display;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_display == null) {
      return Center(child: CircularProgressIndicator());
    }

    final size = _display!.size;
    final pixelRatio = _display!.devicePixelRatio;
    final refreshRate = _display!.refreshRate;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Physical Display Size: ${size.width}x${size.height}'),
        Text('Pixel Ratio: $pixelRatio'),
        Text('Refresh Rate: ${refreshRate.toStringAsFixed(1)} Hz'),
      ],
    );
  }
}
```

---

## Common Pitfalls to Avoid

### ❌ Pitfall 1: Orientation-Based Decisions

**Problem:**
```dart
// ❌ BAD: Orientation doesn't tell you available space
if (MediaQuery.of(context).orientation == Orientation.landscape) {
  return TwoColumnLayout();
} else {
  return SingleColumnLayout();
}
```

**Why:** Landscape orientation doesn't guarantee wide space (multi-window, picture-in-picture)

**Fix:**
```dart
// ✅ GOOD: Base decisions on actual available width
if (MediaQuery.sizeOf(context).width > 600) {
  return TwoColumnLayout();
} else {
  return SingleColumnLayout();
}
```

---

### ❌ Pitfall 2: Device Type Checking

**Problem:**
```dart
// ❌ BAD: Device type doesn't match available space
if (isTablet()) {
  return TabletLayout();
} else if (isPhone()) {
  return MobileLayout();
}
```

**Why:** Window size matters, not device type (resizable windows, multi-window, picture-in-picture)

**Fix:**
```dart
// ✅ GOOD: Check available space
LayoutBuilder(
  builder: (context, constraints) {
    return constraints.maxWidth > 600
        ? TabletLayout()
        : MobileLayout();
  },
)
```

---

### ❌ Pitfall 3: Full-Width Content

**Problem:**
```dart
// ❌ BAD: Content spans entire width on large screens
Container(
  width: double.infinity,  // Takes up all available width
  child: TextField(
    hintText: 'Enter text',
  ),
)
```

**Issue:** Text input and text lines become hard to read on large screens

**Fix:**
```dart
// ✅ GOOD: Constrain width and center
Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 600),
    child: TextField(
      hintText: 'Enter text',
    ),
  ),
)

// OR use GridView for better layout
GridView.builder(
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 600,
  ),
  itemBuilder: (context, index) => ItemWidget(),
)
```

---

### ❌ Pitfall 4: Locked Orientation

**Problem:**
```dart
// ❌ BAD: Locks app to portrait, breaks foldables
SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
]);
```

**Issues:**
- Foldables become letterboxed when unfolded
- Breaks accessibility
- Android devices can override it anyway
- Violates platform guidelines

**Fix:**
```dart
// ✅ GOOD: Allow both orientations
SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);

// OR: Don't lock at all (default behavior)
```

---

### ❌ Pitfall 5: No Input Device Support

**Problem:**
```dart
// ❌ BAD: Only supports touch
GestureDetector(
  onTap: () { /* action */ },
  child: Container(child: Text('Button')),
)
```

**Issues:** 
- No keyboard support (accessibility)
- No mouse hover feedback
- Poor desktop experience

**Fix:**
```dart
// ✅ GOOD: Use Material buttons with built-in support
FilledButton(
  onPressed: () { /* action */ },
  child: Text('Button'),
)

// Or add keyboard/mouse support to custom widgets
GestureDetector(
  onTap: () { /* action */ },
  child: MouseRegion(
    onEnter: (_) { /* hover */ },
    onExit: (_) { /* unhover */ },
    child: Focus(
      onKey: (node, event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          /* action */
        }
        return KeyEventResult.handled;
      },
      child: Container(child: Text('Button')),
    ),
  ),
)
```

---

### ❌ Pitfall 6: Losing State on Configuration Changes

**Problem:**
```dart
// ❌ BAD: No state preservation
ListView.builder(
  itemCount: 100,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)
// Scroll position lost when orientation changes!
```

**Fix:**
```dart
// ✅ GOOD: Use PageStorageKey for state persistence
ListView.builder(
  key: PageStorageKey('myList'),
  itemCount: 100,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
)
// Scroll position maintained!
```

---

### ❌ Pitfall 7: Complex Monolithic Widgets

**Problem:**
```dart
// ❌ BAD: Large, complex widget
class MyComplexScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(...),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 200 lines of UI building code
            // Impossible to test separately
            // Hard to reuse parts
          ],
        ),
      ),
    );
  }
}
```

**Issues:**
- Hard to test
- Difficult to reuse
- Poor performance
- Hard to maintain

**Fix:**
```dart
// ✅ GOOD: Break into smaller widgets
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: MyContent(),
    );
  }
}

class MyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AppBar(...);
}

class MyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > 600
            ? MyWideLayout()
            : MyNarrowLayout();
      },
    );
  }
}

class MyWideLayout extends StatelessWidget { ... }
class MyNarrowLayout extends StatelessWidget { ... }
```

---

## Summary: Adaptive Design Checklist

### Before Building
- [ ] Plan for multiple screen sizes (mobile, tablet, desktop, web)
- [ ] Identify form factor strengths (mobile = capture, desktop = organize)
- [ ] Choose which features to include per platform
- [ ] Plan navigation strategy (BottomNavigationBar vs NavigationRail)

### During Development
- [ ] Break widgets into small, reusable pieces
- [ ] Use `LayoutBuilder` for layout decisions
- [ ] Use `MediaQuery.sizeOf()` for size detection
- [ ] Don't lock orientation
- [ ] Avoid device-type checking
- [ ] Implement touch UI first, then optimize for mouse/keyboard
- [ ] Support multiple input devices (touch, mouse, keyboard, stylus)
- [ ] Constrain content width on large screens (max-width)
- [ ] Use `GridView` for large screen layouts

### Testing
- [ ] Test on actual devices in both orientations
- [ ] Test window resizing (desktop)
- [ ] Test multi-window mode
- [ ] Test foldable devices if possible
- [ ] Test keyboard navigation
- [ ] Test with mouse and trackpad
- [ ] Verify state persistence on orientation change

### Large Screens
- [ ] Use `NavigationRail` instead of `BottomNavigationBar`
- [ ] Use `GridView` for content layouts
- [ ] Add `ConstrainedBox` for max-width
- [ ] Support side-by-side layouts
- [ ] Add right-panel/details pane

### Foldables
- [ ] Support all orientations
- [ ] Don't use `setPreferredOrientations`
- [ ] Test unfolding/folding transitions
- [ ] Consider using `Display` API for special cases
- [ ] Ensure state persists through fold/unfold

---

## Additional Resources

### Official Documentation Pages
- Main: https://docs.flutter.dev/ui/adaptive-responsive
- Best Practices: https://docs.flutter.dev/ui/adaptive-responsive/best-practices
- Large Screens: https://docs.flutter.dev/ui/adaptive-responsive/large-screens
- General Approach: https://docs.flutter.dev/ui/adaptive-responsive/general-approach (in Flutter docs)

### Related Topics
- User input & accessibility: https://docs.flutter.dev/ui/interactivity/user-input
- Material 3 breakpoints: Material Design documentation
- Developing Flutter apps for Large screens: Medium article (free)
- Wonderous app: Example implementation on GitHub

### Key Guidelines
- Android Large Screen App Quality Guidelines
- iOS Human Interface Guidelines
- Material Design: Applying layout guide

---

**Document compiled:** December 27, 2025  
**Flutter version:** 3.38.1  
**Purpose:** Quick reference for building adaptive Flutter apps across all platforms
