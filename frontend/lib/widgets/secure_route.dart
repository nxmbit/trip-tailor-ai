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
      future: authService.isLoggedIn(),
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
          Navigator.of(context).pushReplacementNamed('/signin');
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
