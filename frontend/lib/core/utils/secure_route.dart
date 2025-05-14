import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';

class SecureRoute extends StatelessWidget {
  final Widget child;

  const SecureRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return FutureBuilder<bool>(
      future: authService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          // Ensure user data is loaded if authenticated
          if (userProvider.user == null && !userProvider.isLoading) {
            // Initialize user data if not already loading
            userProvider.initializeUser();
          }
          return child;
        }

        // Redirect to sign in if not authenticated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          userProvider.userService.logoutUser();

          context.go('/signin');
        });

        return const SizedBox.shrink();
      },
    );
  }
}
