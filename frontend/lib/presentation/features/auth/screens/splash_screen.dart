import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/translation_helper.dart';
import '../../../../domain/services/auth_service.dart';
import '../../../../app/router.dart';
import '../../../state/providers/user_provider.dart';

//TODO: possibly make it be shown only when the app is loading
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Give the splash screen time to be visible
    await Future.delayed(const Duration(seconds: 1));

    // Check if user is authenticated
    final isAuthenticated = await authService.isAuthenticated();

    // Update the UserProvider with the correct auth state
    if (userProvider.isAuthenticated != isAuthenticated) {
      userProvider.updateAuthState(isAuthenticated);
    }

    // If authenticated, also load the user data
    if (isAuthenticated) {
      await userProvider.initializeUser();
    }

    if (mounted) {
      debugPrint('Authentication status: $isAuthenticated');

      if (isAuthenticated) {
        // Get the last route if available, otherwise go to home
        final lastRoute = await AppRouter.getLastRoute();
        final targetRoute = lastRoute ?? '/home';
        debugPrint('Navigating to last route: $targetRoute');
        context.go(targetRoute);
      } else {
        // If not authenticated, go to welcome screen
        context.go('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr(context, 'app.title'),
              style: textTheme.displayLarge?.copyWith(
                color: colorScheme.primary,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
