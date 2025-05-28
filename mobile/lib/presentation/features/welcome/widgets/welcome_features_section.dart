import 'package:flutter/material.dart';
import '../../../../core/utils/translation_helper.dart';

class WelcomeFeaturesSection extends StatelessWidget {
  final bool isCompact;

  const WelcomeFeaturesSection({Key? key, required this.isCompact})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: 60.0,
      ),
      child: Column(
        children: [
          Text(
            tr(context, 'welcome.featuresTitle'),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Features grid
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(
                context,
                'welcome.feature1Title',
                'welcome.feature1Description',
                Icons.speed_outlined,
              ),
              _buildFeatureCard(
                context,
                'welcome.feature2Title',
                'welcome.feature2Description',
                Icons.food_bank_outlined,
              ),
              _buildFeatureCard(
                context,
                'welcome.feature3Title',
                'welcome.feature3Description',
                Icons.accessibility_new_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String titleKey,
    String descriptionKey,
    IconData icon,
  ) {
    return Container(
      width: isCompact ? 250 : 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            tr(context, titleKey),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            tr(context, descriptionKey),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
