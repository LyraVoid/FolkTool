<div align="center">

# FolkTool

**专为 [FolkPatch](https://github.com/LyraVoid/FolkTool/releases/latest) 与 [APatch](https://github.com/bmax121/APatch) 打造的 Windows 图形化快速 Root 刷入工具**

[![Windows CI](https://github.com/LyraVoid/FolkTool/actions/workflows/windows-ci.yml/badge.svg)](https://github.com/LyraVoid/FolkTool/actions/workflows/windows-ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/LyraVoid/FolkTool?include_prereleases)](https://github.com/LyraVoid/FolkTool/releases/latest)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11%20x64-0078D6.svg)](https://github.com/LyraVoid/FolkTool/releases/latest)

[English](README_EN.md) · **简体中文** · [下载最新版](https://github.com/LyraVoid/FolkTool/releases/latest) · [提交问题](https://github.com/LyraVoid/FolkTool/issues) · [贡献指南](CONTRIBUTING.md)

</div>

---

## 目录

- [✨ 项目简介](#-项目简介)
- [📱 前置要求](#-前置要求)
- [🚀 下载与安装](#-下载与安装)
- [🎯 操作模式对比](#-操作模式对比)
- [🔄 刷入工作流](#-刷入工作流)
- [🛠️ 常见问题排查](#️-常见问题排查)
- [🙏 开源致谢](#-开源致谢)
- [📄 许可证与免责声明](#-许可证与免责声明)
- [💬 社区与更新日志](#-社区与更新日志)

---

## ✨ 项目简介

**FolkTool** 基于 [Flutter](https://flutter.dev/) 构建，集成了 **ADB**、**Fastboot** 与 [KernelPatch](https://github.com/bmax121/KernelPatch/) (`kptools`)，将繁琐的命令行解包、修补、备份和刷入流程封装为直观的桌面图形界面（支持浅色 / 深色 / 跟随系统主题及中英双语切换）。

### 核心特性

- **多模式刷入：** 支持[一键刷入](#-操作模式对比)、[分步操作](#-操作模式对比)及[仅修补（简单修补）](#-操作模式对比)。
- **刷入前安全检查：** 在执行修补与刷入前自动校验 `boot.img` 完整性、内核版本兼容范围（`3.18 – 6.15`）、设备电量及内置工具链（详见 [SafetyService](lib/features/patching/services/safety_service.dart)）。
- **自动备份与恢复：** 修补前自动备份原始 `boot` 分区镜像，失败时支持一键恢复原厂 `boot`（详见 [PatchProvider](lib/features/patching/providers/patch_provider.dart)）。
- **设备与客户端检测：** 自动识别 ADB / Fastboot 连接状态及客户端安装情况（[DeviceService](lib/features/device/services/device_service.dart)）。
- **一键诊断导出：** 日志控制台支持一键复制、清空及导出完整诊断报告（包含系统环境、设备信息与运行日志）。
- **内置驱动安装：** 集成高通、联发科、一加、OPPO 等常见设备 USB / Fastboot 驱动（[DriverService](lib/features/drivers/services/driver_service.dart)）。

---

## 📱 前置要求

| 项目 | 要求说明 |
| :--- | :--- |
| **操作系统** | Windows 10 / Windows 11 (x64) |
| **运行库** | [Microsoft Visual C++ 2015–2022 Redistributable (x64)](https://aka.ms/vs/17/release/vc_redist.x64.exe)（安装程序会自动检测并引导安装） |
| **Android 设备** | ARM64 架构，Linux 内核版本 `3.18` 至 `6.15` |
| **USB 驱动** | 已安装对应设备的 Android ADB / Fastboot 驱动（可使用内置驱动安装工具） |
| **设备状态** | 已开启**开发者选项**与 **USB 调试**，且**已解锁 Bootloader (OEM Unlock)** |

> [!IMPORTANT]
> 刷入前请确保已解锁 Bootloader 并备份重要个人数据。若系统缺少 `MSVCP140.dll` 或 `VCRUNTIME140_1.dll`，新版安装程序 ([installer.iss](installer.iss)) 会自动检测并静默安装 [VC++ 2015–2022 (x64) 运行库](https://aka.ms/vs/17/release/vc_redist.x64.exe)。

---

## 🚀 下载与安装

1. 前往 [GitHub Releases 发布页面](https://github.com/LyraVoid/FolkTool/releases/latest) 下载最新的 `FolkTool-Setup.exe` 安装包（或便携版 ZIP）。
2. 运行安装程序并按向导完成安装（若系统缺失 VC++ x64 运行库，向导会自动下载并静默安装）。
3. 通过 USB 数据线连接 Android 设备至电脑，并在手机端授权 USB 调试。
4. 启动 **FolkTool**，确认顶部设备状态卡片显示已连接，选择操作模式并按提示完成操作。

> [!TIP]
> 若你的电脑未提前安装 ADB/Fastboot 驱动，可直接在首页进入 **驱动安装** 页面一键启动对应芯片/品牌的官方驱动安装器。

---

## 🎯 操作模式对比

| 模式 | 适用场景 | 自动化程度 |
| :--- | :--- | :--- |
| **一键刷入 (Quick Patch)** | 适合希望全自动完成「安全校验 → 备份 → 修补 → 重启至 Fastboot → 刷入 → 重启」的用户 | 全自动 |
| **分步操作 (Step-by-Step)** | 适合初次使用或需要手动控制重启/刷入时机的用户，每步均有详细指引 | 半自动 / 可暂停 |
| **简单修补 (Simple Patch)** | 仅修补本地 `boot.img` 并保存输出文件，不自动连接或刷入设备 | 仅本地修补 |
| **驱动安装 (Driver Install)** | 安装高通、联发科、一加、OPPO ADB/Fastboot 驱动 | 辅助工具 |

---

## 🔄 刷入工作流

```mermaid
flowchart LR
    A["选择 boot.img<br/>与目标 (FolkPatch/APatch)"] --> B["安全检查<br/>(文件/内核/电量/工具链)"]
    B --> C["备份原始 boot"]
    C --> D["kptools 修补内核<br/>(+ 可选 KPM 模块)"]
    D --> E["重启至 Fastboot<br/>并刷入 boot 分区"]
    E --> F["重启设备完成"]
```

---

## 🛠️ 常见问题排查

<details>
<summary><strong>1. 启动提示找不到 MSVCP140.dll 或 VCRUNTIME140_1.dll</strong></summary>

- 使用新版 `FolkTool-Setup.exe` 重新安装，安装程序会自动检测并安装 Microsoft Visual C++ 2015–2022 Redistributable (x64)。
- 或手动下载安装官方运行库：[vc_redist.x64.exe](https://aka.ms/vs/17/release/vc_redist.x64.exe)。

</details>

<details>
<summary><strong>2. 设备未检测到或无法进入 Fastboot</strong></summary>

1. 确认手机已开启 **USB 调试** 并在连接弹窗中点击「始终允许」。
2. 尝试更换 USB 接口（优先使用主板原生 USB 2.0/3.0 接口）或原装数据线。
3. 在首页打开 **驱动安装**，安装对应品牌的 ADB / Fastboot 驱动。

</details>

<details>
<summary><strong>3. 想要从源码自行编译</strong></summary>

请参阅 [贡献指南 (CONTRIBUTING.md)](CONTRIBUTING.md) 获取完整的 Windows 本地开发环境配置、测试及 Inno Setup 打包命令，或查看 [Windows CI 工作流](.github/workflows/windows-ci.yml)。

</details>

---

## 🙏 开源致谢

本项目基于以下优秀开源项目构建：

- [KernelPatch](https://github.com/bmax121/KernelPatch/) — 内核补丁核心组件
- [APatch](https://github.com/bmax121/APatch) — Android 内核级 Root 方案
- [Flutter](https://flutter.dev/) — 跨平台 UI 框架

---

## 📄 许可证与免责声明

FolkTool 遵循 [GNU General Public License v3 (GPL-3)](LICENSE) 协议开源：

- 若您修改了代码或在项目中集成了 FolkTool 并向第三方分发，您的整个项目必须同样采用 GPLv3 协议开源，并提供完整可读的源代码。
- 严禁对软件授权本身收取许可费；本软件按「原样」提供，不含任何明示或暗示担保。

> [!CAUTION]
> **免责声明：** 刷写引导分区（`boot.img`）具有一定风险，不当操作可能导致设备无法启动（变砖）、数据丢失或失去保修。操作前请务必备份重要数据，作者不对因使用本工具造成的任何直接或间接损失承担责任。

---

## 💬 社区与更新日志

- **Telegram 频道：** [@FolkTool](https://t.me/FolkPatch)
- **GitHub Issues：** [提交 Bug 或功能建议](https://github.com/LyraVoid/FolkTool/issues)
- **贡献代码：** [CONTRIBUTING.md](CONTRIBUTING.md)

<details open>
<summary><strong>📝 更新日志</strong></summary>

### v1.7.0 (2026-11-25)
- **安装器与运行库修复：** 安装脚本 ([installer.iss](installer.iss)) 自动检测并安装 VC++ 2015–2022 (x64) 运行库，解决缺失 `MSVCP140.dll` / `VCRUNTIME140_1.dll` 报错。
- **窗口与任务栏适配：** 修复高 DPI / 小屏下窗口被 Windows 任务栏遮挡的问题，支持自由缩放与最大化（[win32_window.cpp](windows/runner/win32_window.cpp)）。
- **UI/UX 升级：** 采用原生 Material 3 设计，支持浅色 / 深色 / 跟随系统主题、响应式居中布局与日志复制/导出。
- **安全与诊断：** 新增刷入前安全检查、自动备份与恢复原厂 `boot`、导出诊断报告及应用内版本更新提示。

### v1.0.0 (2026-02-23)
- 首次发布，支持 FolkPatch / APatch 图形化快速刷入、分步操作、设备状态检测与中英双语界面。

</details>

---

<div align="center">

**Made with ❤️ by FolkTool Team**

</div>
