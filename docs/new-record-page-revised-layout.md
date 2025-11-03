# NewRecordPage Revised Layout - Space-Efficient Design
**Context**: User feedback - Use EXISTING vertical space, overlay for details  
**Date**: 2025-11-02

---

## User Feedback Summary

✅ **Approved**:
- Print icons in DateTime box (fixed location)
- Text labels for print buttons are fine

❌ **Rejected Original Proposal**:
- Health warning banners ABOVE Historie (adds vertical space)
- Always-visible full text warnings

✅ **Revised Approach**:
- Způsobilost: Button/icon that pops up file viewer (not always-visible banner)
- Use EXISTING vertical space in header and DateTime box
- Add birthdate display (was missing!)
- If health info text is long → expand OVER Historie (overlay), don't push down
- Make all text more compact overall

📱 **Mobile Responsive**:
- Use icon-only approach for now
- Add TODO: Review mobile layout after implementing
- Test on device and revisit if needed

---

## Revised Layout Mockup

### Current State (Before):
```
┌─────────────────────────────────────────────────────────────┐
│ 👤 Vybraná osoba (neuloženo)    │ 🔍 Vyhledat osobu      │ ← 2 rows
│ Jan Novák                        │ [autocomplete______]   │
├──────────────────────────────────────────────────────────────┤
│ 🕒 Historie úrazů                                          │ ← flex 1-2
│ [15:23] Odřenina kolena — Při fotbale...                  │
│ [Včera 10:15] Bolest hlavy — Po slunění...                │
├──────────────────────────────────────────────────────────────┤
│ ⏰ Čas záznamu                            [Změnit]         │ ← Large box
│ 17. ledna 2025, 14:23                                      │
├──────────────────────────────────────────────────────────────┤
│ Nadpis * (povinné)                                         │ ← flex 5-7
│ [___________________________________________]              │
│ Popis úrazu              │ Poznámka                        │
│ ...                                                        │
└──────────────────────────────────────────────────────────────┘
```

### Proposed State (After):
```
┌─────────────────────────────────────────────────────────────┐
│ 👤 Vybraná osoba (neuloženo)    │ 🔍 Vyhledat osobu      │ ← 3 rows
│ Jan Novák, 15 let (12.5.2010)   │ [autocomplete______]   │   (+1 row)
│ [⚠️] [🚫] [ℹ️]  ← click to expand│                        │
├──────────────────────────────────────────────────────────────┤
│ 🕒 Historie úrazů                                          │ ← flex 1-2
│ [15:23] Odřenina kolena — Při fotbale...                  │   (same)
│ [Včera 10:15] Bolest hlavy — Po slunění...                │
├──────────────────────────────────────────────────────────────┤
│ ⏰ Čas záznamu [📄] [➕]                   [Změnit]        │ ← Compact
│ 17. ledna 2025, 14:23                                      │   (same height)
├──────────────────────────────────────────────────────────────┤
│ Nadpis * (povinné)                                         │ ← flex 5-7
│ [___________________________________________]              │   (same)
│ Popis úrazu              │ Poznámka                        │
│ ...                                                        │
└──────────────────────────────────────────────────────────────┘

       ↓ Click warning icon [⚠️] or [🚫]
       
╔════════════════════════════════════════════════════════════╗
║ [X]  Zdravotní upozornění                                 ║ ← Overlay
╠════════════════════════════════════════════════════════════╣   positioned
║ ⚠️ Alergie: arašídy, penicilín, aspirin, ibuprofén       ║   OVER
║                                                            ║   Historie
║ 🚫 Omezení: epilepsie, nesmí na slunce po 12:00, musí    ║   section
║    pít každou hodinu, zvracení - ihned kontaktovat rodiče║
║                                                            ║
║ [ℹ️ Zobrazit způsobilost]  ← Button opens file viewer     ║
╚════════════════════════════════════════════════════════════╝
```

**Net Vertical Space Change**: +1 row (~28px) in header only  
**Key Feature**: Overlay uses z-index stacking, no layout reflow

---

## Design Decisions

### 1. Birthdate Display Format ✅ DECIDED

**User preference**: Option C with modification
```
Jan Novák, 15 let ⓘ  ← click/hover shows "(12.5.2010)"
```

**Decision**: 
- Default: Show age only ("15 let")
- Interaction: Click or hover on ⓘ icon shows full birthdate
- Mobile: Click works (hover limitation acceptable)

---

### 2. Health Info Display ✅ FINAL APPROACH

**Requirement**: First glance visibility for critical info (alergie, omezení, léky)

