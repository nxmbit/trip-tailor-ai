import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:go_router/go_router.dart';

class WelcomeSection extends StatelessWidget {
  final bool isMobile;
  const WelcomeSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            tr(context, 'home.welcomeTitle'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            tr(context, 'home.welcomeSubtitle'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.7),
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: SizedBox(
            width:
                isMobile
                    ? double.infinity
                    : null, // Full width container on mobile
            child: ElevatedButton(
              //TODO: possibly fix overflow
              onPressed: () => context.go('/trip-planner'),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Always use min for the Row
                mainAxisAlignment: MainAxisAlignment.center, // Center for both
                children: [
                  const Icon(Icons.add),
                  const SizedBox(width: 8),
                  Text(
                    tr(context, 'home.welcomeButton'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
