# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

"Linh Thú Kỷ Luật" is a **habit-tracker app with a virtual pet**, built with Flutter and targeting Android first. [PLAN.md](PLAN.md) (in Vietnamese) holds the product design, the mechanics borrowed from Habitica, the tech stack and the phased roadmap. Read it before starting any work, and follow its phase order. Phase 0 (scaffold) is done. Phase 1 steps 1.1 (task CRUD), 1.2 (ticking, streaks, coins, rewards, undo), 1.3 (day rollover, day start hour, resting mode) and 1.4 (reminder notifications) are done. Next is 1.5 (History tab). The Pet and History tabs are still placeholders.

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
dart run drift_dev make-migrations        # after bumping schemaVersion: dumps schema, writes steps + migration test
```

`database.g.dart` and `database.steps.dart` are generated but committed, so the app builds without running `build_runner` first. `drift_schemas/` holds one JSON snapshot per schema version; never edit or delete them, because migration tests are generated from them.

## Architecture

- `lib/main.dart` wraps the app in a Riverpod `ProviderScope` (Riverpod 3: use `Notifier`/`NotifierProvider`; `StateProvider` is legacy-only and unused here). `lib/app.dart` sets up the `MaterialApp` and the theme from `lib/core/theme.dart`, where a single seed colour drives the palette. Its `home` is `DayWatcher(ReminderSync(HomeShell))`: those two invisible widgets are where background behaviour runs, so new app-wide listeners belong beside them, not inside a tab.
- `lib/shell/home_shell.dart` is the bottom `NavigationBar` holding four tabs in an `IndexedStack`: Hôm nay, Linh thú, Lịch sử, Cài đặt.
- Feature code goes in `lib/features/<feature>/` (`tasks`, `pet`, `history`, `settings`). Widgets shared across features go in `lib/shared/`.
- `lib/domain/scoring.dart` is the pure scoring formula, adapted from Habitica's `scoreTask.js`: reward = `0.9747^value × difficulty × crit × (1 + streak/100) × 10` coins. It takes the random crit roll as a parameter so tests stay deterministic.
- Good habits are capped by `Tasks.dailyTarget` (default 1): `ScoreService.score` throws `StateError` once today's `complete` logs reach it, so coins cannot be farmed by tapping repeatedly. Bad habits (`up: false`) are uncapped and give no coins.
- "Today" is a *logical* day that starts at `Profiles.dayStartHour` (0–12), not midnight. All day maths lives in `lib/domain/day.dart` (`logicalDate`, `todayStart`, `isDueOn`); never compare raw `DateTime`s for "same day". Services take a `clock`, and the app-wide one is `clockProvider`. `ScoreService` stamps log `createdAt` from its clock rather than SQLite's time, so tests can move across days.
- Day rollover (`lib/data/rollover_service.dart`, adapted from Habitica's cron) runs from `DayWatcher` (`lib/shell/day_watcher.dart`) on launch, on resume and every minute. It resets dailies' `completed`, breaks the streak of a daily missed on a scheduled day (unless `Profiles.resting`), archives completed to-dos, then stores `Profiles.lastRolloverDate`. Habit counts need no reset: `todayCountsProvider` counts logs since today's start and is rebuilt when `DayWatcher` bumps `dayTickProvider`.
- `lib/data/score_service.dart` applies scores to the database. Every score writes a `TaskLog` row with the exact deltas, inside one transaction; undo (the snackbar's "Hoàn tác" or unticking) reverses that row and deletes it. Never change `coins`, `value`, `streak` or `completed` outside `ScoreService`, or undo stops being exact.
- `lib/data/` is the storage layer. `database.dart` defines the Drift tables: `Tasks` (row class `Task`), `TaskLogs` (scoring history, no foreign key so it survives task deletion) and `Profiles` (a single row, `profileId`, holding the coin wallet and the settings, created in `beforeOpen`). Settings are written through `ProfileRepository`; coins only through `ScoreService`. `TaskRepository.watchAll` hides archived tasks. Enums are stored with `textEnum`, by name, so reordering them is safe but renaming a value needs a migration. `task_enums.dart` holds `TaskType`, `Difficulty` (with its reward multiplier), `TaskElement` (Hỏa/Thủy/Mộc) and the weekday bitmask helpers. `TaskRepository` wraps queries, and `providers.dart` exposes `databaseProvider`, `taskRepositoryProvider` and the `tasksProvider` stream.
- One `Tasks` table holds all four task types; type-specific columns (`habitUp`/`habitDown`, `repeatDays`, `cost`, `reminderMinutes`) are ignored for other types.
- UI watches `tasksProvider` and writes through `taskRepositoryProvider`. It never touches `AppDatabase` directly. Colours and icons per element or type live in `features/tasks/task_style.dart`.
- Schema changes: users already have older schema versions on their phones. Bump `schemaVersion`, run `build_runner` then `make-migrations`, add a `fromXToY` step in `AppDatabase.migration`, and extend `test/drift/app_database/migration_test.dart` with a data-integrity case.
- Reminders: `Tasks.reminderMinutes` (minutes after 0:00) on dailies and good habits. `lib/domain/reminders.dart` turns tasks into `ReminderPlan`s. These are OS-side *repeating* notifications (weekly per scheduled weekday for dailies, daily for habits), so they keep firing even if the app is never reopened. When a task is already done today, its first occurrence is pushed to the next one. `ReminderSync` (`lib/shell/reminder_sync.dart`) listens to `reminderPlansProvider` and calls `NotificationScheduler.replaceAll`, which cancels only *pending* notifications, so reminders already showing stay. Notification ids come from `reminderId(taskId, weekday)`. The notification permission is asked only when the user picks a reminder time (`_pickReminder` in `task_form_screen.dart`), not at launch.
- `LocalNotificationScheduler` uses `inexactAllowWhileIdle` on purpose: exact alarms need a permission that Google Play restricts. The Android setup (core library desugaring in `android/app/build.gradle.kts`, boot receivers and `RECEIVE_BOOT_COMPLETED` in `AndroidManifest.xml`, the `ic_notification` drawable kept by `res/raw/keep.xml`) is required by `flutter_local_notifications` 22; do not remove any of it.
- Material widgets are localized to Vietnamese (`flutter_localizations`, locale `vi`).
- Planned but not yet added: Rive for pet animation.

## Testing

- Tests use an in-memory database: `AppDatabase(NativeDatabase.memory())`. Widget tests inject it with `databaseProvider.overrideWithValue(db)`, override `clockProvider` with a fixed time, override `notificationSchedulerProvider` with `FakeScheduler` (the real plugin has no platform side in tests), and override `scoreServiceProvider` with `ScoreService(db, random: NoCritRandom(), clock: clock)` (`NoCritRandom` is in `test/helpers.dart`). Otherwise the 3% crit and the real weekday make assertions flaky.
- `drift/drift.dart` exports `isNull`/`isNotNull`, which clash with the matchers. Import it with `hide isNull, isNotNull` in tests.
- In this Flutter version a `SnackBar` with an action stays on screen until dismissed. Pass `persist: false` for snackbars that should time out.
- At the end of a widget test, unmount the tree, `pump(Duration.zero)`, and only then `db.close()`. Closing first makes `close()` wait forever under fake async, and the whole test run hangs with no output. Use the `tearDownApp` helper in `test/widget_test.dart`.
- A hung test leaves `flutter_tester.exe` holding `build/native_assets/windows/sqlite3.dll`, and every later `flutter test` fails until that process exits.

The previous project, a Godot monster-tamer game, is preserved on the `archive/ngu-thu-game` branch. Its pet sprites may only be reused once their source and license are confirmed.

## Conventions

- The owner prefers Vietnamese. Write player-facing strings and PLAN.md in Vietnamese; code identifiers stay in English.
- Do not copy code or art from Habitica. Its code is GPL v3 and its art is CC BY-NC-SA. Study its mechanics only.
- The application id is `com.hdyzute.linh_thu_ky_luat`. It becomes permanent once the app is published on Google Play.
