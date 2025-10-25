# List of technical tasks to be done (in no particular order)
It is just to remember what needs to be done before using GH isssues.

## Critical Bugs

- [ ] **BUG-WEB-1**: CSV Import completely broken on web platform (CRITICAL)
  - **Discovered**: 2025-10-25 during ORG-1 investigation
  - **Impact**: Feature non-functional on web - UnsupportedError thrown immediately
  - **Root Cause**: Web file picker provides bytes, but InputParser requires file paths + temp files use dart:io (unavailable on web)
  - **Files**: 
    - `lib/screens2/csv_review_variants/import_screen.dart:270` (creates bytes payload)
    - `lib/services/csv_import_service.dart:140` (blocks bytes with UnsupportedError)
    - `lib/input/file_manager.dart:565` (uses dart:io File operations)
  - **Estimated Fix**: 4-8 hours (architectural change)
  - **Recommended Solution**: Refactor InputParser to accept bytes directly for in-memory parsing on web
  - **Details**: See `docs/reports/csv_flow_review.md` BUG-WEB-1 section

## Technical Debt

- [ ] Add facade class for Logging instead of random spawning of loggers
-  [ ] docs: create mermaid maps to visualize callgraph and logic to some harder ops
-  [ ] simplify DB operations 
    - [ ] ref: MemoryAction -> MemoryEvent (and all subsequent naming)
    - [ ] revisit database_interface and standardize naming + outputs
      -  [ ] reflect changes in app
  -  [ ] reorder methods (also in drift_database_connector)
- [ ] make backup branch, than kill dead code/classes/files etc.