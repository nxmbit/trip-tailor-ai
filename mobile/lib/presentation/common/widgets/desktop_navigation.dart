import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:go_router/go_router.dart';

class DesktopNavigation extends StatelessWidget {
  const DesktopNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        TextButton(
          onPressed: () => context.go('/home'),
          child: Text(
            tr(context, 'app.title'),
            style: textTheme.displayLarge?.copyWith(
              color: colorScheme.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 32),
        TextButton(
          onPressed: () => context.go('/trip-planner'),
          child: Text(tr(context, 'navigation.tripPlanner')),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () => context.go('/your-trips'),
          child: Text(tr(context, 'navigation.yourTrips')),
        ),
      ],
    );
  }
}
