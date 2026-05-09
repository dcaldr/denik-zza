# Defensive Setup Strategy for Edge Cases

## Goal
Guarantee edge-case test setup stays achievable in real app behavior as the app evolves, without relying on brittle memory or manual rituals.

## Core Principle
Use a Setup Contract Layer:
- Build state with app actions when practical.
- Allow back-insert only for difficult preconditions.
- Always prove the precondition is visible and usable through current app paths before running core assertions.

This prevents "testing mocked state" instead of real app behavior.

## Failure Modes To Prevent
1. Hidden preconditions only known by original author.
2. Data setup that bypasses app constraints and becomes unrealistic.
3. Tests passing after app changes because assertions are too soft.
4. Flaky identity selection from non-unique display names.
5. Drift between fixture builders and real app workflows.

## Defensive Mechanisms

### 1) Two-Phase Setup Contract
Every edge-case test should enforce:
- Phase A: Prepare state (in-app or back-insert).
- Phase B: Re-enter through app route and verify setup is truly reachable in UI.

Rule:
If Phase B cannot observe the prepared state, the test fails before business assertions.

### 2) Setup Provenance Tagging
Each test case must declare setup provenance in comments/metadata:
- provenance: in-app
- provenance: back-insert + app-revalidated

This forces explicit accountability and blocks silent setup shortcuts.

### 3) Identity Safety Contract
For participant selection cases, require one unique secondary identifier check (DOB, birth number, internal id resolved via helper) before write actions.

Reason:
Display name is not a stable unique key.

### 4) Precondition Assertions Before Action
Before first critical user action, assert preconditions explicitly:
- current event id is expected
- participant count and expected identities are present
- print state flags are expected baseline
- record counts are expected baseline

This prevents false positives when setup silently regresses.

### 5) Postcondition Double Verification
After critical actions, verify both:
- UI behavior (enabled/disabled route/button/state)
- DB truth per entity (participant, record, medication, restriction, print flags)

No single-layer-only verification for edge cases.

### 6) Negative Assertion Requirement
Each edge-case test must include at least one explicit "must not happen" assertion.
Examples:
- wrong participant id did not get the record
- append did not produce new print side effect
- untouched entities remained unchanged

### 7) Invariant Registry for Unsupported CRUD
Maintain a short registry of currently unsupported operations (for example update/delete on certain entities).

For each unsupported operation, include a test-level invariant assertion path that proves no accidental mutation occurred through available app actions.

## How To Keep It Future-Proof

### A) Setup Builders With Capability Checks
For each edge-case setup helper, include capability checks:
- verify required route/key exists before proceeding
- fail with descriptive guidance if app flow changed

This avoids silent skips and hidden maintenance burden.

### B) One "Contract Test" Per Critical Setup Helper
Add small contract tests for setup helpers themselves:
- helper can create required state
- state is visible in app route
- helper fails loudly when preconditions are invalid

This makes setup drift visible early.

### C) Centralized Preflight for Edge-Case Suite
Before edge-case suite execution, run a short preflight:
1. mode coordinator reset verified
2. database empty/known baseline verified
3. current event state known
4. core navigation routes reachable

If preflight fails, abort suite with actionable message.

### D) Strong Naming + Checklist Instead of Memory
Use case files with explicit checklist sections:
- setup
- revalidation
- action
- expected
- forbidden
- residual risk

The programmer should not need to remember hidden steps.

## Suggested Minimal Governance

1. Add "Setup Contract" section to each new edge-case test.
2. Reject edge-case tests that skip app revalidation after back-insert setup.
3. Require one unique identity assertion in any participant-selection test.
4. Require one negative assertion in every edge-case test.
5. Keep P0 edge-case list in one source-of-truth plan file.

## Practical Application to Current Findings

Immediate hardening targets:
1. Duplicate identity selection (same/similar names) with unique-id post-verify.
2. Blocked append with no new records must be hard-asserted.
3. Intake navigation state reset/persistence contract check.
4. Print-state transition stress sequence with contiguous invariant checks.

## Why This Works
This strategy aligns with integration-test best practices:
- test behavior and side effects, not internals
- prioritize high-risk seams
- avoid over-mocking critical flows
- keep tests deterministic and explicit about setup contracts

Result:
Edge-case tests remain realistic, maintainable, and resilient when app internals evolve.
