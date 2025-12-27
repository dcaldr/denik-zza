# Flutter Adaptive & Responsive Design - Complete Official Documentation
**Source:** Flutter Official Documentation v3.38.1  
**Last Updated:** 2025-10-30  
**Scope:** ALL 6 official pages from docs.flutter.dev/ui/adaptive-responsive  
**Purpose:** Complete reference for building adaptive/responsive Flutter apps (PC/Android/Linux/macOS/Web)

---

## 📑 Complete Menu Structure

This document covers all pages from the official Flutter adaptive/responsive design section:

1. **Adaptive and responsive design in Flutter** - Main introduction
2. **Best practices for adaptive design** - Design considerations and implementation
3. **Large screen devices** - GridView, foldables, navigation, input
4. **General approach to adaptive apps** - 3-step methodology
5. **Automatic platform adaptations** - Android/iOS specific behaviors
6. **Capabilities & policies** - Platform-specific features and guidelines

---

## PAGE 1: ADAPTIVE AND RESPONSIVE DESIGN IN FLUTTER

### Overview
Flutter's primary goal is to create a framework allowing you to develop apps from a single codebase that look and feel great on any platform.

### Platforms & Devices Supported
Your app must handle:
- **Screen sizes**: watches → foldable phones → high-definition monitors
- **Input devices**: physical keyboard, virtual keyboard, mouse, touchscreen, stylus
- **Form factors**: phones, tablets, foldables, ChromeOS, desktop (Windows/Linux/macOS), web, iPads

### Core Definitions

#### Responsive Design
**Definition:** Fitting the UI *into* the available space

**Characteristics:**
- Adjusts placement of design elements based on screen size
- Reflows layout to fit available dimensions
- Maintains functionality across different window sizes
- Example: Elements reposition when screen width changes

#### Adaptive Design
**Definition:** Making the UI *usable* in the available space

**Characteristics:**
- Selects the appropriate layout for the platform
- Chooses optimal input devices for the context
- Prioritizes usability over uniform appearance
- Makes strategic decisions about features per platform

**Example Use Cases:**
- Should tablet UI use bottom navigation or side-panel navigation?
- Should mobile focus on content capture (camera) or organization?
- Should web leverage low-barrier sharing with deep links?

### Key Principle
> **Ideally, your app should be BOTH responsive AND adaptive**
- Responsive = fits the space
- Adaptive = usable in the space

---

## PAGE 2: BEST PRACTICES FOR ADAPTIVE DESIGN

### Design Considerations

#### 1. Break Down Your Widgets ✨

**Why:**
- Reduces complexity of adaptive UI adoption
- Allows code sharing across layouts
- Improves performance
- Better maintainability

**Benefits:**

| Aspect | Benefit |
|--------|---------|
| **Performance** | Small `const` widgets improve rebuild times; Flutter reuses `const` instances |
| **Code Health** | Less-complex widgets are more readable, easier to refactor, less surprising behavior |
| **Scalability** | Large complex widgets must be set up for every rebuild |

**Implementation:**
- Identify small, reusable UI pieces
- Extract logic into separate widgets
- Create shared `const` widgets for efficient rebuilds

---

#### 2. Design to the Strengths of Each Form Factor 🎯

**Core Concept:**
> Don't force identical functionality everywhere. Leverage what each platform does best.

**Strategy:**
- Identify unique strengths of each device category
- Consider whether to focus on specific capabilities per platform
- Remove features if they don't make sense for the device

**Real-World Examples:**

| Mobile | Tablet/Desktop |
|--------|--------|
| **Strengths:** Portable, has camera, always-on connectivity | **Strengths:** Large screen, precision input, stationary |
| **Focus:** Capturing content, tagging with location data | **Focus:** Organizing, manipulating, analyzing content |
| **Input:** Touch, occasional stylus | **Input:** Mouse, keyboard, stylus |

**Web-Specific Strategy:**
- Web has extremely low barrier for sharing
- Design navigation routes with deep links in mind
- Optimize for discoverability and social sharing

**Key Takeaway:** Think about what each platform does best and leverage unique capabilities

---

#### 3. Solve Touch First 📱→🖥️

**Challenge with Touch:**
- Most difficult input paradigm to master
- Lacks input accelerators like:
  - Right-click context menus
  - Scroll wheel
  - Keyboard shortcuts
  - Hover states