**Layout**:
```
👤 Jan Novák, 15 let ⓘ
⚠️ arašídy, penicilín...  ← Click to expand if truncated
🚫 epilepsie              ← Fits completely
💊 ibalgin, paralen       ← Léky also inline
[ℹ️] způsobilost          ← Info icon, opens document viewer
```

**Truncation logic**:
- **≤30 chars**: Show completely inline
- **>30 chars**: Show first 30 chars + "..." + clickable to expand overlay
- **Note**: May adjust to 40 chars after visual testing
- **Overlay**: Shows FULL text when truncated text clicked
- **Způsobilost**: Neutral info icon (blue), opens JPG/PDF viewer

---

### 3. Overlay Dismiss Behavior ✅ DECIDED

**User preference**: Similar to Historie úrazů interaction pattern

**Decision**: 
- Tap on truncated text → expands overlay (like tap-to-expand in Historie)
- Tap again or tap outside → collapses overlay
- Close button [X] also available

**TODO**: Test both approaches during implementation:
- A) Tap-to-toggle (like Histoire items)
- B) Tap outside + close button (traditional overlay)
- Choose based on usability testing

---

### 4. Způsobilost File Viewer ✅ CLARIFIED

**User clarification**: 
- Způsobilost is NOT a warning
- It's just a reference to view previously imported paper (JPG/PDF)
- Like "reverse printing" - shows more info for the case

**Display logic**:
- Show [ℹ️] info icon (neutral blue, NOT warning red)
- Click → Opens file viewer dialog with imported JPG/PDF
- Uses existing FileViewerScreen widget
- Simple document viewer, no complex logic

**Code kept in document for reference** (implementation later)

---

## Implementation Details

### Phase 1: Header Redesign

#### Add Birthdate + Warning Icons
```dart
// In ParticipantCard section:
Container(
  padding: EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: Colors.grey.shade50,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey.shade300),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Row 1: Label + Unsaved badge
      Row(
        children: [
          Icon(Icons.person, size: 13, color: Colors.blue.shade600),
          SizedBox(width: 6),
          Text('Vybraná osoba', style: TextStyle(fontSize: 11, ...)),
          if (_hasUnsavedChanges) ...[
            SizedBox(width: 6),
            _buildUnsavedBadge(),
          ],
        ],
      ),
      SizedBox(height: 4),
      
      // Row 2: Name + Age + Birthdate
      if (_selectedParticipant != null) ...[
        Text(
          _formatParticipantNameWithAge(_selectedParticipant!),
          style: TextStyle(
            fontSize: 14, // Reduced from 15-16 (compactness)
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        
        // Row 3: Warning icon badges
        Row(
          children: [
            if (_hasAllergies()) _buildWarningIcon(
              icon: Icons.warning_amber,
              color: Colors.red,
              tooltip: 'Alergie',
              onTap: () => _showHealthWarningOverlay(WarningType.allergy),
            ),
            if (_hasRestrictions()) _buildWarningIcon(
              icon: Icons.block,
              color: Colors.orange,
              tooltip: 'Omezení',
              onTap: () => _showHealthWarningOverlay(WarningType.restriction),
            ),
            if (_hasZpusobilost()) _buildWarningIcon(
              icon: Icons.info_outline,
              color: Colors.blue,
              tooltip: 'Způsobilost',
              onTap: () => _showZpusobilostPopup(),
            ),
          ],
        ),
      ] else ...[
        Text('Vyberte účastníka...', style: TextStyle(fontSize: 14, ...)),
      ],
    ],
  ),
)
```

#### Helper Methods
```dart
/// Formats participant name with age and birthdate
String _formatParticipantNameWithAge(MemoryOsoba participant) {
  final name = '${participant.jmeno} ${participant.prijmeni}';
  
  if (participant.datumNarozeni == null) {
    return name; // No birthdate available
  }
  
  final age = _calculateAge(participant.datumNarozeni!);
  final dateStr = _formatBirthdate(participant.datumNarozeni!);
  
  // TODO: Decide format with user
  // Option A: "Jan Novák, 15 let"
  // Option B: "Jan Novák, 15 let (12.5.2010)"
  return '$name, $age let ($dateStr)'; // Option B for now
}

/// Calculates age from birthdate
int _calculateAge(DateTime birthDate) {
  final today = DateTime.now();
  int age = today.year - birthDate.year;
  
  // Adjust if birthday hasn't occurred yet this year
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  
  return age;
}

/// Formats birthdate as "12.5.2010"
String _formatBirthdate(DateTime date) {
  return '${date.day}.${date.month}.${date.year}';
}

/// Checks if participant has allergies
bool _hasAllergies() {
  return _selectedParticipant?.alergie != null &&
         _selectedParticipant!.alergie!.isNotEmpty;
}

/// Checks if participant has restrictions
bool _hasRestrictions() {
  return _selectedParticipant?.omezeni != null &&
         _selectedParticipant!.omezeni!.isNotEmpty;
}

/// Checks if participant has způsobilost info
bool _hasZpusobilost() {
  return _selectedParticipant?.zpusobilost != null;
}

/// Builds warning icon button
Widget _buildWarningIcon({
  required IconData icon,
  required Color color,
  required String tooltip,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: EdgeInsets.only(right: 6),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    ),
  );
}
```

