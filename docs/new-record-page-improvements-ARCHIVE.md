# New Record Page - Planned Improvements

**Context**: Nový záznam úrazu (New Injury Record) page for camp/event health records
**User**: Camp Health Nurse (zdravotník/ošetřovatel) - NOT full doctor, basic first aid trained
**Last Updated**: 2025-11-02 (REVISED with camp nurse context corrections)

**⚠️ NOTE**: This document contains background context and original planning.  
**For finalized implementation plan**, see: `new-record-page-revised-layout.md`

## Background Discussion Points

### User Workflow Context - CORRECTED
**Camp Health Nurse (Zdravotník at Tábory)**:
- Basic first aid training, not full medical degree
- Works at camp with 30-100+ children over 1-2 weeks
- Handles ROUTINE injuries: cuts, scrapes, headaches, stomach aches, tick removal, sunburn
- Handles EMERGENCIES: stabilizes patient, but **someone else calls parents/ambulance**
  - Nurse focuses on treatment, not coordination during emergencies
  - Parent contact NOT urgent during record creation
- References doctor's medical clearance (způsobilost) when unsure about conditions
- Documents everything for legal/insurance purposes
- Needs to print records for paper archive (full initial print + append mode)
- Works in outdoor, sometimes remote settings with basic facilities

### Current Page Structure
```
┌─────────────────────────────────────────────────────┐
│ Účastník: [Name] - [Search Button]                 │
├─────────────────────────────────────────────────────┤
│ Historie úrazů (compact, flex: 1-2)                 │
│  - [Time] Title — Description...                    │
│  - (tap to expand for full details)                 │
├─────────────────────────────────────────────────────┤
│ Čas záznamu: [Current DateTime] [Change Button]    │
├─────────────────────────────────────────────────────┤
│ Nadpis * (povinné): [Input Field]                  │
├─────────────────────────────────────────────────────┤
│ Popis úrazu (80%)  │  Poznámka (20%)               │
│ [Large Text Area]  │  [Sticky Note Area]           │
├─────────────────────────────────────────────────────┤
│ [Uložit do deníku] [Zavřít]                        │
└─────────────────────────────────────────────────────┘
```

## Improvement Checklist