**Recommended Approach:**

1. **Start with touch UI first** - Solve the hardest problem
2. **Iterate on desktop** - Faster development loop
3. **Frequently test on mobile** - Verify touch interactions feel right
4. **Layer additional inputs** - Treat as accelerators, not requirements
5. **Optimize for each device** - Consider what users expect from their input device

**Development Flow:**
```
Touch-First UI → Polish Touch Interactions → 
Test on Desktop (fast iteration) → Verify on Mobile → 
Optimize for Precision Input → Add Keyboard Shortcuts
```

**Key Insight:**
> Build for touch first, optimize for precision input second. Consider what users expect from their input device. WE ARE PC FIRST

---

### Implementation Best Practices

#### ❌ DON'T: Lock Screen Orientation

**Why you shouldn't:**
1. Accessibility issue for some users
2. Android large format tiers require portrait AND landscape support at minimum
3. Android devices can override locked orientation
4. Apple guidelines recommend supporting both orientations
5. Multi-window support increasingly common
6. Foldables have many use cases requiring landscape

**Problem with Foldables:**
- App looks fine when folded (portrait mode)
- When unfolded → app becomes **letterboxed** (window locked to center with black bars)
- `MediaQuery` never receives larger window size needed for UI expansion

**If you absolutely must lock (but don't):**
Use the `Display` API instead of `MediaQuery` to get physical screen dimensions

---

#### ❌ DON'T: Use Orientation-Based Layouts

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
- Device orientation doesn't necessarily inform available space
- App might be in multi-window mode or picture-in-picture
- Foldables break this assumption

**✅ DO: Use Size-Based Layouts**
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
```

---

#### ❌ DON'T: Gobble Up All Horizontal Space

**Problem:**
- Apps using full window width with boxes/text fields look bad on large screens
- Violates Android Large Screen App Quality Guidelines
- Violates iOS equivalent guidelines

**Solution: Use GridView**
See [Large Screen Optimization](#page-3-large-screen-devices) section

---

#### ❌ DON'T: Check for Hardware Device Types

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
  return WideLayout();
} else {
  return NarrowLayout();
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

#### ✅ DO: Support Multiple Input Devices

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

#### ✅ DO: Restore List State

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

#### ✅ DO: Save and Restore App State

**Scope:** Handle state retention across:
- Device rotation
- Window resizing
- Foldable unfolding/folding
- Multi-window state changes

**Default Behavior:** Apps should maintain state by default

**Important Notes:**
- Verify plugins and native extensions support the device type
- Some native plugins lose state on device configuration change
- Example: Folding/unfolding foldables causing state loss

**Reference:** "Developing Flutter apps for Large screens" article on Medium

---

## PAGE 3: LARGE SCREEN DEVICES

### What Counts as a Large Screen?
Flutter defines large screens as:
- **Tablets** (Android)
- **Foldables** (Android)
- **ChromeOS devices running Android**
- **Web browsers**
- **Desktop** (Windows, macOS, Linux)
- **iPads**

---

### Problem: Full-Width Content on Large Screens

**Visual Issue:**
When content spans 100% of large screen width, readability suffers:
- Long text lines are hard to read
- Input fields look unnatural
- Violates platform guidelines

**Platform Guidelines Violations:**
- Android Large Screen App Quality Guidelines
- iOS equivalent guidelines
- Text lines and input boxes shouldn't span full width

---

### Solution 1: GridView Layout 🎯

#### Concept
Convert single-column layouts to multi-column grids on large screens

#### Migration Path
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

#### Available GridView Delegates

**SliverGridDelegateWithFixedCrossAxisCount**
- Fixed number of columns regardless of screen width
- Useful when you want consistent column count
```dart
gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  childAspectRatio: 1.0,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
)
```

**SliverGridDelegateWithMaxCrossAxisExtent**
- Max width per item, columns adjust automatically
- Better for responsive behavior
```dart
gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 300,  // Max width per item
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
)
```

#### Performance
Use `.builder` constructor for large item counts to only build visible widgets

---

### Solution 2: ConstrainedBox with MaxWidth

**Approach:**
```dart
// Wrap content in ConstrainedBox with maxWidth
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
- Common breakpoints: 600dp, 840dp, 1200dp
- Adjust based on your app's specific needs

