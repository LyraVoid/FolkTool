import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'config/constants.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'generated/l10n.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FolkToolApp());
}

class FolkToolApp extends StatelessWidget {
  const FolkToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => PatchProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VersionProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: Constants.appName,
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            themeMode: themeProvider.themeMode,
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
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
