import 'package:flutter/material.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:frontend/constants/ui_constants.dart';
import 'package:frontend/services/auth_service.dart';

class SocialAuthButtons extends StatelessWidget {
  final AuthService _authService = AuthService();

  SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GoogleAuthButton(
          onPressed: () => _handleSocialAuth(context, 'google'),
          style: const AuthButtonStyle(buttonType: AuthButtonType.icon),
        ),
        const SizedBox(width: UIConstants.defaultSpacing),
        GithubAuthButton(
          onPressed: () => _handleSocialAuth(context, 'github'),
          style: const AuthButtonStyle(buttonType: AuthButtonType.icon),
        ),
        const SizedBox(width: UIConstants.defaultSpacing),
        FacebookAuthButton(
          onPressed: () => _handleSocialAuth(context, 'facebook'),
          style: const AuthButtonStyle(buttonType: AuthButtonType.icon),
        ),
      ],
    );
  }

  void _handleSocialAuth(BuildContext context, String provider) async {
    try {
      // Show loading indicator or feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Redirecting to login...")),
      );

      // Use the existing method from AuthService
      final success = await _authService.handleSocialAuth(provider);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to launch $provider authentication")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}