---

### Foldables: Special Considerations

#### Challenges
Foldable devices have:
- Two screens connected by hinge
- Folded state: portrait mode (narrow)
- Unfolded state: landscape mode (wide)
- State transitions during app runtime

#### Common Problem: Letterboxing

**When letterboxing occurs:**
1. App was in portrait mode with locked orientation
2. `setPreferredOrientations` puts Android in portrait compatibility mode
3. App window is **letterboxed** (centered with black bars)
4. `MediaQuery` never receives full unfolded window size
5. UI can't expand because it doesn't know the space is available

#### Solution 1: Support All Orientations

**Implementation:**
- Remove orientation locking
- Test layout in both portrait and landscape
- Use responsive layout techniques

**Benefits:**
- Foldable devices work properly
- Multi-window mode works
- Future-proofs your app

#### Solution 2: Use Display API for Physical Dimensions

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

### Adaptive Input for Large Screens

#### Android Large Format Device Tiers
- **Tier 3 (lowest):** Mouse and stylus input support
- **Higher tiers:** Additional features and considerations

#### Navigation Pattern Selection

**Challenge:** Large screens need different navigation than mobile

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

## PAGE 4: GENERAL APPROACH TO ADAPTIVE APPS

### 3-Step Methodology

Google engineers recommend a 3-step approach for adaptive design:

---

### Step 1: Abstract 🏗️

**Goal:** Identify widgets that need to be dynamic and abstract shared data

**Process:**
1. Identify widgets you plan to make dynamic
2. Analyze widget constructors
3. Extract data you can share across variants

**Common Widgets Requiring Adaptability:**
- Dialogs (both fullscreen and modal)
- Navigation UI (both rail and bottom bar)
- Custom layouts (height vs width based layouts)

**Example: Dialog Widget**
```dart
// Share the content of the dialog across variants
class DialogContent {
  final String title;
  final String message;
  final List<Widget> actions;
}

// Build appropriate dialog based on screen size
Widget buildDialog(DialogContent content, BuildContext context) {
  if (MediaQuery.sizeOf(context).width < 600) {
    return AlertDialog(...);  // Mobile variant
  } else {
    return Dialog(...);        // Desktop variant
  }
}
```

**Example: Navigation**
```dart
// Shared destination data
class Destination {
  final IconData icon;
  final String label;
  final Widget screen;
}

final destinations = [
  Destination(Icons.home, 'Home', HomeScreen()),
  Destination(Icons.search, 'Search', SearchScreen()),
];

// Build navigation based on screen size
// Use NavigationBar on small screens, NavigationRail on large screens
```

---

### Step 2: Measure 📏

**Goal:** Determine available display area to decide UI display

**Two Approaches:**

#### Option A: MediaQuery.sizeOf()

**When to use:**
- Get entire app window size
- Widget should be fullscreen
- Base sizing on entire app's window

**Behavior:**
- Returns `Size` object with fixed dimensions
- Triggers rebuild when size changes
- Provides window dimensions at that moment

```dart
final screenSize = MediaQuery.sizeOf(context);
final isWide = screenSize.width > 600;
```

**Important Note:**
- Returns app's entire screen, not single widget
- Can be misleading if app is in small window on large screen
- Avoid using with locked orientation (causes letterboxing)

#### Option B: LayoutBuilder

**When to use:**
- Get constraints from parent widget
- Sizing based on space given to specific widget
- More local/granular sizing
- Custom widgets needing specific space information

**Behavior:**
- Returns `BoxConstraints` instead of `Size`
- Provides min/max width and height ranges
- Specific to the widget tree location
- More flexible for custom layouts

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final isWide = constraints.maxWidth > 600;
    if (isWide) {
      return WideLayout();
    } else {
      return NarrowLayout();
    }
  },
)
```

**Advantages:**
- More granular control
- Works better with custom widgets
- Doesn't rebuild entire widget tree

#### Comparison

| Aspect | MediaQuery.sizeOf() | LayoutBuilder |
|--------|-------------------|---------------|
| **Returns** | Size object | BoxConstraints object |
| **Scope** | Entire app window | Parent widget constraints |
| **Use case** | Full-screen decisions | Local widget sizing |
| **Info type** | Fixed dimensions | Min/max ranges |

---

### Step 3: Branch 🔀

**Goal:** Decide what sizing breakpoints to use when choosing UI version

**Concept:**
Based on measurement results, branch logic to show appropriate layout

**Guidelines:**
- Base decisions on *available window size*, not device type
- Material layout guidelines suggest:
  - < 600 logical pixels: bottom nav bar
  - ≥ 600 pixels: nav rail
- Adjust breakpoints based on your app's needs

**Example:**
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    } else if (constraints.maxWidth < 900) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  },
)
```

