# Flutter Integration Testing Strategy & Architecture

## 1. Executive Summary & Objectives

This document outlines the strategic approach to integration testing for the [Project Name] application. The primary goal is to ensure high application stability across all target platforms (including Windows and Linux) using the standard `integration_test` package.

We aim to move beyond simple "happy path" testing to a tiered structure that guarantees core functionality, verifies complex business logic, measures performance under load, and provides a sandbox for adversarial testing.

### Key Goals

1. **Zero-Regression Core:** A "Protected Flow" that acts as a canary in the coal mine. It must never fail.

2. **Realism with Boundary Mocking:**

    * **Internal Logic (Drift):** We run real code. Database logic runs against an isolated temporary file to test SQL and migrations.

    * **System Boundaries (OS):** We **MUST** mock system interactions that block execution (e.g., Printing dialogs, File Pickers) since standard integration tests cannot control native OS windows.

3. **Performance Scalability:** Reusing functional test logic with heavy datasets to ensure responsiveness using simple metrics (Stopwatch) combined with native reporting.

4. **Visual & Layout Integrity:** * **Visual Gallery:** Automatically capturing one clean screenshot of every major screen to create a visual inventory of the app.
    * **No-Wiggle Policy:** Ensuring layouts that *should* fit on the screen do not accidentally overflow (unnecessary scrollbars) on Desktop/Tablet.

