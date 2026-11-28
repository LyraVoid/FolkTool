enum DeviceState {
  disconnected,
  adb,
  unauthorized,
  offline,
  recovery,
  sideload,
  fastboot,
  unknown,
}

class DeviceInfo {
  final String serial;
  final DeviceState state;
  final String? model;
  final String? androidVersion;
  final String? kernelVersion;
  final int? batteryLevel;
  final bool? bootloaderUnlocked;

  DeviceInfo({
    required this.serial,
    required this.state,
    this.model,
    this.androidVersion,
    this.kernelVersion,
    this.batteryLevel,
    this.bootloaderUnlocked,
  });

  bool get isAuthorizedAdb => state == DeviceState.adb;
  bool get isFastboot => state == DeviceState.fastboot;
  bool get isReadyForOperation => isAuthorizedAdb || isFastboot;

  DeviceInfo copyWith({
    String? serial,
    DeviceState? state,
    String? model,
    String? androidVersion,
    String? kernelVersion,
    int? batteryLevel,
    bool? bootloaderUnlocked,
  }) {
    return DeviceInfo(
      serial: serial ?? this.serial,
      state: state ?? this.state,
      model: model ?? this.model,
      androidVersion: androidVersion ?? this.androidVersion,
      kernelVersion: kernelVersion ?? this.kernelVersion,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      bootloaderUnlocked: bootloaderUnlocked ?? this.bootloaderUnlocked,
    );
  }

  String get stateText {
    switch (state) {
      case DeviceState.disconnected:
        return 'Disconnected';
      case DeviceState.adb:
        return 'ADB';
      case DeviceState.unauthorized:
        return 'Unauthorized';
      case DeviceState.offline:
        return 'Offline';
      case DeviceState.recovery:
        return 'Recovery';
      case DeviceState.sideload:
        return 'Sideload';
      case DeviceState.fastboot:
        return 'Fastboot';
      case DeviceState.unknown:
        return 'Unknown';
    }
  }

  factory DeviceInfo.fromAdbLine(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final serial = parts[0];
      final stateStr = parts[1].toLowerCase();
      DeviceState state = DeviceState.unknown;
      switch (stateStr) {
        case 'device':
          state = DeviceState.adb;
          break;
        case 'unauthorized':
          state = DeviceState.unauthorized;
          break;
        case 'offline':
          state = DeviceState.offline;
          break;
        case 'recovery':
          state = DeviceState.recovery;
          break;
        case 'sideload':
          state = DeviceState.sideload;
          break;
      }
      // Extract optional model:... token from `adb devices -l` output
      String? model;
      for (final token in parts.skip(2)) {
        if (token.startsWith('model:')) {
          model = token.substring(6).replaceAll('_', ' ');
          break;
        }
      }
      return DeviceInfo(serial: serial, state: state, model: model);
    }
    return DeviceInfo(serial: '', state: DeviceState.unknown);
  }

  factory DeviceInfo.fromFastbootLine(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      final serial = parts[0];
      return DeviceInfo(serial: serial, state: DeviceState.fastboot);
    }
    return DeviceInfo(serial: '', state: DeviceState.unknown);
  }
}