import 'package:flutter/material.dart';
import '../../../../core/utils/translation_helper.dart';

class WelcomeHeroSection extends StatelessWidget {
  final bool isDesktop;

  const WelcomeHeroSection({Key? key, required this.isDesktop})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isTablet = !isDesktop && MediaQuery.of(context).size.width >= 600;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 24.0,
        vertical: isDesktop ? 80.0 : 40.0,
      ),
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Main headline
          SizedBox(
            width: isDesktop ? 700 : double.infinity,
            child: Text(
              tr(context, 'welcome.heroTitle'),
              style: textTheme.headlineLarge?.copyWith(
                fontSize: isDesktop ? 48 : (isTablet ? 36 : 28),
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // Subheading
          SizedBox(
            width: isDesktop ? 600 : double.infinity,
            child: Text(
              tr(context, 'welcome.heroSubtitle'),
              style: textTheme.bodyLarge?.copyWith(
                fontSize: isDesktop ? 18 : 16,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Mobile app preview image
          if (isMobile)
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '', // Placeholder for now
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: colorScheme.primary,
                        ),
                      ),
                ),
              ),
            ),
          // App preview image for desktop/tablet - unchanged
          if ((isDesktop || isTablet) && !isMobile) _buildAppPreview(context),
        ],
      ),
    );
  }

  Widget _buildAppPreview(BuildContext context) {
    return Container(
      width: isDesktop ? 800 : 600,
      height: isDesktop ? 450 : 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          tr(context, 'welcome.appPreviewPlaceholder'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
