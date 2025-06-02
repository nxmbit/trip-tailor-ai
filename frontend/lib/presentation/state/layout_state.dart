import 'package:flutter/material.dart';
import 'package:frontend/presentation/common/widgets/mobile/mobile_actions_dialog.dart';
import 'package:frontend/presentation/common/widgets/tablet_desktop/profile_management_dialog.dart';
import 'package:frontend/presentation/common/widgets/tablet_desktop/settings_dialog.dart';
import 'package:frontend/presentation/common/widgets/tablet_desktop/user_actions_dialog.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../common/widgets/mobile/mobile_profile_management_dialog.dart';
import '../common/widgets/mobile/mobile_settings_dialog.dart';

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

  // Dialog/Sheet handling for user actions
  void showActionsDialog(BuildContext context, {bool isMobile = false}) {
    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return MobileActionsDialog(
            onProfileImage: () {
              Navigator.pop(context);
              showProfileImageDialog(context, isMobile: true);
            },
            onSettings: () {
              Navigator.pop(context);
              showSettingsDialog(context, isMobile: true);
            },
            onLogout: () async {
              context.pop();
              await Provider.of<UserProvider>(
                context,
                listen: false,
              ).logoutUser();
            },
          );
        },
      );
    } else {
      // For desktop/tablet, show dialog
      showDialog(
        context: context,
        builder:
            (context) => UserActionsDialog(
              onSettingsPressed: () {
                showSettingsDialog(context);
              },
              onProfileImagePressed: () {
                showProfileImageDialog(context);
              },
            ),
      );
    }
  }

  void showSettingsDialog(BuildContext context, {bool isMobile = false}) {
    if (isMobile) {
      // Full page settings for mobile
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const MobileSettings()));
    } else {
      // Dialog for desktop/tablet
      showDialog(
        context: context,
        builder:
            (context) => SettingsDialog(
              onBackPressed: () {
                Navigator.pop(context);
                showActionsDialog(context);
              },
            ),
      );
    }
  }

  void showProfileImageDialog(BuildContext context, {bool isMobile = false}) {
    if (isMobile) {
      // Full page profile image dialog for mobile
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MobileProfileImageScreen(),
        ),
      );
    } else {
      // Dialog for desktop/tablet
      showDialog(
        context: context,
        builder:
            (context) => ProfileDialog(
              onBackPressed: () {
                Navigator.pop(context);
                showActionsDialog(context);
              },
            ),
      );
    }
  }
}
