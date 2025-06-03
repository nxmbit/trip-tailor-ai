import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/config/theme/app_theme.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:frontend/presentation/state/providers/theme_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        _handleDeepLink(appLink);
      }

      _appLinks.uriLinkStream.listen((uri) {
        _handleDeepLink(uri);
      });
    } catch (e) {
      debugPrint('Deep links error: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          if (uri.scheme == 'triptailor' && uri.host == 'oauth2redirect') {
            debugPrint('Handling deep link: $uri');
            GoRouter.of(context).go('/oauth2/redirect${uri.hasQuery ? '?${uri.query}' : ''}');
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.getRouter(context);

    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        if (!languageProvider.isLoaded) {
          return const Center(child: CircularProgressIndicator());
        }


        return MaterialApp.router(
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
          supportedLocales: const [Locale('en', 'US'), Locale('pl', 'PL'), Locale('de', 'DE')],
          routerConfig: router,
        );
      },
    );
  }
}