# Design Rules Quick Reference Card

**Deník ZZA - UI Standards Cheat Sheet**
Print this page and keep it visible while coding!

---

## 📐 Layout Rules

### Breakpoints (ALWAYS use these)
```dart
Mobile:  < 600px  → 1 column
Tablet:  600-900px → 2 columns
Desktop: > 900px  → 3 columns
Default Window: 1280x720 (flutter_run_size)
```

### Max Widths (prevent stretching)
```dart
Content:  1200px max
Forms:    800px max
Cards:    600px max
```

### Required Check
- [ ] Does my screen use `MediaQuery` or `LayoutBuilder` for responsive layouts?
- [ ] Do multi-column layouts adapt to screen size?
- [ ] Is content constrained with `maxWidth` on desktop?

---

## 📏 Spacing (NEVER hardcode numbers!)

```dart
XS:     4.0   // Tiny gaps
Small:  8.0   // Between related items
Medium: 16.0  // Standard padding (USE THIS MOST)
Large:  24.0  // Between sections
XL:     32.0  // Page margins
XXL:    48.0  // Major spacing
```

### Quick Check
- [ ] Am I using `8`, `12`, `16`, `20`, `24`? → Replace with spacing constants!
- [ ] Is my padding consistent across similar components?

---

## 🎨 Colors (NO hardcoded Colors.x.shade50!)

### ❌ NEVER DO THIS:
```dart
Container(color: Colors.blue.shade50)
Text(style: TextStyle(color: Colors.grey))
```

### ✅ ALWAYS DO THIS:
```dart
Container(color: Theme.of(context).colorScheme.primaryContainer)
Text(style: Theme.of(context).textTheme.bodyMedium)
```

### Quick Check
- [ ] No `Colors.blue`, `Colors.grey`, etc. in my code?
- [ ] Using `Theme.of(context).colorScheme.xxx`?

---

## 🔘 Buttons (Material 3 ONLY!)

### Button Hierarchy
| Priority | Type | Use For |
|----------|------|---------|
| **Primary** | `FilledButton` | Main action (Submit, Save, Confirm) |
| **Secondary** | `OutlinedButton` | Alternative actions (Cancel with action, Reset) |
| **Tertiary** | `TextButton` | Low priority (Cancel, Back, Skip) |

### ❌ FORBIDDEN:
```dart
ElevatedButton()  // Old Material 2 - DON'T USE!
```

### ✅ CORRECT:
```dart
FilledButton(onPressed: _submit, child: Text('Uložit'))
OutlinedButton(onPressed: _reset, child: Text('Reset'))
TextButton(onPressed: _cancel, child: Text('Zrušit'))
```

### Quick Check
- [ ] No `ElevatedButton` in my code?
- [ ] Primary actions use `FilledButton`?
- [ ] Button order: Cancel (left) → Secondary → Primary (right)?

---

## 📝 Typography (NO fontSize hardcoding!)

### ❌ NEVER:
```dart
Text('Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
```

### ✅ ALWAYS:
```dart
Text('Title', style: Theme.of(context).textTheme.titleLarge)
```

### Text Styles Quick Guide
```dart
displayLarge    → Big titles (32px)
titleLarge      → Screen titles (22px)
titleMedium     → Section headers (18px)
bodyLarge       → Body text (16px)
bodyMedium      → Standard text (14px) ← USE THIS MOST
bodySmall       → Small text (12px)
labelLarge      → Button text (14px)
```

### Quick Check
- [ ] No `fontSize: XX` in my TextStyle?
- [ ] Using `Theme.of(context).textTheme.xxx`?

---

## 📅 Dates (NO manual string building!)

### ❌ NEVER:
```dart
'${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}'
```

### ✅ ALWAYS:
```dart
DateFormat('dd.MM.yyyy', 'cs_CZ').format(date)
```

### Quick Check
- [ ] No `.toString()` or `.padLeft()` for dates?
- [ ] Using `DateFormat` with `'cs_CZ'` locale?

---

## ✅ Form Validation (Centralize it!)

### ❌ NEVER:
```dart
validator: (value) => value?.isEmpty ?? true ? 'Povinné pole' : null
```

### ✅ ALWAYS:
```dart
validator: (value) => AppValidators.required(value, fieldName: 'Jméno')
```

