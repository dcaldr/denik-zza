# Edge Cases Main Loop Plan

## Scope
Target hard-to-spot failures in the main app loop without adding new screens.

Main loop reference:
- PreEvent -> Intake -> Event -> Print/Append -> AfterEvent

This plan allows two setup modes:
- In-app setup (preferred)
- Back-insert setup (allowed only to prepare difficult states), followed by app-level action and verification

## Planning Rules
1. Validate behavior through app actions whenever possible.
2. Back-insert is only for state preparation, not for asserting behavior that app never executes.
3. Every edge case must have DB-level verification and UI-level verification when user-visible.
4. Keep tests deterministic: fixed identities, fixed ordering, explicit expectations.
5. No new screens.

## Priority Matrix

### P0 (High Risk)

1. Ambiguous participant selection (same or very similar names)
- Risk: medical record saved to wrong person.
- Setup: in-app achievable now.
- Action: create two participants with colliding name tokens, use Intake/NewRecord search and select.
- Verify:
  - Selected participant identity by unique secondary fields (birth number or DOB).
  - Record lands on expected participant ID only.
- Negative check: partial query that matches both names must not silently pick wrong target.

2. Blocked append when nothing new exists
- Risk: duplicate print output and corrupted print expectations.
- Setup: in-app achievable now.
- Action: full print participant -> return and attempt append without new records.
- Verify:
  - Append action is blocked (hard assertion, not soft observation).
  - No new PDF side effect and no flag mutation.

3. Intake stale state after navigation churn
- Risk: wrong participant marked as arrived.
- Setup: in-app achievable now.
- Action: open intake, select participant A, navigate away and back via drawer, then save flow.
- Verify:
  - Form is reset or clearly bound to current selection contract.
  - Arrival flag changes only for intended participant.

4. Print state sequence integrity under repeated append/full transitions
- Risk: non-contiguous print states and append misbehavior.
- Setup: in-app + optional back-insert for dense state.
- Action: full print -> append -> state management toggles -> append again.
- Verify:
  - Contiguous rule preserved.
  - No re-print of already printed records.

### P1 (Medium Risk)

5. Empty participant print path (0 records)
- Risk: crash/hang in print pipeline.
- Setup: in-app achievable.
- Action: create participant with no records and open print flow.
- Verify:
  - Graceful behavior and consistent flags.

6. Cross-event identity confusion
- Risk: participant from event B appears selectable in event A.
- Setup: in-app achievable.
- Action: create similar participants in two events and switch context.
- Verify:
  - Search and selection strictly scoped by current event.

7. CSV fuzzy insurance ambiguity
- Risk: wrong insurance persisted silently.
- Setup: back-insert CSV input, app import flow for behavior.
- Action: import ambiguous insurance labels.
- Verify:
  - Expected resolution rule (or explicit rejection/review) is enforced.

8. Partial CSV approval with duplicates
- Risk: inconsistent DB state after mixed approve/reject.
- Setup: back-insert CSV file.
- Action: review table mixed decisions then finalize.
- Verify:
  - Only approved rows persisted.
  - No FK or duplication corruption.

### P2 (Structural/Contract)

9. AfterEvent deactivation contract with data integrity
- Risk: accidental data loss on deactivation.
- Setup: in-app achievable.
- Action: pin-toggle to deactivate current event.
- Verify:
  - Current event null.
  - AppDrawer disabled state returned.
  - Event participants remain in DB.

10. Unsupported CRUD invariants remain true
- Risk: architecture drift introduces accidental behavior.
- Setup: mixed.
- Action: execute closest available user path.
- Verify:
  - For entities with no update/delete support, no implicit mutation occurs.
  - Existing behavior contract remains stable.

## Suggested File Roadmap
Place new tests under integration_test/tests/edge_cases/.

Suggested files:
1. duplicate_identity_selection_edge_case_test.dart
2. blocked_append_no_new_records_edge_case_test.dart
3. intake_navigation_state_edge_case_test.dart
4. print_state_transition_edge_case_test.dart
5. empty_participant_print_edge_case_test.dart
6. csv_ambiguity_edge_case_test.dart
7. csv_partial_approval_edge_case_test.dart

## Per-Test Template (Required)
For every edge-case test, include:
1. Why this case is high-value.
2. Setup type (in-app or back-insert) and why.
3. App actions (user-like path).
4. DB verifications (entity-specific).
5. Negative assertion (what must NOT happen).
6. Cleanup/isolation assertion.

## Exit Criteria
This plan is complete when:
1. P0 cases are implemented with hard assertions.
2. P1 cases are at least planned with explicit setup/verification contracts.
3. Unsupported CRUD invariants are documented and validated by tests where feasible.
4. No test relies on hidden assumptions about selection identity or print-state defaults.
