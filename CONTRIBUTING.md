# Contributing to FolkTool

Thank you for contributing to **[FolkTool](https://github.com/LyraVoid/FolkTool)**!

> [!NOTE]
> All contributions are licensed under [GPLv3](LICENSE). Before opening a pull request, please ensure all checks in the [Windows CI workflow](.github/workflows/windows-ci.yml) pass locally.

---

## Prerequisites (Windows)

- **OS:** Windows 10 / 11 (x64)
- **SDK:** [Flutter SDK (stable)](https://docs.flutter.dev/get-started/install/windows) with Windows desktop support enabled
- **Toolchain:** [Visual Studio 2022](https://visualstudio.microsoft.com/) with **Desktop development with C++**
- **Installer (optional):** [Inno Setup 6](https://jrsoftware.org/isinfo.php) for compiling [installer.iss](installer.iss)

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

See [Architecture & Asset Ownership](docs/ARCHITECTURE_AND_ASSETS.md) for module boundaries and binary asset SHA-256 verification.

| Layer | Directory / File | Purpose |
| :--- | :--- | :--- |
| **App Shell** | [folk_tool_app.dart](lib/app/folk_tool_app.dart), [app_shell_screen.dart](lib/app/app_shell_screen.dart) | MultiProvider root & responsive `NavigationRail` / `NavigationBar` desktop shell |
| **Core Foundations** | [app_config.dart](lib/core/config/app_config.dart), [app_theme.dart](lib/core/config/app_theme.dart), [process_runner.dart](lib/core/process/process_runner.dart), [log_console.dart](lib/core/widgets/log_console.dart) | Memoized asset/tool paths, Material 3 themes, timeout-safe process execution, error banners & log console |
| **Device Feature** | [device_service.dart](lib/features/device/services/device_service.dart), [device_provider.dart](lib/features/device/providers/device_provider.dart), [device_status_card.dart](lib/features/device/widgets/device_status_card.dart) | Concurrent ADB/Fastboot monitoring, static property caching, single-call package lookup |
| **Patching Feature** | [patch_provider.dart](lib/features/patching/providers/patch_provider.dart), [kptools_service.dart](lib/features/patching/services/kptools_service.dart), [safety_service.dart](lib/features/patching/services/safety_service.dart) | Pre-flight safety checks, boot backup/restore, state machine, KPM module selection |
| **Drivers, Files & Settings** | [driver_service.dart](lib/features/drivers/services/driver_service.dart), [file_service.dart](lib/features/files/services/file_service.dart), [settings_screen.dart](lib/features/settings/screens/settings_screen.dart) | Authenticode-verified driver installers, recent files & log export, preferences |
| **Win32 Runner** | [main.cpp](windows/runner/main.cpp), [win32_window.cpp](windows/runner/win32_window.cpp), [Runner.rc](windows/runner/Runner.rc) | Work-area clamped DPI-aware window creation, desktop sizing & canonical icon embedding |
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
