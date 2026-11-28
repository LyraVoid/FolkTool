# FolkTool — Windows Installation, Code Signing & Trust Guide

## 1. How FolkTool Is Built & Packaged

FolkTool targets **Windows 10 / 11 x64** (`flutter build windows --release --dart-define=APP_VERSION=<version>`).

1. **Application binary (`FolkTool.exe`)**:
   - Compiled by MSVC via `windows/CMakeLists.txt` and `windows/runner/Runner.rc`.
   - Declares `/MANIFESTUAC:level='asInvoker' uiAccess='false'` in `windows/runner/CMakeLists.txt` alongside `windows/runner/runner.exe.manifest` (`PerMonitorV2` DPI awareness) so normal app usage runs under standard user privileges without triggering full-app UAC elevation.
   - Creates a session-scoped named mutex (`Local\FolkToolRunningMutex`) in `windows/runner/main.cpp` so upgrades and uninstallers reliably detect running instances.
   - Embeds `assets/icons/icon.ico` (multi-resolution `16x16`, `24x24`, `32x32`, `48x48`, `64x64`, `128x128`, `256x256`) directly via `IDI_APP_ICON`.
2. **Installer (`FolkTool-Setup.exe`) & Uninstaller (`unins000.exe`)**:
   - Compiled from the single authoritative script [`installer.iss`](../installer.iss) using Inno Setup 6 (`ISCC.exe`).
   - Bundles `FolkTool.exe`, `flutter_windows.dll`, `url_launcher_windows_plugin.dll`, `data\`, `bin\`, `apk\`, `assets\`, and `kp_versions\`.
   - Embeds the same canonical `assets/icons/icon.ico` into `FolkTool-Setup.exe`, `unins000.exe`, Start Menu/Desktop shortcuts, and Windows Installed Apps (`UninstallDisplayIcon`).

---

## 2. Authenticode Code Signing & Publisher Identity

### Why `Publisher: Unknown` and Smart App Control Blocks Occur

| Prompt / Block | Root Cause | Technical Fix |
|---|---|---|
| **UAC `Publisher: Unknown`** | No valid Authenticode digital signature (or an expired/untrusted self-signed certificate) is embedded in `FolkTool-Setup.exe` / `unins000.exe`. Icons or Inno metadata alone cannot populate UAC publisher identity. | SHA-256 Authenticode signing with an RFC 3161 trusted timestamp on `FolkTool.exe`, plugin/engine DLLs, `unins000.exe` (`SignedUninstaller=yes`), and `FolkTool-Setup.exe`. |
| **Windows 11 Smart App Control (SAC)** | In Enforcement mode, SAC only permits executables/DLLs that are either validly signed by a CA in the Microsoft Trusted Root Program **and all loaded dependencies are signed**, or positively recognized by Microsoft Intelligent Security Graph cloud reputation. | Sign all first-party EXEs, DLLs, uninstaller, and installer with a trusted CA (Microsoft Artifact Signing, SignPath Foundation, or commercial OV CA), and audit every third-party helper dependency. |

### Supported Trusted Signing Providers

`.github/workflows/windows-ci.yml` keeps all credentials out of Git, blocks secret exposure on pull requests, fails hard on release tags (`v*`) if signing is missing or verification fails, and supports:

1. **Microsoft Artifact Signing (Recommended when region/account eligible)**
   - Uses passwordless GitHub OIDC (`azure/login@v2`) plus `Microsoft.Azure.ArtifactSigningClientTools` (`Azure.CodeSigning.Dlib.dll`) invoked through `signtool.exe` and Inno Setup's `/Sfolktool_sign=...`.
   - Signing certificates chain directly to Microsoft's root infrastructure, establishing immediate cryptographic trust for UAC and SAC on Microsoft-verified binaries.
2. **SignPath Foundation (Open-Source Alternative)**
   - Qualifying OSI-licensed projects (`GPL-3.0`) on GitHub Actions can apply at `https://signpath.org/` so protected release tags submit artifacts via OIDC without storing private keys in GitHub secrets.
