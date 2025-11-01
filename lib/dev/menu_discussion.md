# Menu Structure Discussion - Phase-Based Design

**Date:** November 1, 2025  
**Status:** Discussion Phase - No Implementation Yet  
**Goal:** Refocus menu on actual workflow needs, eliminate menu item creep

---

## 📊 Current State Analysis

### Existing Screens (What Actually Exists)
✅ **8 Real User-Facing Screens:**
1. EventRegistrationForm - Create new event
2. EventList - List of events
3. EventDetail - Event detail page
4. ParticipantRegistrationForm - Register participant
5. ParticipantDetail - Participant detail
6. ParticipantEditPage - Edit participant
7. NewRecordPage - Add treatment record (MAIN PURPOSE)
8. NewIntakeFormImproved - Intake form
9. CsvImportScreen - CSV import
10. Print Center - Printing operations

❌ **Screens That DON'T Exist:**
- Seznam záznamů úrazů (Records List) - Never requested, doesn't exist
- Vyhledávání účastníků (Search Participants) - Doesn't exist as separate screen (list has search)
- File Manager "screen" - It's a utility widget, not a user-facing screen

---

## 🔍 Menu Item Creep Analysis

### What Was EXPLICITLY Requested (from todo.md):
1. ✅ "nový záznam úrazu - at least put it to menu" 
2. ✅ "seznam účastníků - probably also to the menu"
3. ✅ "import osoba and osoby by csv"

### Menu Items Added WITHOUT Request (CREEP):
1. ❌ Správce souborů (File Manager) - User confirms: "internal utility not something that has screen"
2. ❌ Test tisku (Print Test) - Technical utility, not user workflow
3. ❌ Seznam záznamů úrazů - User confirms: "right now it wasn't asked"
4. ❌ Vyhledávání účastníků - Doesn't exist, not requested
5. ⚠️ Detail akce - Exists but accessible from Event List (not needed in menu?)
6. ⚠️ Detail účastníka - Exists but accessible from Participant List
7. ⚠️ Úprava účastníka - Exists but accessible from Detail screen

**Current menu: 14 items → Should be: 8 core items (43% reduction)**

---

## ✂️ Proposed Cleanup - 8 Core Items Only

### KEEP These 8 Screens in Menu:
1. **Nová akce** (Create Event) - PreEvent workflow
2. **Seznam akcí** (Event List) - View/select events
3. **Registrace účastníka** (New Participant) - PreEvent workflow
4. **Seznam účastníků** (Participant List) - PreEvent/Intake/Event (has search built-in)
5. **Import CSV** - PreEvent bulk import
6. **Příjímací formulář** (Intake) - Intake workflow
7. **Nový záznam úrazu** (New Record) - Event workflow **MAIN PURPOSE ⭐⭐⭐**
8. **Print Center** - Event/Intake printing

### REMOVE from Menu:
❌ File Manager - Internal utility  
❌ Print Test - Technical utility  
❌ Seznam záznamů - Doesn't exist, not requested  
❌ Vyhledávání - Doesn't exist, use Seznam účastníků search  
❌ Detail akce - Access via Event List  
❌ Detail účastníka - Access via Participant List  
❌ Úprava účastníka - Access via Participant Detail  

**Rationale:** Detail/Edit screens follow standard UX pattern - accessed contextually from lists, not from navigation menu.

---

## 🎨 Three Menu Layout Options (All with 8 Items)

### **OPTION A: Current Structure (Cleaned Up)**
```
UDÁLOSTI (2 items)
├─ Nová akce
└─ Seznam akcí

ÚČASTNÍCI (3 items)
├─ Seznam účastníků
├─ Registrace účastníka
└─ Import CSV

ZÁZNAMY (2 items)
├─ Nový záznam úrazu
└─ Příjímací formulář

NÁSTROJE (1 item)
└─ Print Center
```

**Pros:** 
- Familiar current structure
- Simple category grouping
- All items visible

**Cons:**
- Doesn't reflect workflow phases
- No prominence for "Nový záznam" (main purpose)
- All items equal weight

---

### **OPTION B: Collapsible Sections by Phase**
```
▼ UDÁLOSTI (collapsed by default)
  ├─ Nová akce
  └─ Seznam akcí

▼ ÚČASTNÍCI (collapsed by default)
  ├─ Seznam účastníků
  ├─ Registrace účastníka
  └─ Import CSV

▼ ZÁZNAMY (expanded by default)
  ├─ Nový záznam úrazu
  └─ Příjímací formulář

▼ NÁSTROJE (collapsed by default)
  └─ Print Center
```

**Pros:**
- Reduces clutter with collapsible sections
- Can expand "ZÁZNAMY" by default (main purpose)
- Saves vertical space

**Cons:**
- "Nový záznam" can still be hidden if section collapses
- Doesn't match temporal workflow (PreEvent → Intake → Event)
- State handling: What if no event? Disable entire section?

---

### **OPTION C: Phase-Based Hybrid (RECOMMENDED)** ⭐

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 BĚHEM AKCE (Always Visible - Never Collapses)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
➕ Nový záznam úrazu [needs event+participants] ⭐⭐⭐
👥 Seznam účastníků [needs event]
🖨️ Print Center [needs event]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▼ PŘÍPRAVA AKCE (Collapsible - Default: Collapsed)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📅 Nová akce
  📋 Seznam akcí
  ➕ Registrace účastníka
  📥 Import CSV

