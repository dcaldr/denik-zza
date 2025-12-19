# Project Architecture Blueprint

_Last generated: 2025-10-05_

## 1. Architecture Detection and Analysis

### Technology stack
- **Primary framework:** Flutter (Dart 3.2+) targeting mobile (Android/iOS) with desktop/web scaffolding present.
- **Persistence:** Drift ORM (`drift`, `sqlite3`, `sqlite3_flutter_libs`) backed by SQLite. Database access mediated by `DatabaseWrapper` and `DriftDatabaseConnector`.
- **Dependency management:** Dart `pubspec.yaml` with supporting libraries (`provider`, `pdf`, `printing`, `logger`, `csv`, `intl`, `path_provider`, `file_picker`).
- **Testing toolchain:** `flutter_test`, custom helpers in `test/utils/`, Drift dev tooling via `drift_dev` and `build_runner`.

### Architectural pattern identification
- **Target pattern:** MVP-style "simple triangle" (`UI Widget → Service → DatabaseInterface`) per `rules/architecture.md`.
- **Observed implementation:** Hybrid of target MVP and legacy direct-database usage. Important screens (`EventList`, `Participant` flows) still call `DatabaseWrapper.getDatabase()` directly; newer modules (CSV import, print center) employ dedicated services/controllers.
- **Subsystems:** UI widgets under `lib/screens2/`, domain services under `lib/services/` (CSV, printing), persistence interface `lib/database/`, printing engine `lib/print_ops2/`, utilities in `lib/utils/`, CSV parsing domain under `lib/input/` and `lib/csv/`.
- **Communication mechanisms:** Direct in-process method calls; no remote services detected.

## 2. Architectural Overview
- **Guiding principles:** Ship quickly with minimal layers; gradually evolve toward structured MVP. Prevent widgets from talking to Drift directly; enforce database safety via `DatabaseWrapper`.
- **Boundary enforcement:** Intended separation between UI, services, and persistence. File system operations isolated in `FileManager`. Printing workflows concentrated in `print_ops2`.
- **Hybrid adaptations:** Legacy widgets bypass services; printing implements ChangeNotifier controllers; CSV import uses service abstractions. Architecture rules captured in `/rules/*.md`.

## 3. Architecture Visualization

### Level 1 – System context (textual C4)
```
[User] ──interacts via──> [Deník ZZA Flutter App]
[Deník ZZA Flutter App] ──persists via──> [SQLite Database (Drift)]
[Deník ZZA Flutter App] ──reads/writes──> [Local File System via FileManager]
```

### Level 2 – Container/component relationships
```
+ UI Layer (lib/screens2/) -------------------------------+
|  Widgets, forms, navigation, controllers                |
|  ↕ via Services/Controllers                            |
+---------------------------------------------------------+
            ↓
+ Domain Services (lib/services/, print_ops2/) -----------+
|  CsvImportService, PrintCenterService, controllers      |
|  Coordinates parsing, printing, data fetch              |
+---------------------------------------------------------+
            ↓
+ Persistence Layer (lib/database/) ----------------------+
|  DatabaseWrapper, DatabaseInterface, Drift tables       |
|  In-memory domain models (MemoryOsoba, ...)             |
+---------------------------------------------------------+
            ↓
+ Infrastructure -----------------------------------------+
|  FileManager (event directories, backups), AppLogger    |
+---------------------------------------------------------+
```

### Data flow summary
1. UI triggers service (e.g., CSV import wizard, print center controller).
2. Service fetches/persists through `DatabaseInterface` via `DatabaseWrapper`.
3. Drift converts between tables and `Memory*` domain models.
4. File operations handled by `FileManager` when directories/backups involved.

## 4. Core Architectural Components

### UI Layer (`lib/screens2/`)
- **Purpose:** Provide Czech-language workflows for events, participants, intake, CSV review, print operations.
- **Structure:** Stateful widgets with controllers; new flows add modular `widgets/`, `controllers/`, `state/` subfolders. Legacy pages exceed 250 LOC target.
- **Interactions:** Intended to consume services; some screens still instantiate database connectors. Controllers (e.g., `PrintCenterController`) expose ChangeNotifier state.
- **Evolution:** Move remaining direct DB calls into services, add stores for shared state, enforce keys/testing requirements.

