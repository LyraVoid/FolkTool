import 'dart:io';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:FolkTool/core/config/app_config.dart';
import 'package:FolkTool/core/process/process_runner.dart';
import 'package:FolkTool/features/device/models/device_info.dart';
import 'package:FolkTool/features/device/providers/device_provider.dart';
import 'package:FolkTool/features/device/services/device_service.dart';
import 'package:FolkTool/generated/l10n.dart';

class _FakeProcessRunner implements ProcessRunner {
  final Future<ProcessResult> Function(String executable, List<String> args)
      handler;

  _FakeProcessRunner(this.handler);

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Duration? timeout,
  }) {
    return handler(executable, arguments);
  }
}

void main() {
  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  group('DefaultProcessRunner', () {
    test('executes direct executable without shell and returns stdout', () async {
      const runner = DefaultProcessRunner(timeout: Duration(seconds: 5));
      final exe = Platform.isWindows ? 'cmd.exe' : 'sh';
      final args = Platform.isWindows ? ['/c', 'echo folktool'] : ['-c', 'echo folktool'];
      final res = await runner.run(exe, args);
      expect(res.exitCode, 0);
      expect(res.stdout.toString().trim(), contains('folktool'));
    });

    test('throws ProcessException for missing executable', () async {
      const runner = DefaultProcessRunner(timeout: Duration(seconds: 2));
      await expectLater(
        runner.run('/nonexistent/folktool_missing_bin', const []),
        throwsA(isA<ProcessException>()),
      );
    });
  });

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

    test('getAdbDevices ignores output when adb command fails', () async {
      final service = DeviceService(
        processRunner: _FakeProcessRunner(
          (_, __) async => ProcessResult(
            1,
            1,
            'List of devices attached\nABC123\tdevice\n',
            'server failed',
          ),
        ),
        skipBinaryExistsCheck: true,
      );
      expect(await service.getAdbDevices(), isEmpty);
    });

    test('unauthorized ADB device is not marked ready', () {
      final device = DeviceInfo.fromAdbLine('ABC123 unauthorized');
      expect(device.state, DeviceState.unauthorized);
      expect(device.isReadyForOperation, isFalse);
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

    test('flashBoot refuses missing image before invoking fastboot', () async {
      var invoked = false;
      final service = DeviceService(
        processRunner: _FakeProcessRunner((_, __) async {
          invoked = true;
          return ProcessResult(1, 0, 'SERIAL fastboot\n', '');
        }),
        skipBinaryExistsCheck: true,
      );
      expect(await service.flashBoot('/missing/boot.img'), isFalse);
      expect(invoked, isFalse);
    });

    test('flashBoot rejects multiple targets before writing', () async {
      var flashInvoked = false;
      final service = DeviceService(
        processRunner: _FakeProcessRunner((_, args) async {
          if (args.first == 'devices') {
            return ProcessResult(1, 0, 'A fastboot\nB fastboot\n', '');
          }
          flashInvoked = true;
          return ProcessResult(1, 0, '', '');
        }),
        skipBinaryExistsCheck: true,
      );
      final dir = await Directory.systemTemp.createTemp('folktool_flash_');
      final image = File('${dir.path}/boot.img')..writeAsBytesSync([1, 2, 3]);
      try {
        expect(await service.flashBoot(image.path), isFalse);
        expect(flashInvoked, isFalse);
      } finally {
        await dir.delete(recursive: true);
      }
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

    test('checkInstalledPackages evaluates multiple packages in one pm call',
        () async {
      var pmCalls = 0;
      final runner = _FakeProcessRunner((exe, args) async {
        pmCalls++;
        return ProcessResult(
          1,
          0,
          'package:com.android.settings\npackage:${AppConfig.apatchPackageName}\n',
          '',
        );
      });

      final service = DeviceService(
        processRunner: runner,
        skipBinaryExistsCheck: true,
      );
      final found = await service.checkInstalledPackages(
        const {AppConfig.apatchPackageName, AppConfig.folkpatchPackageName},
      );
      expect(pmCalls, 1);
      expect(found, {AppConfig.apatchPackageName});
    });

    test('DeviceProvider caches static properties and skips redundant notifies',
        () async {
      var propCalls = 0;
      var pmCalls = 0;
      final runner = _FakeProcessRunner((exe, args) async {
        if (exe.endsWith('adb.exe')) {
          if (args.length == 1 && args[0] == 'devices') {
            return ProcessResult(1, 0, 'SER1\tdevice\n', '');
          }
          if (args.contains('getprop') || args.contains('uname')) {
            propCalls++;
            if (args.contains('ro.product.model')) {
              return ProcessResult(1, 0, 'Pixel 9\n', '');
            }
            if (args.contains('ro.build.version.release')) {
              return ProcessResult(1, 0, '15\n', '');
            }
            return ProcessResult(1, 0, '6.1.75\n', '');
          }
          if (args.contains('battery')) {
            return ProcessResult(1, 0, '  level: 85\n', '');
          }
          if (args.contains('pm')) {
            pmCalls++;
            return ProcessResult(1, 0, 'package:${AppConfig.folkpatchPackageName}\n', '');
          }
        }
        return ProcessResult(1, 0, '', '');
      });

      final provider = DeviceProvider(
        deviceService: DeviceService(
          processRunner: runner,
          skipBinaryExistsCheck: true,
        ),
      );

      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.refreshDevices();
      expect(provider.currentDevice?.model, 'Pixel 9');
      expect(provider.currentDevice?.batteryLevel, 85);
      expect(propCalls, 3);
      expect(pmCalls, 1);
      final afterFirstPollNotifications = notifications;

      // Second identical poll should reuse cached static props, skip pm list, and emit 0 notifications.
      await provider.refreshDevices();
      expect(propCalls, 3);
      expect(pmCalls, 1);
      expect(notifications, afterFirstPollNotifications);
    });
  });
}
