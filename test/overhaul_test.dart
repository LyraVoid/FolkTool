import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FolkTool/config/app_theme.dart';
import 'package:FolkTool/config/constants.dart';
import 'package:FolkTool/generated/l10n.dart';
import 'package:FolkTool/models/models.dart';
import 'package:FolkTool/providers/providers.dart';
import 'package:FolkTool/services/services.dart';
import 'package:FolkTool/widgets/widgets.dart';

Widget _wrapWidget(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    theme: AppTheme.light(),
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('zh'), Locale('en')],
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceInfo & ADB/Fastboot error classification', () {
    test('parses unauthorized, offline, and model from adb devices line', () {
      final unauth = DeviceInfo.fromAdbLine('ABC123\tunauthorized');
      expect(unauth.state, DeviceState.unauthorized);
      expect(unauth.isAuthorizedAdb, isFalse);

      final offline = DeviceInfo.fromAdbLine('XYZ999\toffline');
      expect(offline.state, DeviceState.offline);
      expect(offline.isReadyForOperation, isFalse);

      final ready = DeviceInfo.fromAdbLine(
        'DEV001\tdevice product:husky model:Pixel_8_Pro device:husky',
      );
      expect(ready.isAuthorizedAdb, isTrue);
      expect(ready.model, 'Pixel 8 Pro');
    });

    test('classifies unauthorized ADB and locked fastboot errors', () {
      final adbErr = DeviceService.classifyAdbError('error: device unauthorized');
      expect(adbErr.category, AppErrorCategory.adb);
      expect(adbErr.canSafelyRetry, isTrue);

      final fbErr = DeviceService.classifyFastbootError(
        'FAILED (remote: Flashing is not allowed in Lock State)',
        duringFlash: true,
      );
      expect(fbErr.category, AppErrorCategory.fastboot);
      expect(fbErr.canSafelyRetry, isFalse);
    });
  });

  group('SafetyService image magic & device preflight checks', () {
    test('detects ANDROID! boot header and blocks unauthorized/multi-device',
        () async {
      final tempDir = await Directory.systemTemp.createTemp('folktool_magic_');
      addTearDown(() => tempDir.delete(recursive: true));

      final badBoot = File('${tempDir.path}/bad.img');
      await badBoot.writeAsBytes([0, 1, 2, 3, 4, 5, 6, 7]);
      expect(await SafetyService.hasAndroidBootMagic(badBoot.path), isFalse);

      final goodBoot = File('${tempDir.path}/boot.img');
      await goodBoot.writeAsBytes('ANDROID!'.codeUnits + List.filled(64, 0));
      expect(await SafetyService.hasAndroidBootMagic(goodBoot.path), isTrue);

      final safety = SafetyService();
      final multiResult = await safety.runPreflightChecks(
        bootImagePath: goodBoot.path,
        checkBinaries: false,
        checkImageMagic: true,
        requireConnectedDevice: true,
        connectedDeviceCount: 2,
      );
      expect(multiResult.passed, isFalse);
      expect(multiResult.primaryError?.category, AppErrorCategory.deviceConnection);

      final unauthResult = await safety.runPreflightChecks(
        bootImagePath: goodBoot.path,
        deviceInfo: DeviceInfo(serial: 'S1', state: DeviceState.unauthorized),
        checkBinaries: false,
        checkImageMagic: true,
        requireConnectedDevice: true,
        connectedDeviceCount: 1,
      );
      expect(unauthResult.passed, isFalse);
    });
  });

  group('FileService redaction & recent files', () {
    test('redacts Windows username and device serial', () {
      final input =
          r'Path: C:\Users\Alice\Desktop\boot.img Serial: R58N1234567';
      final redacted =
          FileService.redactSensitiveText(input, serial: 'R58N1234567');
      expect(redacted.contains('Alice'), isFalse);
      expect(redacted.contains('R58N1234567'), isFalse);
      expect(redacted.contains('<USER>'), isTrue);
      expect(redacted.contains('<DEVICE_SERIAL>'), isTrue);
    });

    test('removes individual and clears all recent files', () async {
      SharedPreferences.setMockInitialValues({
        'recent_files': ['/tmp/a.img', '/tmp/b.img'],
      });
      final service = FileService();
      expect(await service.getRecentFiles(), ['/tmp/a.img', '/tmp/b.img']);

      await service.removeRecentFile('/tmp/a.img');
      expect(await service.getRecentFiles(), ['/tmp/b.img']);

      await service.clearRecentFiles();
      expect(await service.getRecentFiles(), isEmpty);
    });
  });

  group('SettingsProvider & UI widgets', () {
    test('SettingsProvider updates and resets to defaults', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = SettingsProvider();
      await Future<void>.delayed(Duration.zero);

      expect(settings.autoMonitorDevices, isTrue);
      expect(settings.confirmBeforeFlash, isTrue);
      expect(settings.redactDiagnostics, isTrue);

      await settings.setConfirmBeforeFlash(false);
      expect(settings.confirmBeforeFlash, isFalse);

      await settings.resetToDefaults();
      expect(settings.confirmBeforeFlash, isTrue);
    });

    testWidgets('ErrorBanner hides retry CTA when unsafe', (tester) async {
      final unsafeError = AppError(
        category: AppErrorCategory.flashing,
        title: 'Flash Interrupted',
        message: 'Partition write failed.',
        deviceSafe: false,
        canSafelyRetry: false,
        nextSteps: 'Restore stock boot instead.',
      );

      await tester.pumpWidget(_wrapWidget(
        ErrorBanner(
          error: unsafeError,
          onRetry: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Flash Interrupted'), findsOneWidget);
      expect(find.text('Check Device State'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('LogConsole filters by search text and log level',
        (tester) async {
      final logs = [
        LogEntry(
          timestamp: DateTime(2026, 1, 1, 12, 0, 0),
          level: LogLevel.info,
          message: 'Checking ADB server',
        ),
        LogEntry(
          timestamp: DateTime(2026, 1, 1, 12, 0, 1),
          level: LogLevel.error,
          message: 'Boot image magic missing',
        ),
      ];

      await tester.pumpWidget(_wrapWidget(LogConsole(logs: logs)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Checking ADB server'), findsOneWidget);
      expect(find.textContaining('Boot image magic missing'), findsOneWidget);

      await tester.tap(find.text('Err'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Checking ADB server'), findsNothing);
      expect(find.textContaining('Boot image magic missing'), findsOneWidget);
    });

    test('PatchProvider enforces bounded log history up to maxLogEntries', () {
      final provider = PatchProvider();
      final total = PatchProvider.maxLogEntries + 45;
      for (var i = 0; i < total; i++) {
        provider.addLogEntryForTest(LogLevel.info, 'entry_$i');
      }

      expect(provider.logs.length, PatchProvider.maxLogEntries);
      expect(provider.logs.first.message, 'entry_45');
      expect(provider.logs.last.message, 'entry_${total - 1}');
    });

    test('Constants caches resolved asset paths consistently', () {
      Constants.resetPathCache();
      final firstKp = Constants.kpVersionsBasePath;
      final secondKp = Constants.kpVersionsBasePath;
      expect(firstKp, equals(secondKp));
      expect(Constants.adbPath.isNotEmpty, isTrue);
    });

    testWidgets(
        'BootImageSelectorCard and KpmModulesSelectorCard reflect PatchProvider state',
        (tester) async {
      final provider = PatchProvider()
        ..setSelectedFile(r'C:\images\boot.img')
        ..setKpmModules({r'C:\modules\demo.kpm'});

      await tester.pumpWidget(
        ChangeNotifierProvider<PatchProvider>.value(
          value: provider,
          child: _wrapWidget(
            const SingleChildScrollView(
              child: Column(
                children: [
                  BootImageSelectorCard(),
                  KpmModulesSelectorCard(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'C:\images\boot.img'), findsOneWidget);
      expect(find.text('demo.kpm'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(provider.selectedKpmModules, isEmpty);
    });
  });
}