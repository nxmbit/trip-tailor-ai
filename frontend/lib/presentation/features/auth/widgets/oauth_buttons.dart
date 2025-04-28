import 'package:flutter/material.dart';
import 'package:auth_buttons/auth_buttons.dart';

//TODO split this into folder structure
class SocialAuthButtons extends StatelessWidget {
  SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GoogleAuthButton(
          onPressed: _handleGoogleAuth,
          style: const AuthButtonStyle(buttonType: AuthButtonType.icon),
        ),
        const SizedBox(width: 16.0),
        GithubAuthButton(
          onPressed: () => _handleGithubAuth(context),
          style: const AuthButtonStyle(buttonType: AuthButtonType.icon),
        ),
        const SizedBox(width: 16.0),
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

  void _handleGithubAuth(BuildContext context) async {
    print("Github auth clicked");
  }

  void _handleFacebookAuth() {
    print("Facebook auth clicked");
  }
}