**Reference Implementation:**
See "Building an animated responsive app layout with Material 3" for complete example

---

## PAGE 5: AUTOMATIC PLATFORM ADAPTATIONS

### Adaptation Philosophy

Two cases of platform adaptiveness exist:

1. **Automatic behaviors** - OS environment behaviors (text editing, scrolling) that would be wrong if different
2. **Conventional patterns** - App design choices using OEM's SDKs (tabs on iOS, AlertDialog on Android)

This page covers **Case 1**: Automatic adaptations provided by Flutter on Android and iOS.

For **Case 2**, Flutter provides means to produce appropriate effects but doesn't adapt automatically. See issue #8410 and Material/Cupertino adaptive widget problem definition.

---

### Page Navigation

#### Navigation Transitions

**On Android:**
- Default `Navigator.push()` transition modeled after `startActivity()`
- Uses bottom-up animation variant
- Animation: `ZoomPageTransitionsBuilder` - UI zooms in/out

**On iOS:**
- Default `Navigator.push()` produces iOS Show/Push style transition
- Animates from end-to-start depending on locale's RTL setting
- Page behind new route parallax-slides in same direction as iOS
- Separate bottom-up transition when `PageRoute.fullscreenDialog` is true
- Represents iOS's Present/Modal style (fullscreen modal pages)

#### Platform-Specific Transition Details

**On Android:**
```dart
// Uses ZoomPageTransitionsBuilder animation
// When user taps item: UI zooms in to feature that item
// When user taps back: UI zooms out to previous screen
```

**On iOS:**
```dart
// When using push style transition:
// CupertinoNavigationBar and CupertinoSliverNavigationBar
// automatically animate each subcomponent to corresponding
// subcomponent on next/previous page's navigation bar
```

#### Back Navigation

**On Android:**
- OS back button sent to Flutter by default
- Pops top route of `WidgetsApp`'s Navigator

**On iOS:**
- Edge swipe gesture pops top route
- No physical back button

---

### Scrolling

Scrolling is important to platform look and feel. Flutter automatically adjusts scrolling to match platform.

#### Physics Simulation

**Android vs iOS:**
- iOS has more weight and dynamic friction
- Android has more static friction
- iOS gains high speed more gradually
- Android stops more abruptly
- iOS more slippery at slow speeds

#### Overscroll Behavior

**On Android:**
- Scrolling past edge shows overscroll glow indicator
- Color based on current Material theme

**On iOS:**
- Scrolling past edge overscrolls with increasing resistance
- Snaps back when released

#### Momentum

**On iOS:**
- Repeated flings in same direction stack momentum
- Builds more speed with each successive fling

**On Android:**
- No equivalent momentum behavior

#### Return to Top

**On iOS:**
- Tapping OS status bar scrolls primary scroll controller to top

**On Android:**
- No equivalent behavior

---

### Typography

#### Automatic Font Selection

**When using Material package:**
- Android: Roboto font (default)
- iOS: San Francisco font (default)

**When using Cupertino package:**
- All platforms: San Francisco font (default)

#### Important Note on San Francisco
- License limits usage to iOS, macOS, tvOS only
- Fallback font used when running on Android
- Even if platform is debug-overridden to iOS

#### Customization
```dart
// You can adapt text styling of Material widgets to match iOS styles
TextTheme cupertinoTextTheme = TextTheme(
  headlineMedium: CupertinoThemeData()
      .textTheme
      .navLargeTitleTextStyle,
  titleLarge: CupertinoThemeData()
      .textTheme
      .navTitleTextStyle,
);
```

---

### Iconography

#### Automatic Adaptation

