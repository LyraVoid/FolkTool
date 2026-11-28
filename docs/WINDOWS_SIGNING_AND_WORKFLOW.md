# FolkTool — Linux Development, Windows Build & Code Signing Guide

## 1. Linux Development & Windows Build Workflow

FolkTool targets **Windows 10/11 x64** while supporting active development on **Linux**.

- **Develop & verify logic/UI on Linux**:
  1. Install Flutter (`stable`, Dart SDK `^3.11.0`) and `git`.
  2. Run `flutter pub get`, `flutter analyze --no-fatal-infos`, and `flutter test --reporter expanded`.
  3. Do not attempt `flutter build windows` on Linux; Windows desktop compilation requires MSVC + Windows 10/11 SDK.
- **Build automatically via GitHub Actions** (`.github/workflows/windows-ci.yml`):
  - Runs on `windows-latest` (`x64`), executes `flutter analyze`, `flutter test`, `flutter build windows --release`, PE x64 dependency & `RT_ICON` hash verification ([verify_pe_icon.ps1](../scripts/verify_pe_icon.ps1)), compiles `installer.iss`, runs a silent install/window-bounds/uninstall smoke test, and uploads `FolkTool-Setup-Windows` (`FolkTool-Setup.exe`) and `FolkTool-Windows-Portable` (`FolkTool-Windows-Portable.zip`).
- **Build locally on bootable Windows**:
  1. Install Flutter (`stable`), Visual Studio 2022 ("Desktop development with C++"), and Inno Setup 6.
  2. Run:
     ```pwsh
     flutter pub get
     flutter analyze --no-fatal-infos
     flutter test --reporter expanded
     flutter build windows --release
     "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer.iss
     ```
  3. Output: `build\windows\x64\runner\Release\` and `installer\FolkTool-Setup.exe`.

---

## 2. Root-Cause Audit: Unknown Publisher, SmartScreen & Defender

| Warning Type | Affected Artifact | Root Cause | Fix Implemented / Required |
|---|---|---|---|
| **UAC "Unknown publisher"** | `FolkTool-Setup.exe`, `FolkTool.exe`, `unins000.exe` | Missing Authenticode digital signature; `installer.iss` previously forced `PrivilegesRequired=admin` unconditionally. | Changed `installer.iss` to `PrivilegesRequired=lowest` (`PrivilegesRequiredOverridesAllowed=dialog`, `{autopf}\FolkTool`), added `AppPublisherURL`/`AppSupportURL`/`AppUpdatesURL`, and integrated `signtool.exe` SHA-256 + RFC 3161 timestamping in CI when signing secrets are configured. |
| **Defender SmartScreen ("Windows protected your PC")** | `FolkTool-Setup.exe`, `FolkTool.exe` | Unsigned binaries and new/low-reputation files downloaded from the internet lack Microsoft SmartScreen publisher reputation. | Consistent Authenticode signing with a trusted CA (or SignPath), publishing SHA-256 checksums (`SHA256SUMS.txt`), and avoiding silent executable/driver execution (`vc_redist.x64.exe` now passes `VerifyMicrosoftSignature` before execution). |
| **Defender Antivirus detections** | Bundled tools / installers | False positives can occur on unsigned PyInstaller/Cygwin/MSYS tools or unverified downloads; FolkTool never disables Defender or adds exclusions. | Audit binary signatures in CI; if a clean signed build triggers a false positive, submit the exact binary + SHA-256 to Microsoft Security Intelligence (`https://www.microsoft.com/en-us/wdsi/filesubmission`). |

---

## 3. Code-Signing Options

### Option 1: SignPath Foundation (Recommended for Open Source)
- **Eligibility**: FolkTool is licensed under **GPL-3.0** (`LICENSE`), an OSI-approved open-source license, and builds reproducibly from public GitHub Actions (`windows-ci.yml`).
- **Maintainer Steps**:
  1. Apply at `https://signpath.org/` with repository ownership (`LyraVoid/FolkTool`).
  2. Configure GitHub Actions OIDC / SignPath connector and signing policy on protected release tags (`v*`).

### Option 2: Commercial OV Code-Signing Certificate (Available in India)
- Reputable CAs (DigiCert, Sectigo, GlobalSign) issue OV Authenticode certificates to verified organizations/individuals in India using FIPS 140-2/3 hardware tokens or cloud HSMs (e.g., DigiCert KeyLocker / Sectigo Cloud Signing).
- Export or connect via `WINDOWS_CERT_PFX_BASE64` + `WINDOWS_CERT_PASSWORD` (or HSM CLI) in GitHub Actions secrets — never commit certificates or passwords to git.

### Option 3: Microsoft Artifact Signing (formerly Trusted Signing)
- Subject to regional and entity-eligibility restrictions (historically limited to US/Canada/EU/UK organizations); verify current availability for India before relying on it.

*Until a trusted signing certificate or SignPath approval is configured, CI produces clearly labelled **unsigned test builds** rather than self-signed certificates.*

---

## 4. Windows Testing Checklist (Non-Destructive First)

1. **Application startup**: Launch `FolkTool.exe` from portable ZIP and installed folder; verify no missing `vcruntime140.dll` / `msvcp140.dll` errors.
2. **Application installation**: Run `FolkTool-Setup.exe` (both per-user non-admin and all-users admin modes).
3. **Windows Defender & SmartScreen**: Record exact UAC/SmartScreen prompt text and verify no Defender quarantine.
4. **ADB detection**: Connect Android device with USB Debugging enabled; confirm model, Android version, and battery% appear.
5. **Fastboot detection**: Boot device to bootloader; confirm Fastboot state and `Bootloader Unlocked/Locked` status appear.
6. **USB driver installation**: Open Driver Install, test Samsung official link, and verify Authenticode check + UAC prompt disclosure on bundled drivers.
7. **Samsung device detection**: Verify ADB/Download mode guidance and official Samsung USB driver link.
8. **Multiple connected devices**: Connect 2 devices/emulators; verify `Multiple Devices` warning and `ChoiceChip` target selection.
9. **Device authorization**: Revoke USB debugging authorizations on phone; verify `Unauthorized` state blocks flashing with clear instructions.
10. **Recent Files**: Test missing-file indicator, `Open File Location`, single-item remove, and `Clear All` confirmation (verify files on disk remain intact).
11. **File selection**: Select valid `boot.img` and non-boot dummy file; verify preflight `ANDROID!` magic warning/checks.
12. **One-Click Flash preflight**: Verify pre-flash confirmation dialog displays target serial, image path, and KP version.
13. **Step-by-Step Flash**: Walk through steps 1–4 and verify `patchOnly` + Fastboot detection.
14. **Error handling**: Trigger missing file / unauthorized ADB; verify `ErrorBanner` shows Copy Details, Device Safe badge, and hides Retry when unsafe.
15. **Logs**: Test search filter, level chips (`All/Info/OK/Warn/Err`), auto-scroll toggle, Copy, Export Diagnostics (with redaction enabled), and Clear confirmation.
16. **Window resizing**: Resize window to small/large sizes and verify no overflow errors.
17. **Light & dark themes**: Switch System / Light / Dark in Settings and Home AppBar.
18. **Application shutdown**: Close app cleanly with background device monitoring active.
19. **Upgrade & uninstall**: Re-run installer over existing install, then uninstall via Settings/Apps and confirm clean removal.
20. **Recovery guidance**: Verify `Restore Stock Boot` button and non-retry guidance when a flash error is simulated/triggered.
