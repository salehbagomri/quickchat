#!/usr/bin/env bash
# dev.sh — one-shot setup + quality check for local development
# Usage: bash scripts/dev.sh [--no-test]
set -euo pipefail

NO_TEST=false
for arg in "$@"; do [[ "$arg" == "--no-test" ]] && NO_TEST=true; done

echo "==> flutter pub get"
flutter pub get

echo "==> flutter gen-l10n"
flutter gen-l10n

echo "==> build_runner"
dart run build_runner build --delete-conflicting-outputs

echo "==> flutter analyze"
flutter analyze --fatal-infos

if [[ "$NO_TEST" == "false" ]]; then
  echo "==> flutter test --coverage"
  flutter test --coverage
  echo "Coverage report: coverage/lcov.info"
fi

echo "==> All checks passed!"
