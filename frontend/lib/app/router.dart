import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:frontend/presentation/common/layouts/desktop_scaffold.dart';
import 'package:frontend/presentation/common/layouts/mobile_scaffold.dart';
import 'package:frontend/presentation/common/layouts/tablet_scaffold.dart';
import 'package:frontend/presentation/common/layouts/responsive_layout.dart';
import 'package:frontend/presentation/features/auth/screens/oauth_redirect_handler.dart';
import 'package:frontend/presentation/features/auth/screens/signin_screen.dart';
import 'package:frontend/presentation/features/auth/screens/signup_screen.dart';
import 'package:frontend/presentation/features/auth/screens/splash_screen.dart';
import 'package:frontend/presentation/features/home/screens/home_content.dart';
import 'package:frontend/presentation/features/trip_planner/screens/trip_planner_content.dart';
import 'package:frontend/presentation/features/welcome/screens/welcome_screen.dart';
import 'package:frontend/presentation/features/your_trips/screens/your_trips_content.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';

class AppRouter {
  static GoRouter getRouter(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: userProvider, // Listen to user changes
      redirect: (context, state) async {
        // Force refresh auth status on every redirection
        final isLoggedIn = userProvider.isAuthenticated;

        debugPrint("isLoggedIn: $isLoggedIn");
        debugPrint(
          'Router redirect - path: ${state.matchedLocation}, authenticated: $isLoggedIn',
        );

        // Auth pages that don't require authentication
        final isGoingToAuth =
            state.matchedLocation == '/signin' ||
            state.matchedLocation == '/signup' ||
            state.matchedLocation == '/welcome';

        // Splash screen
        final isGoingToSplash = state.matchedLocation == '/';

        // Not logged in but trying to access a protected route
        if (!isLoggedIn && !isGoingToAuth && !isGoingToSplash) {
          debugPrint('Not authenticated, redirecting to /signin');
          return '/signin';
        }

        // Logged in but trying to access an auth route
        if (isLoggedIn && isGoingToAuth) {
          debugPrint('Already authenticated, redirecting to /home');
          return '/home';
        }

        // No redirect needed
        return null;
      },
      routes: [
        // Splash screen route
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

        // Auth routes
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/signin',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),

        // OAuth redirect
        GoRoute(
          path: '/oauth2/redirect',
          builder: (context, state) => const OAuthRedirectHandler(),
        ),

        // Protected routes under a ShellRoute with AuthShell
        ShellRoute(
          builder: (context, state, child) {
            return AuthShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder:
                  (context, state) => ResponsiveLayout(
                    mobileScaffold: MobileScaffold(child: const HomeContent()),
                    tabletScaffold: TabletScaffold(child: const HomeContent()),
                    desktopScaffold: DesktopScaffold(
                      child: const HomeContent(),
                    ),
                  ),
            ),
            GoRoute(
              path: '/trip-planner',
              builder:
                  (context, state) => ResponsiveLayout(
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
            GoRoute(
              path: '/your-trips',
              builder:
                  (context, state) => ResponsiveLayout(
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
          ],
        ),
      ],
    );
  }
}

/// AuthShell is responsible for ensuring user data is loaded
/// for all authenticated routes
class AuthShell extends StatefulWidget {
  final Widget child;

  const AuthShell({super.key, required this.child});

  @override
  State<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends State<AuthShell> {
  @override
  void initState() {
    super.initState();
    // Initialize user data when this shell mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null && !userProvider.isLoading) {
        userProvider.initializeUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
