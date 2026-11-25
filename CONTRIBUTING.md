# Contributing to FolkTool

Thank you for contributing to **[FolkTool](https://github.com/LyraVoid/FolkTool)**!

> [!NOTE]
> All contributions are licensed under [GPLv3](LICENSE). Before opening a pull request, please ensure all checks in the [Windows CI workflow](.github/workflows/windows-ci.yml) pass locally.

---

## Prerequisites (Windows)

- **OS:** Windows 10 / 11 (x64)
- **SDK:** [Flutter SDK (stable)](https://docs.flutter.dev/get-started/install/windows) with Windows desktop support enabled
- **Toolchain:** [Visual Studio 2022](https://visualstudio.microsoft.com/) with **Desktop development with C++**
- **Installer (optional):** [Inno Setup 6](https://jrsoftware.org/isinfo.php) for compiling [installer.iss](installer.iss) / [install.iss](install.iss)

---

## Local Development Setup

```powershell
git clone https://github.com/LyraVoid/FolkTool.git
cd FolkTool
flutter pub get
flutter analyze --no-fatal-infos
flutter test --reporter expanded
flutter run -d windows
```

---

## Project Architecture

| Layer | Directory / File | Purpose |
| :--- | :--- | :--- |
| **Theme & Config** | [app_theme.dart](lib/config/app_theme.dart), [app_semantic_colors.dart](lib/config/app_semantic_colors.dart), [constants.dart](lib/config/constants.dart) | Material 3 Light/Dark themes, semantic tokens, paths & repo metadata |
| **State Providers** | [providers.dart](lib/providers/providers.dart) | `DeviceProvider`, `PatchProvider`, `VersionProvider`, `ThemeProvider`, `LocaleProvider` |
| **Core Services** | [services.dart](lib/services/services.dart) | `DeviceService`, `KpToolsService`, `FileService`, `SafetyService`, `UpdateService`, `DriverService` |
| **UI Screens & Widgets** | [screens.dart](lib/screens/screens.dart), [widgets.dart](lib/widgets/widgets.dart) | Home, Quick/Simple/Step Patch, Driver Install, Log Console, Status Cards |
| **Win32 Runner** | [main.cpp](windows/runner/main.cpp), [win32_window.cpp](windows/runner/win32_window.cpp) | Work-area clamped DPI-aware window creation & `WM_GETMINMAXINFO` |
| **Localization** | [intl_en.arb](lib/l10n/intl_en.arb), [intl_zh.arb](lib/l10n/intl_zh.arb) | English & Chinese ARB strings + generated `lib/generated/` |

---

## Building the Windows Release & Installer

```powershell
flutter build windows --release --dart-define=APP_VERSION=1.7.0
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" /DMyAppVersion=1.7.0 installer.iss
```

> [!TIP]
> To build a completely self-contained **offline** installer, place `vc_redist.x64.exe` inside a `redist/` folder before running `ISCC.exe`. Otherwise, the installer downloads it automatically when missing.

---

## Pull Request Guidelines

1. Keep changes focused and ensure `flutter analyze --no-fatal-infos` and `flutter test` pass.
2. Update both [intl_en.arb](lib/l10n/intl_en.arb) and [intl_zh.arb](lib/l10n/intl_zh.arb) (along with [lib/generated/](lib/generated/l10n.dart)) when adding UI strings.
3. Never commit personal device serials, private keys, or credentials.
4. For ADB/Fastboot changes, add unit tests using `ProcessRunner` mocks (see [device_service_test.dart](test/device_service_test.dart)).
5. Use the [Pull Request Template](.github/PULL_REQUEST_TEMPLATE.md) when submitting a PR.
