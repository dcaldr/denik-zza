# Deník ZZA Documentation

**Medical Camp Journal - UI/UX Documentation**

---

## 📁 Documentation Structure

### UI Audit (`ui-audit/`)
Historical analysis and findings from UI/UX audit.

- **UI_AUDIT_OVERVIEW.md** - Executive summary of audit findings
- **UI_AUDIT_DOCUMENTATION.md** - Complete technical audit (1500+ lines)
- **USER_FLOWS.md** - User journey analysis (6 main flows)

### Implementation Guides (`implementation/`)
Step-by-step guides for implementing improvements.

- **DESIGN_RULES_QUICK_REF.md** - Printable cheat sheet
- **UI_STANDARDS_CHECKLIST.md** - Phase-by-phase implementation

### Design System (`design-system/`)
Current focus: Creating consistent app feel.

- **APP_DESIGN_FEEL.md** - Your design preferences and decisions ⭐
- **CONSISTENCY_PLAN.md** - Focused plan for UI consistency ⭐ NEW
- **THEME_IMPLEMENTATION.md** - ThemeData setup guide ⭐ NEW

---

## 🎯 Current Focus

**Priority:** App UI Consistency (9/10)

Based on your preferences in `APP_DESIGN_FEEL.md`, we're focusing on:

1. **Consistent ThemeData** - Colors, typography, spacing all defined in one place
2. **Minimalistic, Open Feel** - Clean design with more whitespace
3. **Vibrant Major Actions** - Like intake form buttons
4. **Material 3 Standard** - For smaller actions
5. **Responsive Forms** - 3-column desktop → 1-column mobile

---

## 📖 Where to Start

### If you want to understand the current state:
1. Read `ui-audit/UI_AUDIT_OVERVIEW.md`
2. Check `ui-audit/USER_FLOWS.md` for specific flows

### If you want to implement improvements:
1. **START HERE:** `design-system/CONSISTENCY_PLAN.md` ⭐
2. Follow `design-system/THEME_IMPLEMENTATION.md`
3. Reference `implementation/DESIGN_RULES_QUICK_REF.md` while coding

### If you want to make design decisions:
1. Review your notes in `design-system/APP_DESIGN_FEEL.md`
2. Update as you make decisions

---

## 🚀 Quick Start

```bash
# 1. Read your design preferences
cat docs/design-system/APP_DESIGN_FEEL.md

# 2. Follow the consistency plan
cat docs/design-system/CONSISTENCY_PLAN.md

# 3. Implement ThemeData
cat docs/design-system/THEME_IMPLEMENTATION.md

# 4. Reference quick rules while coding
cat docs/implementation/DESIGN_RULES_QUICK_REF.md
```

---

## 📊 Key Insights from Your Preferences

### Must Keep
- All current functionality and form fields
- 3-column desktop layout (responsive to mobile)
- Offline support (10/10 priority)
- Vibrant intake form buttons style
- Navigation structure

### Top Priority
- **Consistent spacing** across app (9/10)
- **Consistent colors** across app (9/10)
- **Consistent buttons** across app (9/10)
- Make forms work on mobile (7/10)

### Design Feel
- Open, clean, minimalistic
- Professional but not clinical
- More whitespace ("too cramped")
- Less intrusive form field borders
- Support Czech diacritics

### Reference Screens (Good Examples)
- CSV import flow - good design consistency
- NewRecord page - good theming
- Intake form buttons - perfect for major actions

### Screens Needing Work
- **ParticipantDetail** - Complete redesign needed (URGENT)
- **ParticipantRegistrationForm** - Add margins, responsive
- **EventRegistrationForm** - Add margins, fix spacing
- List items - Make clickable, improve UI

---

## 🔧 Technical Approach

Based on 2024 best practices and your preferences:

### 1. Design Tokens (Foundation)
```
lib/design_system/
  ├── tokens/
  │   ├── colors.dart      # ColorScheme + semantic colors
  │   ├── typography.dart  # Text styles (Czech diacritics)
  │   ├── spacing.dart     # Spacing constants
  │   └── radii.dart       # Border radius values
  ├── theme/
  │   └── app_theme.dart   # Complete ThemeData
  └── components/
      ├── buttons.dart     # Vibrant + standard buttons
      └── forms.dart       # Form components
```

### 2. ThemeData First
Put everything in `ThemeData`:
- Colors → `colorScheme`
- Typography → `textTheme`
- Buttons → `filledButtonTheme`, `outlinedButtonTheme`
- Forms → `inputDecorationTheme`
- Cards → `cardTheme`
- Spacing → Through components using tokens

### 3. Avoid Rearranging
- Keep all form fields in same order
- Keep all buttons and actions
- Keep navigation structure
- Only improve visual consistency

---

## 📝 Version History

- **v1.0** (2025-11-06) - Initial audit and documentation
- **v1.1** (2025-11-15) - Reorganized into docs/, added consistency focus

---

## 🔗 Related Files

- Main codebase: `/lib`
- Current screens: `/lib/screens2`, `/lib/print_ops2`
- Old screens (deprecated): `/lib/screens`, `/lib/print_ops`

---

**Last Updated:** 2025-11-15
**Focus:** UI Consistency through ThemeData
