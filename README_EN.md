# STEM Laboratory

[Українська версія](./README.md)

Flutter/Dart application for grade 5–6 STEM lessons, built from one codebase for
Android, iOS, and Web.

## Features

- Ukrainian and English lesson data and UI;
- class, module, theme, and lesson navigation with deep links;
- all/single exercise views and format filters;
- diagrams, rebuses, tables, text, embedded video, homework, quizzes, and
  connect-the-pairs exercises;
- lesson PDF print/download/share;
- persistent navigation, language, teacher session, and lesson storage;
- bcrypt-based teacher login, JSON proposal builder, and teacher-only solutions;
- Android APK download button on the web home page.

## Setup

Install Flutter stable, then run:

```bash
flutter pub get
flutter run -d chrome
```

On macOS, `brew install --cask flutter` is the shortest installation path. If
zsh reports `command not found: flutter`, reopen the terminal after installation
and verify with `which flutter` and `flutter doctor -v`.

## Verification and releases

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --release
flutter build web --release --base-href /tardis/
```

Run `./scripts/build_flutter_releases.sh` to verify the project, build Android,
copy the APK to `web/downloads/stem-laboratory.apk`, and build GitHub Pages.

For iOS, install CocoaPods, run `pod install` inside `ios/`, and use
`flutter build ios --release`. App Store distribution additionally requires an
Apple Developer Team and signing profile.

## GitHub Pages

Two independent workflows run on every push/merge to `main` and support manual
runs through **Actions → Run workflow**:

- `.github/workflows/flutter-android.yml` installs Java and Flutter, runs analysis
  and tests, builds a release APK, and uploads the `stem-laboratory-android`
  artifact to the workflow run.
- `.github/workflows/flutter-pages.yml` runs analysis and tests, builds Flutter
  Web, and deploys GitHub Pages. The download button uses the APK committed at
  `web/downloads/stem-laboratory.apk`; replace that file to update the website's APK.

The workflows do not wait for each other and have separate concurrency groups.
Configure **Settings → Pages → Source → GitHub Actions** once. Change the branch
in both workflows and the `/tardis/` base path if needed.

## Storage

The default JSON-backed mode uses local preferences. Native builds can select
SQLite with:

```bash
flutter run --dart-define=STEM_STORAGE=sqlite
```

Web falls back to browser local storage. Initial lesson files remain in
`src/data/*_class_stem_lesson_{ua,en}.json`.

The old Expo/React Native code remains in `App.tsx` and `src/` as a migration
reference. Production builds use the Flutter code under `lib/`.