▼ NÁSTUP (Collapsible - Default: Collapsed)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📋 Příjímací formulář [needs event]
```

**Why This is Best:**

✅ **Addresses "main point of app easily accessible"**  
   - "Nový záznam" always visible at top (0 clicks, 0 scrolling)
   
✅ **Matches actual workflow frequency**  
   - Event phase (BĚHEM AKCE) used 10x more than PreEvent/Intake
   - Most frequent actions never hidden
   
✅ **Phase-based grouping matches user mental model**  
   - PreEvent → Intake → Event workflow clearly represented
   - User quote: "most actions are done only in their phases"
   
✅ **Reduces clutter intelligently**  
   - PreEvent setup (done once) collapses when not needed
   - Intake (done once at start) collapses after complete
   - Core Event operations stay prominent
   
✅ **Proper state handling**  
   - Core items VISIBLE but DISABLED when no event
   - Shows what's available + why it's disabled
   - Better than hiding (Option B tabs)

**State Handling Example:**
```dart
ListTile(
  enabled: hasEvent && hasParticipants,
  title: Text('Nový záznam úrazu'),
  subtitle: !hasEvent 
    ? Text('Vytvořte akci nejdříve', style: TextStyle(color: Colors.red))
    : !hasParticipants
      ? Text('Přidejte účastníky', style: TextStyle(color: Colors.orange))
      : null,
  ...
)
```

User sees: "Nový záznam úrazu" is there, but grayed with message "Vytvořte akci nejdříve"

---

## ❓ Questions for Decision

### 1. State Handling - Option B vs C?

**Your concern:** "if you don't have a current event you cannot do the main things, but I like it prominent"

**Option B (Tabbed/Collapsible by category):**
- Could disable entire ZÁZNAMY section when no event
- Problem: Hides what user is working toward
- Bad UX: User can't see what's possible

**Option C (Hybrid with permanent core):**
- Keep BĚHEM AKCE always visible
- Disable individual items with explanatory messages
- User sees: "This is the goal, here's what you need to do first"
- Better discoverability and feedback

**Recommendation:** Option C handles state better - items stay visible with clear feedback about prerequisites.

### 2. Czech Naming - Do These Work?

- **BĚHEM AKCE** (During Event) - for core workflow section?
- **PŘÍPRAVA AKCE** (Event Preparation) - for PreEvent?
- **NÁSTUP** (Intake/Arrival) - for Intake phase?

Alternative names:
- HLAVNÍ WORKFLOW (Main Workflow)
- PŘÍJEM (Reception/Intake)
- PŘÍPRAVA (Preparation)

### 3. Seznam účastníků Placement?

Participant List is used in:
- PreEvent: Adding/viewing participants
- Intake: Verifying arrivals
- Event: Looking up person when sick ⭐ (most frequent)

**Current placement:** BĚHEM AKCE (permanent section)  
**Reasoning:** Most frequent use is during Event (person lookup)  
**Alternative:** Keep in ÚČASTNÍCI section?

### 4. Print Center Placement?

Printing is used in:
- Intake: Print all participants after intake complete
- Event: Append print records, reprint person

**Current placement:** BĚHEM AKCE (permanent section)  
**Alternative:** Separate TISK section? Or duplicate in phases?

### 5. Intake Form Placement?

Currently in NÁSTUP (collapsible section)  
But it's time-critical workflow when used...  
**Should it be in permanent section too?** Or is it okay collapsed since it's only used once at event start?

---

## 📝 Summary of Changes Needed

### For ALL Three Options (A, B, C):

**REMOVE from menu:**
1. Správce souborů (File Manager)
2. Test tisku (Print Test)
3. Seznam záznamů úrazů (Records List)
4. Vyhledávání účastníků (Search Participants)

**REMOVE from PŘIPRAVUJEME section:**
- These 3 items exist as screens but accessed via lists (not menu):
  - Detail akce
  - Detail účastníka
  - Úprava účastníka

**Result:** 14 items → 8 core menu items

### Implementation Priority:

1. **First:** Cleanup menu item creep (remove 6 items from all variants)
2. **Second:** Move real screens out of PŘIPRAVUJEME (they exist but aren't placeholders)
3. **Third:** Decide on Option A/B/C and implement chosen layout
4. **Fourth:** Add proper state handling (disable items with clear messaging)

---

## 🎯 Next Steps

**Before any implementation, please confirm:**

1. ✅ Agreement on 8 core items (remove the 6 creep items)?
2. ✅ Agreement that Detail/Edit screens don't need menu entries (accessed via lists)?
3. 🤔 Which option: A (current structure), B (collapsible sections), or C (phase-based hybrid)?
4. 🤔 Czech naming preferences for sections?
5. 🤔 Any adjustments to Option C structure?

**Once decided, implementation will include:**
- Update all 3 comparison variants with cleaned-up 8 items
- Add proper state handling (disable with messages)
- Test keyboard/mouse navigation
- Add tests for new structure

---

## 📌 Key Takeaways

1. **Menu had 43% bloat** - 6 items added without request
2. **"Features vs Screens"** - Some items (File Manager, Print Test) are utilities, not workflows
3. **Standard UX pattern** - Detail/Edit accessed from lists, not navigation menu
4. **Phase-based thinking correct** - Matches actual workflow (PreEvent → Intake → Event)
5. **Option C best addresses** - "main point of app easily accessible" + state management
6. **8 core items sufficient** - Covers entire workflow without clutter

**Current status:** Comparison screen running with OLD structure (14 items). Waiting for confirmation before updating to cleaned structure (8 items).
