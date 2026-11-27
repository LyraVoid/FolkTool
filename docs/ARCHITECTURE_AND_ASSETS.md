# FolkTool Architecture & Asset Ownership

## 1. Feature-Oriented Architecture (`lib/`)

FolkTool uses a pragmatic, acyclic feature-oriented layout under `lib/`:

- **`lib/app/`**: Application root (`FolkToolApp` with `MultiProvider`) and responsive desktop navigation shell (`AppShellScreen` with `NavigationRail`, `NavigationBar`, and Dashboard).
- **`lib/core/`**: Cross-cutting foundations with zero upward imports into `features/`:
  - `config/`: Memoized runtime paths (`AppConfig`), Material 3 light/dark themes (`AppTheme`), and semantic color/spacing tokens (`AppSemanticColors`).
  - `errors/`: Structured actionable errors (`AppError`).
  - `logging/`: Structured `LogEntry` records and `Random.secure()`-backed `generateOperationId()`.
  - `process/`: `ProcessRunner` (`DefaultProcessRunner`) built directly on `dart:io` `Process.start` (`runInShell: false`) with stream draining and timeout kill-on-expiry.
  - `updates/`: Non-blocking GitHub Release version check (`UpdateService`).
  - `widgets/`: Reusable `ErrorBanner` and memoized `LogConsole`.
- **`lib/features/`**: Domain-scoped feature modules:
  - `device/`: `DeviceInfo`, `DeviceService` (concurrent ADB/Fastboot probing and single-call `pm list packages`), `DeviceProvider` (per-serial static property caching + snapshot-diff notification gating), and `DeviceStatusCard` / `ClientCheckCard`.
  - `drivers/`: `DriverService` (Authenticode verification via `ProcessRunner`) and `DriverInstallScreen`.
  - `files/`: `FileService` (boot/KPM file pickers, recent file history, backup/log directories, Explorer reveal, and path/serial diagnostic redaction).
  - `patching/`: Models (`KpVersion`, `OperationStep`, `PatchResult`, `PatchTarget`), services (`KpToolsService`, `SafetyService`, `VersionService`), providers (`PatchProvider`, `VersionProvider`), granular `Selector`-driven screens (`QuickPatchScreen`, `SimplePatchScreen`, `StepPatchScreen`), and shared selector widgets.
  - `settings/`: Persisted preferences (`SettingsProvider`, `ThemeProvider`, `LocaleProvider`) and `SettingsScreen`.

## 2. Asset & Binary Inventory (SHA-256 Verified)

Auditing all binary directories confirmed that seemingly similar binaries serve distinct roles and are not blind duplicates:

| Directory / File | SHA-256 Prefix / Details | Ownership & Packaging Strategy |
|---|---|---|
| `assets/icons/icon.ico` | `5b0ea07a...` (86,380 B, 256×256 RGBA PNG inside ICO) | Canonical source of truth referenced directly by `windows/runner/Runner.rc` (`IDI_APP_ICON`) and `installer.iss` (`SetupIconFile`). Stale `windows/runner/resources/app_icon.ico` was removed and CI verifies PE `RT_ICON` hash match in both `FolkTool.exe` and `FolkTool-Setup.exe`. |
| `bin/` | Android SDK Platform-Tools (32-bit `adb.exe`, `fastboot.exe`, `AdbWin*.dll`, `sqlite3.exe`, `mke2fs*`, `make_f2fs*`, `7za.exe`) + 64-bit `bin/kptools.exe` (`ae43f3da...`) & MSYS2 runtime | Copied directly to `{app}\bin\` beside `FolkTool.exe` (excluded from `pubspec.yaml` `flutter: assets:` so binaries are not duplicated inside `data\flutter_assets\`). |
| `kp_versions/windows/` | Distinct 64-bit `kptools.exe` (`cda2dd4e...`, 741,573 B) paired with `msys-2.0.dll` (`80817f15...`) and `msys-z.dll` (`f548bb16...`) | Copied directly to `{app}\kp_versions\windows\` as `AppConfig.kptoolsPath`; kept separate from `bin/kptools.exe` (`ae43f3da...`) because both build hash and MSYS runtime hashes differ. |
| `kp_versions/folkpatch/kpimg`, `kp_versions/apatch/kpimg`, `assets/kpimg` | `201871cc...`, `ac85815f...`, `6a3507dc...` (all distinct builds) | Copied directly to `{app}\kp_versions\` and `{app}\assets\kpimg` (`assets/kpimg` serves as fallback when `kpVersion` is null). |
| `apk/APatch.apk`, `apk/FolkPatch.apk` | Android companion APKs | Copied to `{app}\apk\` in `installer.iss` and Portable ZIP for `DeviceService.installAPatch()` / `installFolkPatch()`. |
| `drive/` | Bundled USB/Fastboot driver executables (104 MB) | Retained under `pubspec.yaml` `flutter: assets:` because `DriverService` extracts them lazily via `rootBundle.load('drive/...')` on demand, working identically in Debug and Release modes. |

## 3. Installer Consolidation

`install.iss` previously duplicated preprocessor overrides around `installer.iss` and produced a discarded second installer in CI. It has been removed; [installer.iss](../installer.iss) is the single installer definition using `lzma2` compression, non-admin default (`PrivilegesRequired=lowest` with optional elevation), Microsoft Authenticode verification before `vc_redist.x64.exe` execution, and canonical `assets/icons/icon.ico` branding.