5. **Maintainability:** Strict adherence to DRY (Don't Repeat Yourself) principles using the Robot Pattern and **Reusable Scenarios**.

## 2. Test Categorization & Hierarchy

The directory structure is simplified to highlight the three main testing pillars, moving support code into a shared infrastructure folder.

### Tier 1: Protected Flow (The Canary)

* **Location:** `integration_test/tests/protected_flow/`

* **Objective:** Sanity check. Verifies that the app starts and performs the absolute core function.

* **Constraints:**

    * **NO** external dependencies (uses `SimulationProfile.minimal` with a temporary DB).

    * Must be extremely fast.

    * Failure blocks the pipeline immediately.

    * **Visual Evidence:** Must capture a screenshot on success/failure using `binding.takeScreenshot`.

### Tier 2: General Scenarios (The Body)

* **Location:** `integration_test/tests/general/`

* **Objective:** Comprehensive End-to-End (E2E) testing of user journeys and components.

* **Scope:**

    * **Positive & Negative:** Validating success paths and error states.

    * **Component Tests:** Deep dives into specific widgets.

    * **Visual Gallery:** Scenarios should capture screenshots at key stable states and at least one path should produce screenshots for each existing screen.

    * **Layout Check:** Verifies no unintentional scrolling (scroll wiggle) on large screens.

* **Data:** Uses `SimulationProfile.standard` and `TestVectors`.

### Tier 3: Breakdown & Chaos (The Sandbox)

* **Location:** `integration_test/tests/breakdown/`

* **Objective:** Adversarial testing zone designed to break the app.

* **Rules:** Must simulate what a user can really do (i.e., only button presses, inputs...). **NO** setting up situations via non-user-available steps (nothing outside UI interactions).

* **Methodology:**

    * Playground for AI Agents or fuzzing scripts.

    * **Performance Tests:** Runners located here reuse logic from `infrastructure/scenarios/` but execute it with `SimulationProfile.stress`.

## 3. Directory Structure

We use a flat "Source" folder for helpers to keep the focus on the actual tests.

```text
integration_test/
├── tests/                     # The entry points (Runners)
│   ├── breakdown/             # Performance & Chaos runners
│   │   └── AUDIT_LOG.md
│   ├── general/               # Functional correctness tests
│   └── protected_flow/        # Canary flow
├── infrastructure/            # Support code (Hidden complexity)
│   ├── data/                  # SINGLE SOURCE OF TRUTH for Data
│   │   ├── simulation_profiles.dart # DB State (Volume)
│   │   ├── test_vectors.dart        # Test Inputs (Specific Cases)
│   │   └── seeders/                 # Logic to populate DB
│   ├── robots/                # Page Objects (UI Interaction)
│   ├── scenarios/             # REUSABLE Business Logic (Step sequences)
│   └── utils/                 # Helpers (Stopwatch, Layout checkers)
└── flutter_test_config.dart   # Global test configuration (Animation disabling)
```

## 4. Reference Architecture & Standards

This section defines the mandatory patterns and interfaces. All generated code must adhere to these contracts.

### 4.1. Naming & Tagging Conventions

* **Test Files:** `snake_case_test.dart`.
* **Robot Files:** `snake_case_robot.dart`.
* **Scenario Files:** `snake_case_scenario.dart` (Reusable logic).
* **Tags:** Add `@Tags(['protected'])` to critical tests.

### 4.2. Global Configuration (Stability)

To prevent flakiness, `flutter_test_config.dart` must explicitly disable animations.

```dart
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Ensure the binding is initialized for screenshots and performance reporting
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  
  timeDilation = 0.01; 
  await testMain();
}
```

### 4.3. The Robot Contract (UI Interaction)

Every screen must have a Robot extending `BaseRobot`.

**Updates:** Includes `takeScreenshot` and Form Factor helpers.

```dart
abstract class BaseRobot {
  final WidgetTester tester;
  BaseRobot(this.tester);
  
  Future<void> pumpAndSettle() async => await tester.pumpAndSettle();
  
  Finder findKey(String key) => find.byKey(Key(key));

  /// Captures a screenshot named [name].
  Future<void> takeScreenshot(String name) async {
    await IntegrationTestWidgetsFlutterBinding.instance.takeScreenshot(name);
  }

  /// Helper to branch logic based on screen size (e.g. Skip Drawer on Desktop)
  bool get isSmallScreen {
    final size = tester.binding.window.physicalSize / tester.binding.window.devicePixelRatio;
    return size.width < 800; // Example threshold
  }
}
```

### 4.4. Data Centralization Strategy

To ensure consistency, **NO** data should be hardcoded in test files. We use two structures in `infrastructure/data/`:

**A. Simulation Profiles (Database State/Volume)**
Controls *how much* data is in the DB and its initial state, without assuming specific entity types.

```dart
enum DataVolume { minimal, standard, stress }

class SimulationProfile {
  final DataVolume volume;
  final bool simulateNetworkDelay;

  // Factories for different tiers
  factory SimulationProfile.minimal() => ... // Clean state, minimal seeds
  factory SimulationProfile.standard() => ... // Representative dataset
  factory SimulationProfile.stress() => ... // Maximum capacity dataset
}
```

**B. Test Vectors (Test Inputs/Cases)**
Controls *what specific values* are typed into fields during Matrix/Parameterized tests.

```dart
// infrastructure/data/test_vectors.dart
class FormInputTestCase {
  final String description;
  final Map<String, dynamic> inputs;
  final bool shouldSucceed;
  // ... constructor ...
}
```

### 4.5. Data Layer Strategy (Drift & Async)

**Pattern: Real DB, Isolated Storage**
1. **No Mocks:** Use `AppDatabase`.
2. **Isolation:** Inject `NativeDatabase.memory()` or temp file.
3. **Async Awareness:** Since Drift may use real isolates/futures that conflict with `fakeAsync`, wrap heavy DB initialization or complex queries in `tester.runAsync()` if the test hangs.

### 4.6. System Boundary Strategy (Mocking)

**Rule:** Any service triggering a native system dialog (Print, File Picker) **MUST** be faked using an in-memory implementation to prevent test freezes.

### 4.7. The Scenario Contract (Strict Business Logic)

Scenarios allow code reuse between functional and performance tests.

**Rule 1: Pure High-Level Orchestration**
Scenarios **MUST NOT** access `WidgetTester` directly.

**Rule 2: Data Return**
If a scenario creates a domain entity, it **MUST** return the relevant data object (or ID).

**Rule 3: Performance Reporting (Native)**
When running scenarios in Performance Tests, use the native reporting API alongside Stopwatch.

```dart
// Example Scenario Structure
// infrastructure/scenarios/entity_scenarios.dart

Future<int> runCreateEntityScenario({
  required DashboardRobot dashboard,
  required EntityEditorRobot editor,
  required String entityName,
}) async {
  // 1. Navigate
  await dashboard.tapCreateNew();
  
  // 2. Fill Form
  await editor.enterName(entityName);
  await editor.tapSave();
  
  // 3. Return ID (implied or fetched)
  return 123; 
}
```

### 4.8. Visual & Layout Verification Standards

**1. The Visual Gallery (Overview Only)**
* **Requirement:** Scenarios MUST capture exactly one screenshot per screen.
* **Naming:** Use readable names like `view_dashboard`.

**2. The No-Wiggle Assertion (Layout Overflow)**
We verify that screens meant to fit within the viewport do not have active scrollbars.
* **Logic:** If window size > 800px height (Desktop), `maxScrollExtent` MUST be 0.

### 4.9. Parameterized Scenarios (Matrix Testing)

To efficiently cover variations without code duplication, use the **Matrix Pattern** combined with **Test Vectors**.

**Pattern:**
Loop through `TestVectors` instead of defining lists inside the test file.

```dart
// In login_test.dart (Example)
import '../../infrastructure/data/test_vectors.dart';

for (final case in AuthVectors.loginCases) {
  testWidgets('Auth Flow: ${case.description}', (tester) async {
    // 1. Setup Standard DB
    await seed(SimulationProfile.standard());
    
    // 2. Run Scenario with Vector Data
    await runAuthScenario(
      AuthRobot(tester), 
      credentials: case.credentials
    );
    
    // 3. Assert Result
    if (case.shouldSucceed) {
      expect(find.text('Welcome'), findsOneWidget);
    } else {
      expect(find.text('Error'), findsOneWidget);
    }
  });
}
```

### 4.10. Code Generation Guidelines

* **Imports:** Always use relative imports for files within `integration_test/`.
* **Constants:** Do not hardcode strings in tests. Use `TestConstants` or `TestVectors`.
* **Assertions:** Scenarios perform actions. Tests perform assertions.

### 4.11. Future Roadmap: Advanced Performance

While we currently use `Stopwatch` for MVP performance metrics, the architecture allows for future upgrades:

* **Timeline Tracing (Jank Detection):**
  Future tests in `tests/breakdown/` can utilize `tester.binding.traceAction()`. This generates a JSON timeline that can be analyzed to detect dropped frames (Jank) during animations, ensuring smooth 60fps performance even under load.