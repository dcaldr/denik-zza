# NewRecordPage Layout - Implemented
**Last Updated**: 2025-11-03  
**Status**: ✅ Implemented

---

## Current Layout (Implemented)

```
┌─────────────────────────────────────────────────────────────┐
│ 👤 Účastník [USES MOCKUPS !!]  │ 🔍 Vyhledat osobu      │ ← 3 rows
│ Jan Novák, 15 let ⓘ             │ [autocomplete______]   │
│ ⚠️ arašídy... 🚫 astma 💊 ibuprofen [⋯ +5]                │
├──────────────────────────────────────────────────────────────┤
│ 🕒 Historie úrazů                                          │ ← flex 1-2
│ [15:23] Odřenina kolena — Při fotbale...                  │
│ [Včera 10:15] Bolest hlavy — Po slunění...                │
├──────────────────────────────────────────────────────────────┤
│ ⏰ Čas záznamu [📄] [➕] [ℹ️ Způsobilost]     [Změnit]    │ ← Compact
│ 17. ledna 2025, 14:23                                      │
├──────────────────────────────────────────────────────────────┤
│ Nadpis * (povinné)                                         │ ← flex 5-7
│ [___________________________________________]              │
│ Popis úrazu              │ Poznámka                        │
│ ...                                                        │
└──────────────────────────────────────────────────────────────┘

       ↓ Click truncated health chip
       
╔════════════════════════════════════════════════════════════╗
║ [X]  Zdravotní informace                                  ║ ← Overlay
╠════════════════════════════════════════════════════════════╣
║ ⚠️ Alergie: arašídy, penicilín, aspirin, ibuprofén       ║
║                                                            ║
║ (Full text shown when chip clicked)                       ║
╚════════════════════════════════════════════════════════════╝
```

---

## Implementation Details

### Health Information Display ✅

**All health items shown inline as chips:**
- 🚨 Alergie (red) - allergies
- 🚫 Omezení (orange) - restrictions  
- 💊 Léky (blue) - medications

**6-Item Collapse Logic:**
- Shows first 6 items by default when >6 total
- Compact collapse button: `[⋯ +5]` (~50px vs old 180px)
- Button appears WITH health items (in same Wrap)
- Click to expand/collapse

**Truncation:**
- Each chip truncates at 30 characters
- Shows "..." if truncated
- Click chip → overlay with full text

### Age & Birthdate ✅

**Format**: `Jan Novák, 15 let ⓘ`
- Age calculated from `datumNarozeni`
- Info icon (ⓘ) clickable
- Shows full birthdate in dialog

### Print Icons ✅

**Location**: DateTime row (next to Změnit button)
- 📄 Full print - all participant records
- ➕ Append print - add to existing printout
- **Disabled** until record is saved
- TODO: Wire to `print_ops2/` services

### Způsobilost ✅

**Location**: DateTime row (with print icons)
- Blue info chip: `[ℹ️ Způsobilost]`
- Clickable to view medical clearance document
- TODO: Wire to FileViewerScreen

---

## Key Technical Details

### Files Modified
- `lib/screens2/new_record_page.dart` (1423 lines)
- `lib/screens2/widgets/dev_mock_data_badge.dart` (NEW - 73 lines)
- `test/new_record_page_test.dart` (295 lines)

### Key Methods
```dart
Widget _buildHealthInfoRow()                    // Shows health chips with collapse
Widget _buildCompactCollapseButton()            // Ultra-compact [⋯ +5] button
Widget _buildHealthChip()                       // Individual health chip with truncation
void _showHealthDetailOverlay()                 // Overlay for full text
void _showBirthdateInfo()                       // Birthdate dialog
void _showZpusobilostPlaceholder()              // TODO: Wire to FileViewerScreen
bool _canPrint()                                // Returns false until save tracking
```

### Mock Data (DevEnvironment)
- Test participant: Antonín Dvořák
- 11 health items: 1 alergie, 1 omezení, 8 léky
- Tests collapse button with >6 items

### Feature Contract Tests
Added tests to protect critical behaviors:
- Health items visibility when participant selected
- Print icons present in datetime row
- Dev badge visible
- Age with clickable info icon
- Layout overflow handling (narrow screens)

---

## TODO / Not Yet Wired

### Print Functionality
- [ ] Implement save tracking (`_recordSaved`, `_lastSavedRecordId`)
- [ ] Enable print buttons after successful save
- [ ] Wire `_printFullRecord()` to `print_ops2/` services
- [ ] Wire `_printAppendRecord()` to `print_ops2/` services
- [ ] Mark records as printed (`wasPrinted=true`)

### Způsobilost Viewer
- [ ] Replace `_showZpusobilostPlaceholder()` with FileViewerScreen
- [ ] Check `eligibleConfirmationPath` field
- [ ] Open JPG/PDF viewer for documents
- [ ] Handle missing file paths gracefully

### Test Improvements
- [ ] Add test with participant having >6 health items
- [ ] Test clicking truncated health chip shows overlay
- [ ] Test způsobilost chip appears when flag=true
- [ ] Fix overflow tests for narrow screens (expected to fail for now)

### Future Enhancements
- [ ] Flexible collapse logic (see TODO comment in code)
  - Option 1: LayoutBuilder for dynamic space calculation
  - Option 2: Adaptive rows (show what fits in 2 rows)
  - Option 3: Responsive thresholds (desktop vs mobile)
  - Option 4: User preference (remember expanded/collapsed state)

---

## Design Rationale

### Why 6-Item Collapse?
User feedback: "the collapsable logic you removed WAS supposed to stay!"
- Most participants have <6 health items
- Critical medical info visible by default (NOT hidden)
- Collapse optional for edge cases with many medications
- Compact button saves 130px vs old verbose design

### Why Compact Button Design?
- Old: `[▼ Zobrazit více (5 dalších)]` - 180px
- New: `[⋯ +5]` when collapsed, `[▲]` when expanded - 50px
- **3.6x space savings** while maintaining clarity

### Why Print Icons in DateTime Row?
User feedback: "won't it be unintuitive if hidden?"
- Fixed location = easy to find
- Disabled state shows feature exists (grayed out)
- Enabled after save = clear cause-effect relationship

### Why Health Items Always Visible?
Critical correction: "ui is missing all the medication allergies elements"
- Life-critical information for treatment decisions
- Cannot be hidden by default (dangerous oversight)
- First 6 items provide immediate context

---

## Reference

For historical planning discussions and workflow analysis, see:
- `docs/new-record-page-improvements-ARCHIVE.md` (original planning document)
