# TODO - Print Operations 2

## Critical Implementation Tasks

### 🚨 High Priority (Resolved)
- [x] **Fix infinite recursion bug** in GeneratePdfTemplate setters
- [x] **Add Print Mode Selection** - differentiate between full print vs append print
- [x] **Implement Full Print Mode** - reset all wasPrinted flags and use standard PDF generation
- [x] **Implement Append Print Computation Engine** - complex logic beyond simple printing:
  - [x] Transparency rendering for already-printed content
  - [x] Content visibility calculation per page
  - [x] Multi-page append scenario handling
- [x] **Restructure header logic** - combine name + restrictions as single unit for page 1
- [x] **Complete PrintPdfRestrictions.buildSection()** implementation
- [x] **Fix type safety** - replace `dynamic` with proper types

### 📄 Multi-page Support (Implemented)
- [x] **Page 1 header** - combine name + restrictions as single unit
- [x] **Page 2+ headers** - simplified name + age/birthdate only  
- [x] **Header visibility logic** - hide on existing pages, show on new pages
- [x] **Multi-page detection logic** - count pages with/without new records
- [x] **Page-level append validation** - which pages can be appended vs. new pages needed
- [x] **Page numbering** - append-aware page number handling

### 🎯 User Experience (Implemented)
- [x] **Print Mode Selection UI** with options per person
- [x] **Post-print feedback UI** with options
- [x] **Append instruction dialog** with visual guides

### 📚 Documentation & Testing (Implemented)
- [x] **Unit tests** for append validation logic
- [x] **Integration tests** for full print workflows  
- [x] **Robot tests** for UI interaction
- [x] **Visual Verification Suite** for artifact inspection

---

## Design Decisions to Review

### State Management Complexity
Current `OkCodes` system with 4 status fields may be overly complex. Consider:
- Simpler timestamp-based approach
- Event-sourcing pattern for print history
- Single source of truth for print status

### Multi-page Strategy
Need to decide approach for page overflow scenarios:
- Pre-calculate page requirements vs. dynamic page creation
- Header repetition strategy
- Page numbering schemes

### Error Recovery
How to handle physical printing errors that can't be detected automatically:
- User feedback requirements
- Rollback mechanisms
- State correction workflows