---

### Phase 2: Overlay Mechanism

#### Stack + Positioned Overlay
```dart
// Wrap the Column containing Historie section in Stack:
Stack(
  children: [
    // Main layout (existing Column)
    Column(
      children: [
        _buildParticipantSelection(), // Header with warning icons
        SizedBox(height: spacing),
        _buildHistorieSection(),       // Histoire úrazů
        SizedBox(height: spacing),
        _buildFormSection(),           // DateTime + Form fields
      ],
    ),
    
    // Overlay (shown conditionally)
    if (_showHealthWarningOverlay)
      _buildHealthWarningOverlayWidget(),
  ],
)
```

#### Overlay Widget
```dart
Widget _buildHealthWarningOverlayWidget() {
  return Positioned(
    top: _getHistoireTopPosition(), // Calculate position dynamically
    left: 16,
    right: 16,
    child: Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.health_and_safety, size: 20, color: Colors.grey.shade700),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Zdravotní upozornění',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  IconButton(
                    key: Key('health_overlay_close_button'),
                    icon: Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _showHealthWarningOverlay = false),
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Content (scrollable if long)
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Allergy section
                    if (_hasAllergies()) ...[
                      _buildOverlaySection(
                        icon: Icons.warning_amber,
                        iconColor: Colors.red,
                        title: 'Alergie',
                        content: _selectedParticipant!.alergie!,
                      ),
                      SizedBox(height: 8),
                    ],
                    
                    // Restrictions section
                    if (_hasRestrictions()) ...[
                      _buildOverlaySection(
                        icon: Icons.block,
                        iconColor: Colors.orange,
                        title: 'Omezení',
                        content: _selectedParticipant!.omezeni!,
                      ),
                      SizedBox(height: 8),
                    ],
                    
                    // Způsobilost button
                    if (_hasZpusobilost()) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          key: Key('health_overlay_zpusobilost_button'),
                          icon: Icon(Icons.info_outline, size: 18),
                          label: Text('Zobrazit způsobilost'),
                          onPressed: _showZpusobilostPopup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: Colors.blue.shade900,
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildOverlaySection({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String content,
}) {
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: iconColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: iconColor.shade900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

#### Position Calculation (Dynamic)
```dart
// Use GlobalKey to get Histoire section position
final GlobalKey _histoireKey = GlobalKey();

double _getHistoireTopPosition() {
  final RenderBox? renderBox = _histoireKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return 100; // Fallback
  
  final position = renderBox.localToGlobal(Offset.zero);
  return position.dy - 50; // Slightly above Histoire section
}