**When using Material package:**
- Certain icons automatically show different graphics by platform
- Example: Overflow button
  - 3 dots horizontal on iOS
  - 3 dots vertical on Android
- Example: Back button
  - Simple chevron on iOS
  - Stem/shaft on Android

#### Adaptive Icons

Material library provides platform-adaptive icons through `Icons.adaptive`:
```dart
Icon(Icons.adaptive.share)  // Adapts between iOS and Android
```

---

### Haptic Feedback

Material and Cupertino packages automatically trigger platform-appropriate haptic feedback:

**Example: Text Selection**
- Android: 'buzz' vibrate on long-press
- iOS: No feedback on long-press

**Example: Picker**
- iOS: 'light impact' knock when scrolling picker items
- Android: No feedback

---

### Text Editing

Both Material and Cupertino text input fields support platform-appropriate spellcheck.

#### Keyboard Gesture Navigation

**On Android:**
- Horizontal swipes on soft keyboard's space key move cursor
- Works with Material and Cupertino text fields

**On iOS (3D Touch):**
- Force-press-drag gesture on soft keyboard moves cursor in 2D
- Uses floating cursor
- Works with Material and Cupertino text fields

#### Text Selection Toolbar

**On Android with Material:**
- Android style selection toolbar shown on text selection

**On iOS or Cupertino:**
- iOS style selection toolbar shown on text selection

#### Single Tap Gesture

**On Android with Material:**
- Single tap puts cursor at tap location
- Collapsed text selection shows draggable handle

**On iOS or Cupertino:**
- Single tap puts cursor at nearest word edge
- Collapsed text selections don't have draggable handles

#### Long-Press Gesture

**On Android with Material:**
- Long press selects word under press
- Selection toolbar shown on release

**On iOS or Cupertino:**
- Long press places cursor at press location
- Selection toolbar shown on release

#### Long-Press Drag Gesture

**On Android with Material:**
- Dragging while holding long press expands selected words

**On iOS or Cupertino:**
- Dragging while holding long press moves cursor

#### Double Tap Gesture

**On Android and iOS:**
- Double tap selects word and shows selection toolbar

---

### UI Components

#### Widgets with .adaptive() Constructors

Several widgets support `.adaptive()` constructors. When running on iOS, these substitute corresponding Cupertino components.

**Recommendation:** Follow platform conventions for these controls since they're tightly integrated with the OS.

| Material widget | Cupertino widget | Adaptive constructor |
|---|---|---|
| `Switch` | `CupertinoSwitch` | `Switch.adaptive()` |
| `Slider` | `CupertinoSlider` | `Slider.adaptive()` |
| `CircularProgressIndicator` | `CupertinoActivityIndicator` | `CircularProgressIndicator.adaptive()` |
| `RefreshProgressIndicator` | `CupertinoActivityIndicator` | `RefreshIndicator.adaptive()` |
| `Checkbox` | `CupertinoCheckbox` | `Checkbox.adaptive()` |
| `Radio` | `CupertinoRadio` | `Radio.adaptive()` |
| `AlertDialog` | `CupertinoAlertDialog` | `AlertDialog.adaptive()` |

#### Top App Bar and Navigation Bar

##### Material 3 Guidelines
- Since Android 12: Material 3 design guidelines
- iOS: "Navigation Bars" in Apple's Human Interface Guidelines (HIG)

##### Adaptive Properties

**Already automatically adapted:**
- System icons
- Page transitions

**Using Material AppBar and SliverAppBar:**
```dart
// Map text theme to iOS styles
TextTheme cupertinoTextTheme = TextTheme(
  headlineMedium: CupertinoThemeData()
      .textTheme
      .navLargeTitleTextStyle
      .copyWith(letterSpacing: -1.5),
  titleLarge: CupertinoThemeData()
      .textTheme
      .navTitleTextStyle
);

// Use iOS text theme on iOS devices
ThemeData(
  textTheme: Platform.isIOS ? cupertinoTextTheme : null,
  ...
);

// Modify AppBar properties
AppBar(
  surfaceTintColor: Platform.isIOS ? Colors.transparent : null,
  shadowColor: Platform.isIOS ? CupertinoColors.darkBackgroundGray : null,
  scrolledUnderElevation: Platform.isIOS ? .1 : null,
  toolbarHeight: Platform.isIOS ? 44 : null,
  ...
)
```