### Services (`lib/services/`, `lib/print_ops2/print_center_service.dart`)
- **Purpose:** Encapsulate business processes (CSV import, printing) and isolate persistence.
- **Structure:** Concrete classes implementing high-level interfaces (`CsvReviewService`) with private parser factories and logging.
- **Interactions:** Acquire `DatabaseInterface` from `DatabaseWrapper`, orchestrate parsing/validation (`InputParser`, `CsvDefinitions`). Print services stream data using Drift watchers.
- **Evolution:** Extract additional services (participant, record) to eliminate direct DB access, introduce repository interfaces when multiple data sources appear.

### Persistence (`lib/database/`)
- **Purpose:** Provide safe abstraction over Drift.
- **Structure:** `DatabaseWrapper` singleton controlling mode (`production`, `testing`), `DatabaseInterface` contract, Drift tables (`tables.dart`) and generated code (`database.g.dart`). In-memory models `Memory*` bridging UI/service logic.
- **Interactions:** Services and (legacy) widgets call interface methods; tests leverage `DatabaseWrapper.setTestMode()` or direct `AppDatabase.testInMemory()`.
- **Evolution:** Introduce repositories/mappers when decoupling from Drift; migrate `Memory*` classes into domain module with value objects.

### Printing Module (`lib/print_ops2/`)
- **Purpose:** Multi-pass PDF generation (full vs append) with append analysis.
- **Structure:** Service (`PrintCenterService`), controller (`PrintCenterController`), PDF builders (`generate_pdf_template.dart`, `print_pdf_records.dart`), widgets for analysis results.
- **Interactions:** Controller listens to Drift streams, commands PDF generation, updates printed flags via service.
- **Evolution:** Add background job handling, centralize logging, integrate with UI stores.

### File Management (`lib/input/file_manager.dart`)
- **Purpose:** Manage event directories, DB paths, backups across modes (`inMemory`, `persist`, `production`).
- **Structure:** Singleton with mode state, path resolution, IO checks, directory structure enforcement.
- **Interactions:** Called from `main.dart` and tests to align file storage; coordinates with DatabaseWrapper modes.
- **Evolution:** Provide dependency-injected instance, align with services instead of direct widget calls.

### Utilities & Logging (`lib/utils/`)
- **Purpose:** Common helpers (logging via `AppLogger`, date/time, spacing, string tools).
- **Structure:** Standalone statics; logger wraps `package:logger` with adjustable filters.
- **Interactions:** Tests configure `AppLogger` to reduce noise; services log failures.
- **Evolution:** Expand to structured logging with contexts, DI for test overrides.

## 5. Architectural Layers and Dependencies
- **Layering:**
  - Presentation: widgets/controllers.
  - Domain/services: CSV import, print center, prospective participant services.
  - Persistence: `DatabaseInterface`, Drift, FileManager for FS concerns.
- **Dependency rules:** Presentation should depend on services; services on persistence/interface; persistence on Drift. Utilities shared across layers.
- **Observed violations:** `EventList`, other legacy widgets invoke `DatabaseWrapper` directly (violates rule 1 of architecture guide). FileManager used from UI (`main.dart`).
- **Abstraction mechanisms:** `DatabaseInterface`, service interfaces (e.g., `CsvReviewService`), controllers for state.
- **Dependency management:** Manual instantiation; no DI container. Tests rely on static switches.

## 6. Data Architecture
- **Domain models:** `MemoryOsoba`, `MemoryZaznam`, `MemoryLek`, `MemoryOmezeni`, `MemoryAction` bridging UI/service layers with Czech field names.
- **Tables:** `ZzaActions`, `Participants`, `Records`, `Medications`, `AllergiesLimitations`, `InsuranceCompanies`, `Paramedics`, `Cache` (Drift). Foreign keys link participants to events, records to participants and paramedics.
- **Mapping:** Services use `Memory*` objects; conversions handled in service/controller logic (e.g., CSV import builds `MemoryOsoba`, Print center sorts `MemoryZaznam`).
- **Data access patterns:** Synchronous reads via `Future<T>`; reactive streams via `watchParticipantsByCurrentEvent`. Testing uses in-memory DB to isolate.
- **Transformations:** CSV parser normalizes field keys (`TextTools.normText`) and builds review DTOs; PDF templates map domain to PDF widgets.
- **Caching:** `Cache` table holds pinned/current events; FileManager caches directories.
- **Validation:** Input parsing ensures mandatory fields; append analysis ensures printable range; services throw or return bool with logging on failure.

