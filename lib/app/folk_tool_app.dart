import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../core/config/app_config.dart';
import '../core/config/app_theme.dart';
import '../features/device/providers/device_provider.dart';
import '../features/patching/providers/patch_provider.dart';
import '../features/patching/providers/version_provider.dart';
import '../features/settings/providers/locale_provider.dart';
import '../features/settings/providers/settings_provider.dart';
import '../features/settings/providers/theme_provider.dart';
import '../generated/l10n.dart';
import 'app_shell_screen.dart';

class FolkToolApp extends StatelessWidget {
  const FolkToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => PatchProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VersionProvider()),
      ],
      child: Selector2<LocaleProvider, ThemeProvider,
          ({Locale locale, ThemeMode themeMode})>(
        selector: (_, localeProv, themeProv) => (
          locale: localeProv.locale,
          themeMode: themeProv.themeMode,
        ),
        builder: (context, prefs, child) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            locale: prefs.locale,
            themeMode: prefs.themeMode,
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
            home: const AppShellScreen(),
          );
        },
      ),
    );
  }
}
