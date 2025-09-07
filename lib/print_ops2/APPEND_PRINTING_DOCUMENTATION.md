# Append Printing System Documentation

**Feature:** print_ops2 Append Printing  
**Purpose:** Technical documentation for developers implementing append printing functionality  
**Last Updated:** September 7, 2025

---

## Overview

The append printing system enables printing new medical records onto previously printed paper by making already-printed content transparent. This conserves paper during events where records are continuously added throughout the day.

## Core Concept

### Physical Process
1. User generates initial print with records A, B
2. Later, new record C needs to be added
3. User puts the previously printed paper back in printer
4. System generates new print job where A, B are transparent, C is visible
5. Result: Same paper now contains A, B, C

### Technical Implementation
- **Transparency**: Already-printed content rendered with `hiddenColor = PdfColor(0, 0, 0, 0)`
- **State Tracking**: Each entity tracks `wasPrinted`/`isPrinted` status
- **Validation**: Complex rules determine when append is safe vs. when full reprint required

---

## Append Validation Logic

### 1. Can We Append Print?

The system must check several conditions before allowing append printing:

#### ✅ **SAFE TO APPEND:**
```dart
// Scenario 1: Adding chronologically after printed records
Records: [A(printed), B(printed)] → Adding C(new, after B)
Result: APPEND OK - hide A,B; print C

// Scenario 2: Partial print + insertion
Records: [A(printed), B(unprinted)] → Adding Ab(new, between A & B)  
Result: APPEND OK - hide A; print Ab, B

// Scenario 3: Modifying unprinted records
Records: [A(unprinted), B(unprinted)] → Modifying A
Result: APPEND OK - print modified A, B
```

#### ❌ **REQUIRES FULL REPRINT:**
```dart
// Scenario 1: Insertion in middle of printed sequence
Records: [A(printed), B(printed), C(printed)] → Adding Ab(between A & B)
Result: REPRINT REQUIRED - paper cannot be changed retroactively

// Scenario 2: Modifying printed records  
Records: [A(printed), B(printed)] → Modifying A
Result: REPRINT REQUIRED - printed content cannot be changed

// Scenario 3: Name or restrictions change after printing
Person: [Name(printed), Restrictions(printed)] → Changing name OR any restriction
Result: REPRINT REQUIRED - header unit invalidated

// Scenario 4: First print ever
Records: [] → Adding A
Result: REPRINT REQUIRED - no previous paper exists

// Scenario 5: User-requested reset
Previous print marked as "start from scratch"
Result: REPRINT REQUIRED - user feedback override
```

### 2. What Records/Headers to Hide?

#### Header Logic by Page Type

**Page 1 Header (Name + Restrictions Combined)**
- **Content**: Person details + all restrictions/medications
- **Treated as single unit** - cannot partially hide
- **Hide when**: Appending to existing page 1 AND person was previously printed
- **Show when**: Creating new page 1 OR first print ever
- **Change invalidation**: ANY change to name OR restrictions invalidates entire print

**Page 2+ Headers (Simplified)**  
- **Content**: Name + Age/Birthdate only (no restrictions)
- **Hide when**: Appending to existing page N AND person was previously printed on page N
- **Show when**: Creating new page N OR first time printing page N

#### Header Visibility Rules
```dart
// Page 1 header visibility
if (isAppendingToExistingPage1 && osoba.wasPrinted) {
  hideHeader(); // Make transparent
} else {
  showHeader(); // Always visible on new pages
}

// Page 2+ header visibility  
if (isAppendingToExistingPageN && pageN.wasPrinted) {
  hideSimplifiedHeader();
} else {
  showSimplifiedHeader();
}
```

#### Records Section
- **Hide individual records** where `record.isPrinted == true`
- **Show individual records** where `record.isPrinted == false`
- **Maintain chronological order** - gaps allowed but order preserved

### 3. Multi-Page Handling (Future)

Complex scenarios for multi-page documents:

#### Append to Existing Page
- New records fit on existing page with printed content
- **Hide printed content** (including headers if page was previously printed)
- **Show new content** on same page

#### Append + New Pages  
- Some new records fit on existing page, others require new pages
- **Hide printed content** on existing page (including existing page header)
- **Show full headers** on entirely new pages
- Create entirely new pages for overflow

#### New Pages Only
- Existing pages completely full, all new content goes to new pages
- **Don't modify existing pages** at all
- **Show full headers** on new pages (Page 1 style for first new page, simplified for subsequent)

---

## State Management

### Status Tracking with OkCodes

```dart
enum OkCodes {
  unprinted,  // All items in category not printed
  printed,    // All items in category printed  
  broken,     // Mixed state - some printed, some not
  unset,      // Not yet evaluated
}
```