## 7. Cross-Cutting Concerns Implementation
- **Authentication & Authorization:** None implemented (camp health diary used offline). Future integration would require service boundary definitions.
- **Error handling & resilience:** Services wrap persistence calls in try/catch, log via `AppLogger`; DatabaseWrapper asserts production safety; FileManager verifies IO and logs issues.
- **Logging & monitoring:** Centralized `AppLogger` (PrettyPrinter). Tests can adjust log level via `AppLogger.configureForTests`. No remote monitoring yet.
- **Validation:** CSV import re-parses rows with normalized keys; controllers validate append viability. UI uses form validators (Czech messages). Database schema constraints enforce lengths/nullability.
- **Configuration management:** `FileManager` modes toggle runtime behavior; tests use `TEST_MODE` via docs; DatabaseWrapper ensures production/test switching.

## 8. Service Communication Patterns
- **Service boundaries:** All modules local to app; no HTTP or messaging detected.
- **Protocols:** Direct method calls returning `Future` or `Stream` (Drift watchers). PDF generation returns bytes internally.
- **Versioning / discovery:** Not applicable.
- **Resilience:** DatabaseWrapper prevents unsafe mode switches; services handle exceptions and return friendly failures.

## 9. Technology-Specific Architectural Patterns (Flutter)
- **Widget organization:** Screens under `screens2`; supporting widgets controllers subdirectories; emphasis on keys for testing.
- **State management:** Mix of `StatefulWidget`, `ChangeNotifier` controllers (PrintCenterController). `provider` dependency available but not widely used yet.
- **Navigation:** Imperative Navigator push/pop within widgets.
- **Localization:** App locked to Czech locale; `flutter_localizations` included.
- **Asynchronous patterns:** `FutureBuilder`, async/await in services; watchers for streams.
- **Platform integration:** File access via `path_provider`; printing with `printing` package; PDF with `pdf` package.

## 10. Implementation Patterns
- **Interface design:** `DatabaseInterface` enumerates CRUD and query ops; service interfaces like `CsvReviewService` define UI-facing contracts.
- **Service implementation:** Services acquire database via `DatabaseWrapper.getDatabase()`, perform orchestration, log failures (CsvImportService, PrintCenterService). Lifetime: instantiate per use (no global DI).
- **Repository patterns:** Not formalized; to be introduced when multiple data sources exist.
- **Controller/API:** UI controllers (PrintCenterController) expose strongly typed getters, manage async flows, and notify listeners.
- **Domain model enforcement:** Domain classes expose constructors for different contexts (`MemoryOsoba.named`, `.csvNamed`), though validation is minimal.

## 11. Testing Architecture
- **Strategy:** Documented in `rules/testingRules.md` emphasising pyramid (unit > widget > integration > golden).
- **Helpers:** `test/utils/` provides database helpers, unified setup, fake loggers. `HardcodedTestSetup` seeds data for integration flows.
- **Boundaries:** Tests toggle DatabaseWrapper modes or create in-memory `AppDatabase` instances. Widget tests rely on keys per architecture guideline.
- **Data strategy:** Hardcoded fixtures and CSV sample data; future direction encourages builders and deterministic clocks.
- **Coverage focus:** Services (CSV import, printing) have dedicated test suites (e.g., `multipage_*` tests).

## 12. Deployment Architecture
- **Targets:** Flutter supports Android/iOS/desktop/web (platform folders present). No CI config in repo, but scripts ensure tests run with safe DB modes.
- **Runtime dependencies:** SQLite via Drift; file system directories created via `FileManager`. Print operations rely on `pdf`/`printing` packages for PDF generation and OS print dialogs.
- **Configuration:** Production mode default; tests can set `TEST_MODE` defines for persistent & production validation (docs describe process).
- **Packaging:** Standard Flutter build; no containerization.

