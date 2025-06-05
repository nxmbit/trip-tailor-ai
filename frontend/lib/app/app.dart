import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/config/theme/app_theme.dart';
import 'package:frontend/core/utils/map_util.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:frontend/presentation/state/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the router configuration from AppRouter
    final router = AppRouter.getRouter(context);
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        if (!languageProvider.isLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        initializeGoogleMapsWeb(
          initialLanguage: languageProvider.locale.languageCode,
        );
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Trip Tailor',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: languageProvider.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('pl', 'PL'),
            Locale('de', 'DE'),
          ],
          // Use the GoRouter for routing
          routerConfig: router,
        );
      },
    );
  }
}
