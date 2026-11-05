<p align="center">
  <img src="src/app/Husk/Assets.xcassets/AppIcon.appiconset/Icon-Default.png" width="120" height="120" alt="Stride">
</p>

<h1 align="center">Stride</h1>

<p align="center">Android apps and games on iPhone.</p>

<p align="center">
  <strong>Experimental native translation runtime · QEMU fallback</strong>
</p>

Stride is developed from the open-source <a href="https://github.com/Leviidev/Husk">Husk</a> codebase. This repository has its own development history and branding.

## Runtime

- **Native translation layer** — engine-specific drivers, a native Android library loader, JNI/Bionic compatibility and a Dalvik/DEX runtime.
- **Android guest** — QEMU-based Android environment for workloads that need a full guest.
- **PS4 support** — experimental console components remain part of the source tree.

An APK scan only identifies likely engines and native libraries. It does **not** guarantee that an app will launch. Compatibility is confirmed only when the app starts and renders frames on a real device.

## Build

On macOS with Xcode, install the native build tools and Rust iOS target, then run:

```sh
./scripts/ci_build.sh
```

The standard build output is `build/Stride.ipa`.

The manual unsigned builder is available in **Actions → Unsigned iOS IPA**. It produces a `Stride-unsigned.ipa` artifact when the build succeeds.

## Important build notes

The app's Java translation path requires the bundled `build/java-runtime` assets. Android system fonts and certificates are staged from `build/android-system`. A build that omits these assets may still compile, but some Android apps will not start correctly.

The app keeps the existing `com.husk.app` bundle identifier and `husk://` URL scheme for upgrade and sideload-callback compatibility while the visible product name is Stride.

## Licence

GPL-2.0-or-later. See [LICENSE](LICENSE) and [docs/01-licensing.md](docs/01-licensing.md).
