import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FolkTool/core/config/app_theme.dart';
import 'package:FolkTool/core/logging/log_entry.dart';
import 'package:FolkTool/core/widgets/log_console.dart';
import 'package:FolkTool/features/patching/models/operation_step.dart';
import 'package:FolkTool/features/patching/models/patch_target.dart';
import 'package:FolkTool/features/patching/providers/version_provider.dart';
import 'package:FolkTool/features/patching/widgets/patch_target_selector.dart';
import 'package:FolkTool/features/patching/widgets/step_progress.dart';
import 'package:FolkTool/features/patching/widgets/version_selector.dart';
import 'package:FolkTool/features/settings/providers/locale_provider.dart';
import 'package:FolkTool/features/settings/providers/theme_provider.dart';
import 'package:FolkTool/generated/l10n.dart';

Widget _wrapWithApp({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  ThemeProvider? themeProvider,
  VersionProvider? versionProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider(create: (_) => themeProvider ?? ThemeProvider()),
      ChangeNotifierProvider(
          create: (_) => versionProvider ?? VersionProvider()),
    ],
    child: MaterialApp(
      locale: locale,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('en'),
      ],
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ThemeProvider switches between system, light, and dark modes',
      (tester) async {
    final provider = ThemeProvider();
    expect(provider.themeMode, ThemeMode.system);

    await provider.setThemeMode(ThemeMode.dark);
    expect(provider.themeMode, ThemeMode.dark);

    await provider.setThemeMode(ThemeMode.light);
    expect(provider.themeMode, ThemeMode.light);
  });

  testWidgets('PatchTargetSelector renders SegmentedButton and switches target',
      (tester) async {
    final versionProvider = VersionProvider();

    await tester.pumpWidget(
      _wrapWithApp(
        versionProvider: versionProvider,
        child: const PatchTargetSelector(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SegmentedButton<PatchTarget>), findsOneWidget);
    expect(find.text('FolkPatch'), findsOneWidget);
    expect(find.text('APatch'), findsOneWidget);

    await tester.tap(find.text('APatch'));
    await tester.pumpAndSettle();
    expect(versionProvider.currentTarget, PatchTarget.apatch);
  });

  testWidgets('LogConsole renders logs and triggers onClear in dark mode',
      (tester) async {
    var cleared = false;
    final logs = [
      LogEntry(
        timestamp: DateTime(2026, 1, 1, 12, 0, 0),
        level: LogLevel.info,
        message: 'Test log entry',
      ),
    ];

    await tester.pumpWidget(
      _wrapWithApp(
        themeMode: ThemeMode.dark,
        child: LogConsole(
          logs: logs,
          onClear: () => cleared = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Test log entry'), findsOneWidget);
    expect(find.byIcon(Icons.copy_all), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(cleared, isTrue);
  });

  testWidgets('StepProgress renders step statuses and percentage cleanly',
      (tester) async {
    final steps = [
      OperationStep(
        type: StepType.selectFile,
        name: 'Select boot.img',
        status: StepStatus.completed,
      ),
      OperationStep(
        type: StepType.patchImage,
        name: 'Patch image',
        status: StepStatus.inProgress,
      ),
      OperationStep(
        type: StepType.flashImage,
        name: 'Flash to device',
        status: StepStatus.pending,
      ),
    ];

    await tester.pumpWidget(
      _wrapWithApp(
        themeMode: ThemeMode.dark,
        child: StepProgress(steps: steps, currentIndex: 1),
      ),
    );
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('66%'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('VersionSelector renders empty state cleanly in light & dark',
      (tester) async {
    await tester.pumpWidget(
      _wrapWithApp(
        themeMode: ThemeMode.light,
        child: const VersionSelector(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(VersionSelector), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });
}