**Important:** Only adapt styling if cohesive with rest of application. See GitHub discussion on app bar adaptations for more examples.

#### Bottom Navigation Bars

##### Material 3 Guidelines
- Since Android 12: Material 3 design guidelines
- iOS: "Tab Bars" in Apple's Human Interface Guidelines (HIG)

##### Implementation

```dart
final Map<String, Icon> _navigationItems = {
  'Menu': Platform.isIOS 
    ? Icon(CupertinoIcons.house_fill) 
    : Icon(Icons.home),
  'Order': Icon(Icons.adaptive.share),
};

Scaffold(
  body: _currentWidget,
  bottomNavigationBar: Platform.isIOS
    ? CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _loadScreen();
        },
        items: _navigationItems.entries
          .map<BottomNavigationBarItem>(
            (entry) => BottomNavigationBarItem(
              icon: entry.value,
              label: entry.key,
            ))
          .toList(),
      )
    : NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          _loadScreen();
        },
        destinations: _navigationItems.entries
          .map<Widget>((entry) => NavigationDestination(
            icon: entry.value,
            label: entry.key,
          ))
          .toList(),
      ),
);
```

**Note:** Tab bars should match your branding since they're persistent.

#### Text Fields

##### Implementation

```dart
Widget _createAdaptiveTextField() {
  final _border = OutlineInputBorder(
    borderSide: BorderSide(color: CupertinoColors.lightBackgroundGray),
  );
  
  final iOSDecoration = InputDecoration(
    border: _border,
    enabledBorder: _border,
    focusedBorder: _border,
    filled: true,
    fillColor: CupertinoColors.white,
    hoverColor: CupertinoColors.white,
    contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
  );
  
  return Platform.isIOS
    ? SizedBox(
        height: 36.0,
        child: TextField(
          decoration: iOSDecoration,
        ),
      )
    : TextField();
}
```

**See also:** GitHub discussion on text fields for more details.

---

## PAGE 6: CAPABILITIES & POLICIES

### Design to the Strengths of Each Device Type

**Key Concept:**
Consider unique strengths and weaknesses of different devices beyond just screen size and input methods.

**Approach:**
1. Think about what each platform does best
2. See if there are unique capabilities to leverage
3. Ensure your code *runs* AND design is appropriate

**Examples:**
- Apple App Store and Google Play Store have different rules
- Different OS have differing capabilities across time
- Web has extremely low barrier for sharing (design routes with deep links)

---

### Capabilities & Policies Pattern

#### Capabilities

**Definition:** What the code or device *can* do

**Examples:**
- Existence of an API
- OS-enforced restrictions
- Physical hardware requirements (like a camera)

#### Policies

**Definition:** What the code *should* do

**Examples:**
- App store guidelines compliance
- Design preferences
- Assets or copy referring to host device
- Server-side feature flags

#### Why Separate?
With larger products, making logical distinction between what apps *can* do and what they *should* do helps respond to changes:

**Example Scenario:**
- Platform 1 adds permission requiring dialog before sensitive API
- Team creates capability: `requirePermissionDialogFlow`
- Later, Platform 2 adds similar requirement (but only for new API versions)
- Implementation checks API level and returns true for Platform 2
- You've leveraged work already done!

---

### How to Structure Policy Code

#### Anti-Pattern: Direct Platform Checks

```dart
// ❌ AVOID: Direct platform checking in UI code
if (Platform.isAndroid) {
  // Android-specific code
} else if (Platform.isIOS) {
  // iOS-specific code
}
```

**Problems:**
- Unclear *why* the branching exists
- Hard to maintain as platforms evolve
- Difficult to test
- Code intent obscured

#### Pattern: Named Methods

```dart
// ✅ BETTER: Use descriptive method names
bool shouldAllowPurchaseClick() {
  // Banned by Apple App Store guidelines.
  return !Platform.isIOS;
}

// Usage in code
TextSpan(
  text: 'Buy in browser',
  style: TextStyle(color: Colors.blue),
  recognizer: shouldAllowPurchaseClick() 
    ? (TapGestureRecognizer()..onTap = () { launch('<url>') })
    : null,
)
```