3. **Commercial OV Certificate (`WINDOWS_CERT_PFX_BASE64` / HSM CLI)**
   - Standard Organization Validation certificate issued by a Microsoft Trusted Root CA (e.g., DigiCert, Sectigo, GlobalSign), timestamped with SHA-256 RFC 3161 (`http://timestamp.digicert.com`).

> **Self-signed certificates** are **never** used for production releases. Unsigned builds generated from pull requests or forks are strictly CI verification builds and cannot trigger a GitHub Release.

---

## 3. Executable Chain & Bundled Third-Party Dependencies Audit

FolkTool never overwrites upstream third-party signatures with FolkTool's identity unless licensing, provenance, and policy permit it:

| Component | Source / Purpose | Signature Status | Smart App Control Impact |
|---|---|---|---|
| `FolkTool.exe`, `flutter_windows.dll`, `url_launcher_windows_plugin.dll`, `FolkTool-Setup.exe`, `unins000.exe` | First-party app, Flutter Windows engine/plugins, Inno installer/uninstaller | **Signed in release CI** (when signing provider is configured) | Trusted once signed by a Microsoft Trusted Root CA / Artifact Signing |
| `bin/adb.exe`, `bin/fastboot.exe`, `bin/AdbWinApi.dll`, `bin/AdbWinUsbApi.dll`, `bin/sqlite3.exe`, `bin/mke2fs.exe`, `bin/make_f2fs*.exe` | Google Android SDK Platform-Tools | **Signed by Google LLC** (original signature preserved) | Trusted cryptographic publisher |
| `drive/fastboot_driver_64.exe`, `drive/fastboot_driver_32.exe`, `drive/Oppo+USB+Driver+Setup+V4.0.1.6.exe` | OEM / vendor USB driver installers | **Signed by upstream OEMs** | Verified via `Get-AuthenticodeSignature` before launch |
| `drive/adb_driver.exe`, `drive/MTK_USB_All_v1.0.8.exe` | Legacy bundled USB driver installers | **Unsigned** | **Blocked by default** (`DriverService` enforces Authenticode check before running) |
| `kp_versions/windows/kptools.exe`, `msys-2.0.dll`, `msys-z.dll` (+ `bin/kptools.exe`, `bin/msys-*.dll`) | Upstream KernelPatch MSYS2 tools (`bmax121/KernelPatch`) | **Unsigned upstream builds** | When Windows 11 Smart App Control is in Enforcement mode, patching operations that spawn unsigned `kptools.exe` / load `msys-2.0.dll` may still be blocked unless Microsoft cloud reputation recognizes them or signed upstream builds become available |
| `bin/7za.exe` | Auxiliary 7-Zip CLI (not invoked by FolkTool) | **Unsigned** | Unused by FolkTool's runtime workflows |

---

## 4. SmartScreen Reputation Limitations

Code signing with a trusted CA (Artifact Signing, SignPath, or OV certificate) establishes **publisher identity**, **integrity**, and **Smart App Control trust**, **not instant Microsoft Defender SmartScreen reputation**:

- Freshly released binaries—especially newly compiled version bumps—may initially display a SmartScreen warning (`Windows protected your PC`) until Microsoft's cloud reputation accumulates sufficient clean download/execution telemetry across users.
- Purchasing an EV certificate does not guarantee zero initial SmartScreen prompts under current Microsoft reputation rules.
- Maintaining the exact same publisher identity across releases, publishing exclusively via official GitHub Releases with `SHA256SUMS.txt`, and timestamping every signature accelerates steady reputation growth.

---

## 5. How to Verify an Official FolkTool Release

Before launching `FolkTool-Setup.exe` or `FolkTool-Windows-Portable.zip`:

1. **Download only from the official GitHub Releases page** alongside `SHA256SUMS.txt`.
2. **Verify SHA-256 checksum**:
   ```pwsh
   Get-FileHash .\FolkTool-Setup.exe -Algorithm SHA256
   ```
   Confirm the hash matches `SHA256SUMS.txt`.
