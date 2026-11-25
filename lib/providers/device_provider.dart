import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../models/models.dart';
import '../services/services.dart';

enum DeviceConnectionState {
  disconnected,
  adbConnected,
  adbUnauthorized,
  adbOffline,
  multipleDevices,
  fastbootConnected,
  checking,
}

/// 客户端类型
enum ClientType {
  apatch,
  folkpatch,
}

/// 客户端安装状态
class ClientInstallStatus {
  final ClientType type;
  final bool installed;
  final bool installing;

  ClientInstallStatus({
    required this.type,
    required this.installed,
    this.installing = false,
  });

  ClientInstallStatus copyWith({
    ClientType? type,
    bool? installed,
    bool? installing,
  }) {
    return ClientInstallStatus(
      type: type ?? this.type,
      installed: installed ?? this.installed,
      installing: installing ?? this.installing,
    );
  }
}

class DeviceProvider extends ChangeNotifier {
  final DeviceService _deviceService = DeviceService();
  
  DeviceConnectionState _connectionState = DeviceConnectionState.disconnected;
  List<DeviceInfo> _adbDevices = [];
  List<DeviceInfo> _fastbootDevices = [];
  String? _selectedSerial;
  bool _isChecking = false;
  bool _isManualChecking = false;
  bool _isOperationLocked = false;
  Timer? _monitorTimer;
  String? _errorMessage;
  bool _driverInstalled = false;
  
  // 客户端安装状态
  ClientInstallStatus _apatchStatus = ClientInstallStatus(type: ClientType.apatch, installed: false);
  ClientInstallStatus _folkpatchStatus = ClientInstallStatus(type: ClientType.folkpatch, installed: false);
  bool _isCheckingClients = false;
  bool _isManualCheckingClients = false;
  
  DeviceConnectionState get connectionState => _connectionState;
  List<DeviceInfo> get adbDevices => _adbDevices;
  List<DeviceInfo> get fastbootDevices => _fastbootDevices;
  List<DeviceInfo> get authorizedAdbDevices =>
      _adbDevices.where((d) => d.isAuthorizedAdb).toList();
  List<DeviceInfo> get unauthorizedAdbDevices =>
      _adbDevices.where((d) => d.state == DeviceState.unauthorized).toList();
  List<DeviceInfo> get offlineAdbDevices =>
      _adbDevices.where((d) => d.state == DeviceState.offline).toList();
  String? get selectedSerial => _selectedSerial;
  bool get isChecking => _isChecking;
  bool get isManualChecking => _isManualChecking;
  bool get isOperationLocked => _isOperationLocked;
  String? get errorMessage => _errorMessage;
  bool get driverInstalled => _driverInstalled;
  bool get hasAdbDevice => authorizedAdbDevices.isNotEmpty;
  bool get hasFastbootDevice => _fastbootDevices.isNotEmpty;
  bool get hasMultipleDevices {
    if (_selectedSerial != null) {
      final matchesSelected = _fastbootDevices.any((d) => d.serial == _selectedSerial) ||
          authorizedAdbDevices.any((d) => d.serial == _selectedSerial);
      if (matchesSelected) return false;
    }
    return _fastbootDevices.length > 1 ||
        authorizedAdbDevices.length > 1 ||
        (_adbDevices.length > 1 && _selectedSerial == null);
  }

  DeviceInfo? get selectedTargetDevice {
    if (_selectedSerial != null) {
      for (final d in _fastbootDevices) {
        if (d.serial == _selectedSerial) return d;
      }
      for (final d in authorizedAdbDevices) {
        if (d.serial == _selectedSerial) return d;
      }
    }
    if (_fastbootDevices.length == 1) return _fastbootDevices.first;
    if (authorizedAdbDevices.length == 1) return authorizedAdbDevices.first;
    return null;
  }

  DeviceInfo? get currentDevice =>
      selectedTargetDevice ??
      (_fastbootDevices.isNotEmpty
          ? _fastbootDevices.first
          : (_adbDevices.isNotEmpty ? _adbDevices.first : null));

  void selectDevice(String? serial) {
    _selectedSerial = serial;
    _updateConnectionState();
    notifyListeners();
  }

  void setOperationLocked(bool locked) {
    _isOperationLocked = locked;
    notifyListeners();
  }
  
  // 客户端状态 Getters
  ClientInstallStatus get apatchStatus => _apatchStatus;
  ClientInstallStatus get folkpatchStatus => _folkpatchStatus;
  bool get isCheckingClients => _isCheckingClients;
  bool get isManualCheckingClients => _isManualCheckingClients;
  bool get hasAnyClientInstalled => _apatchStatus.installed || _folkpatchStatus.installed;

