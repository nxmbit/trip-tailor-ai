import 'package:flutter/material.dart';
import 'welcome_cta_banner.dart';
import 'welcome_faq_section.dart';
import 'welcome_features_section.dart';
import 'welcome_footer.dart';
import 'welcome_header.dart';
import 'welcome_hero_section.dart';

class WelcomeContent extends StatelessWidget {
  const WelcomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileLayout(context);
        } else if (constraints.maxWidth < 1200) {
          return _buildTabletLayout(context);
        } else {
          return _buildDesktopLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const WelcomeHeader(isDesktop: false),
          const WelcomeHeroSection(isDesktop: false),
          const WelcomeCTABanner(),
          const WelcomeFooter(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const WelcomeHeader(isDesktop: false),
          const WelcomeHeroSection(isDesktop: false),
          const WelcomeFeaturesSection(isCompact: true),
          const WelcomeCTABanner(),
          const WelcomeFAQSection(),
          const WelcomeFooter(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const WelcomeHeader(isDesktop: true),
          const WelcomeHeroSection(isDesktop: true),
          const WelcomeFeaturesSection(isCompact: false),
          const WelcomeCTABanner(),
          const WelcomeFAQSection(),
          const WelcomeFooter(),
        ],
      ),
    );
  }
}