### State Fields in GeneratePdfTemplate

```dart
class GeneratePdfTemplate {
  // Page 1 header (name + restrictions as single unit)
  OkCodes _page1HeaderStatus = OkCodes.unset;     // Combined name + restrictions
  
  // Individual page tracking for multi-page
  Map<int, OkCodes> _pageStatus = {};             // Per-page print status
  
  // Records status  
  OkCodes _recordStatus = OkCodes.unset;          // Records status

  // Validation methods
  bool canAppend()                    // Main entry point
  void isPage1HeaderOk()              // Validates name + restrictions as unit
  void isRecordsOk()                  // Validates chronological record sequence
  void isPageHeaderOk(int pageNum)    // Validates specific page header
}
```

**Key Changes from Current Implementation:**
- Removed separate `_omezeniStatus`, `_lekStatus`, `_allRestrictionsStatus`
- Added `_page1HeaderStatus` for combined name + restrictions
- Added `_pageStatus` map for multi-page header tracking

### State Validation Flow

```dart
bool canAppend() {
  // 1. Check if we have any previous print to append to
  if (!hasAnyPreviousPrint()) return false;
  
  // 2. Validate page 1 header consistency (name + restrictions)
  isPage1HeaderOk();
  if (_page1HeaderStatus == OkCodes.broken) return false;
  
  // 3. Validate records chronological consistency
  isRecordsOk(); 
  if (_recordStatus == OkCodes.broken) return false;
  
  // 4. Check for name/restriction changes that invalidate print
  if (hasHeaderChangesAfterPrint()) return false;
  
  // 5. Validate page-specific scenarios for multi-page
  for (int pageNum in getAffectedPages()) {
    isPageHeaderOk(pageNum);
    if (_pageStatus[pageNum] == OkCodes.broken) return false;
  }
  
  return true;
}
```

---

## Business Rules

### Print Modes

1. **Print Person (Entire/Full)**
   - Prints all records for one person from scratch
   - Resets all `wasPrinted` flags before printing
   - Uses standard PDF generation without transparency logic
   - Marks everything as printed after successful completion
   - Used for complete record printouts or when append is not possible

2. **Append Print Person**
   - Adds new records to existing printout using transparency
   - **Requires specialized computation logic** beyond simple printing:
     - Complex validation of what can be appended
     - Transparency rendering for already-printed content
     - Chronological insertion conflict detection
     - Multi-page append scenario handling
   - May be disabled if validation fails
   - Primary mode during active events

3. **Print All People** 
   - Prints records for all people (full print mode)
   - Option to include people without records
   - Batch operation for end-of-event
   - Always uses full print logic (no append)

4. **Quick Copy Mode** (Future)
   - Reprints existing content without changing print status
   - Used for creating backup copies
   - Bypasses append logic entirely

### Event-Based Workflow

**Recommended Usage:**
1. Print records immediately as events occur ("get it to paper fast")
2. Use append printing for additional records throughout event
3. Don't wait until event end for bulk printing

**Why This Matters:**
- Field conditions require immediate paper documentation
- Paper supplies may be limited 
- Multiple staff may need access to printed records
- Digital backups may not be available/reliable

### User Feedback Requirements

After each print job, system MUST collect user feedback:

```dart
enum PrintJobResult {
  success,           // Use as starting point for next append
  needReprint,       // Something went wrong, reprint this job  
  startFromScratch   // Major error, reset all print status
}
```

**Why User Feedback Is Critical:**
- Automatic detection cannot catch all physical errors
- Paper jams, wrong orientation, wrong paper type
- User may insert wrong previous printout
- Print quality issues (low ink, misalignment)

---

## Implementation Status

### ✅ Currently Implemented
- Basic state tracking with OkCodes
- Chronological validation logic  
- Abstract interfaces for different printing modes
- Font loading and PDF generation infrastructure
- **Simple/Full printing**: Standard PDF generation without append logic

### ❌ Missing Critical Components  
- **Print Mode Selection UI**: No differentiation between full vs append print
- **Full Print Implementation**: No explicit "reset and reprint all" functionality
- **Append Print Computation Engine**: Complex logic beyond simple printing:
  - Transparency rendering for already-printed content
  - Multi-page append scenario calculations  
  - Content visibility determination per page
  - Chronological conflict resolution
- **User Feedback System**: No UI for post-print confirmation
- **Multi-page Logic**: Single page only, no pagination

### 🚨 Known Bugs
- **Infinite recursion** in setter methods (critical)
- **Incomplete interface implementation** in PrintPdfRestrictions
- **Type safety issues** with dynamic typing

