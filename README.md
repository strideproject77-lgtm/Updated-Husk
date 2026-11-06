<p align="center">
  <img src="src/app/Husk/Assets.xcassets/AppIcon.appiconset/Icon-Default.png" width="120" height="120" alt="Stride">
</p>

<h1 align="center">Stride</h1>

<p align="center">Run Android apps and games on iPhone through a native compatibility runtime.</p>

<p align="center"><strong>Experimental Android translation layer for iOS</strong></p>

Stride is an independent project built by modifying and extending the open-source Husk codebase. The app, product identity, interface and ongoing development are branded as **Stride**. Original upstream copyright notices and third-party licence terms remain preserved in the source tree.

## What Stride is

Stride is an experimental iOS runtime that aims to load Android application packages and translate the Android software interfaces they depend on into native iOS-compatible services.

Current development areas include:

- **DEX execution:** Java bytecode loading, runtime dispatch and Android application startup.
- **Android compatibility:** framework APIs, resources, package metadata, intents and services.
- **Native compatibility:** JNI, Bionic interfaces, ELF loading and native symbol resolution.
- **Graphics:** translating Android graphics workloads to iOS graphics APIs.
- **Input and audio:** touch, controller, sound and device integration.

Compatibility is not guaranteed by APK scanning or successful installation. A game is considered working only after it launches and renders correctly on a real device.

## Build

Build on macOS with Xcode and the required native build tools:

```sh
./scripts/ci_build.sh
```

The standard output is `build/Stride.ipa`.

For an unsigned CI build, open **Actions → Unsigned iOS IPA** and run the workflow on `main`. A successful run uploads the `Stride-unsigned-IPA` artifact.

## Compatibility and limitations

Stride is experimental. Some Android APIs, native libraries, graphics paths and games are not implemented yet. Check the project documentation and test reports for verified status; do not treat planned features as completed.

The existing `com.husk.app` bundle identifier and `husk://` URL scheme are intentionally retained during this transition so an update can preserve installation and sideload callback compatibility. They are internal compatibility identifiers, not the displayed product name.

## Licence and upstream attribution

Stride contains modified code derived from **Husk** by Leviidev and contributors. The applicable project licence is **GPL-2.0-or-later**; see [LICENSE](LICENSE) and [docs/01-licensing.md](docs/01-licensing.md). Original copyright notices and all bundled third-party notices must remain with the source and distributed builds. This project is not the original upstream Husk release.
