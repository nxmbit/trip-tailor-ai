import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/translation_helper.dart';
import '../../../../domain/services/auth_service.dart';

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
    // Give the splash screen time to be visible
    await Future.delayed(const Duration(seconds: 1));

    // Check if user is authenticated
    final isAuthenticated = await authService.isAuthenticated();

    if (mounted) {
      if (isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/welcome');
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
