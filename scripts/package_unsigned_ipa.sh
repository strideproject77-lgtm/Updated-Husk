#!/bin/bash
# Build and package a genuinely unsigned Stride IPA for later sideload signing.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/build/Stride-unsigned.ipa}"
DD="${DD:-$ROOT/build/unsigned-derived}"
PROJECT="$ROOT/src/app/Husk.xcodeproj"
APP="$DD/Build/Products/Release-iphoneos/Stride.app"

# Resolve relative output paths before changing into the temporary staging directory.
case "$OUT" in
  /*) ;;
  *) OUT="$ROOT/$OUT" ;;
esac
mkdir -p "$(dirname "$OUT")" "$DD"

command -v xcodegen >/dev/null || { echo "xcodegen is required" >&2; exit 1; }
command -v xcodebuild >/dev/null || { echo "xcodebuild is required" >&2; exit 1; }
command -v ditto >/dev/null || { echo "ditto is required" >&2; exit 1; }
command -v zip >/dev/null || { echo "zip is required" >&2; exit 1; }
command -v unzip >/dev/null || { echo "unzip is required" >&2; exit 1; }

(cd "$ROOT/src/app" && xcodegen generate --quiet)

echo "==> building Stride for iphoneos without Apple code signing"
# Preserve xcodebuild's real exit status. The previous pipeline ended in
# 