3. **Verify Authenticode signature and RFC 3161 timestamp**:
   ```pwsh
   Get-AuthenticodeSignature .\FolkTool-Setup.exe | Format-List Status, SignerCertificate, TimeStamperCertificate
   signtool verify /pa /v .\FolkTool-Setup.exe
   ```
   Confirm `Status` is `Valid`, `SignerCertificate.Subject` matches the documented release publisher, and `TimeStamperCertificate` is present.

---

## 6. Installation, Upgrade, Repair, Clean Install & Uninstall Lifecycle

### Privileges
- `installer.iss` uses `PrivilegesRequired=lowest` with `PrivilegesRequiredOverridesAllowed=dialog`.
- Users may install for the current account (`%LOCALAPPDATA%\Programs\FolkTool`) without elevation or choose **Install for all users** (`%ProgramFiles%\FolkTool`) with an explicit UAC prompt.
- Driver installations run **only on explicit user action** in the Driver Install tab, after signature checking and standard UAC consent.

### Installation Modes
- **First-Time Installation**: Installs app files, creates Start Menu app + Uninstall shortcuts, optionally creates a Desktop shortcut (`{autodesktop}`), registers the Uninstall entry under `AppId={{A1B2C3D4-E5F6-4789-A0B1-C2D3E4F5A6B7}`, and leaves post-install launch unchecked unless explicitly selected.
- **Upgrade / Repair**: Re-running `FolkTool-Setup.exe` detects the existing `AppId`, preserves the installation folder and all user preferences/logs/boot files, closes running FolkTool processes scoped inside `{app}`, restores missing or corrupted application files (`Flags: ignoreversion`), repairs shortcuts/registry metadata, and avoids duplicate Installed Apps entries.
- **Clean Installation**: Selecting **Clean Installation** in the wizard (or `/CLEANINSTALL` CLI switch) closes running `{app}` processes, removes application-owned subdirectories (`data`, `bin`, `apk`, `assets`, `kp_versions`, `redist`) and root app binaries before reinstalling fresh files cleanly. User documents/firmware are never deleted. Optionally resetting AppData preferences requires **explicit confirmation** (or `/PURGEAPPDATA`) and backs up `shared_preferences.json` to `Documents\FolkTool\backup\settings_backup_<timestamp>.json` first.

### Uninstallation & Data Preservation
Available via **Windows Settings → Apps → Installed apps**, **Control Panel → Programs and Features**, or **Start Menu → Uninstall FolkTool**:

1. Closes running FolkTool processes inside the install folder without killing external ADB/Fastboot tools elsewhere on the system.
2. Removes installed binaries, shortcuts, `BUILD_INFO.txt`, and the Uninstall registry entry.
3. **Preserves user data by default**:
   - `%APPDATA%\FolkTool\` (`shared_preferences.json`) and logs are kept unless the user explicitly opts in via the confirmation prompt (defaulting to **No / Keep**) or `/PURGEAPPDATA`.
   - `Documents\FolkTool\patched\`, `Documents\FolkTool\backup\`, user-selected `.img`/`.kpm` files, and shared Windows USB/ADB system drivers are **never** removed by either Clean Install or Uninstall.
4. Verifies `FolkTool.exe` and `flutter_windows.dll` are actually absent post-uninstall and warns cleanly if locked files require a Windows reboot.

---

## 7. Remaining Known Limitations

1. **Signing secrets must be provisioned by the repository maintainer**: Until Microsoft Artifact Signing, SignPath Foundation, or a Commercial OV certificate secret is configured in GitHub repository settings, non-tag CI runs produce unsigned test builds and tag releases are blocked by design.
2. **Upstream unsigned KernelPatch binaries**: `kptools.exe` and MSYS2 DLLs (`msys-2.0.dll`, `msys-z.dll`) ship unsigned from upstream; Microsoft Smart App Control in strict Enforcement mode may block them until signed upstream builds exist or Microsoft cloud reputation allows them.
3. **Interactive Smart App Control & SmartScreen evaluation**: Cannot be exercised headless on GitHub Actions `windows-latest` runners (which have SAC disabled); final pre-tag manual testing should include a clean Windows 11 VM/PC with SAC and SmartScreen active.