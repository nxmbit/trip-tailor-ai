import 'package:flutter/material.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:frontend/constants/ui_constants.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GoogleAuthButton(
          onPressed: _handleGoogleAuth,
          style: const AuthButtonStyle(buttonType: AuthButtonType.icon),
        ),
        const SizedBox(width: UIConstants.defaultSpacing),
        GithubAuthButton(
          onPressed: _handleGithubAuth,
          style: const AuthButtonStyle(buttonType: AuthButtonType.icon),
        ),
        const SizedBox(width: UIConstants.defaultSpacing),
        FacebookAuthButton(
          onPressed: _handleFacebookAuth,
          style: const AuthButtonStyle(buttonType: AuthButtonType.icon),
        ),
      ],
    );
  }

  void _handleGoogleAuth() {
    print("Google auth clicked");
  }

  void _handleGithubAuth() {
    print("Github auth clicked");
  }

  void _handleFacebookAuth() {
    print("Facebook auth clicked");
  }
}
