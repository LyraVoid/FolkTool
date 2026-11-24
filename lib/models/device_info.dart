enum DeviceState {
  disconnected,
  adb,
  fastboot,
  unknown,
}

class DeviceInfo {
  final String serial;
  final DeviceState state;
  final String? model;
  final String? androidVersion;
  final String? kernelVersion;

  DeviceInfo({
    required this.serial,
    required this.state,
    this.model,
    this.androidVersion,
    this.kernelVersion,
  });

  String get stateText {
    switch (state) {
      case DeviceState.disconnected:
        return 'Disconnected';
      case DeviceState.adb:
        return 'ADB';
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
      final stateText = parts[1];
      DeviceState state = DeviceState.unknown;
      if (stateText == 'device') {
        state = DeviceState.adb;
      } else if (stateText == 'offline') {
        state = DeviceState.disconnected;
      }
      return DeviceInfo(serial: serial, state: state);
    }
    return DeviceInfo(serial: '', state: DeviceState.unknown);
  }

  factory DeviceInfo.fromFastbootLine(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    if (parts.isNotEmpty) {
      final serial = parts[0];
      return DeviceInfo(serial: serial, state: DeviceState.fastboot);
    }
    return DeviceInfo(serial: '', state: DeviceState.unknown);
  }
}