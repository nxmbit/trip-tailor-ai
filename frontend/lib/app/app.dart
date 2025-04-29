import 'package:flutter/material.dart';
import 'package:frontend/presentation/features/auth/screens/oauth_redirect_handler.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:frontend/presentation/state/providers/theme_provider.dart';
import 'package:frontend/presentation/common/layouts/desktop_scaffold.dart';
import 'package:frontend/presentation/common/layouts/mobile_scaffold.dart';
import 'package:frontend/presentation/common/layouts/responsive_layout.dart';
import 'package:frontend/presentation/common/layouts/tablet_scaffold.dart';
import 'package:frontend/presentation/features/home/screens/home_content.dart';
import 'package:frontend/presentation/features/your_trips/screens/your_trips_content.dart';
import 'package:frontend/presentation/features/auth/screens/signin_screen.dart';
import 'package:frontend/presentation/features/auth/screens/signup_screen.dart';
import 'package:frontend/presentation/features/trip_planner/screens/trip_planner_content.dart';
import 'package:frontend/presentation/features/welcome/screens/welcome_screen.dart';
import 'package:frontend/core/config/theme/app_theme.dart';
import 'package:frontend/core/utils/secure_route.dart';
import 'package:provider/provider.dart';

import '../presentation/features/auth/screens/splash_screen.dart';

//TODO: switch to go router
//TODO: split into routes and app.dart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        if (!languageProvider.isLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Trip Tailor',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: languageProvider.locale,
          routes: {
            '/': (context) => const SplashScreen(),
            "/welcome": (context) => const WelcomeScreen(),
            "/signin": (context) => const SignInScreen(),
            "/signup": (context) => const SignUpScreen(),
            "/home":
                (context) => SecureRoute(
                  child: ResponsiveLayout(
                    mobileScaffold: MobileScaffold(child: const HomeContent()),
                    tabletScaffold: TabletScaffold(child: const HomeContent()),
                    desktopScaffold: DesktopScaffold(
                      child: const HomeContent(),
                    ),
                  ),
                ),
            "/trip-planner":
                (context) => SecureRoute(
                  child: ResponsiveLayout(
                    mobileScaffold: MobileScaffold(
                      child: const TripPlannerContent(),
                    ),
                    tabletScaffold: TabletScaffold(
                      child: const TripPlannerContent(),
                    ),
                    desktopScaffold: DesktopScaffold(
                      child: const TripPlannerContent(),
                    ),
                  ),
                ),
            "/your-trips":
                (context) => SecureRoute(
                  child: ResponsiveLayout(
                    mobileScaffold: MobileScaffold(
                      child: const YourTripsContent(),
                    ),
                    tabletScaffold: TabletScaffold(
                      child: const YourTripsContent(),
                    ),
                    desktopScaffold: DesktopScaffold(
                      child: const YourTripsContent(),
                    ),
                  ),
                ),
            "/oauth2/redirect": (context) => const OAuthRedirectHandler(),
          },
          initialRoute: "/",
        );
      },
    );
  }
}
