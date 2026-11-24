# FolkTool


🌏 **README Language:** [**English**](README_EN.md) / [**中文**](README.md)


---

## ✨ 介绍

FolkTool 是一个专为 FolkPatch 和 APatch 设计的快速 Root 刷入工具，简化了复杂的刷入流程，提供图形化界面和自动化操作，让 Root 刷入变得更加简单快捷。

### 🎨 核心功能

- 快速刷入 FolkPatch 和 APatch
- 图形化操作界面，无需命令行
- 自动检测设备状态
- 支持 ADB 和 Fastboot 自动操作
- 实时日志输出和错误提示
- 一键快速补丁模式
- 分步详细操作模式

### ⚡ 技术特性

- 基于 Flutter 开发，跨平台支持
- 集成 ADB 和 Fastboot 工具
- 集成 KernelPatch 工具
- 完整的日志记录系统

## 📱 前置要求

- **操作系统：** Windows 10/11
- **运行环境：** [Microsoft Visual C++ 2015-2022 Redistributable (x64)](https://aka.ms/vs/17/release/vc_redist.x64.exe)
- **设备：** 基于 ARM64 架构且 Linux 内核版本 3.18 至 6.15 的 Android 设备
- **驱动：** 已安装 Android ADB 驱动
- **开发者选项：** 已启用 USB 调试
- **OEM 解锁：** 已解锁 Bootloader

## 🚀 下载安装

### 📦 使用指导

1. **下载安装：** 从 [发布页面](https://github.com/yourusername/FolkTool/releases/latest) 下载最新版 FolkTool-Setup.exe

2. **安装程序：** 运行安装程序，按照向导完成安装

3. **连接设备：** 通过 USB 连接 Android 设备到电脑

4. **开始使用：** 启动 FolkTool，选择刷入模式，按照提示完成操作

### ⚙️ 快速开始

1. 启动 FolkTool
2. 确保设备已连接并启用 USB 调试
3. 选择补丁类型（FolkPatch 或 APatch）
4. 选择刷入模式（快速或分步）
5. 按照界面提示完成刷入

## 🎯 功能说明

### 快速补丁模式

- 一键自动完成所有刷入步骤
- 适合有经验的用户
- 自动检测并处理错误

### 分步操作模式

- 详细的步骤指引
- 每步都有说明和提示
- 适合初次使用的用户
- 可以随时暂停和继续

### 设备状态检测

- 自动检测设备连接状态
- 检测 Bootloader 解锁状态
- 检测当前 Android 版本
- 检测内核版本兼容性

## 🙏 开源致谢

本项目基于以下开源项目：

- [KernelPatch](https://github.com/bmax121/KernelPatch/) - 内核补丁核心组件
- [APatch](https://github.com/bmax121/APatch) - Android Patch 方案

## 📄 许可证

FolkTool 遵循 [GNU General Public License v3 (GPL-3)](http://www.gnu.org/copyleft/gpl.html) 许可证开源：

- 若您修改了代码或在项目中集成了 FolkTool 并向第三方分发，您的整个项目必须同样采用 GPLv3 协议开源
- 分发二进制文件时，必须主动提供或承诺提供完整且可读的源代码
- 严禁对软件授权本身收取许可费，您可以针对分发、技术支持或定制开发收费
- 分发行为即代表您授予所有用户使用该项目涉及的您的相关专利
- 本软件"按原样"提供，不含任何担保，原作者不对因使用本软件造成的任何损失负责
- 任何违反上述条款的行为将导致您的 GPLv3 授权自动终止

## ⚠️ 免责声明

使用本工具可能导致设备变砖、数据丢失或失去保修。使用前请务必备份重要数据。作者不对任何因使用本工具造成的直接或间接损失承担责任。

## 💬 社区交流

### FolkTool 讨论交流

- Telegram 频道: [@FolkTool](https://t.me/FolkPatch)
- GitHub Issues: [提交问题](https://github.com/matsuzaka-yuki/FolkTool/issues)

## 📝 更新日志

### v1.0.0 (2026-02-23)

- 首次发布
- 支持 FolkPatch 和 APatch 快速刷入
- 实现图形化操作界面
- 添加快速补丁和分步操作两种模式
- 实现设备状态自动检测
- 添加多语言支持（中文/英文）

---

<div align="center">

**Made with ❤️ by FolkTool Team**

</div>
