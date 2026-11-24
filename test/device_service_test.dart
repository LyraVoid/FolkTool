import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:FolkTool/models/device_info.dart';
import 'package:FolkTool/services/device_service.dart';
import 'package:FolkTool/services/process_runner.dart';

class _FakeProcessRunner implements ProcessRunner {
  final Future<ProcessResult> Function(String executable, List<String> args)
      handler;

  _FakeProcessRunner(this.handler);

  @override
  Future<ProcessResult> run(String executable, List<String> arguments) {
    return handler(executable, arguments);
  }
}

void main() {
  group('DeviceService with mocked ProcessRunner', () {
    test('getAdbDevices parses connected devices', () async {
      final runner = _FakeProcessRunner((exe, args) async {
        expect(args, ['devices']);
        return ProcessResult(
          1,
          0,
          'List of devices attached\nABC12345\tdevice\nDEF67890\tunauthorized\n',
          '',
        );
      });

      final service = DeviceService(
        processRunner: runner,
        skipBinaryExistsCheck: true,
      );
      final devices = await service.getAdbDevices();

      expect(devices, hasLength(2));
      expect(devices[0].serial, 'ABC12345');
      expect(devices[0].state, DeviceState.adb);
      expect(devices[1].serial, 'DEF67890');
      expect(devices[1].state, DeviceState.unauthorized);
    });

    test('getFastbootDevices parses fastboot devices', () async {
      final runner = _FakeProcessRunner((exe, args) async {
        expect(args, ['devices']);
        return ProcessResult(1, 0, 'FASTBOOT123\tfastboot\n', '');
      });

      final service = DeviceService(
        processRunner: runner,
        skipBinaryExistsCheck: true,
      );
      final devices = await service.getFastbootDevices();

      expect(devices, hasLength(1));
      expect(devices.first.serial, 'FASTBOOT123');
      expect(devices.first.state, DeviceState.fastboot);
    });

    test('getBatteryLevel parses dumpsys battery output', () async {
      final runner = _FakeProcessRunner((exe, args) async {
        expect(args, ['shell', 'dumpsys', 'battery']);
        return ProcessResult(
          1,
          0,
          'Current Battery Service state:\n  AC powered: false\n  USB powered: true\n  level: 78\n  scale: 100\n',
          '',
        );
      });

      final service = DeviceService(
        processRunner: runner,
        skipBinaryExistsCheck: true,
      );
      final level = await service.getBatteryLevel();
      expect(level, 78);
    });

    test('checkAppInstalled detects exact package match', () async {
      final runner = _FakeProcessRunner((exe, args) async {
        return ProcessResult(
          1,
          0,
          'package:com.android.settings\npackage:me.bmax.apatch\n',
          '',
        );
      });

      final service = DeviceService(
        processRunner: runner,
        skipBinaryExistsCheck: true,
      );
      expect(await service.checkAPatchInstalled(), isTrue);
      expect(await service.checkFolkPatchInstalled(), isFalse);
    });
  });
}
