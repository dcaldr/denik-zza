# Deep Codebase Audit Plan for Integration Test Readiness

## 1. Objective
To perform an exhaustive, multi-pass static analysis of the entire codebase (including unit tests) to identify *hidden blockers* for integration testing. We aim to eliminate "surprises" such as implicit native calls, global state pollution, or race conditions.

## 2. Audit Passes

### Pass 1: The "Native Surface" Audit
**Goal:** Identify every single line of code that communicates with the host Operating System.
**Tactics:**
*   Scan `pubspec.yml` for all dependencies.
*   Cross-reference with `lib/` imports to see *where* they are used.
*   **Search Keywords:** `MethodChannel`, `Platform.`, `dart:io`, `Process.`, `File(`, `Directory(`.
*   **Specific Targets:** `path_provider`, `shared_preferences`, `url_launcher`, `permission_handler`.

### Pass 2: The "State Persistence" Audit
**Goal:** Find "sticky" state that could pollute tests between runs.
**Tactics:**
*   Search for global variables and static fields that are *mutable*.
*   Analyze `DatabaseWrapper` and `FileManager` for singleton access patterns.
*   **Search Keywords:** `static`, `var`, `late`, `GetIt`, `SharedPreferences`.

### Pass 3: The "Async & Concurrency" Audit
**Goal:** Find "Test Flakiness" generators (infinite loops, unclosed streams).
**Tactics:**
*   Identify logic that might prevent `tester.pumpAndSettle()` from completing.
*   **Search Keywords:** `Timer.periodic`, `Stream.listen` (without cancel), `Future.delayed`.

### Pass 4: The "Existing Test" Audit
**Goal:** Understand the current testing baseline.
**Tactics:**
*   List all files in `test/`.
*   Read `test/` files to see what is currently being mocked vs. real implementations.

## 3. Execution Strategy
This plan will be executed immediately using agentic tools (`grep_search`, `find_by_name`, `read_file`). The findings will be compiled into the `readiness_report.md`.
