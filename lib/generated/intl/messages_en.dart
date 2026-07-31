// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(version) => "FolkTool v${version}";

  static String m1(path) => "ADB executable does not exist: ${path}";

  static String m2(error) => "Backup exception: ${error}";

  static String m3(error) => "Driver check failed: ${error}";

  static String m4(path) => "Fastboot executable does not exist: ${path}";

  static String m5(error) => "Flash exception: ${error}";

  static String m6(error) => "Flash failed: ${error}";

  static String m7(error) => "Failed to get ADB devices: ${error}";

  static String m8(error) => "Failed to get Fastboot devices: ${error}";

  static String m9(path) => "Input file does not exist: ${path}";

  static String m10(path) => "Kpimg file does not exist: ${path}";

  static String m11(path) => "Kptools file does not exist: ${path}";

  static String m12(error) => "Patch exception: ${error}";

  static String m13(error) => "Patch failed: ${error}";

  static String m14(error) => "Reboot exception: ${error}";

  static String m15(error) => "Reboot failed: ${error}";

  static String m16(error) => "Unpack failed: ${error}";

  static String m17(error) => "Failed to launch installer: ${error}";

  static String m18(name) => "${name} installation failed";

  static String m19(name) => "${name} installed successfully";

  static String m20(path) => "Boot backup complete: ${path}";

  static String m21(path) => "Backup successful: ${path}";

  static String m22(error) => "Failed to clean temporary files: ${error}";

  static String m23(path) => "Copied to ${path}";

  static String m24(cmd) => "Executing: ${cmd}";

  static String m25(serial) => "Fastboot device detected: ${serial}";

  static String m26(path) => "File saved: ${path}";

  static String m27(path) => "Flashing: ${path}";

  static String m28(path) => "Input file: ${path}";

  static String m29(path) => "Kpimg path: ${path}";

  static String m30(module) => "KPM Module: ${module}";

  static String m31(path) => "Kptools path: ${path}";

  static String m32(error) => "Failed to list patch info: ${error}";

  static String m33(error) => "Operation error: ${error}";

  static String m34(path) => "Output file: ${path}";

  static String m35(path) => "Patch complete: ${path}";

  static String m36(error) => "Patch exception: ${error}";

  static String m37(error) => "Patch failed: ${error}";

  static String m38(error) => "Repack exception: ${error}";

  static String m39(path, size) => "Repacked: ${path} (${size} MB)";

  static String m40(error) => "Unpack exception: ${error}";

  static String m41(path) => "Unpacked kernel: ${path}";

  static String m42(timeout) =>
      "Waiting for fastboot device (${timeout} seconds)";

  static String m43(dir) => "Working directory: ${dir}";

  static String m44(path) => "Logs saved: ${path}";

  static String m45(count) => "Selected (${count})";

  static String m46(serial) => "Serial: ${serial}";

  static String m47(error) => "Unable to open link: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "aboutDescription": MessageLookupByLibrary.simpleMessage(
      "KernelPatch Auto Flash Tool",
    ),
    "aboutDescription2": MessageLookupByLibrary.simpleMessage(
      "This tool is for automatically patching boot.img and flashing to device",
    ),
    "aboutTitle": MessageLookupByLibrary.simpleMessage("About"),
    "aboutTooltip": MessageLookupByLibrary.simpleMessage("About"),
    "adbConnected": MessageLookupByLibrary.simpleMessage("ADB Connected"),
    "apatchDesc": MessageLookupByLibrary.simpleMessage(
      "Android kernel-level root solution",
    ),
    "appFullName": MessageLookupByLibrary.simpleMessage(
      "FolkTool - KernelPatch Auto Flash Tool",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("FolkTool"),
    "appVersion": m0,
    "backupWarning": MessageLookupByLibrary.simpleMessage(
      "Please backup original boot partition before flashing",
    ),
    "cancelOperation": MessageLookupByLibrary.simpleMessage("Cancel Operation"),
    "checking": MessageLookupByLibrary.simpleMessage("Checking..."),
    "checkingDriver": MessageLookupByLibrary.simpleMessage("Checking Driver"),
    "checkingDriverDesc": MessageLookupByLibrary.simpleMessage(
      "Checking ADB/Fastboot driver...",
    ),
    "clearAllModules": MessageLookupByLibrary.simpleMessage("Clear All"),
    "clearLogs": MessageLookupByLibrary.simpleMessage("Clear Logs"),
    "clickToSelectFile": MessageLookupByLibrary.simpleMessage(
      "Click to select file...",
    ),
    "clientCheck": MessageLookupByLibrary.simpleMessage("Client Detection"),
    "copyLogs": MessageLookupByLibrary.simpleMessage("Copy Logs"),
    "currentVersion": MessageLookupByLibrary.simpleMessage("Current Version"),
    "customVersion": MessageLookupByLibrary.simpleMessage("Custom Version"),
    "customVersionSaved": MessageLookupByLibrary.simpleMessage(
      "Custom version saved",
    ),
    "deviceConnectionTips": MessageLookupByLibrary.simpleMessage(
      "Device Connection Tips",
    ),
    "deviceConnectionTipsDesc": MessageLookupByLibrary.simpleMessage(
      "1. Ensure device is connected to PC via USB\n2. Enable developer options and USB debugging on device\n3. For Fastboot, enter Bootloader mode first",
    ),
    "deviceInFastboot": MessageLookupByLibrary.simpleMessage(
      "Device in Fastboot",
    ),
    "deviceStatus": MessageLookupByLibrary.simpleMessage("Device Status"),
    "driverInstall": MessageLookupByLibrary.simpleMessage("Driver Install"),
    "driverInstallPage": MessageLookupByLibrary.simpleMessage(
      "Driver Installation",
    ),
    "driverInstallSubtitle": MessageLookupByLibrary.simpleMessage(
      "Install the driver to resolve missing driver issues",
    ),
    "errAdbNotAvailable": MessageLookupByLibrary.simpleMessage(
      "ADB is not available",
    ),
    "errAdbNotExist": m1,
    "errBackupException": m2,
    "errDriverCheckFailed": m3,
    "errFastbootNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Fastboot is not available",
    ),
    "errFastbootNotExist": m4,
    "errFlashBootFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to flash boot partition",
    ),
    "errFlashException": m5,
    "errFlashFailed": m6,
    "errGetAdbFailed": m7,
    "errGetFastbootFailed": m8,
    "errInputNotExist": m9,
    "errKernelNotFound": MessageLookupByLibrary.simpleMessage(
      "Kernel file not found",
    ),
    "errKpimgNotExist": m10,
    "errKptoolsNotExist": m11,
    "errOutputKernelNotFound": MessageLookupByLibrary.simpleMessage(
      "Output kernel not found",
    ),
    "errPatchException": m12,
    "errPatchFailed": m13,
    "errRebootException": m14,
    "errRebootFailed": m15,
    "errRepackFailed": MessageLookupByLibrary.simpleMessage("Repack failed"),
    "errSelectBootFirst": MessageLookupByLibrary.simpleMessage(
      "Please select boot.img file first",
    ),
    "errUnpackFailed": m16,
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export Logs"),
    "exportLogsTooltip": MessageLookupByLibrary.simpleMessage("Export Logs"),
    "fastbootConnected": MessageLookupByLibrary.simpleMessage(
      "Fastboot Connected",
    ),
    "fileSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "File saved successfully",
    ),
    "flashBoot": MessageLookupByLibrary.simpleMessage("Flash boot"),
    "flashComplete": MessageLookupByLibrary.simpleMessage("Flash Complete"),
    "flashCompleteDesc": MessageLookupByLibrary.simpleMessage(
      "Reboot device now?",
    ),
    "flashFile": MessageLookupByLibrary.simpleMessage("Flash File"),
    "flashSuccess": MessageLookupByLibrary.simpleMessage("Flash successful!"),
    "flashing": MessageLookupByLibrary.simpleMessage("Flashing..."),
    "folkpatchDesc": MessageLookupByLibrary.simpleMessage(
      "An excellent KernelPatch management client",
    ),
    "github": MessageLookupByLibrary.simpleMessage("GitHub"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "install": MessageLookupByLibrary.simpleMessage("Install"),
    "installDriver": MessageLookupByLibrary.simpleMessage("Install Driver"),
    "installDriverFailed": m17,
    "installDriverSuccess": MessageLookupByLibrary.simpleMessage(
      "Driver installer launched",
    ),
    "installFailed": m18,
    "installSuccess": m19,
    "installed": MessageLookupByLibrary.simpleMessage("Installed"),
    "installing": MessageLookupByLibrary.simpleMessage("Installing..."),
    "invalidVersionFile": MessageLookupByLibrary.simpleMessage(
      "Invalid version file",
    ),
    "kernelPatchVersion": MessageLookupByLibrary.simpleMessage(
      "KernelPatch Version",
    ),
    "kpmModules": MessageLookupByLibrary.simpleMessage(
      "KPM Modules (Optional)",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "loadingVersions": MessageLookupByLibrary.simpleMessage(
      "Loading versions...",
    ),
    "logAutoRebootFailed": MessageLookupByLibrary.simpleMessage(
      "Auto reboot to fastboot failed",
    ),
    "logAutoRebootFailed2": MessageLookupByLibrary.simpleMessage(
      "Auto reboot failed",
    ),
    "logBackingUpBoot": MessageLookupByLibrary.simpleMessage(
      "Backing up boot partition...",
    ),
    "logBackingUpPartition": MessageLookupByLibrary.simpleMessage(
      "Backing up partition...",
    ),
    "logBackupComplete": m20,
    "logBackupFailed": MessageLookupByLibrary.simpleMessage(
      "Boot backup failed",
    ),
    "logBackupFailedTryAlt": MessageLookupByLibrary.simpleMessage(
      "Backup failed, trying alternative method...",
    ),
    "logBackupKernel": MessageLookupByLibrary.simpleMessage(
      "Backing up kernel...",
    ),
    "logBackupSuccess": m21,
    "logCancelling": MessageLookupByLibrary.simpleMessage(
      "Cancelling operation...",
    ),
    "logCheckAdb": MessageLookupByLibrary.simpleMessage("Checking ADB..."),
    "logCheckFastboot": MessageLookupByLibrary.simpleMessage(
      "Checking Fastboot...",
    ),
    "logCheckingFile": MessageLookupByLibrary.simpleMessage("Checking file..."),
    "logCleanWorkDir": MessageLookupByLibrary.simpleMessage(
      "Cleaning temporary files...",
    ),
    "logCleanWorkDirFailed": m22,
    "logConsole": MessageLookupByLibrary.simpleMessage("Log Console"),
    "logCopied": m23,
    "logCopyBoot": MessageLookupByLibrary.simpleMessage(
      "Copying boot image...",
    ),
    "logDeviceInFastboot": MessageLookupByLibrary.simpleMessage(
      "Device is in fastboot mode",
    ),
    "logDeviceNotFastboot": MessageLookupByLibrary.simpleMessage(
      "Device not in fastboot mode",
    ),
    "logDeviceRebooting": MessageLookupByLibrary.simpleMessage(
      "Device is rebooting...",
    ),
    "logDriverCheckPassed": MessageLookupByLibrary.simpleMessage(
      "Driver check passed",
    ),
    "logEntries": MessageLookupByLibrary.simpleMessage("entries"),
    "logExecuteCmd": m24,
    "logFastbootDetected": m25,
    "logFileSaved": m26,
    "logFlashBootSuccess": MessageLookupByLibrary.simpleMessage(
      "Flash completed successfully",
    ),
    "logFlashFailed": MessageLookupByLibrary.simpleMessage("Flash failed"),
    "logFlashSuccess": MessageLookupByLibrary.simpleMessage("Flash successful"),
    "logFlashingBoot": MessageLookupByLibrary.simpleMessage(
      "Flashing boot image...",
    ),
    "logFlashingBootPath": m27,
    "logInputFile": m28,
    "logKpimgPath": m29,
    "logKpmModule": m30,
    "logKptoolsPath": m31,
    "logListPatchInfoFailed": m32,
    "logNoAdbDevice": MessageLookupByLibrary.simpleMessage(
      "No ADB device detected",
    ),
    "logOneClickComplete": MessageLookupByLibrary.simpleMessage(
      "One-click flash completed!",
    ),
    "logOperationError": m33,
    "logOutput": MessageLookupByLibrary.simpleMessage("Log Output"),
    "logOutputFile": m34,
    "logPatchComplete": m35,
    "logPatchException": m36,
    "logPatchFailed": m37,
    "logPatchSuccess": MessageLookupByLibrary.simpleMessage(
      "Kernel patched successfully",
    ),
    "logPatchingBoot": MessageLookupByLibrary.simpleMessage(
      "Patching boot image...",
    ),
    "logPatchingKernel": MessageLookupByLibrary.simpleMessage(
      "Patching kernel...",
    ),
    "logRebootCmdSent": MessageLookupByLibrary.simpleMessage(
      "Reboot command sent",
    ),
    "logRebootSuccess": MessageLookupByLibrary.simpleMessage(
      "Device rebooted successfully",
    ),
    "logRebootingDevice": MessageLookupByLibrary.simpleMessage(
      "Rebooting device...",
    ),
    "logRebootingToFastboot": MessageLookupByLibrary.simpleMessage(
      "Rebooting to fastboot mode...",
    ),
    "logRepackException": m38,
    "logRepackSuccess": m39,
    "logRepacking": MessageLookupByLibrary.simpleMessage(
      "Repacking boot image...",
    ),
    "logSavingFile": MessageLookupByLibrary.simpleMessage(
      "Saving patched file...",
    ),
    "logStartPatching": MessageLookupByLibrary.simpleMessage(
      "Starting patch operation...",
    ),
    "logUnpackException": m40,
    "logUnpackSuccess": m41,
    "logUnpacking": MessageLookupByLibrary.simpleMessage(
      "Unpacking boot image...",
    ),
    "logWaitFastboot": m42,
    "logWaitFastbootTimeout": MessageLookupByLibrary.simpleMessage(
      "Wait for fastboot timeout",
    ),
    "logWorkDir": m43,
    "logsSaved": m44,
    "manuallyEnterFastboot": MessageLookupByLibrary.simpleMessage(
      "Please manually enter Fastboot mode",
    ),
    "manuallyEnterFastbootDesc": MessageLookupByLibrary.simpleMessage(
      "1. Power off device\n2. Hold Volume Down + Power button\n3. Connect USB cable to PC",
    ),
    "matsuzakaYuki": MessageLookupByLibrary.simpleMessage("Matsuzaka Yuki"),
    "mediatekDriver": MessageLookupByLibrary.simpleMessage(
      "MediaTek USB Driver",
    ),
    "mediatekDriverDesc": MessageLookupByLibrary.simpleMessage(
      "USB driver for MediaTek chipset devices",
    ),
    "nextStep": MessageLookupByLibrary.simpleMessage("Next"),
    "noDeviceDetected": MessageLookupByLibrary.simpleMessage(
      "No device detected",
    ),
    "noDeviceDetectedDesc": MessageLookupByLibrary.simpleMessage(
      "Please ensure device is connected and USB debugging is enabled",
    ),
    "noFastbootDevice": MessageLookupByLibrary.simpleMessage(
      "No Fastboot device detected",
    ),
    "noKpmModules": MessageLookupByLibrary.simpleMessage("No modules selected"),
    "noLogs": MessageLookupByLibrary.simpleMessage("No logs"),
    "noVersionSelected": MessageLookupByLibrary.simpleMessage(
      "No version selected",
    ),
    "noVersionsAvailable": MessageLookupByLibrary.simpleMessage(
      "No versions available",
    ),
    "oneClickFlash": MessageLookupByLibrary.simpleMessage("One-Click Flash"),
    "oneplusAdbDriver": MessageLookupByLibrary.simpleMessage(
      "OnePlus Official ADB Driver",
    ),
    "oneplusAdbDriverDesc": MessageLookupByLibrary.simpleMessage(
      "Official OnePlus ADB driver for Windows 7 systems",
    ),
    "operationFailed": MessageLookupByLibrary.simpleMessage("Operation Failed"),
    "operationProgress": MessageLookupByLibrary.simpleMessage(
      "Operation Progress",
    ),
    "oppoAdbDriver": MessageLookupByLibrary.simpleMessage(
      "OPPO Official ADB Driver",
    ),
    "oppoAdbDriverDesc": MessageLookupByLibrary.simpleMessage(
      "Official OPPO USB driver for Windows 10 and above",
    ),
    "patchOnlyComplete": MessageLookupByLibrary.simpleMessage(
      "Patch complete!",
    ),
    "patchTarget": MessageLookupByLibrary.simpleMessage("Patch Target"),
    "patchTargetDesc": MessageLookupByLibrary.simpleMessage(
      "Select patch target to use corresponding KernelPatch version",
    ),
    "patchedFile": MessageLookupByLibrary.simpleMessage("Patched File"),
    "patching": MessageLookupByLibrary.simpleMessage("Patching..."),
    "pleaseSelectFile": MessageLookupByLibrary.simpleMessage(
      "Please select boot.img file first",
    ),
    "previousStep": MessageLookupByLibrary.simpleMessage("Previous"),
    "qualcommDriver32": MessageLookupByLibrary.simpleMessage(
      "Qualcomm Fastboot Driver (32-bit)",
    ),
    "qualcommDriver32Desc": MessageLookupByLibrary.simpleMessage(
      "Qualcomm device driver for 32-bit Windows systems",
    ),
    "qualcommDriver64": MessageLookupByLibrary.simpleMessage(
      "Qualcomm Fastboot Driver (64-bit)",
    ),
    "qualcommDriver64Desc": MessageLookupByLibrary.simpleMessage(
      "Qualcomm device driver for 64-bit Windows systems",
    ),
    "quickPatch": MessageLookupByLibrary.simpleMessage("One-Click Flash"),
    "quickPatchComplete": MessageLookupByLibrary.simpleMessage(
      "One-click flash completed!",
    ),
    "quickPatchSubtitle": MessageLookupByLibrary.simpleMessage(
      "Automatically complete patch, reboot, and flash process",
    ),
    "rebootLater": MessageLookupByLibrary.simpleMessage("Reboot Later"),
    "rebootNow": MessageLookupByLibrary.simpleMessage("Reboot Now"),
    "rebootToFastboot": MessageLookupByLibrary.simpleMessage(
      "Reboot to Fastboot",
    ),
    "recentFiles": MessageLookupByLibrary.simpleMessage("Recent Files"),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "removeModule": MessageLookupByLibrary.simpleMessage("Remove"),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "saveAs": MessageLookupByLibrary.simpleMessage("Save As"),
    "savePatchedFile": MessageLookupByLibrary.simpleMessage(
      "Save Patched File",
    ),
    "saveToFile": MessageLookupByLibrary.simpleMessage("Save to File"),
    "scanning": MessageLookupByLibrary.simpleMessage("Scanning devices..."),
    "selectBootImage": MessageLookupByLibrary.simpleMessage(
      "Select boot.img File",
    ),
    "selectCustomVersion": MessageLookupByLibrary.simpleMessage(
      "Select custom kpimg file",
    ),
    "selectKpmModules": MessageLookupByLibrary.simpleMessage(
      "Select KPM modules...",
    ),
    "selectMode": MessageLookupByLibrary.simpleMessage("Select Operation Mode"),
    "selectSaveLocation": MessageLookupByLibrary.simpleMessage(
      "Select save location",
    ),
    "selectVersion": MessageLookupByLibrary.simpleMessage("Select Version"),
    "selectVersionDesc": MessageLookupByLibrary.simpleMessage(
      "Select the KernelPatch version to use",
    ),
    "selectedModules": m45,
    "serial": m46,
    "simplePatch": MessageLookupByLibrary.simpleMessage("Simple Patch"),
    "simplePatchSubtitle": MessageLookupByLibrary.simpleMessage(
      "Patch boot.img only, save file manually",
    ),
    "startFlash": MessageLookupByLibrary.simpleMessage("Start Flash"),
    "startPatch": MessageLookupByLibrary.simpleMessage("Start Patch"),
    "step1": MessageLookupByLibrary.simpleMessage("Step 1: Patch boot.img"),
    "step1Desc": MessageLookupByLibrary.simpleMessage(
      "Select file and execute patch",
    ),
    "step2": MessageLookupByLibrary.simpleMessage("Step 2: Save Patched File"),
    "step2Desc": MessageLookupByLibrary.simpleMessage(
      "Confirm patched file is saved",
    ),
    "step3": MessageLookupByLibrary.simpleMessage("Step 3: Enter Fastboot"),
    "step3Desc": MessageLookupByLibrary.simpleMessage(
      "Reboot device to Fastboot mode",
    ),
    "step4": MessageLookupByLibrary.simpleMessage("Step 4: Flash boot.img"),
    "step4Desc": MessageLookupByLibrary.simpleMessage(
      "Flash patched file to device",
    ),
    "stepBackupBoot": MessageLookupByLibrary.simpleMessage("Backup Boot"),
    "stepFlashDevice": MessageLookupByLibrary.simpleMessage("Flash to Device"),
    "stepOperation": MessageLookupByLibrary.simpleMessage("Step-by-Step"),
    "stepPatch": MessageLookupByLibrary.simpleMessage("Step-by-Step"),
    "stepPatchImage": MessageLookupByLibrary.simpleMessage("Patch Image"),
    "stepPatchSubtitle": MessageLookupByLibrary.simpleMessage(
      "Manually execute each step, more flexible",
    ),
    "stepRebootComplete": MessageLookupByLibrary.simpleMessage("Reboot Device"),
    "stepRebootToFastboot": MessageLookupByLibrary.simpleMessage(
      "Reboot to Fastboot",
    ),
    "stepSaveFile": MessageLookupByLibrary.simpleMessage("Save File"),
    "stepSelectBoot": MessageLookupByLibrary.simpleMessage("Select Boot File"),
    "switchToChinese": MessageLookupByLibrary.simpleMessage("切换为中文"),
    "switchToEnglish": MessageLookupByLibrary.simpleMessage(
      "Switch to English",
    ),
    "unableToOpenLink": m47,
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "versionCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "versionRecommended": MessageLookupByLibrary.simpleMessage("Recommended"),
    "versionSupportUnpack": MessageLookupByLibrary.simpleMessage(
      "Built-in Unpack",
    ),
  };
}
