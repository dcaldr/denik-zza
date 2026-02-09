# Architectural Analysis: Roots of the Test Hang

The hang in `print_state_robot_test.dart` was a symptom of deeper architectural issues in how data flows from Drift to the UI.

## 1. The N+1 Async Problem
**Symptom:** `PrintStateController` manually stitches data together:
```dart
// Controller logic
listen(participants) {
  for (person in participants) {
    // Await inside loop = N+1 async hops
    final records = await _service.getRecords(person.id); 
  }
}
```
**Impact:**
- **Performance:** Inefficient for large lists.
- **Testing:** In `FakeAsync` tests, every `await` requires the clock to advance. A list of 10 people = 10 separate async operations + the stream listener itself. If the test clock doesn't advance precisely (hence the `pump(Duration)` fix), this complex chain deadlocks.
- **Fragility:** The UI is waiting for a "settled" state that is hard to define because data loads incrementally.

## 2. Leaky Abstractions (Missing Repository Layer)
**Symptom:** The Controller is doing "Data Access" work (joining tables).
- `PrintCenterService` is a thin wrapper that exposes raw DB methods.
- The Controller has to know *how* to fetch records for a person.

**Solution: Reactive Repository Pattern**
The Database/Service layer should expose the *final* data structure needed by the UI, computed efficiently in SQL/Drift.

**Proposed Change:**
Instead of `Stream<List<Osoba>>` AND `Future<List<Zaznam>>`, expose a single stream:
```dart
// A single, joined stream that emits fully populated objects
Stream<List<PersonPrintState>> getPersonPrintStates(int eventId);
```
**Benefits:**
- **Atomic Updates:** The UI gets the full state in one frame. No "loading records" phase.
- **Test Stability:** Tests only need to wait for *one* stream emission. No N+1 async loop to manage.
- **Performance:** Drift can optimize the join (or `asyncMap` batching) internally.

## 3. Singleton Dependency Injection
**Symptom:** `DatabaseWrapper.getDatabase()` is the default argument in services.
- While DI is *possible*, the code defaults to the global singleton, making it easy to write tests that accidentally hit the real DB (as happened with `HardcodedTestSetup`).

**Recommendation:**
1.  **Refactor `PrintStateController`** to consume a single `Stream<List<PersonPrintState>>` from the service.
2.  **Update `PrintCenterService`** to perform the Join (using Drift's `join` or an efficient `asyncMap` inside the Service, not the Controller).
3.  **Strict DI:** Consider removing default values for `DatabaseInterface` in Service constructors to force explicit dependency management (or use a Service Locator like `GetIt` consistently).
