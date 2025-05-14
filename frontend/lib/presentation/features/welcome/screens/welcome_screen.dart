import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/translation_helper.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 0,
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTitle(context, textTheme, colorScheme),
                      const SizedBox(height: 16.0),
                      _buildSubtitle(context, textTheme, colorScheme),
                      const SizedBox(height: 32.0),
                      _buildButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Text(
      tr(context, 'app.title'),
      style: textTheme.displayLarge?.copyWith(
        color: colorScheme.primary,
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubtitle(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Text(
      tr(context, 'app.subtitle'),
      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.center,
      children: [
        FilledButton(
          onPressed: () => context.go('/signin'),
          child: Text(tr(context, 'auth.signIn')),
        ),
        FilledButton.tonal(
          onPressed: () => context.go('/signup'),
          child: Text(tr(context, 'auth.signUp')),
        ),
      ],
    );
  }
}