// Assign key to Histoire container:
Container(
  key: _histoireKey,
  child: _buildHistorieSection(),
)
```

---

### Phase 3: Print Icons in DateTime Box

```dart
// Modify existing DateTime container:
Container(
  padding: EdgeInsets.all(12), // Reduced from 16 (compactness)
  decoration: BoxDecoration(
    color: Colors.blue.shade50.withOpacity(0.3),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.blue.shade200.withOpacity(0.5)),
  ),
  child: Row(
    children: [
      // Icon
      Container(
        padding: EdgeInsets.all(6), // Reduced from 8
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.schedule, color: Colors.blue.shade700, size: 16),
      ),
      SizedBox(width: 10), // Reduced from 12
      
      // DateTime text
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Čas záznamu', style: TextStyle(fontSize: 11, ...)), // Reduced from 12-13
            SizedBox(height: 2),
            Text(_formatSelectedDateTime(), style: TextStyle(fontSize: 13, ...)), // Reduced from 14-15
          ],
        ),
      ),
      
      // Print icons (NEW)
      if (_recordSaved) ...[
        IconButton(
          key: Key('NewRecordPage_print_full_button'),
          icon: Icon(Icons.print),
          iconSize: 20,
          color: Colors.blue.shade700,
          tooltip: 'Tisknout vše',
          onPressed: _printFullRecord,
          padding: EdgeInsets.all(6),
          constraints: BoxConstraints(),
        ),
        SizedBox(width: 4),
        IconButton(
          key: Key('NewRecordPage_print_append_button'),
          icon: Icon(Icons.add_box),
          iconSize: 20,
          color: Colors.blue.shade700,
          tooltip: 'Přidat k tisku',
          onPressed: _printAppendRecord,
          padding: EdgeInsets.all(6),
          constraints: BoxConstraints(),
        ),
      ] else ...[
        // Disabled state (grayed out)
        Icon(Icons.print, size: 20, color: Colors.grey.shade400),
        SizedBox(width: 4),
        Icon(Icons.add_box, size: 20, color: Colors.grey.shade400),
      ],
      
      SizedBox(width: 8),
      
      // Změnit button
      FilledButton.tonal(
        key: Key('datetime_change_button'),
        onPressed: _selectedParticipant != null ? _selectDateTime : null,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced
          minimumSize: Size.zero,
        ),
        child: Text('Změnit', style: TextStyle(fontSize: 11)), // Reduced from 12-13
      ),
    ],
  ),
)
```

#### Print Methods (Wiring to print_ops2/)
```dart
// State variables
bool _recordSaved = false;
int? _lastSavedRecordId;

// After successful save in _saveRecord():
setState(() {
  _recordSaved = true;
  _lastSavedRecordId = newRecordId;
  _hasUnsavedChanges = false;
});

// Reset when participant changes:
void _onParticipantSelected(MemoryOsoba person) async {
  setState(() {
    _recordSaved = false;
    _lastSavedRecordId = null;
    // ... existing logic
  });
}

// Print methods:
Future<void> _printFullRecord() async {
  if (_lastSavedRecordId == null || _selectedParticipant == null) return;
  
  try {
    // Use existing print service
    final template = GeneratePdfTemplate();
    
    // Fetch participant data
    final records = await _db.getRecordsByParticipantID(_selectedParticipant!.id);
    final omezeni = await _db.getOmezeniByParticipantID(_selectedParticipant!.id);
    final leky = await _db.getLekyByParticipantID(_selectedParticipant!.id);
    
    // Generate PDF pages
    final pages = await template.getPdfPages(
      osoba: _selectedParticipant!,
      omezeniList: omezeni,
      lekList: leky,
      zaznamList: records,
    );
    
    // TODO: Send to printer or save PDF
    // (Existing print service handles this - need to research exact API)
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tisknu celý záznam...')),
    );
  } catch (e) {
    AppLogger.l.e('Print full record failed', error: e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chyba při tisku: $e')),
    );
  }
}

Future<void> _printAppendRecord() async {
  if (_lastSavedRecordId == null || _selectedParticipant == null) return;
  
  try {
    // Use append mode (only unprinted records)
    final template = GeneratePdfTemplate();
    
    // Check if append is possible
    template.osoba = _selectedParticipant;
    
    if (!template.canAppend()) {
      // Show warning: must print full instead
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nelze přidat - je třeba vytisknout celý záznam'),
          action: SnackBarAction(
            label: 'Tisknout',
            onPressed: _printFullRecord,
          ),
        ),
      );
      return;
    }
    
    // TODO: Generate append PDF and print
    // (Need to research append API in print_ops2/)
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Přidávám záznam k tisku...')),
    );
  } catch (e) {
    AppLogger.l.e('Print append record failed', error: e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chyba při tisku: $e')),
    );
  }
}
```

---

### Phase 4: Compactness Pass

#### Font Size Reduction
```dart
// Current → Proposed (all -1px)
- Participant name: 15-16 → 14-15
- Section labels: 12-13 → 11-12
- Form field text: 14-15 → 13-14
- Button text: 12-13 → 11-12
- DateTime display: 14-15 → 13-14
- Icons: Keep same (16-20px for touch targets)
```

#### Padding/Spacing Reduction
```dart
// High-impact reductions:
- Container padding: 16px → 12px (DateTime box, form containers)
- SizedBox height: 12px → 8px (between sections)
- Row spacing: 12px → 8px (icon to text gaps)
- Card padding: 10px → 8px (compact cards)

