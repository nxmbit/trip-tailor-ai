import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';

enum UserSectionDisplayMode {
  mobile, // Avatar only
  tablet, // Avatar + Username
  desktop, // Avatar + Username + Email
}

class UserSection extends StatelessWidget {
  final VoidCallback onTap;
  final UserSectionDisplayMode displayMode;

  const UserSection({
    super.key,
    required this.onTap,
    required this.displayMode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return _buildLoadingIndicator(displayMode);
        }
        final user = userProvider.user;

        // Use default values if user is not loaded yet
        final username = user?.username ?? '';
        final email = user?.email ?? '';
        final imageUrl =
            user?.photoUrl.isNotEmpty == true ? user!.photoUrl : null;

        Widget userSection;
        switch (displayMode) {
          case UserSectionDisplayMode.mobile:
            userSection = _buildMobileUserSection(colorScheme, imageUrl);
            break;
          case UserSectionDisplayMode.tablet:
            userSection = _buildTabletUserSection(
              colorScheme,
              username,
              imageUrl,
            );
            break;
          case UserSectionDisplayMode.desktop:
            userSection = _buildDesktopUserSection(
              colorScheme,
              username,
              email,
              imageUrl,
            );
            break;
        }

        return InkWell(onTap: onTap, child: userSection);
      },
    );
  }

  Widget _buildLoadingIndicator(UserSectionDisplayMode mode) {
    // Different sized indicators based on display mode
    double size;
    switch (mode) {
      case UserSectionDisplayMode.mobile:
        size = 32.0; // Circle avatar size
        break;
      case UserSectionDisplayMode.tablet:
        size = 50.0;
        break;
      case UserSectionDisplayMode.desktop:
        size = 60.0;
        break;
    }

    return SizedBox(
      width: size,
      height: size,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
    );
  }

  Widget _buildMobileUserSection(ColorScheme colorScheme, String? imageUrl) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
      child:
          imageUrl == null
              ? const Icon(Icons.person, size: 20, color: Colors.grey)
              : null,
    );
  }

  Widget _buildTabletUserSection(
    ColorScheme colorScheme,
    String username,
    String? imageUrl,
  ) {
    return Row(
      children: [
        // User avatar
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child:
              imageUrl == null
                  ? const Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
        ),
        const SizedBox(width: 8),

        // Username only
        Text(
          username,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),

        // Small dropdown indicator
        const SizedBox(width: 4),
        Icon(Icons.arrow_drop_down, color: colorScheme.onSurface, size: 20),
      ],
    );
  }

  Widget _buildDesktopUserSection(
    ColorScheme colorScheme,
    String username,
    String email,
    String? imageUrl,
  ) {
    return Row(
      children: [
        // User avatar
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child:
              imageUrl == null
                  ? const Icon(Icons.person, size: 24, color: Colors.grey)
                  : null,
        ),
        const SizedBox(width: 12),

        // User info
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              email,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),

        // Dropdown indicator
        const SizedBox(width: 8),
        Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
      ],
    );
  }
}