### Quick Check
- [ ] Using shared validator functions?
- [ ] Not duplicating validation logic?

---

## 🧩 Empty States (Use standard component!)

### Required Elements:
1. Icon (64px, grey)
2. Message text
3. Action button (optional)

```dart
EmptyState(
  icon: Icons.person_off,
  message: 'Žádní účastníci',
  actionLabel: 'Přidat účastníka',
  onAction: _addParticipant,
)
```

### Quick Check
- [ ] All empty states have icon + message?
- [ ] Action button present if user can fix it?

---

## 🔄 Loading States (Show feedback!)

### ❌ BAD:
```dart
CircularProgressIndicator()  // User doesn't know what's loading
```

### ✅ GOOD:
```dart
LoadingIndicator(message: 'Načítání účastníků...')
```

### Quick Check
- [ ] All async operations show loading indicator?
- [ ] Loading message explains what's happening?

---

## 🎯 Accessibility (44x44 minimum!)

### Rules:
- **Touch targets:** Minimum 44x44 dp
- **Font size:** Minimum 12px (14px preferred)
- **Icon buttons:** MUST have `tooltip` and `semanticsLabel`

```dart
IconButton(
  icon: Icon(Icons.add),
  tooltip: 'Přidat účastníka',
  semanticsLabel: 'Přidat účastníka',
  onPressed: _add,
)
```

### Quick Check
- [ ] All IconButtons have tooltips?
- [ ] Buttons are at least 44x44?
- [ ] Font sizes >= 12px?

---

## 🚫 Common Mistakes to Avoid

### 1. Fixed Multi-Column Layouts
```dart
❌ Row(children: [Expanded(...), Expanded(...), Expanded(...)])
✅ Use ResponsiveFormGrid or LayoutBuilder
```

### 2. Overflow Risks
```dart
❌ Row(children: [Text(...), Text(...), IconButton(...)])
✅ Add Expanded/Flexible or use Wrap
```

### 3. Magic Numbers
```dart
❌ SizedBox(height: 18)
✅ SizedBox(height: AppSpacing.medium)
```

### 4. Duplicate Code
```dart
❌ Copy-pasting the same widget tree
✅ Extract to reusable widget/component
```

---

## ⚡ Quick Checklist Before Committing

- [ ] **Responsive?** Layout adapts to mobile/tablet/desktop
- [ ] **Spacing?** Using AppSpacing constants (not hardcoded numbers)
- [ ] **Colors?** Using theme colors (not Colors.x)
- [ ] **Buttons?** Using FilledButton/OutlinedButton (not ElevatedButton)
- [ ] **Text?** Using theme text styles (not hardcoded fontSize)
- [ ] **Dates?** Using DateFormat (not manual string building)
- [ ] **Empty states?** Has icon + message + action
- [ ] **Loading?** Shows indicator with message during async ops
- [ ] **Accessibility?** Icon buttons have tooltips, touch targets 44x44+
- [ ] **Max width?** Content constrained on desktop (< 1200px)

---

## 🔥 Critical Issues to Check

### FileViewerScreen - UNSAFE! 🚨
If you're touching this file, FIX these issues:
- [ ] Add try-catch around `File.readAsBytesSync()`
- [ ] Add AppBar with close button
- [ ] Fix PDF constraints (remove `/1.3`, `/2`, `*4` magic numbers)
- [ ] Add loading indicator
- [ ] Handle corrupted/missing files gracefully

### ParticipantRegistrationForm - NOT Mobile-Friendly! 📱
- [ ] Replace fixed 3-column Row with ResponsiveFormGrid
- [ ] Use LayoutBuilder to switch 1/2/3 columns based on width

---

## 📚 Where to Find More

- **Full Analysis:** `UI_AUDIT_DOCUMENTATION.md` (technical details)
- **Overview:** `UI_AUDIT_OVERVIEW.md` (high-level summary)
- **Implementation Guide:** `UI_STANDARDS_CHECKLIST.md` (step-by-step)
- **User Flows:** `USER_FLOWS.md` (journey analysis)
- **Design Feel:** `APP_DESIGN_FEEL.md` (what to keep/change)

---

**Last Updated:** 2025-11-06
**Version:** 1.0

💡 **Tip:** Print this page and hang it next to your monitor!
