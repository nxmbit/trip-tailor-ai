import 'package:flutter/material.dart';

import '../../../../core/utils/translation_helper.dart';

class BackToWelcomeButton extends StatelessWidget {
  const BackToWelcomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pushReplacementNamed('/welcome'),
      child: Text(
        tr(context, 'auth.backToWelcome'),
        textAlign: TextAlign.center,
      ),
    );
  }
}
