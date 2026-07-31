// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(version) => "FolkTool v${version}";

  static String m1(path) => "ADB 可执行文件不存在: ${path}";

  static String m2(error) => "备份异常: ${error}";

  static String m3(error) => "驱动检查失败: ${error}";

  static String m4(path) => "Fastboot 可执行文件不存在: ${path}";

  static String m5(error) => "刷入异常: ${error}";

  static String m6(error) => "刷入失败: ${error}";

  static String m7(error) => "获取 ADB 设备失败: ${error}";

  static String m8(error) => "获取 Fastboot 设备失败: ${error}";

  static String m9(path) => "输入文件不存在: ${path}";

  static String m10(path) => "Kpimg 文件不存在: ${path}";

  static String m11(path) => "Kptools 文件不存在: ${path}";

  static String m12(error) => "修补异常: ${error}";

  static String m13(error) => "修补失败: ${error}";

  static String m14(error) => "重启异常: ${error}";

  static String m15(error) => "重启失败: ${error}";

  static String m16(error) => "解包失败: ${error}";

  static String m17(error) => "启动安装程序失败: ${error}";

  static String m18(name) => "${name} 安装失败";

  static String m19(name) => "${name} 安装成功";

  static String m20(path) => "Boot 备份完成: ${path}";

  static String m21(path) => "备份成功: ${path}";

  static String m22(error) => "清理临时文件失败: ${error}";

  static String m23(path) => "已复制到 ${path}";

  static String m24(cmd) => "执行命令: ${cmd}";

  static String m25(serial) => "检测到 Fastboot 设备: ${serial}";

  static String m26(path) => "文件已保存: ${path}";

  static String m27(path) => "正在刷入: ${path}";

  static String m28(path) => "输入文件: ${path}";

  static String m29(path) => "Kpimg 路径: ${path}";

  static String m30(module) => "KPM 模块: ${module}";

  static String m31(path) => "Kptools 路径: ${path}";

  static String m32(error) => "获取补丁信息失败: ${error}";

  static String m33(error) => "操作错误: ${error}";

  static String m34(path) => "输出文件: ${path}";

  static String m35(path) => "修补完成: ${path}";

  static String m36(error) => "修补异常: ${error}";

  static String m37(error) => "修补失败: ${error}";

  static String m38(error) => "重新打包异常: ${error}";

  static String m39(path, size) => "重新打包完成: ${path} (${size} MB)";

  static String m40(error) => "解包异常: ${error}";

  static String m41(path) => "已解包内核: ${path}";

  static String m42(timeout) => "等待 fastboot 设备 (${timeout} 秒)";

  static String m43(dir) => "工作目录: ${dir}";

  static String m44(path) => "日志已保存: ${path}";

  static String m45(count) => "已选择 (${count})";

  static String m46(serial) => "序列号: ${serial}";

  static String m47(error) => "无法打开链接: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "aboutDescription": MessageLookupByLibrary.simpleMessage(
      "KernelPatch 自动刷入工具",
    ),
    "aboutDescription2": MessageLookupByLibrary.simpleMessage(
      "本工具用于自动修补 boot.img 并刷入设备",
    ),
    "aboutTitle": MessageLookupByLibrary.simpleMessage("关于"),
    "aboutTooltip": MessageLookupByLibrary.simpleMessage("关于"),
    "adbConnected": MessageLookupByLibrary.simpleMessage("ADB 已连接"),
    "apatchDesc": MessageLookupByLibrary.simpleMessage("Android 内核级 Root 解决方案"),
    "appFullName": MessageLookupByLibrary.simpleMessage(
      "FolkTool - KernelPatch 自动刷入工具",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("FolkTool"),
    "appVersion": m0,
    "backupWarning": MessageLookupByLibrary.simpleMessage("刷入前请备份原始 boot 分区"),
    "cancelOperation": MessageLookupByLibrary.simpleMessage("取消操作"),
    "checking": MessageLookupByLibrary.simpleMessage("检测中..."),
    "checkingDriver": MessageLookupByLibrary.simpleMessage("驱动检测中"),
    "checkingDriverDesc": MessageLookupByLibrary.simpleMessage(
      "正在检查 ADB/Fastboot 驱动...",
    ),
    "clearAllModules": MessageLookupByLibrary.simpleMessage("清空全部"),
    "clearLogs": MessageLookupByLibrary.simpleMessage("清除日志"),
    "clickToSelectFile": MessageLookupByLibrary.simpleMessage("点击选择文件..."),
    "clientCheck": MessageLookupByLibrary.simpleMessage("客户端检测"),
    "copyLogs": MessageLookupByLibrary.simpleMessage("复制日志"),
    "currentVersion": MessageLookupByLibrary.simpleMessage("当前版本"),
    "customVersion": MessageLookupByLibrary.simpleMessage("自定义版本"),
    "customVersionSaved": MessageLookupByLibrary.simpleMessage("自定义版本已保存"),
    "deviceConnectionTips": MessageLookupByLibrary.simpleMessage("设备连接提示"),
    "deviceConnectionTipsDesc": MessageLookupByLibrary.simpleMessage(
      "1. 确保设备已通过 USB 连接到电脑\n2. 在设备上开启开发者选项和 USB 调试\n3. 如需 Fastboot，请先进入 Bootloader 模式",
    ),
    "deviceInFastboot": MessageLookupByLibrary.simpleMessage("设备已进入 Fastboot"),
    "deviceStatus": MessageLookupByLibrary.simpleMessage("设备状态"),
    "driverInstall": MessageLookupByLibrary.simpleMessage("驱动安装"),
    "driverInstallPage": MessageLookupByLibrary.simpleMessage("驱动安装"),
    "driverInstallSubtitle": MessageLookupByLibrary.simpleMessage("安装设备驱动程序"),
    "errAdbNotAvailable": MessageLookupByLibrary.simpleMessage("ADB 不可用"),
    "errAdbNotExist": m1,
    "errBackupException": m2,
    "errDriverCheckFailed": m3,
    "errFastbootNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Fastboot 不可用",
    ),
    "errFastbootNotExist": m4,
    "errFlashBootFailed": MessageLookupByLibrary.simpleMessage("刷入 boot 分区失败"),
    "errFlashException": m5,
    "errFlashFailed": m6,
    "errGetAdbFailed": m7,
    "errGetFastbootFailed": m8,
    "errInputNotExist": m9,
    "errKernelNotFound": MessageLookupByLibrary.simpleMessage("未找到内核文件"),
    "errKpimgNotExist": m10,
    "errKptoolsNotExist": m11,
    "errOutputKernelNotFound": MessageLookupByLibrary.simpleMessage("未找到输出内核"),
    "errPatchException": m12,
    "errPatchFailed": m13,
    "errRebootException": m14,
    "errRebootFailed": m15,
    "errRepackFailed": MessageLookupByLibrary.simpleMessage("重新打包失败"),
    "errSelectBootFirst": MessageLookupByLibrary.simpleMessage(
      "请先选择 boot.img 文件",
    ),
    "errUnpackFailed": m16,
    "exportLogs": MessageLookupByLibrary.simpleMessage("导出日志"),
    "exportLogsTooltip": MessageLookupByLibrary.simpleMessage("导出日志"),
    "fastbootConnected": MessageLookupByLibrary.simpleMessage("Fastboot 已连接"),
    "fileSavedSuccessfully": MessageLookupByLibrary.simpleMessage("文件已保存"),
    "flashBoot": MessageLookupByLibrary.simpleMessage("刷入 boot"),
    "flashComplete": MessageLookupByLibrary.simpleMessage("刷入完成"),
    "flashCompleteDesc": MessageLookupByLibrary.simpleMessage("是否立即重启设备？"),
    "flashFile": MessageLookupByLibrary.simpleMessage("刷入文件"),
    "flashSuccess": MessageLookupByLibrary.simpleMessage("刷入成功！"),
    "flashing": MessageLookupByLibrary.simpleMessage("刷入中..."),
    "folkpatchDesc": MessageLookupByLibrary.simpleMessage(
      "一个优秀的KernelPatch管理客户端",
    ),
    "github": MessageLookupByLibrary.simpleMessage("GitHub"),
    "home": MessageLookupByLibrary.simpleMessage("首页"),
    "install": MessageLookupByLibrary.simpleMessage("安装"),
    "installDriver": MessageLookupByLibrary.simpleMessage("安装驱动"),
    "installDriverFailed": m17,
    "installDriverSuccess": MessageLookupByLibrary.simpleMessage("驱动安装程序已启动"),
    "installFailed": m18,
    "installSuccess": m19,
    "installed": MessageLookupByLibrary.simpleMessage("已安装"),
    "installing": MessageLookupByLibrary.simpleMessage("安装中..."),
    "invalidVersionFile": MessageLookupByLibrary.simpleMessage("无效的版本文件"),
    "kernelPatchVersion": MessageLookupByLibrary.simpleMessage(
      "KernelPatch 版本",
    ),
    "kpmModules": MessageLookupByLibrary.simpleMessage("KPM 模块 (可选)"),
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "loadingVersions": MessageLookupByLibrary.simpleMessage("加载版本中..."),
    "logAutoRebootFailed": MessageLookupByLibrary.simpleMessage(
      "自动重启到 fastboot 失败",
    ),
    "logAutoRebootFailed2": MessageLookupByLibrary.simpleMessage("自动重启失败"),
    "logBackingUpBoot": MessageLookupByLibrary.simpleMessage("正在备份 boot 分区..."),
    "logBackingUpPartition": MessageLookupByLibrary.simpleMessage("正在备份分区..."),
    "logBackupComplete": m20,
    "logBackupFailed": MessageLookupByLibrary.simpleMessage("Boot 备份失败"),
    "logBackupFailedTryAlt": MessageLookupByLibrary.simpleMessage(
      "备份失败，尝试备用方法...",
    ),
    "logBackupKernel": MessageLookupByLibrary.simpleMessage("正在备份内核..."),
    "logBackupSuccess": m21,
    "logCancelling": MessageLookupByLibrary.simpleMessage("正在取消操作..."),
    "logCheckAdb": MessageLookupByLibrary.simpleMessage("正在检查 ADB..."),
    "logCheckFastboot": MessageLookupByLibrary.simpleMessage(
      "正在检查 Fastboot...",
    ),
    "logCheckingFile": MessageLookupByLibrary.simpleMessage("正在检查文件..."),
    "logCleanWorkDir": MessageLookupByLibrary.simpleMessage("正在清理临时文件..."),
    "logCleanWorkDirFailed": m22,
    "logConsole": MessageLookupByLibrary.simpleMessage("日志控制台"),
    "logCopied": m23,
    "logCopyBoot": MessageLookupByLibrary.simpleMessage("正在复制 boot 镜像..."),
    "logDeviceInFastboot": MessageLookupByLibrary.simpleMessage(
      "设备已进入 fastboot 模式",
    ),
    "logDeviceNotFastboot": MessageLookupByLibrary.simpleMessage(
      "设备未处于 fastboot 模式",
    ),
    "logDeviceRebooting": MessageLookupByLibrary.simpleMessage("设备正在重启..."),
    "logDriverCheckPassed": MessageLookupByLibrary.simpleMessage("驱动检查通过"),
    "logEntries": MessageLookupByLibrary.simpleMessage("条记录"),
    "logExecuteCmd": m24,
    "logFastbootDetected": m25,
    "logFileSaved": m26,
    "logFlashBootSuccess": MessageLookupByLibrary.simpleMessage("刷入完成"),
    "logFlashFailed": MessageLookupByLibrary.simpleMessage("刷入失败"),
    "logFlashSuccess": MessageLookupByLibrary.simpleMessage("刷入成功"),
    "logFlashingBoot": MessageLookupByLibrary.simpleMessage("正在刷入 boot 镜像..."),
    "logFlashingBootPath": m27,
    "logInputFile": m28,
    "logKpimgPath": m29,
    "logKpmModule": m30,
    "logKptoolsPath": m31,
    "logListPatchInfoFailed": m32,
    "logNoAdbDevice": MessageLookupByLibrary.simpleMessage("未检测到 ADB 设备"),
    "logOneClickComplete": MessageLookupByLibrary.simpleMessage("一键刷入完成！"),
    "logOperationError": m33,
    "logOutput": MessageLookupByLibrary.simpleMessage("日志输出"),
    "logOutputFile": m34,
    "logPatchComplete": m35,
    "logPatchException": m36,
    "logPatchFailed": m37,
    "logPatchSuccess": MessageLookupByLibrary.simpleMessage("内核修补成功"),
    "logPatchingBoot": MessageLookupByLibrary.simpleMessage("正在修补 boot 镜像..."),
    "logPatchingKernel": MessageLookupByLibrary.simpleMessage("正在修补内核..."),
    "logRebootCmdSent": MessageLookupByLibrary.simpleMessage("重启命令已发送"),
    "logRebootSuccess": MessageLookupByLibrary.simpleMessage("设备重启成功"),
    "logRebootingDevice": MessageLookupByLibrary.simpleMessage("正在重启设备..."),
    "logRebootingToFastboot": MessageLookupByLibrary.simpleMessage(
      "正在重启到 fastboot 模式...",
    ),
    "logRepackException": m38,
    "logRepackSuccess": m39,
    "logRepacking": MessageLookupByLibrary.simpleMessage("正在重新打包 boot 镜像..."),
    "logSavingFile": MessageLookupByLibrary.simpleMessage("正在保存修补文件..."),
    "logStartPatching": MessageLookupByLibrary.simpleMessage("开始修补操作..."),
    "logUnpackException": m40,
    "logUnpackSuccess": m41,
    "logUnpacking": MessageLookupByLibrary.simpleMessage("正在解包 boot 镜像..."),
    "logWaitFastboot": m42,
    "logWaitFastbootTimeout": MessageLookupByLibrary.simpleMessage(
      "等待 fastboot 超时",
    ),
    "logWorkDir": m43,
    "logsSaved": m44,
    "manuallyEnterFastboot": MessageLookupByLibrary.simpleMessage(
      "请手动将设备进入 Fastboot 模式",
    ),
    "manuallyEnterFastbootDesc": MessageLookupByLibrary.simpleMessage(
      "1. 关闭设备\n2. 同时按住 音量下键 + 电源键\n3. 连接 USB 线到电脑",
    ),
    "matsuzakaYuki": MessageLookupByLibrary.simpleMessage("Matsuzaka Yuki"),
    "mediatekDriver": MessageLookupByLibrary.simpleMessage("联发科 USB 驱动"),
    "mediatekDriverDesc": MessageLookupByLibrary.simpleMessage(
      "适用于联发科芯片设备的 USB 驱动程序",
    ),
    "nextStep": MessageLookupByLibrary.simpleMessage("下一步"),
    "noDeviceDetected": MessageLookupByLibrary.simpleMessage("未检测到设备"),
    "noDeviceDetectedDesc": MessageLookupByLibrary.simpleMessage(
      "请确保设备已连接并开启 USB 调试",
    ),
    "noFastbootDevice": MessageLookupByLibrary.simpleMessage(
      "未检测到 Fastboot 设备",
    ),
    "noKpmModules": MessageLookupByLibrary.simpleMessage("未选择模块"),
    "noLogs": MessageLookupByLibrary.simpleMessage("暂无日志"),
    "noVersionSelected": MessageLookupByLibrary.simpleMessage("未选择版本"),
    "noVersionsAvailable": MessageLookupByLibrary.simpleMessage("没有可用的版本"),
    "oneClickFlash": MessageLookupByLibrary.simpleMessage("一键刷入"),
    "oneplusAdbDriver": MessageLookupByLibrary.simpleMessage("一加官方 ADB 驱动"),
    "oneplusAdbDriverDesc": MessageLookupByLibrary.simpleMessage(
      "一加官方 ADB 驱动程序，适用于 Windows 7 系统",
    ),
    "operationFailed": MessageLookupByLibrary.simpleMessage("操作失败"),
    "operationProgress": MessageLookupByLibrary.simpleMessage("操作进度"),
    "oppoAdbDriver": MessageLookupByLibrary.simpleMessage("OPPO 官方 ADB 驱动"),
    "oppoAdbDriverDesc": MessageLookupByLibrary.simpleMessage(
      "OPPO 官方 USB 驱动程序，适用于 Windows 10 及以上系统",
    ),
    "patchOnlyComplete": MessageLookupByLibrary.simpleMessage("修补完成！"),
    "patchTarget": MessageLookupByLibrary.simpleMessage("修补目标"),
    "patchTargetDesc": MessageLookupByLibrary.simpleMessage(
      "选择修补目标以使用对应的 KernelPatch 版本",
    ),
    "patchedFile": MessageLookupByLibrary.simpleMessage("修补文件"),
    "patching": MessageLookupByLibrary.simpleMessage("修补中..."),
    "pleaseSelectFile": MessageLookupByLibrary.simpleMessage(
      "请先选择 boot.img 文件",
    ),
    "previousStep": MessageLookupByLibrary.simpleMessage("上一步"),
    "qualcommDriver32": MessageLookupByLibrary.simpleMessage(
      "高通 Fastboot 驱动 (32位)",
    ),
    "qualcommDriver32Desc": MessageLookupByLibrary.simpleMessage(
      "适用于 32 位 Windows 系统的高通设备驱动",
    ),
    "qualcommDriver64": MessageLookupByLibrary.simpleMessage(
      "高通 Fastboot 驱动 (64位)",
    ),
    "qualcommDriver64Desc": MessageLookupByLibrary.simpleMessage(
      "适用于 64 位 Windows 系统的高通设备驱动",
    ),
    "quickPatch": MessageLookupByLibrary.simpleMessage("一键刷入"),
    "quickPatchComplete": MessageLookupByLibrary.simpleMessage("一键刷入完成！"),
    "quickPatchSubtitle": MessageLookupByLibrary.simpleMessage("你只需要负责等待"),
    "rebootLater": MessageLookupByLibrary.simpleMessage("稍后重启"),
    "rebootNow": MessageLookupByLibrary.simpleMessage("立即重启"),
    "rebootToFastboot": MessageLookupByLibrary.simpleMessage("重启到 Fastboot"),
    "recentFiles": MessageLookupByLibrary.simpleMessage("最近使用"),
    "refresh": MessageLookupByLibrary.simpleMessage("刷新"),
    "removeModule": MessageLookupByLibrary.simpleMessage("移除"),
    "reset": MessageLookupByLibrary.simpleMessage("重置"),
    "restart": MessageLookupByLibrary.simpleMessage("重新开始"),
    "retry": MessageLookupByLibrary.simpleMessage("重试"),
    "saveAs": MessageLookupByLibrary.simpleMessage("另存为"),
    "savePatchedFile": MessageLookupByLibrary.simpleMessage("保存修补文件"),
    "saveToFile": MessageLookupByLibrary.simpleMessage("保存到文件"),
    "scanning": MessageLookupByLibrary.simpleMessage("正在扫描设备连接"),
    "selectBootImage": MessageLookupByLibrary.simpleMessage("选择 boot.img 文件"),
    "selectCustomVersion": MessageLookupByLibrary.simpleMessage(
      "选择自定义 kpimg 文件",
    ),
    "selectKpmModules": MessageLookupByLibrary.simpleMessage("选择 KPM 模块..."),
    "selectMode": MessageLookupByLibrary.simpleMessage("选择操作模式"),
    "selectSaveLocation": MessageLookupByLibrary.simpleMessage("选择保存位置"),
    "selectVersion": MessageLookupByLibrary.simpleMessage("选择版本"),
    "selectVersionDesc": MessageLookupByLibrary.simpleMessage(
      "选择要使用的 KernelPatch 版本",
    ),
    "selectedModules": m45,
    "serial": m46,
    "simplePatch": MessageLookupByLibrary.simpleMessage("简单修补"),
    "simplePatchSubtitle": MessageLookupByLibrary.simpleMessage("单纯的修补文件"),
    "startFlash": MessageLookupByLibrary.simpleMessage("开始刷入"),
    "startPatch": MessageLookupByLibrary.simpleMessage("开始修补"),
    "step1": MessageLookupByLibrary.simpleMessage("步骤 1: 修补 boot.img"),
    "step1Desc": MessageLookupByLibrary.simpleMessage("选择文件并执行修补"),
    "step2": MessageLookupByLibrary.simpleMessage("步骤 2: 保存修补文件"),
    "step2Desc": MessageLookupByLibrary.simpleMessage("确认修补文件已保存"),
    "step3": MessageLookupByLibrary.simpleMessage("步骤 3: 设备进入 Fastboot"),
    "step3Desc": MessageLookupByLibrary.simpleMessage("将设备重启到 Fastboot 模式"),
    "step4": MessageLookupByLibrary.simpleMessage("步骤 4: 刷入 boot.img"),
    "step4Desc": MessageLookupByLibrary.simpleMessage("将修补后的文件刷入设备"),
    "stepBackupBoot": MessageLookupByLibrary.simpleMessage("备份 Boot"),
    "stepFlashDevice": MessageLookupByLibrary.simpleMessage("刷入设备"),
    "stepOperation": MessageLookupByLibrary.simpleMessage("分步操作"),
    "stepPatch": MessageLookupByLibrary.simpleMessage("分步操作"),
    "stepPatchImage": MessageLookupByLibrary.simpleMessage("修补镜像"),
    "stepPatchSubtitle": MessageLookupByLibrary.simpleMessage("手动执行每个步骤，更灵活"),
    "stepRebootComplete": MessageLookupByLibrary.simpleMessage("重启设备"),
    "stepRebootToFastboot": MessageLookupByLibrary.simpleMessage(
      "重启到 Fastboot",
    ),
    "stepSaveFile": MessageLookupByLibrary.simpleMessage("保存文件"),
    "stepSelectBoot": MessageLookupByLibrary.simpleMessage("选择 Boot 文件"),
    "switchToChinese": MessageLookupByLibrary.simpleMessage("切换为中文"),
    "switchToEnglish": MessageLookupByLibrary.simpleMessage(
      "Switch to English",
    ),
    "unableToOpenLink": m47,
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "versionCustom": MessageLookupByLibrary.simpleMessage("自定义"),
    "versionRecommended": MessageLookupByLibrary.simpleMessage("推荐"),
    "versionSupportUnpack": MessageLookupByLibrary.simpleMessage("内置解包"),
  };
}
