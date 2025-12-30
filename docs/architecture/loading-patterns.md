# Loading State Patterns

## Overview

This document defines the standard patterns for handling async data loading in Flutter widgets. Consistent patterns ensure predictable behavior in both production and E2E tests.

## The 4 Rules

### Rule 1: Forms with Async Data → `isLoading` flag

**When:** Screen has TextField, Autocomplete, or any form input.

**Why:** FutureBuilder causes TextField to rebuild, losing focus and input data.

```dart
class MyFormScreen extends StatefulWidget {
  @override
  _MyFormScreenState createState() => _MyFormScreenState();
}

class _MyFormScreenState extends State<MyFormScreen> {
  bool _isLoading = true;
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await service.getData();
    if (!mounted) return;
    setState(() { 
      _items = data;
      _isLoading = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return MyFormWithTextFields(items: _items);
  }
}
```

**Current screens using this pattern:**
- `event_detail.dart`
- `participant_detail.dart`
- `csv_review_shared.dart`

---

### Rule 2: Read-Only Lists → FutureBuilder

**When:** Display-only lists with no user input.

**Critical:** Always create Future in `initState`, never in `build()`!

```dart
class MyListScreen extends StatefulWidget {
  @override
  _MyListScreenState createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  late Future<List<Item>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = service.getData();  // Create ONCE here!
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: _dataFuture,  // Pass existing Future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (_, i) => ItemTile(snapshot.data![i]),
        );
      },
    );
  }
}
```

**Current screens using this pattern:**
- `event_list.dart`

---

### Rule 3: E2E Tests → `pump()` not `pumpAndSettle()`

**Problem:** `CircularProgressIndicator` is an infinite animation. `pumpAndSettle()` waits for all animations to complete and will timeout.

```dart
// ❌ WRONG: Will timeout with spinner
await tester.pumpAndSettle();

// ✅ CORRECT: Single pump + wait + pump
await tester.pump();
await Future.delayed(Duration(milliseconds: 500));
await tester.pump();

// ✅ BETTER: Retry loop waiting for element
for (int i = 0; i < 20; i++) {
  await tester.pump(Duration(milliseconds: 100));
  if (find.byKey(Key('content_loaded')).evaluate().isNotEmpty) break;
}
```

---

### Rule 4: Loading Indicator Keys (for testing)

Add key to loading state so tests can detect loading state:

```dart
if (_isLoading) {
  return Center(
    key: const Key('ScreenName_loading'),  // ← Test can find this
    child: CircularProgressIndicator(),
  );
}
```

Robot pattern:
```dart
// Wait until loading is done
while (find.byKey(Key('ScreenName_loading')).evaluate().isNotEmpty) {
  await tester.pump(Duration(milliseconds: 100));
}
```

---

## Decision Tree

```
Loading async data?
  └── Screen has TextField/Autocomplete/Form?
        ├── YES → Use Rule 1 (isLoading flag)
        └── NO → Is it a display-only list?
              ├── YES → Use Rule 2 (FutureBuilder)
              └── NO → Use Rule 1 (safer default)
```

---

## Migration Checklist

When adding loading state to a screen:

- [ ] Identify if screen has form inputs
- [ ] Add `bool _isLoading = true;` field
- [ ] Load data in `initState()` or separate method
- [ ] Check `mounted` before `setState`
- [ ] Add loading key: `Key('ScreenName_loading')`
- [ ] Update E2E tests to use `pump()` not `pumpAndSettle()` during loading

---

## References

- Research based on 7 web searches (Dec 2024)
- flutter.dev FutureBuilder documentation
- Testing guidelines: pumpAndSettle limitations
