# Implementation Plan - Phase 2: Integration Test Infrastructure

# Goal Description
Build the "Factory Floor" for integration tests. We will implement the shared support code required to write clean, maintainable tests using the Robot Pattern. All code will reside in `integration_test/infrastructure/` to strictly separate test logic from app code.

## User Review Required
> [!NOTE]
> This phase does not modify any `lib/` code. It only adds new support files in `integration_test/`.
> **Directory Structure Confirmation:** All files will be created under `integration_test/infrastructure/`.

## Proposed Changes

### 1. The Robot Foundation (`infrastructure/robots/`)
We need the base class for all Page Objects to handle common tasks like pumping, finding keys, and screen-size logic.

#### [NEW] [base_robot.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/integration_test/infrastructure/robots/base_robot.dart)
*   **Responsibility:** Wraps `WidgetTester`, provides `pumpAndSettle`, `findKey`, and `takeScreenshot`.
*   **Key Method:** `tap(Finder)` with automatic pumping.

### 1. The Test Harness (`infrastructure/utils/`)
A specialized root widget (`test_harness.dart`) is needed to force the app into "Integration Test Mode" without manual configuration in every test file.
*   **Responsibility:**
    *   Initialize `IntegrationTestWidgetsFlutterBinding`.
    *   Call `ModeCoordinator.setIntegrationTestMode()`.
    *   Manually set `Intl.defaultLocale = 'cs_CZ'` and initialize date formatting (replicating `main.dart`).
    *   Wrap app in `ZzaTheme`.

### 2. Data Seeding (`infrastructure/data/`)
We initially need a **Hardcoded** Golden State to guarantee tests start from a known good point.

#### [NEW] [hardcoded_test_setup.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/integration_test/infrastructure/data/hardcoded_test_setup.dart)
*   **Source Logic:** Port from `lib/dev/dev_environment.dart`.
*   **Modifications:**
    *   Use `DriftDatabaseConnector` directly (no generic wrappers if possible).
    *   Function: `static Future<void> setupTestData(AppDatabase db)`.
    *   **Data:** 1 Event ("Letní Tábor 2024"), 1 Paramedic ("test_admin"), 10 Participants (Czech Figures), ~10 Records.

### 3. Missing Keys (Code Changes Required)
To enable Robots, we must add keys to target widgets.

#### [MODIFY] [lib/screens2/event_list.dart]
*   Add `Key('EventList_add_button')` to the `+` IconButton.
*   Add `Key('EventList_select_action_${action.idAkce}')` to the `ListTile`.

### 4. Robots
#### [NEW] [base_robot.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/integration_test/infrastructure/robots/base_robot.dart)
*   Standard wrapping of `WidgetTester`.

#### [NEW] [dashboard_robot.dart](file:///d:/dev/my_flutter_projects/our-awesome-semestral/integration_test/infrastructure/robots/dashboard_robot.dart)
*   `tapCreateNewEvent()`: Taps `EventList_add_button`.
*   `selectEvent(int id)`: Taps `EventList_tile_$id`.

## Verification Plan

### Automated Validation
1.  **Analyze:** `flutter analyze integration_test/infrastructure` (Must be clean).
2.  **Smoke Test:** Create a dummy test `integration_test/tests/infra_smoke_test.dart` that:
    *   Uses `test_harness`.
    *   Instantiates a `BaseRobot`.
    *   Calls `pumpAndSettle`.
    *   **Success:** Test passes = Infrastructure is wired correctly.

### Manual Verification
*   None required (Pure code structure).