  Future<void> checkDriver() async {
    debugPrint('[DriverCheck] ADB Path: ${Constants.adbPath}');
    debugPrint('[DriverCheck] Fastboot Path: ${Constants.fastbootPath}');
    _driverInstalled = await _deviceService.checkDriverInstalled(
      onLog: (line) => debugPrint('[DriverCheck] $line'),
    );
    notifyListeners();
  }

  void _updateConnectionState() {
    if (hasMultipleDevices) {
      _connectionState = DeviceConnectionState.multipleDevices;
    } else if (_fastbootDevices.isNotEmpty) {
      _connectionState = DeviceConnectionState.fastbootConnected;
    } else if (authorizedAdbDevices.isNotEmpty) {
      _connectionState = DeviceConnectionState.adbConnected;
    } else if (unauthorizedAdbDevices.isNotEmpty) {
      _connectionState = DeviceConnectionState.adbUnauthorized;
    } else if (offlineAdbDevices.isNotEmpty) {
      _connectionState = DeviceConnectionState.adbOffline;
    } else {
      _connectionState = DeviceConnectionState.disconnected;
    }
  }

  Future<void> _pollDevices() async {
    _adbDevices = await _deviceService.getAdbDevices(
      onLog: (line) => debugPrint('[ADB] $line'),
    );

    _fastbootDevices = await _deviceService.getFastbootDevices(
      onLog: (line) => debugPrint('[Fastboot] $line'),
    );

    // Clear stale manual selection if that device disconnected.
    if (_selectedSerial != null) {
      final stillPresent = _adbDevices.any((d) => d.serial == _selectedSerial) ||
          _fastbootDevices.any((d) => d.serial == _selectedSerial);
      if (!stillPresent) {
        _selectedSerial = null;
      }
    }

    // Enrich the targeted device with OS/battery or bootloader lock state.
    final target = selectedTargetDevice;
    if (target != null && target.isAuthorizedAdb) {
      final enriched = await _deviceService.queryAdbDeviceDetails(target);
      final idx = _adbDevices.indexWhere((d) => d.serial == target.serial);
      if (idx != -1) {
        _adbDevices[idx] = enriched;
      }
    } else if (target != null && target.isFastboot) {
      final unlocked = await _deviceService.queryBootloaderUnlocked(
        serial: target.serial,
      );
      if (unlocked != null) {
        final idx = _fastbootDevices.indexWhere((d) => d.serial == target.serial);
        if (idx != -1) {
          _fastbootDevices[idx] = _fastbootDevices[idx].copyWith(
            bootloaderUnlocked: unlocked,
          );
        }
      }
    }

    _updateConnectionState();

    if (hasAdbDevice) {
      await checkInstalledClients();
    }
  }

  Future<void> refreshDevices() async {
    if (_isChecking || _isOperationLocked) return;

    _isChecking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _pollDevices();
    } catch (e) {
      _errorMessage = e.toString();
      _connectionState = DeviceConnectionState.disconnected;
    }

