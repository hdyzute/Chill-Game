# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

"Linh Thú Kỷ Luật" is a **habit-tracker app with a virtual pet**, built with Flutter and targeting Android first. [PLAN.md](PLAN.md) (in Vietnamese) holds the product design, the mechanics borrowed from Habitica, the tech stack and the phased roadmap. Read it before starting any work, and follow its phase order. Phase 0 (scaffold) is done; the tab screens are still placeholders.

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
```

## Architecture

- `lib/main.dart` wraps the app in a Riverpod `ProviderScope`. `lib/app.dart` sets up the `MaterialApp` and the theme from `lib/core/theme.dart`, where a single seed colour drives the palette.
- `lib/shell/home_shell.dart` is the bottom `NavigationBar` holding four tabs in an `IndexedStack`: Hôm nay, Linh thú, Lịch sử, Cài đặt.
- Feature code goes in `lib/features/<feature>/` (`tasks`, `pet`, `history`, `settings`). Widgets shared across features go in `lib/shared/`.
- Planned but not yet added: Drift (SQLite) for local storage, `flutter_local_notifications` for reminders, and Rive for pet animation.

The previous project, a Godot monster-tamer game, is preserved on the `archive/ngu-thu-game` branch. Its pet sprites may only be reused once their source and license are confirmed.

## Conventions

- The owner prefers Vietnamese. Write player-facing strings and PLAN.md in Vietnamese; code identifiers stay in English.
- Do not copy code or art from Habitica. Its code is GPL v3 and its art is CC BY-NC-SA. Study its mechanics only.
- The application id is `com.hdyzute.linh_thu_ky_luat`. It becomes permanent once the app is published on Google Play.
