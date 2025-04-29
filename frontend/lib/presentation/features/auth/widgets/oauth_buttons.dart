import 'package:flutter/material.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/services/auth_service.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the AuthService from the provider
    final authService = Provider.of<AuthService>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GoogleAuthButton(
          onPressed: () => _handleSocialAuth(context, 'google', authService),
          style: const AuthButtonStyle(buttonType: AuthButtonType.icon),
        ),
        const SizedBox(width: 16.0),
        GithubAuthButton(
          onPressed: () => _handleSocialAuth(context, 'github', authService),
          style: const AuthButtonStyle(buttonType: AuthButtonType.icon),
        ),
        const SizedBox(width: 16.0),
        FacebookAuthButton(
          onPressed: () => _handleSocialAuth(context, 'facebook', authService),
          style: const AuthButtonStyle(buttonType: AuthButtonType.icon),
        ),
      ],
    );
  }

  void _handleSocialAuth(
    BuildContext context,
    String provider,
    AuthService authService,
  ) async {
    try {
      // Show loading indicator or feedback
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Redirecting to login...")));

      // Use the injected AuthService
      final success = await authService.handleSocialAuth(provider);

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to launch $provider authentication")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
