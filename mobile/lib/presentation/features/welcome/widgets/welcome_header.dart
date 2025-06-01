import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/translation_helper.dart';

class WelcomeHeader extends StatelessWidget {
  final bool isDesktop;

  const WelcomeHeader({Key? key, required this.isDesktop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = !isDesktop && MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.0 : 40.0,
        vertical: 16.0,
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Text(
            'TripTailor',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Auth buttons
          isMobile
              ? // Mobile auth options
              Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: () => context.go('/signin'),
                      tooltip: tr(context, 'auth.signIn'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () => context.go('/signup'),
                      tooltip: tr(context, 'auth.signUp'),
                    ),
                  ],
                )
              : // Text buttons for tablet and desktop
              Row(
                children: [
                  TextButton(
                    onPressed: () => context.go('/signin'),
                    child: Text(tr(context, 'auth.signIn')),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => context.go('/signup'),
                    child: Text(tr(context, 'auth.signUp')),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}