### 1. Quick Print Actions (Priority: MEDIUM)
- [ ] **Add print action buttons - PERSISTENT AFTER SAVE**
  - **Location**: Expandable section below save button (appears and stays visible after first save)
  - **Rationale**: Discoverability + workflow clarity
    - User concern: "won't it be unintuitive if hidden?"
    - Solution: Section expands after save, stays visible for session
    - Clear cause-effect: save unlocks printing options
  - **Actions needed**:
    - [ ] Quick Print (full participant record with all existing records)
    - [ ] Append Print (print only new records since last print)
  - **Proposed UI**:
    ```
    Bottom of form:
    [Uložit do deníku]
    
    [After first save, this section appears and STAYS visible:]
    ┌──────────────────────────────────────────────────────────┐
    │ ✅ Záznam uložen!                                        │
    │ Tisknout: [📄 Vše] [➕ Přidat]                          │
    │           ↑full    ↑append only new                     │
    └──────────────────────────────────────────────────────────┘
    
    [Zavřít]
    ```
  - **Icon suggestions**:
    - Full Print: `Icons.print` (📄) - standard print icon
    - Append Print: `Icons.note_add` (➕) - add to existing printout
  - **Implementation notes**:
    - Section remains visible after first save (doesn't auto-hide)
    - Allows multiple saves then batch print
    - No confusing disabled buttons - section simply doesn't exist until needed
    - Print buttons also accessible from participant list view

### 2. Historie úrazů Timestamp Display (Priority: MEDIUM)
**Current**: Shows only time `[14:23]`
**Problem**: On multi-day camps, paramedic can't tell which day the injury occurred

**Option A: Full Timestamp**
```
[21.12. 14:23] Title — Description...
[20.12. 09:15] Title — Description...
```
**Pros**: Clear, unambiguous, consistent format
**Cons**: Takes more horizontal space in compact view

**Option B: Relative Time**
```
[Dnes 14:23] Title — Description...
[-1 den 09:15] Title — Description...
[-2 dny 18:30] Title — Description...
```
**Pros**: Easier to parse "how recent", feels more natural
**Cons**: "Dnes" becomes ambiguous after midnight, localization complexity

**Option C: Smart Hybrid**
```
[14:23] Title — Description...           (today's records)
[Včera 09:15] Title — Description...      (yesterday)
[20.12. 18:30] Title — Description...     (older records)
```
**Pros**: Best of both worlds - compact for recent, clear for old
**Cons**: More complex logic

**Recommendation**: **Option C (Smart Hybrid)** - provides context without clutter

**Refined Format**:
```
[14:23] Bolest hlavy — ...          ← Today (current date implied)
[Včera 09:15] Odřenina — ...        ← Yesterday
[19.12. 18:30] Zánět — ...          ← 2+ days ago (full date)
```

**Edge Case Handling**:
- Use calendar date comparison, not 24-hour rolling window
- "Dnes" is implicit (just show time) to reduce redundancy
- "Včera" is explicit and helpful for recent history
- Older records show full date for legal documentation needs

**Implementation Details**:
- [ ] Modify `RecordListItem` in `record_list_widget.dart`
- [ ] Add date comparison helper function:
  ```dart
  String formatRecordTimestamp(DateTime recordTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(recordTime.year, recordTime.month, recordTime.day);
    final difference = today.difference(recordDate).inDays;
    
    if (difference == 0) {
      // Today - just show time
      return DateFormat('HH:mm').format(recordTime);
    } else if (difference == 1) {
      // Yesterday - show "Včera" + time
      return 'Včera ${DateFormat('HH:mm').format(recordTime)}';
    } else {
      // Older - show full date + time
      return DateFormat('d.M. HH:mm').format(recordTime);
    }
  }
  ```
- [ ] Update timestamp formatting in compact view
- [ ] Ensure expanded view always shows full date+time for clarity

### 3. Participant Health Information Display (Priority: HIGH - NEEDS DESIGN)

#### Current Implementation
- Participant name shown at top
- No health details visible on new record page
- User must remember or check elsewhere

#### Critical Health Information Available in Database
From `Participants` table and `MemoryOsoba`:
1. **Alergie** (Allergies) - `alergie: String?`
2. **Omezení** (Restrictions/Limitations) - `omezeni: String?`
3. **Způsobilost** (Eligibility/Medical Clearance) - `prisel: bool`, `zpusobilost: bool?`
4. **Pojišťovna** (Insurance Company) - `insuranceCompanyFK`
5. **Rodné číslo** (Birth Number) - for identification
6. **Datum narození** (Birth Date) - for age calculation
7. **Poznámka** (General Note) - already displayed in side panel

#### Discussion: What to Display and How?

**Critical Questions**:
1. **What information is immediately life-critical?**
   - Allergies (CRITICAL - could be life-threatening)
   - Restrictions/Limitations (HIGH - affects treatment decisions)
   - Age (MEDIUM - affects dosages, treatment approaches)

2. **What information is administratively needed?**
   - Insurance (needed for documentation, not urgent)
   - Medical clearance status (already verified at intake)
   - Birth number (administrative ID, not urgent)

3. **What's the cognitive load during emergency?**
   - Paramedic is stressed, needs clear visual hierarchy
   - Too much info = information overload
   - Too little info = dangerous omissions

#### Design Options

**Option 1: Compact Alert Banner (Always Visible)**
```
┌─────────────────────────────────────────────────────┐
│ Účastník: Antonín Dvořák [Search]                  │
│ ⚠️ Alergie: arašídy, penicilín  🚫 Omezení: astma   │  ← New
├─────────────────────────────────────────────────────┤
```
**Pros**: Always visible, catches attention, color-coded (red/yellow)
**Cons**: Takes vertical space, may be empty for healthy participants

**Option 2: Expandable Health Details Panel**
```
┌─────────────────────────────────────────────────────┐
│ Účastník: Antonín Dvořák [Search] [▼ Zdravotní info] │
│   [When expanded:]                                   │
│   • Alergie: arašídy, penicilín                     │
│   • Omezení: astma                                  │
│   • Věk: 12 let (nar. 15.3.2013)                    │
│   • Pojišťovna: VZP                                 │
├─────────────────────────────────────────────────────┤
```
**Pros**: Doesn't clutter interface, all info available on demand
**Cons**: May be forgotten in emergency (out of sight, out of mind)

**Option 3: Smart Conditional Display**
```
┌─────────────────────────────────────────────────────┐
│ Účastník: Antonín Dvořák [Search]                  │
│ ⚠️ POZOR: Alergie na arašídy, penicilín!           │  ← Only if allergies exist
│ ℹ️ Omezení: astma                                   │  ← Only if restrictions exist
├─────────────────────────────────────────────────────┤
```
**Pros**: Shows only what matters, draws attention to problems
**Cons**: Inconsistent UI (varies per participant)

**Option 4: Icon-Based Quick Reference**
```
┌─────────────────────────────────────────────────────┐
│ Účastník: Antonín Dvořák [🔍] [⚠️] [ℹ️] [📋]      │
│             Search      Allergies Restrictions Details
│ [On hover/tap shows tooltip with details]           │
├─────────────────────────────────────────────────────┤
```
**Pros**: Compact, scalable, visual
**Cons**: Requires interaction, may not be obvious

#### Proposed Solution: **Camp Nurse Optimized Layout**

```
┌──────────────────────────────────────────────────────────────┐
│ Účastník: [Antonín Dvořák • 12 let (15.3.2013)] [🔍]      │
│           └─ Clickable link to ParticipantDetailPage       │
├──────────────────────────────────────────────────────────────┤
│ ⚠️ ALERGIE: arašídy, penicilín, aspirin                    │ ← Red/orange bg (if present)
│ 🚫 OMEZENÍ: astma, nesmí běhat na dlouhé vzdálenosti       │ ← Yellow bg (if present)
│ ℹ️ Způsobilý s podmínkou: užívat lék XYZ ráno/večer       │ ← Blue bg (if conditional)
│    └─ Click for full způsobilost details                   │
└──────────────────────────────────────────────────────────────┘
```

**Rationale** (based on camp nurse workflow corrections):
- **Participant Name = Clickable Link**: Opens ParticipantDetailPage
  - Contains: full contact info (parent phone/email), insurance, rodné číslo
  - Contains: complete medical history, all injury records, způsobilost form
  - Contains: editable poznámka, attendance, medication schedule
  - Keeps NewRecordPage clean, deep details available when needed
  
- **Allergies & Restrictions**: ALWAYS visible when present
  - Critical for treatment decisions (what can/cannot give, do)
  - Uses color AND icons AND text (accessibility)
  - High contrast backgrounds for instant recognition
  
- **Age + Birth Date**: Both shown for quick reference
  - Age: Mental reference for approach
  - Birth date: Context for dosages, developmental stage
  - User confirmed this format is good
  
- **Způsobilost Status**: Brief indicator with click-through
  - Shows: "✓ Způsobilý" (clear) or "ℹ️ Způsobilý s podmínkou: ..." (conditional)
  - Nurse needs to reference doctor-provided clearance information
  - NOT just administrative - contains medical conditions from doctor
  - Click opens ParticipantDetailPage with full způsobilost form/scan
  
- **Parent Contact REMOVED from here**: 
  - In true emergencies: someone else calls while nurse treats
  - Available in ParticipantDetailPage when needed
  - Not urgent during record creation workflow
  
- **Administrative Details**: All in ParticipantDetailPage
  - Insurance, birth number, full history grouped together
  - Accessed via clickable participant name

### 4. Implementation Tasks

#### Task 4.1: Print Action Buttons
- [ ] Research best placement (near datetime vs floating action button)
- [ ] Add icons to UI
- [ ] Wire up to existing print services in `print_ops2/`
- [ ] Add button states (enabled after save, disabled before)
- [ ] Add confirmation dialogs if needed
- [ ] Test with real printer workflow

#### Task 4.2: Historie Timestamp Enhancement
- [ ] Create date comparison helper function
- [ ] Update `RecordListItem._buildCompactView()` in `record_list_widget.dart`
- [ ] Add logic for "Dnes", "Včera", or full date
- [ ] Ensure expanded view always shows full timestamp
- [ ] Update tests to cover new timestamp formats

#### Task 4.3: Participant Header with Clickable Link (Priority HIGH)
- [ ] **Make participant name clickable/tappable**:
  - Link to ParticipantDetailPage
  - Visual indicator: underline, blue color, or [→] icon
  - Shows full details: contact, insurance, complete history, způsobilost form
- [ ] **Create/enhance ParticipantDetailPage**:
  - Section: Demographics (name, birth date, age, address, rodné číslo)
  - Section: Parent Contact (jméno, telefon, email with [Call] [Copy] buttons)
  - Section: Insurance (pojišťovna name, number)
  - Section: Medical (allergies, restrictions, způsobilost form/scan, poznámka)
  - Section: Complete Injury History (all records for this participant)
  - Section: Attendance/Participation tracking (if applicable)
  - Make editable where appropriate (poznámka, contact info)

#### Task 4.4: Health Information Display (CRITICAL - Priority HIGH)
- [ ] **Design phase**: Finalize exact layout (create mockup)
- [ ] **Create health warnings widget** (conditional rendering):
  ```dart
  Widget _buildHealthWarnings(MemoryOsoba participant) {
    return Column(
      children: [
        if (participant.alergie?.isNotEmpty ?? false)
          Container(
            color: Colors.red.shade50,
            padding: EdgeInsets.all(8),
            child: Row([
              Icon(Icons.warning_amber, color: Colors.red),
              SizedBox(width: 8),
              Expanded(child: Text('ALERGIE: ${participant.alergie}')),
            ]),
          ),
        if (participant.omezeni?.isNotEmpty ?? false)
          Container(
            color: Colors.orange.shade50,
            padding: EdgeInsets.all(8),
            child: Row([
              Icon(Icons.block, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(child: Text('OMEZENÍ: ${participant.omezeni}')),
            ]),
          ),
        // NEW: Způsobilost status indicator
        if (participant.zpusobilost == false || 
            (participant.zpusobilostPodminka?.isNotEmpty ?? false))
          InkWell(
            onTap: () => Navigator.push(/* ParticipantDetailPage */),
            child: Container(
              color: Colors.blue.shade50,
              padding: EdgeInsets.all(8),
              child: Row([
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(child: Text(
                  participant.zpusobilost == false 
                    ? '⚠️ Nezpůsobilý - viz detail'
                    : 'ℹ️ Způsobilý s podmínkou: ${participant.zpusobilostPodminka}'
                )),
                Icon(Icons.arrow_forward_ios, size: 16),
              ]),
            ),
          ),
      ],
    );
  }
  ```
  **Note**: Assuming database has field for způsobilost conditions - may need schema update
- [ ] **Extend `_onParticipantSelected()`** to load and display:
  - Age calculation from `datumNarozeni`
  - Allergy information
  - Restrictions/limitations
  - Způsobilost status (zpusobilost boolean and podmínka text)
  - Make participant name clickable/tappable
- [ ] **Remove expandable administrative panel from NewRecordPage**:
  - All administrative details moved to ParticipantDetailPage
  - Accessed via clickable participant name
  - Keeps NewRecordPage focused on injury documentation
- [ ] **Add age calculation helper**:
  ```dart
  int? calculateAge(DateTime? birthDate) {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  ```
- [ ] **Handle empty states**:
  - If no allergies: Show subtle "✓ Žádné známé alergie" OR hide section
  - If no restrictions: Hide section (don't show unnecessary positive messages)
- [ ] **Implement text overflow handling**:
  - Long allergy lists: Show first 3, then "... a další X"
  - Expandable on tap for full text
- [ ] **Update tests**:
  - Test with participant with allergies only
  - Test with participant with restrictions only
  - Test with participant with both
  - Test with participant with neither
  - Test with very long text (overflow scenarios)
  - Test age calculation with edge cases (leap years, today's birthday)
- [ ] **Verify accessibility** (WCAG compliance):
  - Screen readers announce warnings with urgency
  - Color is NOT the only indicator (icon + text required)
  - High contrast ratios (4.5:1 minimum for text)
  - Touch targets minimum 44x44 dp for buttons

#### Task 4.4: Documentation
- [ ] Document new widget components
- [ ] Update user story documentation
- [ ] Add screenshots to docs
- [ ] Document print workflow integration

## Technical Notes for Future AI/Developer

### Key Files
- **Main page**: `lib/screens2/new_record_page.dart` (967 lines)
- **Record list widget**: `lib/screens2/record_list_widget.dart` (~300 lines)
- **Database models**: `lib/database/in_memory_structures_tmp/` (MemoryOsoba, MemoryZaznam)
- **Print services**: `lib/print_ops2/` (modular printing components)

### Important Patterns
- **Database access**: ALWAYS through service layer (RecordService, ParticipantService)
- **Keys**: All interactive elements need named keys for testing (format: `Key('PageName_element')`)
- **Async safety**: After `await`, always check `if (!mounted) return;` before `setState()`
- **Responsive**: Use `isCompact` breakpoint at 600px width
- **Language**: UI text in Czech, code/comments in English

### State Management
- `_selectedParticipant`: Currently selected participant (MemoryOsoba?)
- `_titleController`: TextEditingController for nadpis
- `_descriptionController`: TextEditingController for popis
- `_poznamkaController`: TextEditingController for poznámka
- `_recordDateTime`: DateTime for record timestamp
- `_hasUnsavedChanges`: Tracks if form has modifications

### Health Information Fields Available
```dart
class MemoryOsoba {
  int id;
  String jmeno;
  String prijmeni;
  DateTime? datumNarozeni;
  String? alergie;           // ← CRITICAL
  String? omezeni;           // ← HIGH PRIORITY
  bool? zpusobilost;         // Medical clearance status
  String? poznamka;          // Already displayed in note field
  int? pojistovnaId;
  bool prisel;               // Arrival confirmation
  // ... other fields
}
```

### Printing System Integration
- Two modes: Full print (initial) and Append print (add records)
- Service: `PrintCenterService` in `print_ops2/`
- PDF generation: `generate_pdf_template.dart`
- Need to track `wasPrinted` flag on records

### Testing Requirements
- Must include integration tests with real database
- Widget tests need keys for all interactive elements
- Test health information display with various scenarios:
  - No allergies/restrictions
  - Only allergies
  - Only restrictions
  - Both present
  - Very long text (overflow handling)

## Design Decisions Made (After Camp Nurse Context Corrections)

### 1. Print Button Placement → **REVISED: Persistent After Save**
- **User concern**: "won't it be unintuitive if hidden in success message?"
- **New approach**: Expandable section appears after save and STAYS visible
- **Rationale**: 
  - Discoverability - user sees feature exists
  - Clear workflow - save unlocks printing
  - No auto-dismissing that hides functionality
  - Supports batch workflow (save multiple, print once)
- **Alternative**: Print buttons also accessible from participant list view

### 2. Health Warnings Persistence → **DECIDED: Always Visible (Cannot Hide)**
- **Rationale**: Critical for treatment decisions (what to give/do)
- **Camp nurse context**: Needs immediate reference during routine care
- **No dismissal option**: Must always see allergies/restrictions
- **Prevents dangerous oversight** when handling many kids per day

### 3. Age Display Format → **CONFIRMED: "12 let (15.3.2013)"**
- **User approved this format**
- **Rationale**: Serves both purposes
  - Age: Quick mental reference
  - Birth date: Context and dosage reference
- **Compact format**: "Antonín Dvořák • 12 let (15.3.2013)"
- **Handles missing data**: If birthDate null, show just name and age if available

### 4. Empty State Handling → **DECIDED: Conditional Rendering**
- **If no allergies/restrictions**: Hide entire warning section
- **Rationale**: Reduces clutter, clean interface for healthy kids
- **Avoids "positive noise"**: Blank space clearer than unnecessary messages
- **Visual clarity**: Presence of warning = important information to consider

### 5. Způsobilost Display → **REVISED: Show Status Indicator**
- **Previous decision WRONG**: I incorrectly assumed "already checked at intake"
- **Correction**: Způsobilost contains DOCTOR-PROVIDED medical information
- **Camp nurse needs**: Reference doctor's clearance and conditions
- **New approach**: 
  - Brief status indicator: "✓ Způsobilý" (clear) or "ℹ️ Způsobilý s podmínkou..." (conditional)
  - Clickable to view full způsobilost form in ParticipantDetailPage
  - Shows when: zpusobilost=false OR podmínka exists
- **Rationale**: Nurse may need to check "what did the doctor say?" during treatment

### 6. Parent Contact Access → **REVISED: In ParticipantDetailPage Only**
- **Previous decision WRONG**: I over-estimated urgency based on "full doctor" context
- **Camp nurse correction**: "Someone else calls parents during emergencies"
- **New approach**: Parent contact in ParticipantDetailPage (via clickable name)
- **Rationale**: 
  - Nurse focuses on treatment during emergencies
  - Someone else (camp director, coordinator) handles parent communication
  - Contact info needed for non-urgent situations (should we call about X?)
  - Available when needed, doesn't clutter treatment screen

### 7. Administrative Details → **DECIDED: All in ParticipantDetailPage**
- **Accessed via clickable participant name** 
- **Contains**: Insurance, rodné číslo, full contact info, complete history, způsobilost form
- **Rationale**: Keeps NewRecordPage focused on injury documentation
- **Deep-dive available**: When nurse needs full context about participant

## Open Questions for Further Discussion

### 1. Způsobilost Field Structure - **CLARIFIED**
**Database Structure** (from codebase analysis):
- Field: `zpusobilost: bool?` in Participants table
- Field: `potvrzeniPath: String?` (eligibleConfirmationPath) - path to uploaded file
- **Two modes**:
  1. **Toggle only**: User clicks checkbox → `zpusobilost = true`
  2. **File upload**: User uploads PNG/JPG/PDF → automatically sets `zpusobilost = true` + stores file path
- **No separate text field** for conditions - conditions would be in the uploaded document or in `omezeni` field
- **Action**: No schema changes needed, use existing fields

### 2. Způsobilost Display Details - **CLARIFIED**
**User preference**: Show in popup similar to intake_form
- **Implementation**: Reuse `FileViewerLogic` and `FileViewerScreen` widgets from intake form
- **Display logic**:
  - If `potvrzeniPath` exists: Show file viewer (PDF/image viewer)
  - If `zpusobilost == true` but no file: Show "✓ Způsobilý" badge
  - If `zpusobilost == false` or null: Show "⚠️ Nezpůsobilý" warning
- **Interaction**: Click opens popup/dialog with file viewer widget
- **Reference**: See `lib/screens2/widgets/intake_main_content.dart` lines 68-76 for existing implementation

### 3. ParticipantDetailPage Priority - **CLARIFIED**
**Status**: Page already exists at `lib/screens2/participant_detail.dart`
- **Currently shows**:
  - Osobní údaje (personal info, birth date, gender, address)
  - Pojišťovací údaje (insurance, rodné číslo)
  - Potvrzení (bezinfekčnost, způsobilost as Yes/No)
  - Lékařské záznamy (medical records list)
  - Print and New Record buttons
- **Needs enhancement**:
  - Add způsobilost file viewer (if potvrzeniPath exists)
  - Add parent contact section
  - Add allergies/restrictions display
  - Improve layout/organization
- **Priority**: OUT OF SCOPE for NewRecordPage improvements
  - Focus first on NewRecordPage health warnings
  - ParticipantDetailPage enhancements are separate task

### 4. Print Button Placement - **CLARIFIED**
**User preference**: Icons in the "Čas záznamu" box
- **NOT** expandable section below save button
- **Implementation**: Add print icons to datetime section header
- **Layout**:
  ```
  ┌─────────────────────────────────────────────────┐
  │ Čas záznamu [📄] [➕]                           │
  │ [Current DateTime]         [Změnit] button      │
  └─────────────────────────────────────────────────┘
  ```
- **Icon meanings**:
  - [📄] = Tisknout vše (print full record)
  - [➕] = Přidat k tisku (append to existing printout)
- **State management**: 
  - Disabled (grayed out) until record is saved
  - Enabled after first save
  - Remain enabled for session

### 5. Allergy/Restriction Text Length - **CLARIFIED**
**User estimate**: ~50 characters typical
- Example: "arašídy, penicilín, aspirin, ibuprofén" = 42 chars
- **Design decision**: Show full text, no truncation needed
- **Layout**: Single line for most cases, wrap to 2-3 lines if longer
- **Max length**: No character limit in database, use `Expanded` widget for overflow
- **Visual**: High-contrast background (red/orange) makes text stand out

### 6. Způsobilost Form Storage - **CLARIFIED**
**Two modes** (from codebase):
1. **Toggle only**: Checkbox → `zpusobilost = true`, no file
2. **File upload**: Upload PNG/JPG/PDF → `zpusobilost = true` + `potvrzeniPath` set

**Display logic for NewRecordPage**:
- If `zpusobilost == true` AND `potvrzeniPath` exists:
  - Show: `ℹ️ Způsobilý (klikni pro dokument)` 
  - Click: Opens popup with file viewer
- If `zpusobilost == true` AND no file:
  - Show: `✓ Způsobilý` (simple badge, no click action)
- If `zpusobilost == false` or null:
  - Show: `⚠️ Nezpůsobilý` (warning, click for details?)
  - OR: Hide entirely (shouldn't be at camp if nezpůsobilý)

**File viewer widget**: Reuse existing `FileViewerScreen` from intake form

## Questions Requiring User Testing

1. **Print workflow patterns**:
   - Do you save one record then print immediately?
   - Or document multiple injuries, then print at end of day?
   - **Impacts**: Whether print section should persist or auto-hide

2. **Způsobilost reference frequency**:
   - How often do you need to check způsobilost during treatment?
   - Daily? Only for complex cases? Never?
   - **Impacts**: Whether brief preview or just icon is sufficient

3. **Participant detail access patterns**:
   - When do you need full participant details?
   - During initial record? Or only for follow-ups?
   - **Impacts**: Whether clickable name is sufficient or need quick-access button

## Recommendations Summary

### Immediate Priority (HIGH)
1. **Allergies & Restrictions Display** - Life-critical information
   - Implement always-visible warning banner when present
   - Use clear icons and warning colors
   - Test with real camp scenarios

### Short-term Priority (MEDIUM)
2. **Historie Timestamp Improvement** - Reduces confusion
   - Implement smart hybrid format (Dnes/Včera/Full date)
   - Low implementation cost, high usability gain

3. **Print Action Buttons** - Workflow improvement
   - Add quick access to print functions
   - Research optimal placement with user feedback

### Future Considerations (LOW)
4. **Expandable details panel** - Nice to have
   - Insurance, birth number, other administrative data
   - Not urgent for emergency treatment

## User Feedback Needed

Before implementing, validate with actual zdravotník users:
- Is the proposed health info layout clear enough?
- Would they prefer always-visible vs expandable panels?
- What's the typical workflow: Save then print, or multiple saves then print?
- Are there other critical fields we're missing?
- How do they handle very long allergy lists in practice?
- Do they need parent contact during initial record creation, or only later?

## Summary of Key Insights from Discussion (REVISED)

### Context Understanding - CORRECTED
**Camp Health Nurse (Zdravotník) at Czech summer camps**:
- **NOT a full doctor** - basic first aid training, not medical degree
- Handles 30-100+ children over 1-2 weeks
- **Routine care dominates**: minor scrapes (daily), headaches, stomach aches, tick removal, sunburn
- **Emergencies are rare**: stabilizes patient, **but someone else calls parents/ambulance**
  - Nurse focuses on treatment, not coordination
  - Parent contact NOT urgent during record creation
- **References doctor's clearance (způsobilost)** when unsure about conditions
- Works in outdoor, sometimes remote settings with basic facilities
- Must maintain legal/insurance documentation for camp records
- Sees dozens of routine cases daily - needs efficient workflow

### Medical UI Best Practices Applied
1. **"Clarity beats cleverness"** - Plain language, familiar icons, simple layouts
2. **"Design for high-stress, low-time scenarios"** - Critical info always visible
3. **"Color as backup singer, not lead"** - Use color + icon + text (accessibility)
4. **"Prioritize crucial information"** - Avoid information overload
5. **"One screen = one purpose"** - Don't try to show everything at once

### Critical vs Non-Critical Information - REVISED
**CRITICAL (always visible on NewRecordPage)**:
- ⚠️ Allergies - affects what can be given/done
- 🚫 Restrictions/Limitations - affects treatment approach
- 👤 Age + Birth Date - context and reference
- ℹ️ Způsobilost Status - doctor's clearance/conditions (brief indicator, click for details)

**IMPORTANT (easily accessible via clickable name)**:
- Full Participant Details → ParticipantDetailPage
- Parent Contact - needed for non-urgent "should we call?" decisions
- Complete Injury History - pattern recognition
- Způsobilost Form/Scan - full doctor's notes

**NON-CRITICAL (in ParticipantDetailPage)**:
- Pojišťovna - administrative documentation
- Rodné číslo - identification, not treatment-related
- Other administrative details

### Workflow Optimization
1. **Save-first model**: Enter data → Save → Decide about printing
2. **Batch-friendly**: Allow multiple records before printing
3. **Emergency-ready**: Critical health info visible without clicks
4. **Routine-efficient**: Clean interface for frequent daily use

### Accessibility Considerations
- High contrast backgrounds for warnings
- Icons + text + color (not color alone)
- Large enough touch targets (44x44 dp minimum)
- Screen reader support for urgent warnings
- Works in outdoor lighting conditions

---

**Note**: This document should be updated as decisions are made and implementation progresses. Include screenshots/mockups once available.

**For Future AI/Developers**: This document represents deep analysis of **camp health nurse (zdravotník)** workflow at Czech camps - NOT full doctor context. The user provided critical corrections about the real-world usage:
1. Nurse has basic first aid training, not medical degree
2. Someone else calls parents during emergencies (nurse treats, doesn't coordinate)
3. Způsobilost contains doctor-provided information nurse needs to reference
4. Print button discoverability is important (not hidden-only approach)
5. Routine care dominates (scrapes, headaches), emergencies are rare

Design decisions balance: critical information visibility for treatment, efficient workflow for daily routine cases, deep-dive access to complete participant details when needed.