## 13. Extension and Evolution Patterns
- **Feature addition:**
  - Place new screens under `screens2/`, ensure <250 LOC, provide keys.
  - Expose business logic through services under `lib/services/` or module-specific service folder.
  - Persist via `DatabaseInterface`; add Drift tables/migrations carefully.
- **Modification:**
  - Refactor legacy widgets to consume services; remove direct `DatabaseWrapper` access.
  - Extract mappers and value objects before introducing new sources.
  - Maintain backward compatibility by using `Memory*` adapters until domain models modernized.
- **Integration:**
  - Use adapter services for external systems (e.g., remote CSV sources) to keep DatabaseInterface intact.
  - Introduce anti-corruption layer if integrating remote APIs.
- **Configuration growth:** Extend `FileManagerMode` and `DatabaseWrapper` with explicit feature flags; document in `docs/`.

## 14. Architectural Pattern Examples

### Layer separation
```dart
// Service acquires persistence via DatabaseWrapper
final DatabaseInterface database = DatabaseWrapper.getDatabase();
final MemoryOsoba person = await _buildPersonFromRow(parser, row);
final bool saved = await database.addOsoba(person);
```

### Component communication
```dart
class PrintCenterController extends ChangeNotifier {
  final PrintCenterService _service;

  Future<void> selectParticipant(MemoryOsoba osoba) async {
    final records = await _service.getRecords(osoba.id);
    // ... update state and notify listeners
  }
}
```

### Extension points
```dart
class DatabaseWrapper {
  static void setTestMode() {
    _databaseMode = DatabaseMode.testing;
  }

  static void useTestDriftDatabase(AppDatabase db) {
    _injectedTestDb = db; // enables injecting custom DB implementations
  }
}
```

## 15. Architectural Decision Records
- **Adopt simple MVP triangle:** Provides lightweight structure for rapid iteration; alternative (full Clean Architecture) deferred to avoid complexity.
- **Retain `Memory*` domain classes:** Maintains compatibility with legacy UI while Drift schema evolves; consequence is duplication and manual mapping work.
- **Use Drift for persistence:** Selected for type-safe queries and code generation; requires build_runner but aligns with SQLite needs.
- **Centralize database access via `DatabaseWrapper`:** Ensures production safety and test configurability; requires diligence to avoid direct connector usage.
- **Implement multi-pass append printing (`print_ops2`):** Needed to support paper append flows; increases module complexity but isolates printing logic with high test coverage.

## 16. Architecture Governance
- **Documentation:** Architecture, testing, logging rules captured under `rules/`. Printing module ships with dedicated README/docs. This blueprint supplements existing docs.
- **Automated checks:** No enforced architectural lints yet; rely on review discipline and lint set (`flutter_lints`).
- **Review practices:** Emphasis on services, keys, and database safety per instructions. Future automation could scan for `DatabaseWrapper.getDatabase()` in widgets.

## 17. Blueprint for New Development
- **Workflow:**
  1. Review relevant `rules/*.md` and this blueprint.
  2. Define UI components (<250 LOC each) with keys.
  3. Implement or extend service/controller; never call Drift directly from widgets.
  4. Update Drift schema and regenerate code if persistence changes.
  5. Write unit tests for services, widget tests for UI interactions, integration tests for flows.
  6. Update docs (`docs/`, module README) and this blueprint if architecture changes.

- **Templates & organization:**
  - Place services in `lib/services/feature_service.dart` (or module folder) returning domain models.
  - Controllers extend `ChangeNotifier` or use Provider when reactive updates needed.
  - Shared domain models go under `lib/database/in_memory_structures_tmp/` until refactored into dedicated domain module.
  - Tests use helpers from `test/utils/` and `test/setup_templates/`.

- **Common pitfalls:**
  - Avoid direct `DatabaseWrapper.getDatabase()` in widgets—wrap in services.
  - Ensure `AppLogger` used instead of `print`.
  - Respect DatabaseWrapper test mode toggles in tests to prevent data leakage.
  - Keep PDF changes aligned with `print_ops2` append analysis expectations.

- **Maintenance recommendations:**
  - Regenerate this blueprint after major architectural changes.
  - Track evolution toward full MVP (UI → Service → Database) by auditing widgets.
  - Consider introducing repositories/stores when sharing state across screens becomes complex.
