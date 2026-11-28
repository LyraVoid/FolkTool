<div align="center">

# FolkTool

**Fast Graphical Windows Root Flashing Tool for [FolkPatch](https://github.com/LyraVoid/FolkTool/releases/latest) & [APatch](https://github.com/bmax121/APatch)**

[![Windows CI](https://github.com/LyraVoid/FolkTool/actions/workflows/windows-ci.yml/badge.svg)](https://github.com/LyraVoid/FolkTool/actions/workflows/windows-ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/LyraVoid/FolkTool?include_prereleases)](https://github.com/LyraVoid/FolkTool/releases/latest)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11%20x64-0078D6.svg)](https://github.com/LyraVoid/FolkTool/releases/latest)

**English** · [简体中文](README.md) · [Download Latest](https://github.com/LyraVoid/FolkTool/releases/latest) · [Report an Issue](https://github.com/LyraVoid/FolkTool/issues) · [Contributing](CONTRIBUTING.md)

</div>

---

## Table of Contents

- [✨ Introduction](#-introduction)
- [📱 Prerequisites](#-prerequisites)
- [🚀 Download & Install](#-download--install)
- [🎯 Operation Modes](#-operation-modes)
- [🔄 Flashing Workflow](#-flashing-workflow)
- [🛠️ Troubleshooting](#️-troubleshooting)
- [🙏 Acknowledgments](#-acknowledgments)
- [📄 License & Disclaimer](#-license--disclaimer)
- [💬 Community & Changelog](#-community--changelog)

---

## ✨ Introduction

**FolkTool** is a lightweight Windows desktop application built with [Flutter](https://flutter.dev/). It integrates **ADB**, **Fastboot**, and [KernelPatch](https://github.com/bmax121/KernelPatch/) (`kptools`) into a clean Material 3 GUI—supporting **Light / Dark / System** themes and **English / Chinese** localization.

### Core Features

- **Flexible Flashing Modes:** Choose between [One-Click Flash](#-operation-modes), [Step-by-Step](#-operation-modes), or [Simple Patch](#-operation-modes).
- **Pre-Flight Safety Checks:** Validates `boot.img` integrity, kernel version compatibility (`3.18 – 6.15`), device battery level, and bundled binaries before flashing ([SafetyService](lib/features/patching/services/safety_service.dart)).
- **Automatic Stock Backup & Restore:** Backs up the original `boot` partition prior to patching and supports one-click stock restore on failure ([PatchProvider](lib/features/patching/providers/patch_provider.dart)).
- **Device & Client Detection:** Real-time ADB / Fastboot status monitoring and APatch / FolkPatch client detection ([DeviceService](lib/features/device/services/device_service.dart)).
- **Diagnostic Log Console:** Monospace selectable log viewer with **Copy All**, **Clear**, and **Export Diagnostic Report** actions ([LogConsole](lib/core/widgets/log_console.dart)).
- **Built-in Driver Installers:** One-click launch for Qualcomm, MediaTek, OnePlus, and OPPO USB/Fastboot drivers ([DriverService](lib/features/drivers/services/driver_service.dart)).

---

## 📱 Prerequisites

| Requirement | Details |
| :--- | :--- |
| **Operating System** | Windows 10 / Windows 11 (x64) |
| **Runtime** | [Microsoft Visual C++ 2015–2022 Redistributable (x64)](https://aka.ms/vs/17/release/vc_redist.x64.exe) (auto-detected and installed by setup) |
| **Android Device** | ARM64 device running Linux kernel `3.18` to `6.15` |
| **USB Drivers** | Android ADB / Fastboot drivers installed (available via built-in Driver Install page) |
| **Device Prep** | **Developer Options** & **USB Debugging** enabled, **Bootloader Unlocked (OEM Unlock)** |

> [!IMPORTANT]
> Unlocking the bootloader and backing up important data are required before flashing. If a system lacks `MSVCP140.dll` or `VCRUNTIME140_1.dll`, the installer ([installer.iss](installer.iss)) automatically detects and silently installs the [Visual C++ 2015–2022 (x64) Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe).

---

## 🚀 Download & Install

1. Download the latest `FolkTool-Setup.exe` (or portable ZIP) from the [GitHub Releases Page](https://github.com/LyraVoid/FolkTool/releases/latest).
2. Run the installer and follow the setup wizard (missing VC++ x64 runtime dependencies are downloaded and installed automatically).
3. Connect your Android device via USB and accept the USB debugging authorization prompt.
4. Launch **FolkTool**, verify connection in the **Device Status** card, choose your mode, and follow the prompts.

> [!TIP]
> If your device isn't recognized in ADB or Fastboot mode, open **Driver Install** from the home screen to install the appropriate USB driver.

---

## 🎯 Operation Modes

| Mode | Best For | Automation |
| :--- | :--- | :--- |
| **One-Click Flash (Quick Patch)** | End-to-end automated flow: safety checks → backup → patch → reboot to Fastboot → flash → reboot | Fully automated |
| **Step-by-Step** | First-time users or manual control over reboot and flashing timing | Guided / Pausable |
| **Simple Patch** | Patching a local `boot.img` file without connecting or flashing a device | Local patch only |
| **Driver Install** | Installing Qualcomm, MediaTek, OnePlus, or OPPO USB/Fastboot drivers | Utility |

---

## 🔄 Flashing Workflow

```mermaid
flowchart LR
    A["Select boot.img<br/>& Target (FolkPatch/APatch)"] --> B["Pre-Flight Checks<br/>(File/Kernel/Battery/Bins)"]
    B --> C["Backup Stock Boot"]
    C --> D["kptools Kernel Patch<br/>(+ Optional KPM Modules)"]
    D --> E["Reboot to Fastboot<br/>& Flash Boot"]
    E --> F["Reboot Device"]
```

---

## 🛠️ Troubleshooting

<details>
<summary><strong>1. Startup error: MSVCP140.dll or VCRUNTIME140_1.dll was not found</strong></summary>

- Re-run the latest `FolkTool-Setup.exe` installer, which detects and silently installs the Microsoft Visual C++ 2015–2022 Redistributable (x64).
- Alternatively, install the official package directly: [vc_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe).

</details>

<details>
<summary><strong>2. Device not detected in ADB or Fastboot</strong></summary>

1. Verify **USB Debugging** is enabled and tap **Allow** on the device RSA authorization dialog.
2. Try a direct motherboard USB port or a different data-capable USB cable.
3. Open **Driver Install** on the FolkTool home screen and install your device's USB/Fastboot driver.

</details>

<details>
<summary><strong>3. Building from source</strong></summary>

See [CONTRIBUTING.md](CONTRIBUTING.md) for local Flutter Windows setup, testing commands, and Inno Setup packaging instructions, or inspect the [Windows CI Workflow](.github/workflows/windows-ci.yml).

</details>

---

## 🙏 Acknowledgments

Built on top of:

- [KernelPatch](https://github.com/bmax121/KernelPatch/) — Core kernel patching engine
- [APatch](https://github.com/bmax121/APatch) — Kernel-based Android root solution
- [Flutter](https://flutter.dev/) — Cross-platform UI framework

---

## 📄 License & Disclaimer

FolkTool is licensed under the [GNU General Public License v3 (GPL-3)](LICENSE):

- Any modified or derivative distribution must remain open source under GPLv3 with readable source code provided.
- Charging license fees for the software itself is prohibited; the software is provided "as is" without warranty of any kind.

> [!CAUTION]
> **Disclaimer:** Flashing boot images carries inherent risk and may cause bootloops, data loss, or void warranty. Always back up important data beforehand. The authors are not responsible for any direct or indirect damages.

---

## 💬 Community & Changelog

- **Telegram Channel:** [@FolkTool](https://t.me/FolkPatch)
- **GitHub Issues:** [Submit Bugs or Feature Requests](https://github.com/LyraVoid/FolkTool/issues)
- **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md)

<details open>
<summary><strong>📝 Changelog</strong></summary>

### v1.7.0 (2026-11-25)
- **Installer Runtime Fix:** Updated [installer.iss](installer.iss) to detect and install VC++ 2015–2022 (x64) automatically, resolving missing `MSVCP140.dll` / `VCRUNTIME140_1.dll` errors.
- **Window & Taskbar Fix:** Clamped initial and minimum window bounds to `MONITORINFO.rcWork` and enabled `WS_OVERLAPPEDWINDOW` resizing/maximizing ([win32_window.cpp](windows/runner/win32_window.cpp)).
- **Material 3 UI/UX:** Added Light / Dark / System themes, responsive desktop layout, native `SegmentedButton`, and enhanced Log Console actions.
- **Safety & Diagnostics:** Added pre-flight checks, stock `boot.img` backup/restore, diagnostic report export, and non-blocking GitHub Release update checks.

### v1.0.0 (2026-02-23)
- Initial release with One-Click Flash, Step-by-Step mode, automatic device detection, and Chinese/English localization.

</details>

---

<div align="center">

**Made with ❤️ by FolkTool Team**

</div>
