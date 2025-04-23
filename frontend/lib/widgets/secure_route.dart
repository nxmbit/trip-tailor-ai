import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';

class SecureRoute extends StatelessWidget {
  final Widget child;
  final AuthService authService;

  const SecureRoute({
    super.key,
    required this.child,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: authService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        }

        // Redirect to sign in if not authenticated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          authService.logout(notifyServer: false);
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil("/signin", (route) => false);
        });

        return const SizedBox.shrink();
      },
    );
  }
}
