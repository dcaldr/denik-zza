# Menu Comparison Screen

## Purpose
Dev-only screen for side-by-side comparison of menu layout alternatives.

## Location
`lib/dev/dev_menu_comparison.dart`

## How to Run
```bash
flutter run -t lib/dev/dev_menu_comparison.dart -d windows
```

## What It Shows

### Left Side: Současné menu (Current AppDrawer)
- Displays the existing `AppDrawer` implementation
- All functional screens and navigation
- Shows current menu structure with 4 main sections + "PŘIPRAVUJEME"

### Right Side: Sbalitelné sekce (Collapsible Sections)
- Alternative layout using `ExpansionTile` widgets
- Groups menu items into collapsible sections:
  - **UDÁLOSTI** (3 items)
  - **ÚČASTNÍCI** (4 items) 
  - **ZÁZNAMY** (2 items)
  - **NÁSTROJE** (3 items)
  - **PŘIPRAVUJEME** (5 items)
- Sections can be expanded/collapsed individually
- Reduces visual clutter for long menus

## Key Features

### Current Drawer (Left)
- ✅ Standard Material Design Drawer
- ✅ Linear list of all items
- ✅ Simple, familiar pattern
- ❌ Gets long with many items (14 total)

### Collapsible Sections (Right)
- ✅ Groups related items together
- ✅ Sections can collapse to save space
- ✅ Good for 10+ menu items
- ✅ Visual hierarchy with section headers
- ❌ Requires extra tap to expand sections
- ❌ More complex interaction pattern

## State Management
Both implementations:
- Check database state (`hasEvent`, `hasParticipants`)
- Disable menu items when prerequisites not met
- Use same navigation logic

## Implementation Notes

### ExpansionTile Configuration
```dart
ExpansionTile(
  leading: const Icon(Icons.event),
  title: const Text('UDÁLOSTI'),
  initiallyExpanded: true,  // Main sections start open
  children: [
    // Menu items as ListTiles
  ],
)
```

### Section Grouping Strategy
- **Main workflow sections**: Initially expanded (UDÁLOSTI, ÚČASTNÍCI, ZÁZNAMY)
- **Tools section**: Initially collapsed (NÁSTROJE)
- **Placeholder section**: Initially collapsed (PŘIPRAVUJEME)

## Testing
All menu items have named keys for widget testing:
- `Key('CollapsibleMenu_udalostiSection')`
- `Key('CollapsibleMenu_createEvent')`
- etc.

## Decision Criteria

Choose **Current Drawer** if:
- Menu has fewer than 10 items
- Users need quick access to all items
- Simplicity is paramount

Choose **Collapsible Sections** if:
- Menu has 10+ items
- Items naturally group by workflow/feature
- Screen space is limited
- Visual hierarchy helps users navigate

## Next Steps
1. ✅ Test both layouts interactively
2. Get user feedback on preferred layout
3. Consider Material 3 `NavigationDrawer` as third option
4. Implement chosen layout in production
