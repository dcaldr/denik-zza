# Test Coverage Gaps & Known Issues

**Purpose:** Track testing limitations and gaps that cause bugs to slip through passing tests  
**Audience:** All developers writing or reviewing tests  
**Last Updated:** November 2, 2025

---

## 📋 Quick Reference: Known Testing Gaps

**⚠️ Review this checklist before writing tests for interactive widgets, forms, or user input**

### Interactive Widget Testing Gaps

- [x] **Focus Management**: `tester.enterText()` bypasses focus mechanism - TextField focus loss bugs not detected
  - **Impact:** Critical UX bugs (unusable inputs) pass tests
  - **Detection:** Manual testing or integration tests required
  - **See:** [Case Study #1: TextField Focus Loss](#case-study-1-textfield-focus-loss)

- [ ] **Keyboard Event Simulation**: Widget tests don't simulate real keyboard events
  - **Impact:** Character-by-character input behavior not tested
  - **Missing:** Key press events, modifiers (Shift/Ctrl), platform-specific behavior
  - **Workaround:** Integration tests with real keyboard input

- [ ] **Gesture Sequences**: Complex touch gestures not fully tested
  - **Impact:** Multi-touch, drag-and-drop, swipe patterns may fail in production
  - **Missing:** Real gesture recognition pipeline
  - **Workaround:** Integration tests or manual testing

- [ ] **Platform-Specific Interactions**: Widget tests run in test environment
  - **Impact:** Platform differences (iOS/Android/Web) not caught
  - **Missing:** Native widget behavior, platform conventions
  - **Workaround:** Platform-specific integration tests

### State Management Testing Gaps

- [x] **Rebuild-Triggered Bugs**: setState() causing widget recreation not always caught
  - **Impact:** Focus loss, animation resets, scroll position loss
  - **Missing:** Lifecycle testing across rebuilds
  - **See:** [Case Study #1: TextField Focus Loss](#case-study-1-textfield-focus-loss)

- [ ] **Async State Transitions**: Race conditions between async operations
  - **Impact:** Intermittent failures, data inconsistency
  - **Missing:** Concurrency testing patterns
  - **Workaround:** Careful use of `pumpAndSettle()`, explicit timing tests

---

## 🎯 How to Use This Document

### When Writing New Tests
1. Review the [Quick Reference](#-quick-reference-known-testing-gaps) checklist above
2. If testing interactive widgets, read relevant case studies below
3. Add test limitations as comments in your test file
4. Consider if integration tests are needed

### When Reviewing Tests
1. Check if PR addresses interactive widgets listed in checklist
2. Verify test doesn't rely solely on `tester.enterText()` for TextField tests
3. Ask: "Could this pass tests but fail for real users?"
4. Require integration tests for critical user interaction paths

### When Adding New Issues
Use this template:

```markdown
- [ ] **Issue Name**: Brief description of what tests miss
  - **Impact:** What bugs slip through
  - **Missing:** What testing capability is absent
  - **Workaround:** How to catch these bugs
  - **See:** [Link to case study if applicable]
```

---

## 📚 Case Studies: Detailed Analysis

### Case Study #1: TextField Focus Loss

**Bug:** ParticipantListScreen search TextField loses focus on every keystroke, making it completely unusable.

**Test Result:** All 22 widget tests pass (100%) ✅ including "rapid typing" test

**Why Tests Didn't Catch It:**

```dart
// Test code that PASSES but shouldn't
await tester.enterText(searchField, 'Kafka');  // ← Bypasses focus mechanism!
await tester.pumpAndSettle();
expect(find.text('Franz Kafka'), findsOneWidget);  // ← Passes ✅
```

**The `tester.enterText()` limitation:**
- Directly sets `TextEditingController.text` via API
- Does NOT trigger `onChanged` for each character
- Does NOT simulate keyboard events
- Does NOT interact with FocusNode
- Does NOT test the actual user input path

**Real User Experience:**
1. User clicks TextField → gets focus ✅
2. User types 'K' → `onChanged` → `setState()` → widget rebuilds → **FOCUS LOST** ❌
3. User must click again → types 'a' → **FOCUS LOST** ❌
4. Feature is completely unusable

**Root Cause:**

```dart
// BROKEN CODE
class _ParticipantListScreenState extends State<ParticipantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  // ❌ No FocusNode - new one created on each rebuild!
  
  TextField(
    controller: _searchController,
    onChanged: (value) {
      setState(() { _searchQuery = value; });  // ← Triggers rebuild
    }
  )
}
```

Each `setState()` rebuilds the widget tree → TextField recreated → new FocusNode → focus lost.

**Solution Implemented:** ✅ **PersonAutocomplete Widget (Recommended Pattern)**

```dart
// USING PersonAutocomplete (intake form pattern)
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';

class _ParticipantListScreenState extends State<ParticipantListScreen> {
  final DatabaseInterface _database = DatabaseWrapper.getDatabase();
  List<MemoryOsoba> _allParticipants = [];
  List<MemoryOsoba> _filteredParticipants = [];
  
  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }
  
  Future<void> _loadParticipants() async {
    final participants = await _database.getParticipantsByCurrentEvent();
    if (!mounted) return;
    setState(() {
      _allParticipants = participants;
      _filteredParticipants = participants;
    });
  }
  
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PersonAutocomplete handles focus management internally
        PersonAutocomplete(
          key: const Key('ParticipantList_autocomplete'),
          availablePersons: _allParticipants,
          onPersonSelected: (person) {
            // Filter list to show only selected person (or keep showing all)
            setState(() {
              _filteredParticipants = [person];
            });
          },
          onRefresh: () async {
            await _loadParticipants();
          },
        ),
        // Show filtered list
        Expanded(
          child: ListView.builder(
            itemCount: _filteredParticipants.length,
            itemBuilder: (context, index) {
              return ParticipantListItem(osoba: _filteredParticipants[index]);
            },
          ),
        ),
      ],
    );
  }
}
```

**Why PersonAutocomplete Works:**
- Uses Flutter's `Autocomplete` widget internally
- `fieldViewBuilder` provides stable `FocusNode` managed by framework
- FocusNode lifecycle handled automatically
- Proven pattern from intake form
- Includes dropdown suggestions as bonus feature

**Alternative: Simple FocusNode Pattern (for non-dropdown cases)**

```dart
class _ParticipantListScreenState extends State<ParticipantListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();  // ✅ Stable across rebuilds
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();  // ✅ Must dispose
    super.dispose();
  }
  
  TextField(
    controller: _searchController,
    focusNode: _searchFocusNode,  // ✅ Same instance survives rebuilds
    onChanged: (value) {
      setState(() { _searchQuery = value; });  // Now safe!
    }
  )
}
```

**When to use each:**
- **PersonAutocomplete:** Need dropdown suggestions, selection behavior, Czech UI
- **Simple FocusNode:** Just need stable focus without dropdown

**Status:**
- ✅ **Documented:** November 2, 2025
- 🔲 **Implementation:** Update ParticipantListScreen to use PersonAutocomplete
- ✅ **Added to README:** test/README.md warns about this limitation

**Lessons Learned:**
1. **100% test coverage ≠ bug-free code**
2. **Widget tests have fundamental limitations** - they test API, not real interaction
3. **Focus management is invisible to standard widget tests**
4. **Reuse proven patterns** (PersonAutocomplete) instead of reinventing
5. **Always dispose FocusNodes** (and controllers)

**Prevention Checklist:**
- [ ] Use PersonAutocomplete for search/filter with dropdown
- [ ] OR create FocusNode in State for simple TextField
- [ ] Pass FocusNode to TextField/TextFormField
- [ ] Dispose FocusNode in dispose()
- [ ] Add comment explaining why FocusNode is needed
- [ ] Consider integration test for critical inputs

---

## 🛠️ Testing Patterns & Solutions

### Pattern: Using PersonAutocomplete for Search

**Recommended for:** Search fields, filters, any input needing dropdown suggestions

```dart
// PersonAutocomplete provides stable focus + dropdown UX
PersonAutocomplete(
  availablePersons: allParticipants,
  onPersonSelected: (person) {
    // Handle selection
  },
  onRefresh: () async {
    // Reload data
  },
)
```

**Benefits:**
- ✅ Focus management handled automatically
- ✅ Dropdown suggestions included
- ✅ Proven pattern from intake form
- ✅ Czech UI text
- ✅ Keyboard navigation built-in

---

### Pattern: Simple FocusNode Management

**Use when:** Need stable focus without dropdown

```dart
class _MyWidgetState extends State<MyWidget> {
  final _focusNode = FocusNode();  // ✅ Create in State
  
  @override
  void dispose() {
    _focusNode.dispose();  // ✅ Always dispose
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,  // ✅ Pass stable reference
    );
  }
}
```

---

### Pattern: Testing Focus Stability (Future Work)

**Problem:** Widget tests can't detect focus loss bugs

**Solution:** Add integration test with real keyboard simulation

```dart
// Example integration test (future work)
testWidgets('search maintains focus during typing', (tester) async {
  await tester.pumpWidget(MyApp());
  
  final searchField = find.byKey(Key('searchField'));
  await tester.tap(searchField);
  await tester.pump();
  
  // Verify focus before typing
  expect(tester.widget<TextField>(searchField).focusNode?.hasFocus, isTrue);
  
  // Type character-by-character (simulates real keyboard)
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.pump();
  
  // Verify focus maintained after setState()
  expect(tester.widget<TextField>(searchField).focusNode?.hasFocus, isTrue);
});
```

**Status:** 🔲 Pattern documented, not yet implemented

---

## 📖 References

### Documentation
- [test/README.md](./README.md) - Test best practices and limitations warning
- [rules/widgetRules.md](../rules/widgetRules.md) - Widget development rules
- [rules/testingRules.md](../rules/testingRules.md) - Testing strategies

### Related Code
- `lib/screens2/widgets/person_autocomplete.dart` - **Recommended pattern** with stable FocusNode
- `lib/screens2/participant_list_screen.dart` - Example needing PersonAutocomplete
- `test/participant_list_screen_widget_test.dart` - Tests that pass despite focus bug

### External Resources
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing Best Practices](https://flutter.dev/docs/cookbook/testing/widget)
- [Autocomplete Widget](https://api.flutter.dev/flutter/material/Autocomplete-class.html)

---

## 🔄 Change Log

**November 2, 2025:**
- ✅ Created document structure
- ✅ Added Case Study #1: TextField Focus Loss
- ✅ Documented PersonAutocomplete as recommended solution
- ✅ Added quick reference checklist
- ✅ Added usage guide for different scenarios
- 🔲 **TODO:** Update ParticipantListScreen to use PersonAutocomplete

**Future Additions:**
- [ ] Case Study #2: [To be added as issues discovered]
- [ ] Integration test examples
- [ ] Focus stability test helper
- [ ] More testing patterns
