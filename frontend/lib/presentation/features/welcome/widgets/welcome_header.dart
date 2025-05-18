import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/translation_helper.dart';

class WelcomeHeader extends StatelessWidget {
  final bool isDesktop;

  const WelcomeHeader({Key? key, required this.isDesktop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = !isDesktop;

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

          // Sign in button - simplified for mobile
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () => context.go('/signin'),
            tooltip: tr(context, 'auth.signIn'),
          ),
        ],
      ),
    );
  }
}
