import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/translation_helper.dart';
import '../../../../presentation/state/providers/language_provider.dart';

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

    // Get current language from provider
    final currentLanguage =
        Provider.of<LanguageProvider>(context).locale.languageCode;

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

          // App preview image for desktop/tablet with language-specific image
          if ((isDesktop || isTablet) && !isMobile)
            _buildAppPreview(context, currentLanguage),
        ],
      ),
    );
  }

  Widget _buildAppPreview(BuildContext context, String language) {
    return Column(
      children: [
        Container(
          width:
              isDesktop
                  ? 800
                  : 700, // Increased from 600 to 800/700 depending on screen size
          height: isDesktop ? 560 : 480, // Increased from 400 to 560/480
          margin: const EdgeInsets.only(bottom: 32), // Increased margin
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16), // Slightly larger radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.15,
                ), // Slightly stronger shadow
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16), // Match container radius
            child: Image.asset(
              // Choose image based on language
              language == 'pl' ? 'images/pl.png' : 'images/en.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomLeft,
              errorBuilder:
                  (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 80, // Larger icon for error state
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
