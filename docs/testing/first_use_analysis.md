# Analysis of First Use & Empty State Testing

## 1. Overview & Terminology
This analysis verifies **UI Guardrails** and uncovers **Bad States** (Trap Doors).
The goal is to find where the application is vulnerable when "First Use" (No Data) conditions are met.

**Key Finding ("The Crash Maker")**: The Database Layer (`DriftDatabaseConnector`) explicitly crashes if a participant is added without an active event. This makes all UI Trap Doors **High Severity**.

## 2. Identified Scenarios

### Scenario A: The "Absolute Empty" State
**Context**: Fresh Install. No Event. No Participants.
*   **Test**:
    *   `AppDrawer_new_record`: **Disabled**.
    *   `AppDrawer_participant_list`: **Disabled**.
    *   `AppDrawer_print_center`: **Disabled**.
    *   `AppDrawer_add_event`: **ENABLED**.
    *   **Visuals**: Verify subtitles like "Vytvořte akci nejdříve".

### Scenario B: The "Partial" State (Event Exists, No People)
**Context**: User created an Event, but hasn't added anyone yet.
*   **Test**:
    *   `AppDrawer_new_record`: **Disabled** (Subtitle: "Přidejte účastníky").
    *   `AppDrawer_new_participant`: **ENABLED**.

### Scenario C: Component Self-Defense (NewRecordPage)
**Context**: `NewRecordPage` pumped directly with no data.
**Test**:
*   Assert `Item Opacity` is 0.4.
*   Assert `TextFormField.enabled` is `false`.
*   Assert `SaveButton` does not crash.

### Scenario D: The "Trap Door" (ParticipantList Inconsistency)
**Context**: `ParticipantListScreen` forced open without event.
**Vulnerability**: Drawer is locked, but internal `Add Button` is open.
**Test**:
*   Pump `ParticipantListScreen` directly.
*   **Assert**: `ParticipantList_addButton` is `ENABLED`.
*   **Action**: Tap it -> Navigates to `ParticipantRegistrationPage`.
*   **Result**: User enters the "Minefield" (Scenario G).

### Scenario E: Complex Form "Zombie State" (IntakeFormImproved)
**Context**: `NewIntakeFormImproved` pumped directly without event.
**Vulnerability**: `IntakeController` initializes and tries to save data using the same flawed DB logic.
**Test**:
*   Pump `NewIntakeFormImproved`.
*   **Action**: Fill dummy data and Save.
*   **Result**: **CRASH** (Scenario G).

### Scenario F: Service Resilience (PrintCenter)
**Context**: `PrintCenterPage` pumped directly without event.
**Test**:
*   Pump `PrintCenterPage`.
*   **Assert**: Controller handles "No Event" gracefully (empty list) instead of crashing.

### Scenario G: "The Crash Maker" (Database Vulnerability)
**Context**: `Context-less Save Operation`.
**Technical Root Cause**: `DriftDatabaseConnector.addOsobaAndReturnId` calls `(await _driftDatabase.getCurrentActionID())!`.
**The "Bang"**: If this runs without a Current Event, it throws `Null check operator used on a null value`.
**Test**:
*   This is the *consequence* of Scenarios D and E.
*   Any test that reaches a "Save" button in Scenarios D/E *must* assert that it fails/crashes in the current codebase (or verify the fix if we were fixing it).

## 3. Supplementary Scenarios (Reaching 10)

### Scenario H: "The Ghost Search" (Autocomplete Vulnerability)
**Context**: `PersonAutocomplete` pumped with empty list (simulating failed fetch).
**Focus**: Does it mistakenly allow free-text entry that looks like a valid person?
**Test**:
*   Pump `PersonAutocomplete` with empty list.
*   Type, press Enter/Submit.
*   **Assert**: No valid `MemoryOsoba` is returned/created. (It should block or do nothing).

### Scenario I: "Zombie Detail View"
**Context**: `ParticipantDetailPage` pumped with a valid `MemoryOsoba` object, but *NO* underlying database record/event context.
**Test**:
*   Pump `ParticipantDetailPage` with a dummy MemoryOsoba.
*   **Assert**: `_fetchRecords` returns empty list (graceful failure) instead of crashing on DB Lookup.
*   **Assert**: "Edit" button is functional? If clicked, does it go to `ParticipantEditPage`?
*   **Trap**: If it goes to Edit Page and User saves, does it trigger Scenario G? (Likely yes, if "Edit" becomes "Save New" logic or if update checks constraints).

### Scenario J: "Orphaned Edit"
**Context**: `ParticipantEditPage` pumped directly with a `MemoryOsoba` (ID -1, New Person) but *NO* Event.
**Test**:
*   Pump `ParticipantEditPage` (new person mode).
*   **Assert**: Save button is Enabled.
*   **Action**: Tap Save.
*   **Result**: Hits "The Crash Maker" (Scenario G). This confirms that "Edit Page" is just as dangerous as "Registration Form" if accessed without context.

## 4. Victory Conditions (The "Fails")
We have successfully identified how to break the app via Widget Tests:
1.  **Fail 1**: `ParticipantListScreen` allows navigation to the Crash Maker.
2.  **Fail 2**: `IntakeFormImproved` allows execution of the Crash Maker.
3.  **Fail 3**: `ParticipantEditPage` (Orphaned Edit) allows execution of the Crash Maker.
4.  **Fail 4**: `DriftDatabaseConnector` logic is structural vulnerability.

This comprehensive suite covers Navigation, Components, Services, and Data Integrity.