**Benefits:**
- Code intent is clear
- Easy to understand *why* branching exists
- Can be tested independently
- Future-proof if requirements change

#### Pattern: Policy Classes

```dart
// ✅ BEST: Encapsulate in dedicated class
class Policy {
  bool shouldAllowPurchaseClick() {
    // Banned by Apple App Store guidelines.
    return !Platform.isIOS;
  }
  
  bool shouldShowFeature() {
    // Feature not available on all platforms
    return !Platform.isIOS;
  }
}

// Usage
if (Policy().shouldAllowPurchaseClick()) {
  // Show purchase link
}
```

**Benefits:**
- Centralized policy decisions
- Easy to mock in tests
- Scalable for complex policies
- Can break into feature-specific classes

#### Testing Policy Code

```dart
// ✅ Mock policies in widget tests
class MockPolicy implements Policy {
  @override
  bool shouldAllowPurchaseClick() => true;  // Mock value
}

testWidgets('purchase link shown when policy allows', (tester) async {
  // Provide mock policy
  await tester.pumpWidget(
    TestApp(policy: MockPolicy()),
  );
  
  // Verify behavior independent of actual device
  expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
});
```

**Advantages:**
- Tests don't need to change when policy changes
- Can test all branches without multiple devices
- Clear separation of concerns

---

### Capabilities vs Policies Summary

| Aspect | Capability | Policy |
|--------|-----------|--------|
| **Definition** | What code *can* do | What code *should* do |
| **Examples** | API exists, hardware present | App store rules, design preferences |
| **Checks** | Usually compile/runtime | Compile, runtime, or RPC |
| **Implementation** | Direct feature detection | Named methods in classes |
| **Testing** | Mock capabilities | Mock policies |

---

### Implementation Guidelines

#### Policy Implementation Types

**Compile-Time:**
- Good for platform preferences unlikely to change
- Accidental changes have large consequences
- Example: Never link to Play Store on certain platforms

```dart
class Policy {
  static const bool _allowPlayStoreLink = !Platform.isWeb;
  bool shouldShowPlayStoreLink() => _allowPlayStoreLink;
}
```

**Runtime:**
- Good for device features to check (touch screen, camera)
- Can check Android feature flags or web touch points

```dart
class Policy {
  bool hasTouchScreen() {
    // Check platform capabilities
    if (Platform.isAndroid) {
      // Use Android API
    } else if (kIsWeb) {
      // Check web max touch points
    }
    return true;
  }
}
```

**RPC-Backed (Remote Procedure Call):**
- Good for incremental feature rollout
- Good for decisions that might change later
- Server can control feature availability

```dart
class Policy {
  Future<bool> isFeatureEnabled(String featureName) async {
    // Call server for current feature status
    final response = await http.get('/api/features/$featureName');
    return response.data['enabled'];
  }
}
```

---

### Best Practices Summary

1. **Use a Capability class** to define what code *can* do
   - Check for API existence
   - Check OS-enforced restrictions
   - Check physical hardware requirements

2. **Use a Policy class(es)** to define what code *should* do
   - Comply with app store guidelines
   - Implement design preferences
   - Provide device-appropriate assets/copy

3. **Name methods by what they branch on**
   - Not by device type
   - Example: `shouldAllowPurchaseClick()` vs `isIOS()`

4. **Test by mocking**
   - Widget tests mock capabilities/policies
   - Don't change when actual implementation changes
   - Can test all branches without multiple devices

5. **Separate concerns**
   - Policies can be broken up by feature if complexity grows
   - Keep single responsibility principle

---

## 🎯 Complete Implementation Checklist

### Planning Phase
- [ ] Identify all target platforms (mobile, tablet, desktop, web, foldables)
- [ ] List platform-specific capabilities (camera, NFC, etc.)
- [ ] Identify platform-specific policies (app store rules, design preferences)
- [ ] Plan feature matrix by platform
- [ ] Design breakpoint strategy

### Design Phase
- [ ] Break complex screens into smaller widgets
- [ ] Identify widgets needing adaptability (dialogs, navigation, layouts)
- [ ] Design for platform strengths, not identical experiences
- [ ] Plan touch-first interaction
- [ ] Design navigation strategy (BottomNavigationBar vs NavigationRail)

### Development Phase

