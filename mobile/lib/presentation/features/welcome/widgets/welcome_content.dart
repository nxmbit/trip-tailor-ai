import 'package:flutter/material.dart';
import 'welcome_cta_banner.dart';
import 'welcome_features_section.dart';
import 'welcome_footer.dart';
import 'welcome_header.dart';

class WelcomeContent extends StatelessWidget {
  const WelcomeContent({Key? key}) : super(key: key);

  // Maximum content width - adjust this as needed
  static const double maxContentWidth = 1200.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _constrainedContent(
            child: const WelcomeHeader(isDesktop: false),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _constrainedContent(
            child: const WelcomeFeaturesSection(isCompact: true),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _constrainedContent(
            child: const WelcomeCTABanner(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          const WelcomeFooter(), // Footer stays full width
        ],
      ),
    );
  }

  // Helper method to constrain content width
  Widget _constrainedContent({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 24),
  }) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        padding: padding,
        child: child,
      ),
    );
  }

}