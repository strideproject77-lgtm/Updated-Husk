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
case "$DD" in
  /*) ;;
  *) DD="$ROOT/$DD" ;;
esac
APP="$DD/Build/Products/Release-iphoneos/Stride.app"
mkdir -p "$(dirname "$OUT")" "$DD"

command -v xcodegen >/dev/null || { echo "xcodegen is required" >&2; exit 1; }
command -v xcodebuild >/dev/null || { echo "xcodebuild is required" >&2; exit 1; }
command -v ditto >/dev/null || { echo "ditto is required" >&2; exit 1; }
command -v zip >/dev/null || { echo "zip is required" >&2; exit 1; }
command -v unzip >/dev/null || { echo "unzip is required" >&2; exit 1; }

(cd "$ROOT/src/app" && xcodegen generate --quiet)

echo "==> building Stride for iphoneos without Apple code signing"
# Preserve xcodebuild's real exit status; do not mask a failed build with a successful final pipeline command.
set +e
xcodebuild -project "$PROJECT" -scheme Husk -sdk iphoneos -configuration Release \
  -derivedDataPath "$DD" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" build 2>&1 | tee "$DD/build.log"
BUILD_STATUS=${PIPESTATUS[0]}
set -e

if [ "$BUILD_STATUS" -ne 0 ] || ! grep -q "BUILD SUCCEEDED" "$DD/build.log"; then
  echo "Xcode build failed (exit $BUILD_STATUS); refusing to package" >&2
  grep -E "error:|warning:" "$DD/build.log" | tail -40 >&2 || true
  exit 1
fi

[ -d "$APP" ] || { echo "Missing app product: $APP" >&2; exit 1; }

PLIST="$APP/Info.plist"
for key in CFBundleIdentifier CFBundleExecutable CFBundleName CFBundlePackageType CFBundleVersion CFBundleShortVersionString MinimumOSVersion UIDeviceFamily; do
  value="$(/usr/libexec/PlistBuddy -c "Print :$key" "$PLIST" 2>/dev/null || true)"
  [ -n "$value" ] || { echo "Missing required Info.plist key: $key" >&2; exit 1; }
done
EXE="$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "$PLIST")"
[ -f "$APP/$EXE" ] || { echo "Missing app executable: $EXE" >&2; exit 1; }

# A truly unsigned IPA must not contain an app signature or provisioning profile.
if codesign -dv "$APP" >/dev/null 2>&1; then
  echo "App unexpectedly has a code signature; refusing to label it unsigned" >&2
  exit 1
fi
[ ! -e "$APP/embedded.mobileprovision" ] || { echo "Unexpected provisioning profile in unsigned app" >&2; exit 1; }

STAGE="$(mktemp -d "$DD/unsigned-stage.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
mkdir -p "$STAGE/Payload"
ditto "$APP" "$STAGE/Payload/Stride.app"
(cd "$STAGE" && /usr/bin/zip -qry "$OUT" Payload)
unzip -t "$OUT" >/dev/null
unzip -Z1 "$OUT" | grep -Fxq "Payload/Stride.app/Info.plist" || {
  echo "IPA is missing Payload/Stride.app/Info.plist" >&2
  exit 1
}
unzip -Z1 "$OUT" | grep -Fxq "Payload/Stride.app/$EXE" || {
  echo "IPA is missing the Stride executable" >&2
  exit 1
}

echo "==> unsigned IPA ready: $OUT"
