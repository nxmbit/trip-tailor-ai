import 'package:flutter/material.dart';
import 'package:frontend/widgets/welcome_scaffold.dart';
import 'package:frontend/constants/ui_constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return WelcomeScaffold(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: UIConstants.screenPadding,
            child: Card(
              elevation: 0,
              color: colorScheme.surface,
              child: Padding(
                padding: UIConstants.cardPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitle(textTheme, colorScheme),
                    const SizedBox(height: UIConstants.defaultSpacing),
                    _buildWelcomeText(textTheme, colorScheme),
                    const SizedBox(height: UIConstants.smallSpacing),
                    _buildSubtitle(textTheme, colorScheme),
                    const SizedBox(height: UIConstants.largePadding),
                    _buildButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      'tripTailor.ai',
      style: textTheme.displayLarge?.copyWith(color: colorScheme.primary),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildWelcomeText(TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      'Welcome back!',
      style: textTheme.headlineMedium?.copyWith(color: colorScheme.onSurface),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      'Plan your trip with us',
      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Wrap(
      spacing: UIConstants.buttonSpacing,
      runSpacing: UIConstants.buttonSpacing,
      alignment: WrapAlignment.center,
      children: [
        FilledButton(
          onPressed: () => Navigator.of(context).pushNamed('/signin'),
          child: const Text('Sign In'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pushNamed('/signup'),
          child: const Text('Sign Up'),
        ),
      ],
    );
  }
}