    _isChecking = false;
    notifyListeners();
  }

  /// 手动刷新设备状态（显示加载指示器）
  Future<void> manualRefreshDevices() async {
    if (_isChecking || _isManualChecking || _isOperationLocked) return;

    _isChecking = true;
    _isManualChecking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _pollDevices();
    } catch (e) {
      _errorMessage = e.toString();
      _connectionState = DeviceConnectionState.disconnected;
    }

    _isChecking = false;
    _isManualChecking = false;
    notifyListeners();
  }

  void startMonitoring({Duration interval = const Duration(seconds: 3)}) {
    stopMonitoring();
    refreshDevices();
    _monitorTimer = Timer.periodic(interval, (_) => refreshDevices());
  }

  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  Future<bool> rebootToFastboot() async {
    if (!hasAdbDevice) return false;
    final serial = selectedTargetDevice?.serial;

    final success = await _deviceService.rebootToFastboot(
      serial: serial,
      onLog: (line) => debugPrint('[Reboot] $line'),
    );

    if (success) {
      await Future.delayed(const Duration(seconds: 2));
      await waitForFastboot();
    }

    return success;
  }

  Future<bool> waitForFastboot({Duration timeout = const Duration(seconds: 60)}) async {
    final device = await _deviceService.waitForFastbootDevice(
      timeout: timeout,
      onLog: (line) => debugPrint('[WaitFastboot] $line'),
    );

    if (device != null) {
      _fastbootDevices = [device];
      _selectedSerial = device.serial;
      _connectionState = DeviceConnectionState.fastbootConnected;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> flashBoot(String imagePath, {void Function(String)? onLog}) async {
    if (!hasFastbootDevice) return false;

    return await _deviceService.flashBoot(
      imagePath,
      serial: selectedTargetDevice?.serial,
      onLog: onLog ?? (line) => debugPrint('[Flash] $line'),
    );
  }

  Future<bool> backupBoot(String outputPath, {void Function(String)? onLog}) async {
    if (!hasFastbootDevice) return false;

    return await _deviceService.backupBoot(
      outputPath,
      serial: selectedTargetDevice?.serial,
      onLog: onLog ?? (line) => debugPrint('[Backup] $line'),
    );
  }

  Future<bool> rebootDevice({void Function(String)? onLog}) async {
    if (!hasFastbootDevice) return false;

    return await _deviceService.rebootDevice(
      serial: selectedTargetDevice?.serial,
      onLog: onLog ?? (line) => debugPrint('[Reboot] $line'),
    );
  }

  /// 检测已安装的客户端（后台自动检测）
  Future<void> checkInstalledClients() async {
    if (!hasAdbDevice || _isCheckingClients) return;
    
    _isCheckingClients = true;
    notifyListeners();
    
    try {
      final apatchInstalled = await _deviceService.checkAPatchInstalled(
        onLog: (line) => debugPrint('[ClientCheck] $line'),
      );
      final folkpatchInstalled = await _deviceService.checkFolkPatchInstalled(
        onLog: (line) => debugPrint('[ClientCheck] $line'),
      );
      
      _apatchStatus = ClientInstallStatus(type: ClientType.apatch, installed: apatchInstalled);
      _folkpatchStatus = ClientInstallStatus(type: ClientType.folkpatch, installed: folkpatchInstalled);
      
      debugPrint('[ClientCheck] APatch: $apatchInstalled, FolkPatch: $folkpatchInstalled');
    } catch (e) {
      debugPrint('[ClientCheck] Error: $e');
    }
    
    _isCheckingClients = false;
    notifyListeners();
  }

  /// 手动刷新客户端状态（显示加载指示器）
  Future<void> manualRefreshClients() async {
    if (!hasAdbDevice || _isCheckingClients || _isManualCheckingClients) return;
    
    _isCheckingClients = true;
    _isManualCheckingClients = true;
    notifyListeners();
    
    try {
      final apatchInstalled = await _deviceService.checkAPatchInstalled(
        onLog: (line) => debugPrint('[ClientCheck] $line'),
      );
      final folkpatchInstalled = await _deviceService.checkFolkPatchInstalled(
        onLog: (line) => debugPrint('[ClientCheck] $line'),
      );
      
      _apatchStatus = ClientInstallStatus(type: ClientType.apatch, installed: apatchInstalled);
      _folkpatchStatus = ClientInstallStatus(type: ClientType.folkpatch, installed: folkpatchInstalled);
      
      debugPrint('[ClientCheck] APatch: $apatchInstalled, FolkPatch: $folkpatchInstalled');
    } catch (e) {
      debugPrint('[ClientCheck] Error: $e');
    }
    
    _isCheckingClients = false;
    _isManualCheckingClients = false;
    notifyListeners();
  }

  /// 安装客户端
  Future<bool> installClient(ClientType type, {void Function(String)? onLog}) async {
    if (!hasAdbDevice) {
      onLog?.call('未检测到 ADB 设备');
      return false;
    }
    
    // 设置安装中状态
    if (type == ClientType.apatch) {
      _apatchStatus = _apatchStatus.copyWith(installing: true);
    } else {
      _folkpatchStatus = _folkpatchStatus.copyWith(installing: true);
    }
    notifyListeners();
    
    final serial = selectedTargetDevice?.serial;
    bool success;
    if (type == ClientType.apatch) {
      success = await _deviceService.installAPatch(serial: serial, onLog: onLog);
      _apatchStatus = ClientInstallStatus(
        type: ClientType.apatch,
        installed: success,
        installing: false,
      );
    } else {
      success = await _deviceService.installFolkPatch(serial: serial, onLog: onLog);
      _folkpatchStatus = ClientInstallStatus(
        type: ClientType.folkpatch,
        installed: success,
        installing: false,
      );
    }
    
    notifyListeners();
    return success;
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}