import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/common/widgets/action_item.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:frontend/core/utils/translation_helper.dart';

class UserActionsDialog extends StatelessWidget {
  final VoidCallback onSettingsPressed;

  const UserActionsDialog({Key? key, required this.onSettingsPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final double maxWidth = size.width * 0.9;
    final double maxHeight = size.height * 0.8;

    return Dialog(
      // Constrain dialog size
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.05,
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        width: min(400, maxWidth), // Fixed width with max limit
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final user = userProvider.user;

            // Use default values if user is not loaded yet
            final username = user?.username ?? 'Username';
            final email = user?.email ?? 'example@example.com';
            final imageUrl =
                user?.photoUrl.isNotEmpty == true ? user!.photoUrl : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            imageUrl != null ? NetworkImage(imageUrl) : null,
                        child:
                            imageUrl == null
                                ? const Icon(
                                  Icons.person,
                                  size: 24,
                                  color: Colors.grey,
                                )
                                : null,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                email,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ActionItem(
                            icon: Icons.settings,
                            text: tr(context, 'settings.title'),
                            onTap: () {
                              Navigator.pop(context);
                              onSettingsPressed();
                            },
                          ),
                          const SizedBox(height: 16),
                          ActionItem(
                            icon: Icons.logout,
                            text: tr(context, 'settings.logout'),
                            color: Colors.red,
                            onTap: () async {
                              Navigator.pop(context);

                              // Use userProvider to access user service for logout
                              userProvider.userService.clearUser();

                              if (context.mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/signin',
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
