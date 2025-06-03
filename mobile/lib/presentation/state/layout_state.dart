import 'package:flutter/material.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../common/widgets/mobile_actions_dialog.dart';
import '../common/widgets/mobile_settings.dart';
import '../common/widgets/mobile_profile_management_screen.dart';

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
  void showActionsDialog(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return MobileActionsDialog(
            onProfileImage: () {
              Navigator.pop(context);
              showProfileImageDialog(context);
            },
            onSettings: () {
              Navigator.pop(context);
              showSettingsDialog(context);
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
  }

  void showSettingsDialog(BuildContext context) {
      // Full page settings for mobile
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const MobileSettings()));

  }

  void showProfileImageDialog(BuildContext context) {
      // Full page profile image dialog for mobile
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MobileProfileManagementScreen(),
        ),
      );

  }
}
