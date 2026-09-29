#!/usr/bin/env bash

# Starts the STEM Laboratory locally. With no arguments it opens the web app
# in Chrome; pass Flutter run options to target a different device instead.
# Examples:
#   ./scripts/start_local.sh
#   ./scripts/start_local.sh -d macos
#   ./scripts/start_local.sh -d <android-device-id>

set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter was not found. Install Flutter and add it to your PATH." >&2
  exit 1
fi

flutter pub get

if [[ $# -eq 0 ]]; then
  exec flutter run -d chrome
fi

exec flutter run "$@"
