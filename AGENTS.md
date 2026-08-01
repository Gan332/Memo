# AGENTS.md

## Build & Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

**No `android/`, `ios/`, `web/`, etc. platform dirs exist.** The project has only `lib/`, `test/`, and CI workflow files. Platform dirs must be generated with `flutter create .` before building. CI uses `platform-build.yml` separately.

## Code Generation

Drift (v2.22) generates `lib/data/database/app_database.g.dart` via `build_runner`. **Never hand-edit `.g.dart` files.** The CI regenerates them.

Key generated types from `app_database.dart`:
- Table `Notes` → data class `NoteRow` (forced via `@DataClassName('NoteRow')`), companion `NotesCompanion`
- Table `Tags` → data class `Tag`, companion `TagsCompanion`
- Table `NoteTags` → data class `NoteTag`, companion `NoteTagsCompanion`
- Table `ChecklistItems` → data class `ChecklistItem`, companion `ChecklistItemsCompanion`
- Table `NoteColorValues` → data class `NoteColorValue`, companion `NoteColorValuesCompanion`

## Drift Companion APIs (gotcha-heavy)

`TableCompanion.insert()` and the regular `TableCompanion()` constructor have **different parameter conventions**:

**`.insert()` constructor**: columns with `withDefault()` or `autoIncrement()` are optional `Value<T>` params. Columns **without** defaults are **required plain values** (not wrapped in `Value`):
```dart
// createdAt/updatedAt have NO default → plain String
// title/color/etc have defaults → Value<T> or omitted
NotesCompanion.insert(
  title: Value('hi'),       // optional, has default
  createdAt: '2025-01-01',  // required, no default → plain String
  updatedAt: '2025-01-01',
)
```

**Regular constructor**: ALL fields use `Value<T>`:
```dart
NotesCompanion(
  id: Value(1),
  title: Value('hi'),
  createdAt: Value('2025-01-01'),
)
```

`ChecklistItems` column is named `itemText` (not `text` — renamed to avoid conflict with Drift's `Table.text()` method).

## Architecture

```
lib/
  data/
    database/app_database.dart   # Drift DB, 5 tables, seed colors
    database/connection.dart     # NativeDatabase lazy connection
    models/backup.dart           # BackupData/BackupMetadata
    repositories/                # note_repository, tag_repository, checklist_repository
  domain/entities/               # NoteEntity, TagEntity, ChecklistEntity (plain Dart classes)
  state/providers/               # NoteProvider, TagProvider, ChecklistProvider, ThemeProvider (ChangeNotifier)
  screens/                       # HomeScreen, AddEditNoteScreen, ArchiveScreen, TagManageScreen, SettingsScreen, StatsScreen, TrashScreen
  widgets/                       # NoteCard, ChecklistEditor, FilterMenu, TagChip
  services/backup_service.dart   # Import/export
  theme/                         # AppTheme (M3), AppColors, AppTypography
```

- **State**: Provider (ChangeNotifier), no Riverpod/Bloc
- **DB**: Drift with SQLite (NativeDatabase)
- **UI**: Material 3, dynamic_color support
- **i18n**: zh_CN hardcoded (no localization framework)

## CI

`ci.yml` runs on push to `main` and PRs:
1. `flutter pub get`
2. `dart run build_runner build --delete-conflicting-outputs`
3. `dart format .` (non-blocking)
4. `flutter analyze --no-fatal-infos` (errors/warnings fail; infos pass)
5. `flutter test --coverage` (non-blocking via `|| true`)

Flutter version pinned to `3.27.4` in CI.

## Known Test Issues

- `home_screen_test.dart` tests all fail with `pumpAndSettle timed out` — `AppDatabase()` creates `NativeDatabase` which needs platform channels unavailable in headless tests. Tests need DB mocking.
- `app_theme_test.dart` has 1 color mismatch — `MaterialColor` vs `Color` from `ColorScheme.fromSeed`.

## Analysis Config

`analysis_options.yaml` enforces strict rules: `require_trailing_commas`, `prefer_const_constructors`, `avoid_print`, `use_super_parameters`, etc. Generated `*.g.dart` and `*.freezed.dart` files are excluded from analysis.
