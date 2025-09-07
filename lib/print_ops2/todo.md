# TODO - Print Operations 2

## Critical Implementation Tasks

### 🚨 High Priority (Blocking Issues)
- [ ] **Fix infinite recursion bug** in GeneratePdfTemplate setters
- [ ] **Add Print Mode Selection** - differentiate between full print vs append print
- [ ] **Implement Full Print Mode** - reset all wasPrinted flags and use standard PDF generation
- [ ] **Implement Append Print Computation Engine** - complex logic beyond simple printing:
  - [ ] Transparency rendering for already-printed content
  - [ ] Content visibility calculation per page
  - [ ] Multi-page append scenario handling
  - [ ] Chronological conflict resolution
- [ ] **Restructure header logic** - combine name + restrictions as single unit for page 1
- [ ] **Add simplified header** for page 2+ (name + age/birthdate only)
- [ ] **Implement header visibility rules** - hide only on existing pages, show on new pages
- [ ] **Add user feedback system** - post-print confirmation dialog
- [ ] **Complete PrintPdfRestrictions.buildSection()** implementation
- [ ] **Fix type safety** - replace `dynamic` with proper types

### 📄 Multi-page Support
- [ ] **Page 1 header** - combine name + restrictions as single unit
- [ ] **Page 2+ headers** - simplified name + age/birthdate only  
- [ ] **Header visibility logic** - hide on existing pages, show on new pages
- [ ] **Multi-page detection logic** - count pages with/without new records
- [ ] **Page-level append validation** - which pages can be appended vs. new pages needed
- [ ] **Page numbering** - append-aware page number handling
- [ ] **Complex scenarios:**
  - [ ] Append to existing page only (hide existing headers)
  - [ ] Append to existing + create new pages (hide on existing, show on new)
  - [ ] Create new pages only (show headers on all new pages)

**Note:** This doesn't solve situation when new record(s) fit on existing page, but push some existing record(s) to new page vs when we are adding only new pages.

### 🔄 Append Logic Enhancements  
- [ ] **Page 1 header invalidation** - any name OR restriction change requires full reprint
- [ ] **Per-page header tracking** - separate status for each page's header
- [ ] **Chronological insertion validation** - handle insertions in middle of printed sequences
- [ ] **Modification detection** - track changes to already-printed records
- [ ] **State reset mechanisms** - when user requests "start from scratch"
- [ ] **Better error messages** - explain why append failed and what to do

### 🎯 User Experience
- [ ] **Print Mode Selection UI** with options per person:
  - "Print Entire Person" (full reprint)
  - "Append New Records" (conditional, only when valid)
  - Visual indicators showing which mode is recommended
- [ ] **Post-print feedback UI** with options:
  - "Success - use for next append"  
  - "Need to reprint this job"
  - "Start from scratch"
- [ ] **Append preview** - show what will be hidden vs. printed
- [ ] **Print validation messages** - explain why append failed and suggest alternatives
- [ ] **Quick copy mode** - reprint without changing status

### 🚀 Future Features
- [ ] **Per-event printing mode** - multiple people with name/birthdate columns
- [ ] **Integration with main app** - replace demo data with real database
- [ ] **Performance optimization** - handle large record sets efficiently for both full and append modes
- [ ] **Advanced multi-page logic** - intelligent page breaks and headers
- [ ] **Print Mode API** - comprehensive enum system for different print types
- [ ] **Batch operations** - "Print All People" with full reprint mode

### 📚 Documentation & Testing
- [ ] **Unit tests** for append validation logic
- [ ] **Integration tests** for full print workflows  
- [ ] **User documentation** - how to use append printing effectively
- [ ] **Error handling documentation** - troubleshooting guide

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
