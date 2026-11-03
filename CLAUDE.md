# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

"Linh Thú Kỷ Luật" is a **habit-tracker app with a virtual pet**, built with Flutter and targeting Android first. [PLAN.md](PLAN.md) (in Vietnamese) holds the product design, the mechanics borrowed from Habitica, the tech stack and the phased roadmap. Read it before starting any work, and follow its phase order. Phase 0 (scaffold) is done. Phase 1 step 1.1 (task CRUD on the Today tab) is done; ticking, streaks and scoring are not built yet. The Pet, History and Settings tabs are still placeholders.

## Commands

The Flutter SDK lives at `C:\src\flutter` and its `bin` folder is on the user PATH. In a shell that predates the PATH change, call `/c/src/flutter/bin/flutter`.

```sh
flutter pub get
flutter analyze
flutter test                              # all tests
flutter test test/widget_test.dart        # one file
flutter test --plain-name "<test name>"   # one test
flutter run                               # needs an emulator or USB phone
flutter build apk --debug
dart run build_runner build               # regenerate lib/data/database.g.dart after changing tables
```

`database.g.dart` is generated but committed, so the app builds without running `build_runner` first.

## Architecture

- `lib/main.dart` wraps the app in a Riverpod `ProviderScope`. `lib/app.dart` sets up the `MaterialApp` and the theme from `lib/core/theme.dart`, where a single seed colour drives the palette.
- `lib/shell/home_shell.dart` is the bottom `NavigationBar` holding four tabs in an `IndexedStack`: Hôm nay, Linh thú, Lịch sử, Cài đặt.
- Feature code goes in `lib/features/<feature>/` (`tasks`, `pet`, `history`, `settings`). Widgets shared across features go in `lib/shared/`.
- `lib/data/` is the storage layer. `database.dart` defines the Drift tables (currently only `Tasks`, generating the `Task` row class and `TasksCompanion`). Enums are stored with `textEnum`, by name, so reordering them is safe but renaming a value needs a migration. `task_enums.dart` holds `TaskType`, `Difficulty` (with its reward multiplier), `TaskElement` (Hỏa/Thủy/Mộc) and the weekday bitmask helpers. `TaskRepository` wraps queries, and `providers.dart` exposes `databaseProvider`, `taskRepositoryProvider` and the `tasksProvider` stream.
- One `Tasks` table holds all four task types; type-specific columns (`habitUp`/`habitDown`, `repeatDays`, `cost`) are ignored for other types. Scoring columns (`value`, `streak`, `completed`) already exist for step 1.2.
- UI watches `tasksProvider` and writes through `taskRepositoryProvider`. It never touches `AppDatabase` directly. Colours and icons per element or type live in `features/tasks/task_style.dart`.
- Bumping `schemaVersion` requires adding a `MigrationStrategy` to `AppDatabase`, because users already have version 1 on their phones.
- Planned but not yet added: `flutter_local_notifications` for reminders, and Rive for pet animation.

## Testing

- Tests use an in-memory database: `AppDatabase(NativeDatabase.memory())`. Widget tests inject it with `databaseProvider.overrideWithValue(db)`.
- At the end of a widget test, unmount the tree, `pump(Duration.zero)`, and only then `db.close()`. Closing first makes `close()` wait forever under fake async, and the whole test run hangs with no output. Use the `tearDownApp` helper in `test/widget_test.dart`.
- A hung test leaves `flutter_tester.exe` holding `build/native_assets/windows/sqlite3.dll`, and every later `flutter test` fails until that process exits.

The previous project, a Godot monster-tamer game, is preserved on the `archive/ngu-thu-game` branch. Its pet sprites may only be reused once their source and license are confirmed.

## Conventions

- The owner prefers Vietnamese. Write player-facing strings and PLAN.md in Vietnamese; code identifiers stay in English.
- Do not copy code or art from Habitica. Its code is GPL v3 and its art is CC BY-NC-SA. Study its mechanics only.
- The application id is `com.hdyzute.linh_thu_ky_luat`. It becomes permanent once the app is published on Google Play.
