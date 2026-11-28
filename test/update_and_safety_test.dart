import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:FolkTool/core/logging/log_entry.dart';
import 'package:FolkTool/core/updates/update_service.dart';
import 'package:FolkTool/core/widgets/log_console.dart';
import 'package:FolkTool/features/device/models/device_info.dart';
import 'package:FolkTool/features/device/services/device_service.dart';
import 'package:FolkTool/features/files/services/file_service.dart';
import 'package:FolkTool/features/patching/services/safety_service.dart';
import 'package:FolkTool/generated/l10n.dart';

void main() {
  group('UpdateService version helpers', () {
    test('normalizeVersion strips v prefix and suffixes', () {
      expect(UpdateService.normalizeVersion('v1.7.0'), '1.7.0');
      expect(UpdateService.normalizeVersion('V2.0.1+5'), '2.0.1');
      expect(UpdateService.normalizeVersion('1.8.0-beta.1'), '1.8.0');
    });

    test('isNewerVersion compares semantic versions accurately', () {
      expect(UpdateService.isNewerVersion('v1.8.0', '1.7.0'), isTrue);
      expect(UpdateService.isNewerVersion('1.7.1', '1.7.0'), isTrue);
      expect(UpdateService.isNewerVersion('2.0.0', '1.9.9'), isTrue);
      expect(UpdateService.isNewerVersion('1.7.0', '1.7.0'), isFalse);
      expect(UpdateService.isNewerVersion('1.6.9', '1.7.0'), isFalse);
      expect(UpdateService.isNewerVersion('invalid', '1.7.0'), isFalse);
    });
  });

  group('SafetyService & battery parsing', () {
    test('isKernelCompatible enforces 3.18 to 6.15 range', () {
      expect(SafetyService.isKernelCompatible('3.17.99'), isFalse);
      expect(SafetyService.isKernelCompatible('3.18.140'), isTrue);
      expect(SafetyService.isKernelCompatible('5.15.104-android13'), isTrue);
      expect(SafetyService.isKernelCompatible('6.15.0'), isTrue);
      expect(SafetyService.isKernelCompatible('6.16.0'), isFalse);
      expect(SafetyService.isKernelCompatible(''), isFalse);
      expect(SafetyService.isKernelCompatible(null), isFalse);
    });

    test('DeviceService.parseBatteryLevel extracts level from dumpsys output',
        () {
      expect(DeviceService.parseBatteryLevel('  level: 42\n'), 42);
      expect(DeviceService.parseBatteryLevel('no level here'), isNull);
    });

    test('runPreflightChecks reports errors for missing or empty boot.img',
        () async {
      final safety = SafetyService();
      final missing = await safety.runPreflightChecks(
        bootImagePath: '/nonexistent/boot.img',
        checkBinaries: false,
      );
      expect(missing.passed, isFalse);
      expect(missing.errors, isNotEmpty);

      final tmpDir = await Directory.systemTemp.createTemp('folktool_test_');
      try {
        final emptyBoot = File('${tmpDir.path}/boot.img');
        await emptyBoot.writeAsBytes([]);
        final emptyResult = await safety.runPreflightChecks(
          bootImagePath: emptyBoot.path,
          checkBinaries: false,
        );
        expect(emptyResult.passed, isFalse);

        await emptyBoot.writeAsBytes([1, 2, 3, 4]);
        final warnResult = await safety.runPreflightChecks(
          bootImagePath: emptyBoot.path,
          deviceInfo: DeviceInfo(
            serial: 'XYZ',
            state: DeviceState.adb,
            kernelVersion: '6.18.0',
          ),
          batteryLevel: 10,
          checkBinaries: false,
        );
        expect(warnResult.passed, isTrue);
        expect(warnResult.warnings, hasLength(2));
      } finally {
        await tmpDir.delete(recursive: true);
      }
    });
  });

  group('Diagnostics & LogConsole export', () {
    test('FileService.buildDiagnosticReport includes device info and logs', () {
      final service = FileService();
      final report = service.buildDiagnosticReport(
        deviceInfo: DeviceInfo(
          serial: 'SER123',
          state: DeviceState.adb,
          model: 'Pixel 7',
          androidVersion: '14',
          kernelVersion: '5.15.104',
        ),
        logs: [
          LogEntry(
            timestamp: DateTime(2026, 11, 25, 0, 0, 0),
            level: LogLevel.info,
            message: 'Sample diagnostic log',
          ),
        ],
      );

      expect(report, contains('FolkTool Diagnostic Report'));
      expect(report, contains('SER123'));
      expect(report, contains('Pixel 7'));
      expect(report, contains('Sample diagnostic log'));
    });

    testWidgets('LogConsole triggers onExport when export button is tapped',
        (tester) async {
      var exported = false;
      final logs = [
        LogEntry(
          timestamp: DateTime(2026, 11, 25, 0, 0, 0),
          level: LogLevel.info,
          message: 'Exportable log',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('zh'), Locale('en')],
          home: Scaffold(
            body: LogConsole(
              logs: logs,
              onExport: () => exported = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.download_outlined));
      await tester.pumpAndSettle();
      expect(exported, isTrue);
    });
  });
}
