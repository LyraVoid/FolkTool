# FolkTool

[![Windows CI](https://github.com/LyraVoid/FolkTool/actions/workflows/windows-ci.yml/badge.svg)](https://github.com/LyraVoid/FolkTool/actions/workflows/windows-ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/LyraVoid/FolkTool?include_prereleases)](https://github.com/LyraVoid/FolkTool/releases/latest)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11%20x64-0078D6.svg)](#)

🌏 **README Language:** [**English**](README_EN.md) / [**中文**](README.md)


---

## ✨ Introduction

FolkTool is a fast Root flashing tool designed specifically for FolkPatch and APatch. It simplifies the complex flashing process with a graphical interface and automated operations, making Root flashing easier and faster.

### 🎨 Core Features

- Quick flash for FolkPatch and APatch
- Graphical interface, no command line required
- Automatic device status detection
- ADB and Fastboot automation support
- Real-time log output and error prompts
- One-click quick patch mode
- Step-by-step detailed operation mode

### ⚡ Technical Features

- Built with Flutter, cross-platform support
- Integrated ADB and Fastboot tools
- Integrated KernelPatch tools
- Complete logging system

## 📱 Prerequisites

- **Operating System:** Windows 10/11
- **Runtime:** [Microsoft Visual C++ 2015-2022 Redistributable (x64)](https://aka.ms/vs/17/release/vc_redist.x64.exe)
- **Device:** Android device based on ARM64 architecture with Linux kernel version 3.18 to 6.15
- **Driver:** Android ADB driver installed
- **Developer Options:** USB debugging enabled
- **OEM Unlock:** Bootloader unlocked

## 🚀 Download & Install

### 📦 Usage Guide

1. **Download:** Download the latest `FolkTool-Setup.exe` or portable ZIP from the [Release Page](https://github.com/LyraVoid/FolkTool/releases/latest)

2. **Install:** Run the installer and complete the installation following the wizard

3. **Connect:** Connect your Android device to the computer via USB

4. **Start:** Launch FolkTool, select flashing mode, and follow the prompts

### ⚙️ Quick Start

1. Launch FolkTool
2. Ensure your device is connected with USB debugging enabled
3. Select patch type (FolkPatch or APatch)
4. Select flashing mode (Quick or Step-by-step)
5. Follow the on-screen instructions to complete flashing

## 🎯 Features

### Quick Patch Mode

- One-click automatic completion of all flashing steps
- Suitable for experienced users
- Automatic error detection and handling

### Step-by-step Mode

- Detailed step-by-step guidance
- Explanations and prompts for each step
- Suitable for first-time users
- Pause and resume at any time

### Device Status Detection

- Automatic device connection status detection
- Bootloader unlock status detection
- Current Android version detection
- Kernel version compatibility detection

## 🙏 Acknowledgments

This project is based on the following open source projects:

- [KernelPatch](https://github.com/bmax121/KernelPatch/) - Core kernel patch component
- [APatch](https://github.com/bmax121/APatch) - Android Patch solution

## 📄 License

FolkTool is open source under [GNU General Public License v3 (GPL-3)](http://www.gnu.org/copyleft/gpl.html):

- If you modify the code or integrate FolkTool into a project and distribute it to third parties, your entire project must be open source under the GPLv3 license
- When distributing binary files, you must actively provide or promise to provide complete and readable source code
- Prohibition of charging license fees for the software license itself; you may charge for distribution, technical support, or customized development
- Distribution implies granting all users the use of your related patents involved in the project
- This software is provided "as is" without any warranty; the author is not responsible for any losses caused by the use of this software
- Any violation of the above terms will result in automatic termination of your GPLv3 license

## ⚠️ Disclaimer

Using this tool may cause device bricking, data loss, or void warranty. Please backup important data before use. The author is not responsible for any direct or indirect losses caused by the use of this tool.

## 💬 Community

### FolkTool Discussion

- Telegram Channel: [@FolkTool](https://t.me/FolkPatch)
- GitHub Issues: [Submit Issues](https://github.com/LyraVoid/FolkTool/issues)
- Contributing: [CONTRIBUTING.md](CONTRIBUTING.md)

## 📝 Changelog

### v1.7.0 (2026-11-25)

- Added pre-flight safety checks (kernel range, battery level, and bundled binary verification) before flashing
- Added automatic stock `boot.img` backup before patching and stock restore support
- Added **Export Logs** in the Log Console for easier diagnostics and bug reporting
- Added non-blocking in-app update check against GitHub Releases
- Unified Inno Setup installer scripts and added tag-triggered Windows Release automation with SHA-256 checksums

### v1.0.0 (2026-02-23)

- Initial release
- Support for quick flashing of FolkPatch and APatch
- Graphical interface implementation
- Added two modes: Quick Patch and Step-by-step
- Automatic device status detection
- Multi-language support (Chinese/English)

---

<div align="center">

**Made with ❤️ by FolkTool Team**

</div>