// Keep for accessibility:
- Button padding: minimum 8px vertical (touch target 44x44)
- Icon button size: minimum 40x40 (touch target)
- Text field padding: minimum 12px horizontal (readability)
```

---

## Technical Research Findings

### MemoryOsoba Structure
```dart
class MemoryOsoba {
  DateTime? datumNarozeni; // ✅ Confirmed: nullable
  String? alergie;         // ✅ Unlimited text
  String? omezeni;         // ✅ Unlimited text
  bool? zpusobilost;       // ✅ True/false/null
  String? eligibleConfirmationPath; // ✅ File path (PNG/JPG/PDF)
}
```

### Print Service API (print_ops2/)
```dart
// Full print (all records)
GeneratePdfTemplate.getPdfPages(
  osoba: MemoryOsoba,
  omezeniList: List<MemoryOmezeni>?,
  lekList: List<MemoryLek>?,
  zaznamList: List<MemoryZaznam>?,
) -> Future<List<pw.Page>>

// Append mode (unprinted records only)
template.osoba = participant;
template.canAppend() -> bool

// Print flags
PrintCenterService.setRecordPrintedFlag(recordId, true) -> Future<bool>
PrintCenterService.setParticipantPrintedFlag(participantId, true) -> Future<bool>
```

**TODO**: Research how to actually send PDF to printer (API exists but need to trace full flow)

---

## Design Decisions Summary

### ✅ Finalized:

1. **Birthdate**: "15 let ⓘ" (hover/click for full date)
2. **Health info**: Alergie, omezení, léky ALL inline with truncation
   - **≤30 chars**: Show all
   - **>30 chars**: Show "..." + click to expand
   - **Note**: May adjust to 40 chars after testing
3. **Overlay dismiss**: Test both approaches (tap-to-toggle vs tap-outside)
4. **Způsobilost**: Neutral info icon [ℹ️], opens JPG/PDF viewer
5. **Print icons**: [📄] [➕] in DateTime box

### 🎯 Implementation Strategy:

- **Small incremental steps** with verification after each
- **Flexible layout** as primary goal
- Wait for user confirmation between changes

---

## Small-Step Implementation Plan

**Strategy**: One small change at a time, wait for user verification

### Change 1: Add birthdate display ⏸️ NEXT
- Add "15 let ⓘ" to participant name
- Implement age calculation helper
- Add hover/click for full date
- **VERIFY** with user before continuing

### Change 2: Add alergie inline (if exists) ⏸️ WAIT
- Show truncated text (≤30 chars)
- Add "..." if longer
- **VERIFY** with user before continuing

### Change 3: Add omezení inline (if exists) ⏸️ WAIT
- Same truncation logic
- **VERIFY** with user before continuing

### Change 4: Add léky inline (if exists) ⏸️ WAIT
- Same truncation logic
- **VERIFY** with user before continuing

### Change 5: Add způsobilost icon ⏸️ WAIT
- Neutral [ℹ️] info icon
- **VERIFY** with user before continuing

### Change 6: Wire truncated text to overlay ⏸️ WAIT
- Click "..." expands full text
- Test tap-to-toggle vs tap-outside
- **VERIFY** with user before continuing

### Change 7: Add print icons to DateTime box ⏸️ WAIT
- [📄] [➕] icons (disabled initially)
- **VERIFY** with user before continuing

### Change 8: Wire print functionality ⏸️ WAIT
- Enable after save
- Connect to print_ops2/
- **VERIFY** with user

### Change 9: Compactness pass ⏸️ WAIT
- Reduce font sizes (-1px)
- Reduce padding
- **VERIFY** with user

**CRITICAL**: Stop and wait for user confirmation after EACH change above

---

## Next Steps

**Immediate**: Need user decisions on:
1. Birthdate format
2. Icon behavior (single vs multiple overlays)
3. Overlay dismiss method
4. Způsobilost display logic

**After decisions**: Create implementation plan for Round 1 (layout changes)

**Testing**: Add tests progressively with each round (no big-bang testing)

---

## Mobile Responsive TODO

**Note to add after implementation**:
```markdown
## Mobile Layout Review TODO

After implementing space-efficient layout on desktop:

1. **Test on actual mobile device** (not just emulator)
   - Screen size: ≤600px width
   - Outdoor lighting conditions (bright sun)
   - Touch target sizes (minimum 44x44)

2. **Evaluate icon-only approach**:
   - Are [⚠️] [🚫] [ℹ️] badges visible enough?
   - Does overlay work well on small screen?
   - Is birthdate text readable at 14px?

3. **Consider alternatives if needed**:
   - Collapse header to single row with dropdown
   - Bottom sheet instead of overlay for warnings
   - Larger touch targets for icons (48x48)

4. **Document final decision**:
   - Keep same layout, or
   - Create separate mobile layout variant

Location: Add to `docs/mobile-responsive-notes.md` after Round 5 complete
```