---

## Future Enhancements

### Per-Event Printing Mode
Alternative to per-person printing:
- Multiple people per page in columnar format
- Columns: Name, Birthdate, Record Details
- Used for event-wide record keeping

### Quick Copy Mode  
Special printing mode:
- Prints entire pages without changing print status
- Used for creating backup copies
- Doesn't affect append logic state

### Advanced Multi-Page Append
Complex scenarios for large record sets:
- Intelligent page break handling
- Header repetition on new pages
- Page numbering with append considerations

---

## Implementation Requirements

### Print Mode Selection API
```dart
enum PrintMode {
  entirePerson,     // Full reprint (reset all print status)
  appendPerson,     // Append new content (complex computation)
  allPeople,        // Print all people (full mode only)
  quickCopy,        // Reprint without changing print status
}

class GeneratePdfTemplate {
  Future<List<pw.Page>> getPdfPages({
    required MemoryOsoba osoba,
    required PrintMode mode,          // NEW: Explicit mode selection
    List<MemoryOmezeni>? omezeniList,
    List<MemoryLek>? lekList,  
    List<MemoryZaznam>? zaznamList,
  })
}
```

### Mode-Specific Processing
```dart
Future<List<pw.Page>> getPdfPages(...) async {
  switch (mode) {
    case PrintMode.entirePerson:
      return await _generateFullPrint(...);     // Simple, standard logic
      
    case PrintMode.appendPerson:
      return await _generateAppendPrint(...);   // Complex computation engine
      
    case PrintMode.allPeople:
      return await _generateBatchPrint(...);    // Batch processing
      
    case PrintMode.quickCopy:
      return await _generateQuickCopy(...);     // Copy without status change
  }
}
```

### Append Print Computation Engine
**Key Point**: Append printing requires sophisticated computation logic beyond simple PDF generation:

```dart
Future<List<pw.Page>> _generateAppendPrint(...) async {
  // Step 1: Validate append possibility
  if (!canAppend()) throw AppendNotPossibleException();
  
  // Step 2: Calculate content visibility per page  
  final visibilityMap = await _calculateContentVisibility();
  
  // Step 3: Apply transparency to printed content
  final processedContent = await _applyTransparencyLogic(visibilityMap);
  
  // Step 4: Handle multi-page append scenarios
  final pages = await _generatePagesWithAppendLogic(processedContent);
  
  return pages;
}
```

### UI Updates for Print Mode Selection
```dart
// PersonSelectionScreen with multiple print options
ListTile(
  title: Text('${person.jmeno} ${person.prijmeni}'),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Full Print Button
      IconButton(
        icon: Icon(Icons.print),
        tooltip: 'Print Entire Person',
        onPressed: () => _navigateToPrint(person, PrintMode.entirePerson),
      ),
      // Append Print Button (conditional)
      if (_canAppendPrint(person))
        IconButton(
          icon: Icon(Icons.add_to_photos),  
          tooltip: 'Append New Records',
          onPressed: () => _navigateToPrint(person, PrintMode.appendPerson),
        ),
    ],
  ),
)
```

---

## Developer Notes

### Testing Append Logic
```dart
// Test data setup for various scenarios
final person = MemoryOsoba(wasPrinted: true);
final records = [
  MemoryZaznam(isPrinted: true, casZaznamu: DateTime(2024, 1, 1)),
  MemoryZaznam(isPrinted: true, casZaznamu: DateTime(2024, 1, 2)),
  MemoryZaznam(isPrinted: false, casZaznamu: DateTime(2024, 1, 3)),
];

final template = GeneratePdfTemplate();
final canAppend = template.canAppend(); // Test validation
```

### Debugging State Issues
```dart
// Add logging to track state changes
Logger().d('Omezeni status: $_omezeniStatus');
Logger().d('Lek status: $_lekStatus'); 
Logger().d('All restrictions: $_allRestrictionsStatus');
Logger().d('Records status: $_recordStatus');
```

### Integration with Main App
When integrating with main application:
1. Replace demo data with real database queries
2. Implement user feedback collection UI
3. Add proper error handling and user messaging
4. Consider performance implications for large record sets

---

## References

- **Main Report**: `/docs/reports/print2report.md` - High-level analysis and issues
- **Demo Implementation**: `dev_main.dart` - Working example with test data
- **Core Logic**: `generate_pdf_template.dart` - State management and validation
- **TODO Items**: `todo.md` - Known limitations and planned improvements

---

*This documentation reflects the intended design as of September 7, 2025. Implementation may be incomplete or contain bugs.*
