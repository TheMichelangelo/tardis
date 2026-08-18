#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

flutter pub get
flutter analyze
flutter test
flutter build apk --release

mkdir -p web/downloads
cp build/app/outputs/flutter-apk/app-release.apk \
  web/downloads/stem-laboratory.apk

flutter build web --release --base-href /tardis/
cp build/web/index.html build/web/404.html
touch build/web/.nojekyll

printf 'Android repository artifact: %s\n' \
  "$project_root/web/downloads/stem-laboratory.apk"
printf 'Android build artifact: %s\n' \
  "$project_root/build/app/outputs/flutter-apk/app-release.apk"
printf 'Web build: %s\n' "$project_root/build/web"
