import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/presentation/common/widgets/profile_image_dialog.dart';
import 'package:frontend/presentation/common/widgets/settings_dialog.dart';
import 'package:frontend/presentation/common/widgets/user_actions_dialog.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:frontend/presentation/state/providers/theme_provider.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../domain/services/user_service.dart';

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

  void showProfileImageDialog(BuildContext context, {bool isMobile = false}) {
    if (isMobile) {
      // Full page profile image dialog for mobile
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => mobileProfileImageDialog(context),
        ),
      );
    } else {
      // Dialog for desktop/tablet
      showDialog(
        context: context,
        builder:
            (context) => ProfileImageDialog(
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
            leading: const Icon(Icons.account_circle),
            title: Text(tr(context, 'profileImage.title')),
            onTap: () {
              Navigator.pop(context);
              showProfileImageDialog(context, isMobile: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(tr(context, 'settings.title')),
            onTap: () {
              Navigator.pop(context);
              showSettingsDialog(context, isMobile: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              tr(context, 'settings.logout'),
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              await Provider.of<UserProvider>(
                context,
                listen: false,
              ).logoutUser();
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

  // Mobile implementation of profile image dialog
  Scaffold mobileProfileImageDialog(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'profileImage.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          _ProfileImageContent(), // Extract content to a separate widget to avoid duplication
    );
  }
}

// Extracted widget for the mobile profile image screen
class _ProfileImageContent extends StatefulWidget {
  @override
  State<_ProfileImageContent> createState() => _ProfileImageContentState();
}

class _ProfileImageContentState extends State<_ProfileImageContent> {
  XFile? _selectedImage;
  bool _isLoading = false;
  String? _error;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = tr(context, 'profileImage.pickError');
      });
    }
  }

  Future<void> _saveImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Upload the image
      await userService.updateProfileImage(_selectedImage!);

      // Refresh user data to get the updated profile URL
      await userProvider.initializeUser();

      // If we get here, the upload was successful
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog after successful upload
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _resetProfileImage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Reset the profile image
      await userService.resetProfileImage();

      // Refresh user data to get the updated profile
      await userProvider.initializeUser();

      // If we get here, the reset was successful
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog after successful reset
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String? currentImageUrl = user?.photoUrl;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image preview
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child:
                  _selectedImage != null
                      ? ClipOval(
                        child:
                            kIsWeb
                                ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                                : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                      )
                      : ClipOval(
                        child:
                            currentImageUrl != null &&
                                    currentImageUrl.isNotEmpty
                                ? Image.network(
                                  currentImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                )
                                : Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                                ),
                      ),
            ),
            const SizedBox(height: 24),
            // Error message if any
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            // Select new image button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _pickImage,
                child: Text(tr(context, 'profileImage.selectNew')),
              ),
            ),
            const SizedBox(height: 12),
            // Reset image button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _resetProfileImage,
                child: Text(tr(context, 'profileImage.reset')),
              ),
            ),
            const SizedBox(height: 12),
            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    _isLoading || _selectedImage == null ? null : _saveImage,
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(tr(context, 'profileImage.save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
