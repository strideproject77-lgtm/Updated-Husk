#!/bin/bash
# Build and package a genuinely unsigned Husk IPA for later sideload signing.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/build/Husk-unsigned.ipa}"
DD="${DD:-$ROOT/build/unsigned-derived}"
PROJECT="$ROOT/src/app/Husk.xcodeproj"
APP="$DD/Build/Products/Release-iphoneos/Husk.app"
mkdir -p "$(dirname "$OUT")" "$DD"

command -v xcodegen >/dev/null || { echo "xcodegen is required" >&2; exit 1; }
(cd "$ROOT/src/app" && xcodegen generate --quiet)

echo "==> building Husk for iphoneos without Apple code signing"
set -o pipefail
xcodebuild -project "$PROJECT" -scheme Husk -sdk iphoneos -configuration Release \
  -derivedDataPath "$DD" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" build 2>&1 | tee "$DD/build.log" | grep -E "error:|BUILD (SUCCEEDED|FAILED)" || true

if ! grep -q "BUILD SUCCEEDED" "$DD/build.log"; then
  echo "Xcode build failed; refusing to package" >&2
  grep -E "error:" "$DD/build.log" | head -20 >&2 || true
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
ditto "$APP" "$STAGE/Payload/Husk.app"
(cd "$STAGE" && /usr/bin/zip -qry "$OUT" Payload)
unzip -t "$OUT" >/dev/null
echo "==> unsigned IPA ready: $OUT"
