import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:frontend/presentation/common/widgets/settings_dialog.dart';
import 'package:frontend/presentation/common/widgets/user_actions_dialog.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:frontend/presentation/state/providers/theme_provider.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:provider/provider.dart';

class LayoutState {
  // Navigation state
  int currentIndex = 0;

  // For tracking current route for navigation indicators
  void updateSelectedIndexFromRoute(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '';

    if (route.startsWith('/home')) {
      currentIndex = 0;
    } else if (route.startsWith('/trip-planner')) {
      currentIndex = 1;
    } else if (route.startsWith('/your-trips')) {
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
      Navigator.pushReplacementNamed(context, route);
    }
  }

  // Dialog/Sheet handling for user actions
  void showActionsDialog(BuildContext context, {bool isMobile = false}) {
    if (isMobile) {
      // For mobile, show bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return mobileActionsDialog(context);
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
            ),
      );
    }
  }

  void showSettingsDialog(BuildContext context, {bool isMobile = false}) {
    if (isMobile) {
      // Full page settings for mobile
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => mobileSettingsDialog(context)),
      );
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

  void _showLanguageSelectionDialog(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'pl', 'name': 'Polski', 'flag': '🇵🇱'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      tr(context, 'settings.language'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final bool isSelected =
                      language['code'] == languageProvider.locale.languageCode;

                  return ListTile(
                    leading: Text(
                      language['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(language['name']!),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                            : null,
                    onTap: () {
                      languageProvider.setLanguage(language['code']!);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Padding mobileActionsDialog(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final user = userProvider.user;
              final username = user?.username ?? 'Username';
              final email = user?.email ?? 'example@example.com';
              final imageUrl =
                  user?.photoUrl.isNotEmpty == true ? user!.photoUrl : null;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      imageUrl != null ? NetworkImage(imageUrl) : null,
                  child:
                      imageUrl == null
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                ),
                title: Text(username),
                subtitle: Text(email),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(tr(context, 'settings.title')),
            onTap: () {
              showSettingsDialog(context, isMobile: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              tr(context, 'settings.logout'),
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              // Get services from provider
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );

              // Perform logout
              authService.logout();
              userProvider.userService.clearUser();

              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/signin', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Scaffold mobileSettingsDialog(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'settings.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme toggle
            Consumer<ThemeProvider>(
              builder:
                  (context, themeProvider, _) => SwitchListTile(
                    title: Text(tr(context, 'settings.mobileDarkMode')),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(value),
                  ),
            ),
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, _) {
                final currentLanguage =
                    languageProvider.locale.languageCode == 'pl'
                        ? 'Polski'
                        : 'English';
                return ListTile(
                  title: Text(tr(context, 'settings.language')),
                  subtitle: Text(
                    currentLanguage,
                  ), // Show current language as subtitle
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showLanguageSelectionDialog(context, languageProvider);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
