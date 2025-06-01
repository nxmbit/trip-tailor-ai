import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/presentation/common/layouts/mobile_scaffold.dart';
import 'package:frontend/presentation/features/auth/screens/oauth_redirect_handler.dart';
import 'package:frontend/presentation/features/auth/screens/signin_screen.dart';
import 'package:frontend/presentation/features/auth/screens/signup_screen.dart';
import 'package:frontend/presentation/features/auth/screens/splash_screen.dart';
import 'package:frontend/presentation/features/home/screens/home_content.dart';
import 'package:frontend/presentation/features/trip_planner/screens/trip_planner_content.dart';
import 'package:frontend/presentation/features/your_trips/screens/your_trips_content.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';

import '../domain/services/auth_service.dart';
import '../presentation/features/nearby_places/screen/nearby_places_content.dart';
import '../presentation/features/trip/screens/trip_detail_content.dart';
import '../presentation/features/welcome/screens/welcome_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  // Constants for route storage
  static const String _lastRouteKey = 'last_authenticated_route';

  // List of all protected routes that require authentication
  static final List<String> _protectedRoutes = [
    '/home',
    '/trip-planner',
    '/your-trips',
    '/nearby-places',
  ];

  // List of public routes that don't require authentication
  static final List<String> _publicRoutes = [
    '/signin',
    '/signup',
    '/welcome',
    '/oauth2/redirect',
    '/',
  ];

  static GoRouter getRouter(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: userProvider,
      navigatorKey: navigatorKey,
      redirect: (context, state) async {
        // Important: For page refreshes, we need to rely on the token check
        // instead of the in-memory userProvider state
        final isLoggedIn = await authService.isAuthenticated();

        // Synchronize UserProvider with the actual authentication state
        // This ensures the UI updates correctly after the auth check
        if (userProvider.isAuthenticated != isLoggedIn) {
          // Update the UserProvider without triggering another redirect
          WidgetsBinding.instance.addPostFrameCallback((_) {
            userProvider.updateAuthState(isLoggedIn);
          });
        }

        final isInitializing = userProvider.isLoading;
        final isGoingToPublicRoute = _publicRoutes.contains(
          state.matchedLocation,
        );
        final isGoingToProtectedRoute = _isProtectedRoute(
          state.matchedLocation,
        );

        debugPrint(
          'Router redirect - path: ${state.matchedLocation}, authenticated: $isLoggedIn, initializing: $isInitializing',
        );

        // If we're still initializing and going to the splash screen, don't redirect
        if (isInitializing && state.matchedLocation == '/') {
          return null;
        }

        // Case 1: Not logged in but trying to access a protected route
        if (!isLoggedIn && isGoingToProtectedRoute) {
          // Save the attempted path for later redirect after login
          await _saveLastRoute("/home");
          debugPrint('Not authenticated, redirecting to /signin');
          return '/signin';
        }

        // Case 2: Logged in but trying to access a public auth route
        if (isLoggedIn &&
            isGoingToPublicRoute &&
            state.matchedLocation != '/') {
          if (state.matchedLocation == '/oauth2/redirect') {
            // Don't redirect from OAuth handler
            return null;
          }
          debugPrint(
            'Already authenticated, redirecting to last route or /home',
          );
          // Return to the last known route or home
          final lastRoute = await _getLastRoute();
          return lastRoute ?? '/home';
        }

        // Case 3: Initial app load (splash screen)
        if (state.matchedLocation == '/') {
          // SplashScreen will handle the redirect logic
          return null;
        }

        // Save the current route if user is authenticated and on a protected route
        if (isLoggedIn && isGoingToProtectedRoute) {
          await _saveLastRoute(state.matchedLocation);
        }

        // No redirect needed
        return null;
      },
      routes: [
        // Splash screen and auth routes remain the same
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
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
        GoRoute(
          path: '/oauth2/redirect',
          builder: (context, state) => const OAuthRedirectHandler(),
        ),

        // Protected routes with persistent scaffold
        ShellRoute(
          builder: (context, state, child) {
            return MobileScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder:
                  (context, state) =>
                      NoTransitionPage(child: const HomeContent()),
            ),
            GoRoute(
              path: '/trip-planner',
              pageBuilder:
                  (context, state) =>
                      NoTransitionPage(child: const TripPlannerContent()),
            ),
            GoRoute(
              path: '/your-trips',
              pageBuilder:
                  (context, state) =>
                      NoTransitionPage(child: const YourTripsContent()),
            ),
            GoRoute(
              path: '/your-trips/:id',
              pageBuilder:
                  (context, state) => NoTransitionPage(
                    child: TripPlanDetailContent(
                      tripId: state.pathParameters['id']!,
                    ),
                  ),
            ),
            GoRoute(
              path: '/nearby-places',
              pageBuilder:
                  (context, state) =>
                      NoTransitionPage(child: const NearbyPlacesContent()),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to check if a route is protected
  static bool _isProtectedRoute(String path) {
    // Check exact matches
    if (_protectedRoutes.contains(path)) {
      return true;
    }

    // Check for routes with parameters (like /your-trips/:id)
    for (final route in _protectedRoutes) {
      if (path.startsWith('$route/')) {
        return true;
      }
    }

    return false;
  }

  // Save last authenticated route to preferences
  static Future<void> _saveLastRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRouteKey, route);
    debugPrint('Saved last route: $route');
  }

  // Get last authenticated route from preferences
  static Future<String?> getLastRoute() async {
    return _getLastRoute();
  }

  static Future<String?> _getLastRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRoute = prefs.getString(_lastRouteKey);
    debugPrint('Retrieved last route: $lastRoute');
    return lastRoute;
  }

  static Future<void> resetLastRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastRouteKey);

      debugPrint('Reset last route');
    } catch (e) {
      debugPrint('Error resetting last route: $e');
    }
  }
}
