# UI Standards Implementation Checklist

**Deník ZZA - Step-by-Step Guide to Standardize UI**

This guide helps you apply design rules systematically across the app.

---

## 📋 Table of Contents

1. [Quick Start - Create Foundation Files](#phase-0-quick-start)
2. [Phase 1 - Critical Fixes (Week 1-2)](#phase-1-critical-fixes)
3. [Phase 2 - Component Library (Week 3-4)](#phase-2-component-library)
4. [Phase 3 - Screen-by-Screen Migration (Week 5-6)](#phase-3-screen-migration)
5. [Phase 4 - Polish & Testing (Week 7-8)](#phase-4-polish)
6. [Code Review Checklist](#code-review-checklist)

---

## Phase 0: Quick Start - Create Foundation Files

**Goal:** Create the basic design system files that all other code will use.

### Step 1: Create Design System Folder

```bash
mkdir -p lib/design_system
```

### Step 2: Create AppSpacing Constants

**File:** `lib/design_system/app_spacing.dart`

```dart
class AppSpacing {
  // Spacing values
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Common padding patterns
  static const EdgeInsets screenPadding = EdgeInsets.all(medium);
  static const EdgeInsets cardPadding = EdgeInsets.all(medium);
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(
    vertical: small,
    horizontal: 0,
  );
}
```

**Checklist:**
- [ ] Created `lib/design_system/app_spacing.dart`
- [ ] Added to version control
- [ ] Imported in at least one file to test

---

### Step 3: Create AppBreakpoints

**File:** `lib/design_system/app_breakpoints.dart`

```dart
import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static int getFormColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }
}
```

**Checklist:**
- [ ] Created `lib/design_system/app_breakpoints.dart`
- [ ] Tested `getFormColumns()` returns correct values

---

### Step 4: Create AppConstraints

**File:** `lib/design_system/app_constraints.dart`

```dart
import 'package:flutter/material.dart';

class AppConstraints {
  static const double maxContentWidth = 1200;
  static const double maxFormWidth = 800;
  static const double maxCardWidth = 600;

  static Widget constrainContent(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: child,
      ),
    );
  }

  static Widget constrainForm(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxFormWidth),
        child: child,
      ),
    );
  }
}
```

**Checklist:**
- [ ] Created `lib/design_system/app_constraints.dart`
- [ ] Added helper methods work correctly

---

### Step 5: Create AppDateFormats

**File:** `lib/design_system/app_date_formats.dart`

```dart
import 'package:intl/intl.dart';

class AppDateFormats {
  static final DateFormat short = DateFormat('dd.MM.yyyy', 'cs_CZ');
  static final DateFormat long = DateFormat('d. MMMM yyyy', 'cs_CZ');
  static final DateFormat time = DateFormat('HH:mm', 'cs_CZ');
  static final DateFormat dateTime = DateFormat('dd.MM.yyyy HH:mm', 'cs_CZ');

  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return short.format(date);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return AppDateFormats.dateTime.format(dateTime);
  }
}
```

**Checklist:**
- [ ] Created `lib/design_system/app_date_formats.dart`
- [ ] Verified `'cs_CZ'` locale is initialized in `main.dart`

---

### Step 6: Export Design System

**File:** `lib/design_system/design_system.dart`

```dart
// Central export file for design system
export 'app_spacing.dart';
export 'app_breakpoints.dart';
export 'app_constraints.dart';
export 'app_date_formats.dart';
```

**Checklist:**
- [ ] Created `lib/design_system/design_system.dart`
- [ ] Can import with: `import 'package:denik_zza/design_system/design_system.dart';`

---

## Phase 1: Critical Fixes (Week 1-2)

### 🚨 Priority 1: Fix FileViewerScreen (URGENT!)

**Why:** This screen will crash on missing/corrupted files.

**File:** `lib/screens2/widgets/file_viewer_screen_widget.dart`

#### Changes Required:

1. **Add AppBar**
```dart
return Scaffold(
  appBar: AppBar(
    title: Text('Prohlížeč souborů'),
    actions: [
      IconButton(
        icon: Icon(Icons.close),
        tooltip: 'Zavřít',
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  ),
  body: _buildView(extension),
);
```

2. **Add Error Handling**
```dart
Widget _buildPDFView() {
  return FutureBuilder<Uint8List>(
    future: _loadPdfBytes(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Nelze načíst PDF soubor'),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Zavřít'),
              ),
            ],
          ),
        );
      }

      if (!snapshot.hasData) {
        return LoadingIndicator(message: 'Načítání PDF...');
      }

      return PdfPreview(
        build: (format) => snapshot.data!,
      );
    },
  );
}

Future<Uint8List> _loadPdfBytes() async {
  try {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Soubor neexistuje');
    }
    return await file.readAsBytes();
  } catch (e) {
    throw Exception('Chyba při čtení souboru: $e');
  }
}
```

3. **Fix PDF Constraints**
```dart
// Remove magic numbers, use proper responsive layout
Widget _buildPDFView() {
  return LayoutBuilder(
    builder: (context, constraints) {
      return PdfPreview(
        build: (format) => _loadPdfBytes(),
        maxPageWidth: constraints.maxWidth * 0.9,
      );
    },
  );
}
```

**Checklist:**
- [ ] Added AppBar with close button
- [ ] Wrapped file operations in try-catch
- [ ] Added FutureBuilder for async loading
- [ ] Added error state UI
- [ ] Added loading indicator
- [ ] Removed magic numbers (1.3, 2, *4)
- [ ] Tested with missing file (should show error, not crash)
- [ ] Tested with corrupted PDF (should show error)
- [ ] Tested with valid PDF (should display correctly)

---

### 🔴 Priority 2: Fix ParticipantRegistrationForm Responsive Grid

**Why:** Form is unusable on mobile devices.

**File:** `lib/screens2/participant_registration_form.dart`

#### Create ResponsiveFormGrid Widget

**File:** `lib/screens2/widgets/responsive_form_grid.dart`

```dart
import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/design_system.dart';

class ResponsiveFormGrid extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveFormGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final columns = AppBreakpoints.getFormColumns(context);

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final rowChildren = children.skip(i).take(columns).toList();

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren
              .map((child) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: child,
                    ),
                  ))
              .toList(),
        ),
      );

      rows.add(SizedBox(height: AppSpacing.small));
    }

    return Column(children: rows);
  }
}
```

#### Update ParticipantRegistrationForm

Replace fixed Rows with ResponsiveFormGrid:

```dart
// OLD (fixed 3 columns):
Row(
  children: [
    Expanded(child: _buildTextField('jmeno', ...)),
    Expanded(child: _buildTextField('prijmeni', ...)),
    Expanded(child: _buildTextField('cisloPojisteni', ...)),
  ],
)

// NEW (responsive):
ResponsiveFormGrid(
  children: [
    _buildTextField('jmeno', ...),
    _buildTextField('prijmeni', ...),
    _buildTextField('cisloPojisteni', ...),
  ],
)
```

**Checklist:**
- [ ] Created `ResponsiveFormGrid` widget
- [ ] Replaced all fixed `Row` layouts in form
- [ ] Tested on mobile (375px width) - shows 1 column
- [ ] Tested on tablet (768px width) - shows 2 columns
- [ ] Tested on desktop (1200px width) - shows 3 columns
- [ ] All form fields are accessible and usable

---

### 🟡 Priority 3: Replace ElevatedButton with Material 3

**Why:** Consistency with Material 3 design language.

#### Files to Update:
- `lib/screens2/event_registration_form.dart`
- `lib/screens2/participant_registration_form.dart`
- `lib/screens2/participant_edit_page.dart`
- Any other files with `ElevatedButton`

#### Find All Instances:
```bash
grep -r "ElevatedButton" lib/screens2/ lib/print_ops2/
```

#### Replacement Rules:
```dart
// Primary actions (submit, save, confirm):
ElevatedButton(...) → FilledButton(...)

// Secondary actions (reset, alternative):
ElevatedButton(...) → OutlinedButton(...)

// Cancel/back actions:
ElevatedButton(...) → TextButton(...)
```

**Checklist:**
- [ ] Found all `ElevatedButton` instances
- [ ] Replaced with appropriate Material 3 button
- [ ] Verified button hierarchy (primary = filled, secondary = outlined)
- [ ] All buttons still work correctly
- [ ] Visual regression test passed

---

### 🟢 Priority 4: Replace Hardcoded Spacing

**Goal:** Replace all hardcoded numbers with `AppSpacing` constants.

#### Find Candidates:
```bash
# Find hardcoded padding/margins
grep -rn "EdgeInsets.all(16" lib/screens2/
grep -rn "SizedBox(height: " lib/screens2/
grep -rn "padding: const EdgeInsets" lib/screens2/
```

#### Replacement Pattern:
```dart
// OLD:
EdgeInsets.all(16.0)
SizedBox(height: 8)
Padding(padding: const EdgeInsets.symmetric(vertical: 12))

// NEW:
EdgeInsets.all(AppSpacing.medium)
SizedBox(height: AppSpacing.small)
Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.medium))
```

#### Common Mappings:
- `4` → `AppSpacing.xs`
- `8` → `AppSpacing.small`
- `16` → `AppSpacing.medium`
- `24` → `AppSpacing.large`
- `32` → `AppSpacing.xl`

**Checklist:**
- [ ] Replaced all `EdgeInsets.all(16)` → `EdgeInsets.all(AppSpacing.medium)`
- [ ] Replaced all `SizedBox(height: 8)` → `SizedBox(height: AppSpacing.small)`
- [ ] Replaced all `SizedBox(height: 16)` → `SizedBox(height: AppSpacing.medium)`
- [ ] No more magic numbers in padding/spacing
- [ ] Layout still looks correct

---

### 🟣 Priority 5: Fix Date Formatting

**Goal:** Replace manual string building with `AppDateFormats`.

#### Find All Manual Date Formatting:
```bash
grep -rn ".toString()" lib/screens2/ | grep -i date
grep -rn "padLeft(2, '0')" lib/screens2/
```

#### Files to Fix:
- `lib/screens2/event_detail.dart` (DT1, DT2 TODOs)
- `lib/screens2/participant_detail.dart`
- Any other manual date formatting

#### Replacement:
```dart
// OLD:
'${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}'

// NEW:
AppDateFormats.formatDate(date)
```

**Checklist:**
- [ ] Imported `AppDateFormats` in all files
- [ ] Replaced all manual date string building
- [ ] Verified date format is consistent (dd.MM.yyyy)
- [ ] Handled null dates gracefully (shows 'N/A')

---

## Phase 2: Component Library (Week 3-4)

### Component 1: EmptyState Widget

**File:** `lib/screens2/widgets/empty_state.dart`

```dart
import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/design_system.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: AppSpacing.medium),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.large),
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**Checklist:**
- [ ] Created `EmptyState` widget
- [ ] Added to exports
- [ ] Replaced empty states in `ParticipantListScreen`
- [ ] Replaced empty states in `EventList`
- [ ] Replaced empty states in `EventDetail`
- [ ] Replaced empty states in `NewRecordPage`

---

### Component 2: LoadingIndicator Widget

**File:** `lib/screens2/widgets/loading_indicator.dart`

```dart
import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/design_system.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: AppSpacing.medium),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
```

**Checklist:**
- [ ] Created `LoadingIndicator` widget
- [ ] Replaced loading indicators in `EventList`
- [ ] Replaced loading indicators in `ParticipantListScreen`
- [ ] Replaced loading indicators in `ParticipantDetail`
- [ ] Replaced loading indicators in `CsvImportScreen`

---

## Phase 3: Screen Migration (Week 5-6)

### Screen-by-Screen Migration Checklist

For each screen, complete this checklist:

#### EventList (`event_list.dart`)
- [ ] Uses `AppSpacing` constants
- [ ] Uses `FilledButton` for add button
- [ ] Uses `EmptyState` component
- [ ] Uses `LoadingIndicator` component
- [ ] Uses `AppDateFormats` for dates
- [ ] Removed or implemented search button
- [ ] Added max width constraint

#### ParticipantListScreen (`participant_list_screen.dart`)
- [ ] Uses `AppSpacing` constants
- [ ] Uses Material 3 buttons
- [ ] Uses `EmptyState` component
- [ ] Uses `LoadingIndicator` component
- [ ] Added pull-to-refresh

#### EventDetail (`event_detail.dart`)
- [ ] Uses `AppSpacing` constants
- [ ] Uses `AppDateFormats` (removed DT1/DT2 manual formatting)
- [ ] Search field has proper layout (doesn't overflow)
- [ ] Uses `EmptyState` for no participants
- [ ] Added max width constraint

#### NewRecordPage (`new_record_page.dart`)
- [ ] Uses `AppSpacing` constants
- [ ] Participant info section responsive (doesn't squeeze)
- [ ] Uses `AppDateFormats`
- [ ] Form disabled state clear
- [ ] Print buttons properly positioned

#### EventRegistrationForm (`event_registration_form.dart`)
- [ ] Uses `AppSpacing` constants
- [ ] Uses `FilledButton` (not ElevatedButton)
- [ ] Uses `AppDateFormats`
- [ ] Form fields consistent with other forms

#### IntakeFormImproved (`intake_form_improved.dart`)
- [ ] Uses `AppSpacing` constants
- [ ] Max width appropriate
- [ ] Uses `ResponsiveFormGrid` if applicable

#### CsvImportScreen (`csv/import_screen.dart`)
- [ ] Uses `AppSpacing` constants
- [ ] Loading indicator properly sized
- [ ] Error messages clear

#### CsvReviewTable (`csv/table_overview_screen.dart`)
- [ ] Added mobile layout alternative
- [ ] Uses `AppSpacing` constants
- [ ] Uses theme colors

#### CsvImportSummaryScreen (`csv/summary_screen.dart`)
- [ ] Uses `AppSpacing` constants
- [ ] Export button implemented or hidden
- [ ] Success state enhanced

#### ParticipantDetail (`participant_detail.dart`)
- [ ] Uses `AppSpacing` constants
- [ ] Uses `AppDateFormats`
- [ ] Uses Material 3 buttons
- [ ] Action buttons don't overflow
- [ ] Added max width constraint

#### ParticipantEditPage (`participant_edit_page.dart`)
- [ ] Uses `AppSpacing` constants
- [ ] Removed duplicate save button
- [ ] Uses `OutlinedButton` for cancel
- [ ] Max width appropriate for form

#### PrintCenterPage (`print_ops2/print_center.dart`)
- [ ] Uses `AppSpacing` constants
- [ ] Feature cards have max width
- [ ] Disabled states clear

---

## Phase 4: Polish & Testing (Week 7-8)

### Accessibility Audit

For EVERY screen, verify:

- [ ] All `IconButton` widgets have `tooltip` parameter
- [ ] All interactive elements >= 44x44 dp
- [ ] Font sizes >= 12px (14px preferred)
- [ ] Color contrast meets WCAG AA standard
- [ ] All images have semantic labels

### Responsive Testing

Test EVERY screen at these widths:

- [ ] 375px (iPhone SE) - Mobile
- [ ] 768px (iPad) - Tablet
- [ ] 1024px (iPad Pro) - Large Tablet
- [ ] 1440px (Desktop) - Desktop
- [ ] 1920px (Large Desktop) - Large Desktop

### Visual Regression Testing

- [ ] Take screenshots of all screens at all breakpoints
- [ ] Compare with original screenshots
- [ ] Document intentional changes
- [ ] Fix unintentional changes

---

## Code Review Checklist

Use this checklist when reviewing UI code:

### Layout & Responsive
- [ ] Uses `LayoutBuilder` or `MediaQuery` for responsive layouts
- [ ] Multi-column layouts adapt to screen size
- [ ] Content has max width constraint on desktop
- [ ] No horizontal overflow on narrow screens

### Spacing & Sizing
- [ ] No hardcoded padding/margin numbers
- [ ] Uses `AppSpacing` constants
- [ ] Consistent spacing between related elements

### Colors & Theming
- [ ] No `Colors.blue.shade50` etc.
- [ ] Uses `Theme.of(context).colorScheme.xxx`
- [ ] Uses `Theme.of(context).textTheme.xxx`

### Components
- [ ] No `ElevatedButton` (uses Material 3 buttons)
- [ ] Empty states use `EmptyState` component
- [ ] Loading states use `LoadingIndicator` component
- [ ] Date formatting uses `AppDateFormats`

### Accessibility
- [ ] All `IconButton` widgets have tooltips
- [ ] Touch targets >= 44x44 dp
- [ ] Font sizes >= 12px

### Code Quality
- [ ] No duplicate widget trees (extracted to widgets)
- [ ] No `// TODO` comments without issue number
- [ ] No commented-out code
- [ ] No `Logger().i()` in production code

---

## Tracking Progress

### Progress Dashboard

Create a simple tracking file: `UI_MIGRATION_PROGRESS.md`

```markdown
# UI Migration Progress

## Phase 1: Critical Fixes
- [x] FileViewerScreen fixed
- [x] ParticipantRegistrationForm responsive
- [x] Buttons migrated to Material 3
- [x] Spacing constants created and applied
- [x] Date formatting standardized

## Phase 2: Component Library
- [ ] EmptyState component
- [ ] LoadingIndicator component
- [ ] ResponsiveFormGrid component

## Screens Migrated (0/16)
- [ ] EventList
- [ ] ParticipantListScreen
- [ ] EventDetail
- [ ] NewRecordPage
- [ ] EventRegistrationForm
- [ ] ParticipantRegistrationForm
- [ ] IntakeFormImproved
- [ ] CsvImportScreen
- [ ] CsvReviewTable
- [ ] CsvImportSummaryScreen
- [ ] ParticipantDetail
- [ ] ParticipantEditPage
- [ ] PrintCenterPage
- [ ] PersonAndModeFlowPage
- [ ] AppDrawer
- [ ] FileViewerScreen
```

---

## Tips for Success

### 1. Work in Small PRs
- Don't try to fix everything at once
- Each PR should be < 500 lines
- Focus on one screen or one pattern at a time

### 2. Test Continuously
- Test on real device after each change
- Use Flutter DevTools to inspect layout
- Check for console warnings/errors

### 3. Document Decisions
- Update `APP_DESIGN_FEEL.md` with notes
- Document any deviations from standards
- Keep track of what works and what doesn't

### 4. Ask for Feedback
- Share screenshots in PRs
- Get user feedback early
- Iterate based on feedback

---

**Last Updated:** 2025-11-06
**Version:** 1.0
