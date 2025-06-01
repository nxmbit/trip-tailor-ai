import 'package:flutter/material.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:frontend/presentation/common/widgets/language_selection_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../common/widgets/language_selection_dialog.dart';
import '../common/widgets/mobile_actions_dialog.dart';
import '../common/widgets/mobile_settings.dart';
import '../common/widgets/profile_image_screen.dart';

class LayoutState {
  // Navigation state
  int currentIndex = 0;

  // For tracking current route for navigation indicators
  void updateSelectedIndexFromRoute(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith('/home')) {
      currentIndex = 0;
    } else if (location.startsWith('/trip-planner')) {
      currentIndex = 1;
    } else if (location.startsWith('/your-trips')) {
      currentIndex = 2;
    }
  }

  // Navigate based on index - common logic for all nav types
  void navigateToIndex(int index, BuildContext context) {
    currentIndex = index;
    String route = '/home';

    switch (index) {
      case 0:
        route = '/home';
        break;
      case 1:
        route = '/trip-planner';
        break;
      case 2:
        route = '/your-trips';
        break;
    }

    // Only navigate if not already on this route
    if (ModalRoute.of(context)?.settings.name != route) {
      context.go(route);
    }
  }

  // Dialog/Sheet handlers
  void showActionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const MobileActionsDialog();
      },
    );
  }

  void showSettingsDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MobileSettings()),
    );
  }

  void showProfileImageDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileImageScreen(),
      ),
    );
  }

  void showLanguageSelectionDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return LanguageSelectionDialog(languageProvider: languageProvider);
      },
    );
  }
}