// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `FolkTool`
  String get appName {
    return Intl.message('FolkTool', name: 'appName', desc: '', args: []);
  }

  /// `FolkTool - KernelPatch Auto Flash Tool`
  String get appFullName {
    return Intl.message(
      'FolkTool - KernelPatch Auto Flash Tool',
      name: 'appFullName',
      desc: '',
      args: [],
    );
  }

  /// `FolkTool v{version}`
  String appVersion(Object version) {
    return Intl.message(
      'FolkTool v$version',
      name: 'appVersion',
      desc: '',
      args: [version],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `About`
  String get aboutTooltip {
    return Intl.message('About', name: 'aboutTooltip', desc: '', args: []);
  }

  /// `About`
  String get aboutTitle {
    return Intl.message('About', name: 'aboutTitle', desc: '', args: []);
  }

  /// `KernelPatch Auto Flash Tool`
  String get aboutDescription {
    return Intl.message(
      'KernelPatch Auto Flash Tool',
      name: 'aboutDescription',
      desc: '',
      args: [],
    );
  }

  /// `This tool is for automatically patching boot.img and flashing to device`
  String get aboutDescription2 {
    return Intl.message(
      'This tool is for automatically patching boot.img and flashing to device',
      name: 'aboutDescription2',
      desc: '',
      args: [],
    );
  }

  /// `Please backup original boot partition before flashing`
  String get backupWarning {
    return Intl.message(
      'Please backup original boot partition before flashing',
      name: 'backupWarning',
      desc: '',
      args: [],
    );
  }

  /// `Select Operation Mode`
  String get selectMode {
    return Intl.message(
      'Select Operation Mode',
      name: 'selectMode',
      desc: '',
      args: [],
    );
  }

  /// `One-Click Flash`
  String get quickPatch {
    return Intl.message(
      'One-Click Flash',
      name: 'quickPatch',
      desc: '',
      args: [],
    );
  }

  /// `Automatically complete patch, reboot, and flash process`
  String get quickPatchSubtitle {
    return Intl.message(
      'Automatically complete patch, reboot, and flash process',
      name: 'quickPatchSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Step-by-Step`
  String get stepPatch {
    return Intl.message('Step-by-Step', name: 'stepPatch', desc: '', args: []);
  }

  /// `Manually execute each step, more flexible`
  String get stepPatchSubtitle {
    return Intl.message(
      'Manually execute each step, more flexible',
      name: 'stepPatchSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Recent Files`
  String get recentFiles {
    return Intl.message(
      'Recent Files',
      name: 'recentFiles',
      desc: '',
      args: [],
    );
  }

  /// `Select boot.img File`
  String get selectBootImage {
    return Intl.message(
      'Select boot.img File',
      name: 'selectBootImage',
      desc: '',
      args: [],
    );
  }

  /// `Click to select file...`
  String get clickToSelectFile {
    return Intl.message(
      'Click to select file...',
      name: 'clickToSelectFile',
      desc: '',
      args: [],
    );
  }

  /// `Device Status`
  String get deviceStatus {
    return Intl.message(
      'Device Status',
      name: 'deviceStatus',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `Checking...`
  String get checking {
    return Intl.message('Checking...', name: 'checking', desc: '', args: []);
  }

  /// `Checking Driver`
  String get checkingDriver {
    return Intl.message(
      'Checking Driver',
      name: 'checkingDriver',
      desc: '',
      args: [],
    );
  }

  /// `Checking ADB/Fastboot driver...`
  String get checkingDriverDesc {
    return Intl.message(
      'Checking ADB/Fastboot driver...',
      name: 'checkingDriverDesc',
      desc: '',
      args: [],
    );
  }

  /// `No device detected`
  String get noDeviceDetected {
    return Intl.message(
      'No device detected',
      name: 'noDeviceDetected',
      desc: '',
      args: [],
    );
  }

  /// `Please ensure device is connected and USB debugging is enabled`
  String get noDeviceDetectedDesc {
    return Intl.message(
      'Please ensure device is connected and USB debugging is enabled',
      name: 'noDeviceDetectedDesc',
      desc: '',
      args: [],
    );
  }

  /// `Device Connection Tips`
  String get deviceConnectionTips {
    return Intl.message(
      'Device Connection Tips',
      name: 'deviceConnectionTips',
      desc: '',
      args: [],
    );
  }

  /// `1. Ensure device is connected to PC via USB\n2. Enable developer options and USB debugging on device\n3. For Fastboot, enter Bootloader mode first`
  String get deviceConnectionTipsDesc {
    return Intl.message(
      '1. Ensure device is connected to PC via USB\n2. Enable developer options and USB debugging on device\n3. For Fastboot, enter Bootloader mode first',
      name: 'deviceConnectionTipsDesc',
      desc: '',
      args: [],
    );
  }

  /// `ADB Connected`
  String get adbConnected {
    return Intl.message(
      'ADB Connected',
      name: 'adbConnected',
      desc: '',
      args: [],
    );
  }

  /// `Serial: {serial}`
  String serial(Object serial) {
    return Intl.message(
      'Serial: $serial',
      name: 'serial',
      desc: '',
      args: [serial],
    );
  }

  /// `Fastboot Connected`
  String get fastbootConnected {
    return Intl.message(
      'Fastboot Connected',
      name: 'fastbootConnected',
      desc: '',
      args: [],
    );
  }

  /// `Scanning devices...`
  String get scanning {
    return Intl.message(
      'Scanning devices...',
      name: 'scanning',
      desc: '',
      args: [],
    );
  }

  /// `Patch Target`
  String get patchTarget {
    return Intl.message('Patch Target', name: 'patchTarget', desc: '', args: []);
  }

  /// `Select patch target to use corresponding KernelPatch version`
  String get patchTargetDesc {
    return Intl.message(
      'Select patch target to use corresponding KernelPatch version',
      name: 'patchTargetDesc',
      desc: '',
      args: [],
    );
  }

  /// `KPM Modules (Optional)`
  String get kpmModules {
    return Intl.message(
      'KPM Modules (Optional)',
      name: 'kpmModules',
      desc: '',
      args: [],
    );
  }

  /// `Select KPM modules...`
  String get selectKpmModules {
    return Intl.message(
      'Select KPM modules...',
      name: 'selectKpmModules',
      desc: '',
      args: [],
    );
  }

  /// `No modules selected`
  String get noKpmModules {
    return Intl.message(
      'No modules selected',
      name: 'noKpmModules',
      desc: '',
      args: [],
    );
  }

  /// `Selected ({count})`
  String selectedModules(Object count) {
    return Intl.message(
      'Selected ($count)',
      name: 'selectedModules',
      desc: '',
      args: [count],
    );
  }

  /// `Clear All`
  String get clearAllModules {
    return Intl.message(
      'Clear All',
      name: 'clearAllModules',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get removeModule {
    return Intl.message('Remove', name: 'removeModule', desc: '', args: []);
  }

  /// `KPM Module: {module}`
  String logKpmModule(Object module) {
    return Intl.message(
      'KPM Module: $module',
      name: 'logKpmModule',
      desc: '',
      args: [module],
    );
  }

  /// `One-Click Flash`
  String get oneClickFlash {
    return Intl.message(
      'One-Click Flash',
      name: 'oneClickFlash',
      desc: '',
      args: [],
    );
  }

  /// `Export Logs`
  String get exportLogs {
    return Intl.message('Export Logs', name: 'exportLogs', desc: '', args: []);
  }

  /// `Export Logs`
  String get exportLogsTooltip {
    return Intl.message(
      'Export Logs',
      name: 'exportLogsTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Start Flash`
  String get startFlash {
    return Intl.message('Start Flash', name: 'startFlash', desc: '', args: []);
  }

  /// `Flashing...`
  String get flashing {
    return Intl.message('Flashing...', name: 'flashing', desc: '', args: []);
  }

  /// `Cancel Operation`
  String get cancelOperation {
    return Intl.message(
      'Cancel Operation',
      name: 'cancelOperation',
      desc: '',
      args: [],
    );
  }

  /// `One-click flash completed!`
  String get quickPatchComplete {
    return Intl.message(
      'One-click flash completed!',
      name: 'quickPatchComplete',
      desc: '',
      args: [],
    );
  }

  /// `Restart`
  String get restart {
    return Intl.message('Restart', name: 'restart', desc: '', args: []);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Operation Failed`
  String get operationFailed {
    return Intl.message(
      'Operation Failed',
      name: 'operationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Logs saved: {path}`
  String logsSaved(Object path) {
    return Intl.message(
      'Logs saved: $path',
      name: 'logsSaved',
      desc: '',
      args: [path],
    );
  }

  /// `Unable to open link: {error}`
  String unableToOpenLink(Object error) {
    return Intl.message(
      'Unable to open link: $error',
      name: 'unableToOpenLink',
      desc: '',
      args: [error],
    );
  }

  /// `Please select boot.img file first`
  String get pleaseSelectFile {
    return Intl.message(
      'Please select boot.img file first',
      name: 'pleaseSelectFile',
      desc: '',
      args: [],
    );
  }

  /// `Step-by-Step`
  String get stepOperation {
    return Intl.message(
      'Step-by-Step',
      name: 'stepOperation',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `Step 1: Patch boot.img`
  String get step1 {
    return Intl.message(
      'Step 1: Patch boot.img',
      name: 'step1',
      desc: '',
      args: [],
    );
  }

  /// `Select file and execute patch`
  String get step1Desc {
    return Intl.message(
      'Select file and execute patch',
      name: 'step1Desc',
      desc: '',
      args: [],
    );
  }

  /// `Step 2: Save Patched File`
  String get step2 {
    return Intl.message(
      'Step 2: Save Patched File',
      name: 'step2',
      desc: '',
      args: [],
    );
  }

  /// `Confirm patched file is saved`
  String get step2Desc {
    return Intl.message(
      'Confirm patched file is saved',
      name: 'step2Desc',
      desc: '',
      args: [],
    );
  }

  /// `Step 3: Enter Fastboot`
  String get step3 {
    return Intl.message(
      'Step 3: Enter Fastboot',
      name: 'step3',
      desc: '',
      args: [],
    );
  }

  /// `Reboot device to Fastboot mode`
  String get step3Desc {
    return Intl.message(
      'Reboot device to Fastboot mode',
      name: 'step3Desc',
      desc: '',
      args: [],
    );
  }

  /// `Step 4: Flash boot.img`
  String get step4 {
    return Intl.message(
      'Step 4: Flash boot.img',
      name: 'step4',
      desc: '',
      args: [],
    );
  }

  /// `Flash patched file to device`
  String get step4Desc {
    return Intl.message(
      'Flash patched file to device',
      name: 'step4Desc',
      desc: '',
      args: [],
    );
  }

  /// `Start Patch`
  String get startPatch {
    return Intl.message('Start Patch', name: 'startPatch', desc: '', args: []);
  }

  /// `Patching...`
  String get patching {
    return Intl.message('Patching...', name: 'patching', desc: '', args: []);
  }

  /// `Patched File`
  String get patchedFile {
    return Intl.message(
      'Patched File',
      name: 'patchedFile',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Previous`
  String get previousStep {
    return Intl.message('Previous', name: 'previousStep', desc: '', args: []);
  }

  /// `Next`
  String get nextStep {
    return Intl.message('Next', name: 'nextStep', desc: '', args: []);
  }

  /// `Reboot to Fastboot`
  String get rebootToFastboot {
    return Intl.message(
      'Reboot to Fastboot',
      name: 'rebootToFastboot',
      desc: '',
      args: [],
    );
  }

  /// `Please manually enter Fastboot mode`
  String get manuallyEnterFastboot {
    return Intl.message(
      'Please manually enter Fastboot mode',
      name: 'manuallyEnterFastboot',
      desc: '',
      args: [],
    );
  }

  /// `1. Power off device\n2. Hold Volume Down + Power button\n3. Connect USB cable to PC`
  String get manuallyEnterFastbootDesc {
    return Intl.message(
      '1. Power off device\n2. Hold Volume Down + Power button\n3. Connect USB cable to PC',
      name: 'manuallyEnterFastbootDesc',
      desc: '',
      args: [],
    );
  }

  /// `Device in Fastboot`
  String get deviceInFastboot {
    return Intl.message(
      'Device in Fastboot',
      name: 'deviceInFastboot',
      desc: '',
      args: [],
    );
  }

  /// `Flash File`
  String get flashFile {
    return Intl.message('Flash File', name: 'flashFile', desc: '', args: []);
  }

  /// `Flash boot`
  String get flashBoot {
    return Intl.message('Flash boot', name: 'flashBoot', desc: '', args: []);
  }

  /// `No Fastboot device detected`
  String get noFastbootDevice {
    return Intl.message(
      'No Fastboot device detected',
      name: 'noFastbootDevice',
      desc: '',
      args: [],
    );
  }

  /// `Flash successful!`
  String get flashSuccess {
    return Intl.message(
      'Flash successful!',
      name: 'flashSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Flash Complete`
  String get flashComplete {
    return Intl.message(
      'Flash Complete',
      name: 'flashComplete',
      desc: '',
      args: [],
    );
  }

  /// `Reboot device now?`
  String get flashCompleteDesc {
    return Intl.message(
      'Reboot device now?',
      name: 'flashCompleteDesc',
      desc: '',
      args: [],
    );
  }

  /// `Reboot Later`
  String get rebootLater {
    return Intl.message(
      'Reboot Later',
      name: 'rebootLater',
      desc: '',
      args: [],
    );
  }

  /// `Reboot Now`
  String get rebootNow {
    return Intl.message('Reboot Now', name: 'rebootNow', desc: '', args: []);
  }

  /// `GitHub`
  String get github {
    return Intl.message('GitHub', name: 'github', desc: '', args: []);
  }

  /// `Matsuzaka Yuki`
  String get matsuzakaYuki {
    return Intl.message(
      'Matsuzaka Yuki',
      name: 'matsuzakaYuki',
      desc: '',
      args: [],
    );
  }

  /// `Switch to English`
  String get switchToEnglish {
    return Intl.message(
      'Switch to English',
      name: 'switchToEnglish',
      desc: '',
      args: [],
    );
  }

  /// `切换为中文`
  String get switchToChinese {
    return Intl.message('切换为中文', name: 'switchToChinese', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Log Console`
  String get logConsole {
    return Intl.message('Log Console', name: 'logConsole', desc: '', args: []);
  }

  /// `Log Output`
  String get logOutput {
    return Intl.message('Log Output', name: 'logOutput', desc: '', args: []);
  }

  /// `entries`
  String get logEntries {
    return Intl.message('entries', name: 'logEntries', desc: '', args: []);
  }

  /// `No logs`
  String get noLogs {
    return Intl.message('No logs', name: 'noLogs', desc: '', args: []);
  }

  /// `Clear Logs`
  String get clearLogs {
    return Intl.message('Clear Logs', name: 'clearLogs', desc: '', args: []);
  }

  /// `Copy Logs`
  String get copyLogs {
    return Intl.message('Copy Logs', name: 'copyLogs', desc: '', args: []);
  }

  /// `Operation Progress`
  String get operationProgress {
    return Intl.message(
      'Operation Progress',
      name: 'operationProgress',
      desc: '',
      args: [],
    );
  }

  /// `Checking file...`
  String get logCheckingFile {
    return Intl.message(
      'Checking file...',
      name: 'logCheckingFile',
      desc: '',
      args: [],
    );
  }

  /// `Input file: {path}`
  String logInputFile(Object path) {
    return Intl.message(
      'Input file: $path',
      name: 'logInputFile',
      desc: '',
      args: [path],
    );
  }

  /// `Output file: {path}`
  String logOutputFile(Object path) {
    return Intl.message(
      'Output file: $path',
      name: 'logOutputFile',
      desc: '',
      args: [path],
    );
  }

  /// `Kpimg path: {path}`
  String logKpimgPath(Object path) {
    return Intl.message(
      'Kpimg path: $path',
      name: 'logKpimgPath',
      desc: '',
      args: [path],
    );
  }

  /// `Kptools path: {path}`
  String logKptoolsPath(Object path) {
    return Intl.message(
      'Kptools path: $path',
      name: 'logKptoolsPath',
      desc: '',
      args: [path],
    );
  }

  /// `Working directory: {dir}`
  String logWorkDir(Object dir) {
    return Intl.message(
      'Working directory: $dir',
      name: 'logWorkDir',
      desc: '',
      args: [dir],
    );
  }

  /// `Copying boot image...`
  String get logCopyBoot {
    return Intl.message(
      'Copying boot image...',
      name: 'logCopyBoot',
      desc: '',
      args: [],
    );
  }

  /// `Copied to {path}`
  String logCopied(Object path) {
    return Intl.message(
      'Copied to $path',
      name: 'logCopied',
      desc: '',
      args: [path],
    );
  }

  /// `Unpacking boot image...`
  String get logUnpacking {
    return Intl.message(
      'Unpacking boot image...',
      name: 'logUnpacking',
      desc: '',
      args: [],
    );
  }

  /// `Unpacked kernel: {path}`
  String logUnpackSuccess(Object path) {
    return Intl.message(
      'Unpacked kernel: $path',
      name: 'logUnpackSuccess',
      desc: '',
      args: [path],
    );
  }

  /// `Backing up kernel...`
  String get logBackupKernel {
    return Intl.message(
      'Backing up kernel...',
      name: 'logBackupKernel',
      desc: '',
      args: [],
    );
  }

  /// `Patching kernel...`
  String get logPatchingKernel {
    return Intl.message(
      'Patching kernel...',
      name: 'logPatchingKernel',
      desc: '',
      args: [],
    );
  }

  /// `Kernel patched successfully`
  String get logPatchSuccess {
    return Intl.message(
      'Kernel patched successfully',
      name: 'logPatchSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Repacking boot image...`
  String get logRepacking {
    return Intl.message(
      'Repacking boot image...',
      name: 'logRepacking',
      desc: '',
      args: [],
    );
  }

  /// `Repacked: {path} ({size} MB)`
  String logRepackSuccess(Object path, Object size) {
    return Intl.message(
      'Repacked: $path ($size MB)',
      name: 'logRepackSuccess',
      desc: '',
      args: [path, size],
    );
  }

  /// `Cleaning temporary files...`
  String get logCleanWorkDir {
    return Intl.message(
      'Cleaning temporary files...',
      name: 'logCleanWorkDir',
      desc: '',
      args: [],
    );
  }

  /// `Failed to clean temporary files: {error}`
  String logCleanWorkDirFailed(Object error) {
    return Intl.message(
      'Failed to clean temporary files: $error',
      name: 'logCleanWorkDirFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Unpack exception: {error}`
  String logUnpackException(Object error) {
    return Intl.message(
      'Unpack exception: $error',
      name: 'logUnpackException',
      desc: '',
      args: [error],
    );
  }

  /// `Repack exception: {error}`
  String logRepackException(Object error) {
    return Intl.message(
      'Repack exception: $error',
      name: 'logRepackException',
      desc: '',
      args: [error],
    );
  }

  /// `Failed to list patch info: {error}`
  String logListPatchInfoFailed(Object error) {
    return Intl.message(
      'Failed to list patch info: $error',
      name: 'logListPatchInfoFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Executing: {cmd}`
  String logExecuteCmd(Object cmd) {
    return Intl.message(
      'Executing: $cmd',
      name: 'logExecuteCmd',
      desc: '',
      args: [cmd],
    );
  }

  /// `Backing up boot partition...`
  String get logBackingUpBoot {
    return Intl.message(
      'Backing up boot partition...',
      name: 'logBackingUpBoot',
      desc: '',
      args: [],
    );
  }

  /// `Boot backup complete: {path}`
  String logBackupComplete(Object path) {
    return Intl.message(
      'Boot backup complete: $path',
      name: 'logBackupComplete',
      desc: '',
      args: [path],
    );
  }

  /// `Boot backup failed`
  String get logBackupFailed {
    return Intl.message(
      'Boot backup failed',
      name: 'logBackupFailed',
      desc: '',
      args: [],
    );
  }

  /// `Device not in fastboot mode`
  String get logDeviceNotFastboot {
    return Intl.message(
      'Device not in fastboot mode',
      name: 'logDeviceNotFastboot',
      desc: '',
      args: [],
    );
  }

  /// `Patching boot image...`
  String get logPatchingBoot {
    return Intl.message(
      'Patching boot image...',
      name: 'logPatchingBoot',
      desc: '',
      args: [],
    );
  }

  /// `Saving patched file...`
  String get logSavingFile {
    return Intl.message(
      'Saving patched file...',
      name: 'logSavingFile',
      desc: '',
      args: [],
    );
  }

  /// `File saved: {path}`
  String logFileSaved(Object path) {
    return Intl.message(
      'File saved: $path',
      name: 'logFileSaved',
      desc: '',
      args: [path],
    );
  }

  /// `No ADB device detected`
  String get logNoAdbDevice {
    return Intl.message(
      'No ADB device detected',
      name: 'logNoAdbDevice',
      desc: '',
      args: [],
    );
  }

  /// `Rebooting to fastboot mode...`
  String get logRebootingToFastboot {
    return Intl.message(
      'Rebooting to fastboot mode...',
      name: 'logRebootingToFastboot',
      desc: '',
      args: [],
    );
  }

  /// `Auto reboot to fastboot failed`
  String get logAutoRebootFailed {
    return Intl.message(
      'Auto reboot to fastboot failed',
      name: 'logAutoRebootFailed',
      desc: '',
      args: [],
    );
  }

  /// `Wait for fastboot timeout`
  String get logWaitFastbootTimeout {
    return Intl.message(
      'Wait for fastboot timeout',
      name: 'logWaitFastbootTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Device is in fastboot mode`
  String get logDeviceInFastboot {
    return Intl.message(
      'Device is in fastboot mode',
      name: 'logDeviceInFastboot',
      desc: '',
      args: [],
    );
  }

  /// `Flashing boot image...`
  String get logFlashingBoot {
    return Intl.message(
      'Flashing boot image...',
      name: 'logFlashingBoot',
      desc: '',
      args: [],
    );
  }

  /// `Flash failed`
  String get logFlashFailed {
    return Intl.message(
      'Flash failed',
      name: 'logFlashFailed',
      desc: '',
      args: [],
    );
  }

  /// `Flash successful`
  String get logFlashSuccess {
    return Intl.message(
      'Flash successful',
      name: 'logFlashSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Rebooting device...`
  String get logRebootingDevice {
    return Intl.message(
      'Rebooting device...',
      name: 'logRebootingDevice',
      desc: '',
      args: [],
    );
  }

  /// `Device rebooted successfully`
  String get logRebootSuccess {
    return Intl.message(
      'Device rebooted successfully',
      name: 'logRebootSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Auto reboot failed`
  String get logAutoRebootFailed2 {
    return Intl.message(
      'Auto reboot failed',
      name: 'logAutoRebootFailed2',
      desc: '',
      args: [],
    );
  }

  /// `One-click flash completed!`
  String get logOneClickComplete {
    return Intl.message(
      'One-click flash completed!',
      name: 'logOneClickComplete',
      desc: '',
      args: [],
    );
  }

  /// `Operation error: {error}`
  String logOperationError(Object error) {
    return Intl.message(
      'Operation error: $error',
      name: 'logOperationError',
      desc: '',
      args: [error],
    );
  }

  /// `Starting patch operation...`
  String get logStartPatching {
    return Intl.message(
      'Starting patch operation...',
      name: 'logStartPatching',
      desc: '',
      args: [],
    );
  }

  /// `Patch complete: {path}`
  String logPatchComplete(Object path) {
    return Intl.message(
      'Patch complete: $path',
      name: 'logPatchComplete',
      desc: '',
      args: [path],
    );
  }

  /// `Patch failed: {error}`
  String logPatchFailed(Object error) {
    return Intl.message(
      'Patch failed: $error',
      name: 'logPatchFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Patch exception: {error}`
  String logPatchException(Object error) {
    return Intl.message(
      'Patch exception: $error',
      name: 'logPatchException',
      desc: '',
      args: [error],
    );
  }

  /// `Cancelling operation...`
  String get logCancelling {
    return Intl.message(
      'Cancelling operation...',
      name: 'logCancelling',
      desc: '',
      args: [],
    );
  }

  /// `Backing up partition...`
  String get logBackingUpPartition {
    return Intl.message(
      'Backing up partition...',
      name: 'logBackingUpPartition',
      desc: '',
      args: [],
    );
  }

  /// `Backup successful: {path}`
  String logBackupSuccess(Object path) {
    return Intl.message(
      'Backup successful: $path',
      name: 'logBackupSuccess',
      desc: '',
      args: [path],
    );
  }

  /// `Backup failed, trying alternative method...`
  String get logBackupFailedTryAlt {
    return Intl.message(
      'Backup failed, trying alternative method...',
      name: 'logBackupFailedTryAlt',
      desc: '',
      args: [],
    );
  }

  /// `Reboot command sent`
  String get logRebootCmdSent {
    return Intl.message(
      'Reboot command sent',
      name: 'logRebootCmdSent',
      desc: '',
      args: [],
    );
  }

  /// `Fastboot device detected: {serial}`
  String logFastbootDetected(Object serial) {
    return Intl.message(
      'Fastboot device detected: $serial',
      name: 'logFastbootDetected',
      desc: '',
      args: [serial],
    );
  }

  /// `Flashing: {path}`
  String logFlashingBootPath(Object path) {
    return Intl.message(
      'Flashing: $path',
      name: 'logFlashingBootPath',
      desc: '',
      args: [path],
    );
  }

  /// `Flash completed successfully`
  String get logFlashBootSuccess {
    return Intl.message(
      'Flash completed successfully',
      name: 'logFlashBootSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for fastboot device ({timeout} seconds)`
  String logWaitFastboot(Object timeout) {
    return Intl.message(
      'Waiting for fastboot device ($timeout seconds)',
      name: 'logWaitFastboot',
      desc: '',
      args: [timeout],
    );
  }

  /// `Device is rebooting...`
  String get logDeviceRebooting {
    return Intl.message(
      'Device is rebooting...',
      name: 'logDeviceRebooting',
      desc: '',
      args: [],
    );
  }

  /// `Checking ADB...`
  String get logCheckAdb {
    return Intl.message(
      'Checking ADB...',
      name: 'logCheckAdb',
      desc: '',
      args: [],
    );
  }

  /// `Checking Fastboot...`
  String get logCheckFastboot {
    return Intl.message(
      'Checking Fastboot...',
      name: 'logCheckFastboot',
      desc: '',
      args: [],
    );
  }

  /// `Driver check passed`
  String get logDriverCheckPassed {
    return Intl.message(
      'Driver check passed',
      name: 'logDriverCheckPassed',
      desc: '',
      args: [],
    );
  }

  /// `Please select boot.img file first`
  String get errSelectBootFirst {
    return Intl.message(
      'Please select boot.img file first',
      name: 'errSelectBootFirst',
      desc: '',
      args: [],
    );
  }

  /// `Input file does not exist: {path}`
  String errInputNotExist(Object path) {
    return Intl.message(
      'Input file does not exist: $path',
      name: 'errInputNotExist',
      desc: '',
      args: [path],
    );
  }

  /// `Kpimg file does not exist: {path}`
  String errKpimgNotExist(Object path) {
    return Intl.message(
      'Kpimg file does not exist: $path',
      name: 'errKpimgNotExist',
      desc: '',
      args: [path],
    );
  }

  /// `Kptools file does not exist: {path}`
  String errKptoolsNotExist(Object path) {
    return Intl.message(
      'Kptools file does not exist: $path',
      name: 'errKptoolsNotExist',
      desc: '',
      args: [path],
    );
  }

  /// `Unpack failed: {error}`
  String errUnpackFailed(Object error) {
    return Intl.message(
      'Unpack failed: $error',
      name: 'errUnpackFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Kernel file not found`
  String get errKernelNotFound {
    return Intl.message(
      'Kernel file not found',
      name: 'errKernelNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Patch failed: {error}`
  String errPatchFailed(Object error) {
    return Intl.message(
      'Patch failed: $error',
      name: 'errPatchFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Output kernel not found`
  String get errOutputKernelNotFound {
    return Intl.message(
      'Output kernel not found',
      name: 'errOutputKernelNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Repack failed`
  String get errRepackFailed {
    return Intl.message(
      'Repack failed',
      name: 'errRepackFailed',
      desc: '',
      args: [],
    );
  }

  /// `Patch exception: {error}`
  String errPatchException(Object error) {
    return Intl.message(
      'Patch exception: $error',
      name: 'errPatchException',
      desc: '',
      args: [error],
    );
  }

  /// `Failed to flash boot partition`
  String get errFlashBootFailed {
    return Intl.message(
      'Failed to flash boot partition',
      name: 'errFlashBootFailed',
      desc: '',
      args: [],
    );
  }

  /// `Flash failed: {error}`
  String errFlashFailed(Object error) {
    return Intl.message(
      'Flash failed: $error',
      name: 'errFlashFailed',
      desc: '',
      args: [error],
    );
  }

  /// `ADB executable does not exist: {path}`
  String errAdbNotExist(Object path) {
    return Intl.message(
      'ADB executable does not exist: $path',
      name: 'errAdbNotExist',
      desc: '',
      args: [path],
    );
  }

  /// `Failed to get ADB devices: {error}`
  String errGetAdbFailed(Object error) {
    return Intl.message(
      'Failed to get ADB devices: $error',
      name: 'errGetAdbFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Fastboot executable does not exist: {path}`
  String errFastbootNotExist(Object path) {
    return Intl.message(
      'Fastboot executable does not exist: $path',
      name: 'errFastbootNotExist',
      desc: '',
      args: [path],
    );
  }

  /// `Failed to get Fastboot devices: {error}`
  String errGetFastbootFailed(Object error) {
    return Intl.message(
      'Failed to get Fastboot devices: $error',
      name: 'errGetFastbootFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Reboot failed: {error}`
  String errRebootFailed(Object error) {
    return Intl.message(
      'Reboot failed: $error',
      name: 'errRebootFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Reboot exception: {error}`
  String errRebootException(Object error) {
    return Intl.message(
      'Reboot exception: $error',
      name: 'errRebootException',
      desc: '',
      args: [error],
    );
  }

  /// `Flash exception: {error}`
  String errFlashException(Object error) {
    return Intl.message(
      'Flash exception: $error',
      name: 'errFlashException',
      desc: '',
      args: [error],
    );
  }

  /// `Backup exception: {error}`
  String errBackupException(Object error) {
    return Intl.message(
      'Backup exception: $error',
      name: 'errBackupException',
      desc: '',
      args: [error],
    );
  }

  /// `ADB is not available`
  String get errAdbNotAvailable {
    return Intl.message(
      'ADB is not available',
      name: 'errAdbNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Fastboot is not available`
  String get errFastbootNotAvailable {
    return Intl.message(
      'Fastboot is not available',
      name: 'errFastbootNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Driver check failed: {error}`
  String errDriverCheckFailed(Object error) {
    return Intl.message(
      'Driver check failed: $error',
      name: 'errDriverCheckFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Select Boot File`
  String get stepSelectBoot {
    return Intl.message(
      'Select Boot File',
      name: 'stepSelectBoot',
      desc: '',
      args: [],
    );
  }

  /// `Backup Boot`
  String get stepBackupBoot {
    return Intl.message(
      'Backup Boot',
      name: 'stepBackupBoot',
      desc: '',
      args: [],
    );
  }

  /// `Patch Image`
  String get stepPatchImage {
    return Intl.message(
      'Patch Image',
      name: 'stepPatchImage',
      desc: '',
      args: [],
    );
  }

  /// `Save File`
  String get stepSaveFile {
    return Intl.message('Save File', name: 'stepSaveFile', desc: '', args: []);
  }

  /// `Reboot to Fastboot`
  String get stepRebootToFastboot {
    return Intl.message(
      'Reboot to Fastboot',
      name: 'stepRebootToFastboot',
      desc: '',
      args: [],
    );
  }

  /// `Flash to Device`
  String get stepFlashDevice {
    return Intl.message(
      'Flash to Device',
      name: 'stepFlashDevice',
      desc: '',
      args: [],
    );
  }

  /// `Reboot Device`
  String get stepRebootComplete {
    return Intl.message(
      'Reboot Device',
      name: 'stepRebootComplete',
      desc: '',
      args: [],
    );
  }

  /// `Client Detection`
  String get clientCheck {
    return Intl.message(
      'Client Detection',
      name: 'clientCheck',
      desc: '',
      args: [],
    );
  }

  /// `Android kernel-level root solution`
  String get apatchDesc {
    return Intl.message(
      'Android kernel-level root solution',
      name: 'apatchDesc',
      desc: '',
      args: [],
    );
  }

  /// `An excellent KernelPatch management client`
  String get folkpatchDesc {
    return Intl.message(
      'An excellent KernelPatch management client',
      name: 'folkpatchDesc',
      desc: '',
      args: [],
    );
  }

  /// `Installed`
  String get installed {
    return Intl.message('Installed', name: 'installed', desc: '', args: []);
  }

  /// `Install`
  String get install {
    return Intl.message('Install', name: 'install', desc: '', args: []);
  }

  /// `Installing...`
  String get installing {
    return Intl.message(
      'Installing...',
      name: 'installing',
      desc: '',
      args: [],
    );
  }

  /// `{name} installed successfully`
  String installSuccess(Object name) {
    return Intl.message(
      '$name installed successfully',
      name: 'installSuccess',
      desc: '',
      args: [name],
    );
  }

  /// `{name} installation failed`
  String installFailed(Object name) {
    return Intl.message(
      '$name installation failed',
      name: 'installFailed',
      desc: '',
      args: [name],
    );
  }

  /// `Simple Patch`
  String get simplePatch {
    return Intl.message(
      'Simple Patch',
      name: 'simplePatch',
      desc: '',
      args: [],
    );
  }

  /// `Patch boot.img only, save file manually`
  String get simplePatchSubtitle {
    return Intl.message(
      'Patch boot.img only, save file manually',
      name: 'simplePatchSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Save to File`
  String get saveToFile {
    return Intl.message('Save to File', name: 'saveToFile', desc: '', args: []);
  }

  /// `Save As`
  String get saveAs {
    return Intl.message('Save As', name: 'saveAs', desc: '', args: []);
  }

  /// `Select save location`
  String get selectSaveLocation {
    return Intl.message(
      'Select save location',
      name: 'selectSaveLocation',
      desc: '',
      args: [],
    );
  }

  /// `File saved successfully`
  String get fileSavedSuccessfully {
    return Intl.message(
      'File saved successfully',
      name: 'fileSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Patch complete!`
  String get patchOnlyComplete {
    return Intl.message(
      'Patch complete!',
      name: 'patchOnlyComplete',
      desc: '',
      args: [],
    );
  }

  /// `Save Patched File`
  String get savePatchedFile {
    return Intl.message(
      'Save Patched File',
      name: 'savePatchedFile',
      desc: '',
      args: [],
    );
  }

  /// `Driver Install`
  String get driverInstall {
    return Intl.message(
      'Driver Install',
      name: 'driverInstall',
      desc: '',
      args: [],
    );
  }

  /// `Install the driver to resolve missing driver issues`
  String get driverInstallSubtitle {
    return Intl.message(
      'Install the driver to resolve missing driver issues',
      name: 'driverInstallSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Driver Installation`
  String get driverInstallPage {
    return Intl.message(
      'Driver Installation',
      name: 'driverInstallPage',
      desc: '',
      args: [],
    );
  }

  /// `Qualcomm Fastboot Driver (64-bit)`
  String get qualcommDriver64 {
    return Intl.message(
      'Qualcomm Fastboot Driver (64-bit)',
      name: 'qualcommDriver64',
      desc: '',
      args: [],
    );
  }

  /// `Qualcomm device driver for 64-bit Windows systems`
  String get qualcommDriver64Desc {
    return Intl.message(
      'Qualcomm device driver for 64-bit Windows systems',
      name: 'qualcommDriver64Desc',
      desc: '',
      args: [],
    );
  }

  /// `Qualcomm Fastboot Driver (32-bit)`
  String get qualcommDriver32 {
    return Intl.message(
      'Qualcomm Fastboot Driver (32-bit)',
      name: 'qualcommDriver32',
      desc: '',
      args: [],
    );
  }

  /// `Qualcomm device driver for 32-bit Windows systems`
  String get qualcommDriver32Desc {
    return Intl.message(
      'Qualcomm device driver for 32-bit Windows systems',
      name: 'qualcommDriver32Desc',
      desc: '',
      args: [],
    );
  }

  /// `MediaTek USB Driver`
  String get mediatekDriver {
    return Intl.message(
      'MediaTek USB Driver',
      name: 'mediatekDriver',
      desc: '',
      args: [],
    );
  }

  /// `USB driver for MediaTek chipset devices`
  String get mediatekDriverDesc {
    return Intl.message(
      'USB driver for MediaTek chipset devices',
      name: 'mediatekDriverDesc',
      desc: '',
      args: [],
    );
  }

  /// `OnePlus Official ADB Driver`
  String get oneplusAdbDriver {
    return Intl.message(
      'OnePlus Official ADB Driver',
      name: 'oneplusAdbDriver',
      desc: '',
      args: [],
    );
  }

  /// `Official OnePlus ADB driver for Windows 7 systems`
  String get oneplusAdbDriverDesc {
    return Intl.message(
      'Official OnePlus ADB driver for Windows 7 systems',
      name: 'oneplusAdbDriverDesc',
      desc: '',
      args: [],
    );
  }

  /// `OPPO Official ADB Driver`
  String get oppoAdbDriver {
    return Intl.message(
      'OPPO Official ADB Driver',
      name: 'oppoAdbDriver',
      desc: '',
      args: [],
    );
  }

  /// `Official OPPO USB driver for Windows 10 and above`
  String get oppoAdbDriverDesc {
    return Intl.message(
      'Official OPPO USB driver for Windows 10 and above',
      name: 'oppoAdbDriverDesc',
      desc: '',
      args: [],
    );
  }

  /// `Install Driver`
  String get installDriver {
    return Intl.message(
      'Install Driver',
      name: 'installDriver',
      desc: '',
      args: [],
    );
  }

  /// `Driver installer launched`
  String get installDriverSuccess {
    return Intl.message(
      'Driver installer launched',
      name: 'installDriverSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to launch installer: {error}`
  String installDriverFailed(Object error) {
    return Intl.message(
      'Failed to launch installer: $error',
      name: 'installDriverFailed',
      desc: '',
      args: [error],
    );
  }

  /// `KernelPatch Version`
  String get kernelPatchVersion {
    return Intl.message(
      'KernelPatch Version',
      name: 'kernelPatchVersion',
      desc: '',
      args: [],
    );
  }

  /// `Select Version`
  String get selectVersion {
    return Intl.message(
      'Select Version',
      name: 'selectVersion',
      desc: '',
      args: [],
    );
  }

  /// `Select the KernelPatch version to use`
  String get selectVersionDesc {
    return Intl.message(
      'Select the KernelPatch version to use',
      name: 'selectVersionDesc',
      desc: '',
      args: [],
    );
  }

  /// `Custom Version`
  String get customVersion {
    return Intl.message(
      'Custom Version',
      name: 'customVersion',
      desc: '',
      args: [],
    );
  }

  /// `Select custom kpimg file`
  String get selectCustomVersion {
    return Intl.message(
      'Select custom kpimg file',
      name: 'selectCustomVersion',
      desc: '',
      args: [],
    );
  }

  /// `Current Version`
  String get currentVersion {
    return Intl.message(
      'Current Version',
      name: 'currentVersion',
      desc: '',
      args: [],
    );
  }

  /// `No version selected`
  String get noVersionSelected {
    return Intl.message(
      'No version selected',
      name: 'noVersionSelected',
      desc: '',
      args: [],
    );
  }

  /// `Recommended`
  String get versionRecommended {
    return Intl.message(
      'Recommended',
      name: 'versionRecommended',
      desc: '',
      args: [],
    );
  }

  /// `Built-in Unpack`
  String get versionSupportUnpack {
    return Intl.message(
      'Built-in Unpack',
      name: 'versionSupportUnpack',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get versionCustom {
    return Intl.message('Custom', name: 'versionCustom', desc: '', args: []);
  }

  /// `Invalid version file`
  String get invalidVersionFile {
    return Intl.message(
      'Invalid version file',
      name: 'invalidVersionFile',
      desc: '',
      args: [],
    );
  }

  /// `Custom version saved`
  String get customVersionSaved {
    return Intl.message(
      'Custom version saved',
      name: 'customVersionSaved',
      desc: '',
      args: [],
    );
  }

  /// `Loading versions...`
  String get loadingVersions {
    return Intl.message(
      'Loading versions...',
      name: 'loadingVersions',
      desc: '',
      args: [],
    );
  }

  /// `No versions available`
  String get noVersionsAvailable {
    return Intl.message(
      'No versions available',
      name: 'noVersionsAvailable',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
