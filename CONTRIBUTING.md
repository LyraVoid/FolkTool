# Contributing to FolkTool

Thank you for contributing to **FolkTool**!

## Prerequisites (Windows)

- **Windows 10/11 (x64)**
- **Flutter SDK (stable channel)** with Windows desktop support enabled
- **Visual Studio 2022** with the **Desktop development with C++** workload
- **Inno Setup 6** (optional, for building `FolkTool-Setup.exe`)

## Local Development Setup

```powershell
git clone https://github.com/rebeeh/FolkTool.git
cd FolkTool
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter run -d windows
```

## Building the Windows Release & Installer

```powershell
flutter build windows --release --dart-define=APP_VERSION=1.7.0
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" /DMyAppVersion=1.7.0 installer.iss
```

## Pull Request Guidelines

1. Keep changes focused and well-tested (`flutter analyze` and `flutter test` must pass).
2. Update both `lib/l10n/intl_en.arb` and `lib/l10n/intl_zh.arb` (and generated `l10n` files) when adding user-facing strings.
3. Never commit personal device serials, private keys, or credentials.
4. For flashing/ADB/Fastboot changes, include unit tests using `ProcessRunner` mocks.