**Core Implementation:**
- [ ] Use `LayoutBuilder` or `MediaQuery.sizeOf()` for size detection
- [ ] Don't lock screen orientation
- [ ] Don't use `MediaQuery.orientation` for layout decisions
- [ ] Don't check device types for layout decisions
- [ ] Implement `Capability` and `Policy` classes

**Widgets & Components:**
- [ ] Break widgets into small, reusable pieces
- [ ] Use appropriate responsive layout widgets
- [ ] Use `GridView` for large screen layouts
- [ ] Add `ConstrainedBox` for max-width on large screens
- [ ] Support multiple input devices (touch, mouse, keyboard)
- [ ] Use `PageStorageKey` for list scroll state persistence

**Platform Adaptations:**
- [ ] Use Material's `.adaptive()` constructors
- [ ] Implement platform-specific navigation transitions
- [ ] Adapt typography to platform conventions
- [ ] Adapt text editing behavior
- [ ] Provide adaptive icons

**State Management:**
- [ ] Preserve app state across orientation changes
- [ ] Preserve app state across window resizing
- [ ] Preserve app state during fold/unfold

### Testing Phase
- [ ] Test on actual devices (mobile, tablet, desktop)
- [ ] Test in both portrait and landscape orientations
- [ ] Test window resizing on desktop
- [ ] Test multi-window mode
- [ ] Test foldable folding/unfolding transitions
- [ ] Test keyboard navigation on all platforms
- [ ] Test mouse and trackpad interactions
- [ ] Test with various window sizes (small, medium, large)
- [ ] Verify state persistence on configuration changes

### Large Screen Testing
- [ ] Use `NavigationRail` instead of `BottomNavigationBar`
- [ ] Use `GridView` for content layouts
- [ ] Add `ConstrainedBox` for max-width
- [ ] Support side-by-side layouts
- [ ] Add right-panel/details pane
- [ ] Test on tablets and iPad
- [ ] Test on desktop (Windows/macOS/Linux)
- [ ] Test on web browsers

### Foldable Testing
- [ ] Support all orientations (don't lock)
- [ ] Don't use `setPreferredOrientations`
- [ ] Test unfolding/folding transitions
- [ ] Test state persistence through fold/unfold
- [ ] Consider using `Display` API for special cases
- [ ] Test with actual foldable devices if available

---

## 📚 Additional Resources

### Official Flutter Documentation
- **Main Page:** https://docs.flutter.dev/ui/adaptive-responsive
- **Best Practices:** https://docs.flutter.dev/ui/adaptive-responsive/best-practices
- **Large Screens:** https://docs.flutter.dev/ui/adaptive-responsive/large-screens
- **General Approach:** https://docs.flutter.dev/ui/adaptive-responsive/general
- **Platform Adaptations:** https://docs.flutter.dev/ui/adaptive-responsive/platform-adaptations
- **Capabilities & Policies:** https://docs.flutter.dev/ui/adaptive-responsive/capabilities

### Related Topics to Study
- User input & accessibility
- Material 3 breakpoints and guidelines
- Cupertino design guidelines
- Developing Flutter apps for Large screens (Medium article)
- Wonderous app (example implementation on GitHub)

### Platform-Specific Guidelines
- Android Large Screen App Quality Guidelines
- iOS Human Interface Guidelines (HIG)
- Material Design: Applying layout guide
- Google Play Store: Large screens support requirements

---

## 🎓 Summary

This document covers ALL 6 official pages of Flutter's adaptive and responsive design documentation:

1. **Introduction** - Fundamental concepts of responsive vs adaptive design
2. **Best Practices** - Design considerations and implementation guidelines
3. **Large Screens** - GridView, foldables, navigation patterns
4. **General Approach** - 3-step methodology (Abstract, Measure, Branch)
5. **Platform Adaptations** - Automatic behaviors and platform-specific patterns
6. **Capabilities & Policies** - Platform-specific features and design patterns

**Key Takeaway:** Build once with responsive layouts, adapt intelligently for platform strengths.

---

**Document compiled:** December 27, 2025  
**Flutter version:** 3.38.1  
**Complete coverage:** ✓ All 6 official pages included  
**Purpose:** Quick reference for building truly adaptive Flutter apps across all platforms
