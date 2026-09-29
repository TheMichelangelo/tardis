# STEM Laboratory — Project Guide

## Scope and architecture

- The production application is Flutter/Dart. Start at `lib/main.dart` and
  `lib/app.dart`; features live under `lib/features/`.
- `App.tsx` and the TypeScript files under `src/` are legacy Expo/React Native
  material. Do not add product features there unless the task explicitly targets
  that legacy app.
- The same Flutter code supports Android, iOS, and web. Keep layouts responsive
  for narrow phones, tablets, and desktop browsers.

## Running and checking changes

```bash
./scripts/start_local.sh
dart format lib test
flutter analyze
flutter test
```

Pass a device to the start script when needed, for example
`./scripts/start_local.sh -d macos` or `./scripts/start_local.sh -d <device-id>`.

Run the focused relevant test first, then the full test suite for broad changes.
Tests include responsive and Unicode coverage; do not remove those checks merely
to accommodate a layout change.

## Content, localization, and assets

- Lesson catalogs are in `src/data/*_class_stem_lesson_{ua,en}.json` and are
  bundled through `pubspec.yaml`.
- Keep `public/src/data/` synchronized with matching files in `src/data/` when
  editing catalog content; it is the web mirror.
- Keep lesson `number` values and all ten exercise-slot positions stable so
  shared seven-digit lesson codes continue to resolve correctly. Empty slots use
  `"isPlaceholder": true`.
- UI strings belong in `lib/core/localization.dart`. If a page must react to a
  language change, ensure it listens to `LanguageController` rather than relying
  on a manual refresh.
- Add static images and documents under `src/data/`, then register Flutter assets
  in `pubspec.yaml` when necessary.

## UI conventions

- Use Material widgets and the app theme in `lib/core/app_theme.dart`.
- Preserve accessibility: semantic labels, keyboard navigation, visible focus,
  readable contrast, and scalable text.
- For home-page changes, retain the full-screen STEM image background and its
  decorative formula layer. Interactive content must remain readable on top.
- Avoid fixed layouts that overflow at 320 px wide or with enlarged text.

## Repository hygiene

- Do not edit generated build output, dependency folders, or unrelated user
  files. In particular, leave untracked documents alone unless the user names
  them as part of the task.
- Use `apply_patch` for source and documentation edits. Format changed Dart
  files before testing.
- Build releases with `./scripts/build_flutter_releases.sh`; it validates the
  project and updates the downloadable APK before building web output.
