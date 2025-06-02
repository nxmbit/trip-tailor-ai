import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';

class MobileActionsDialog extends StatelessWidget {
  final VoidCallback onProfileImage;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const MobileActionsDialog({
    super.key,
    required this.onProfileImage,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final username = user?.username ?? 'Username';
    final email = user?.email ?? 'example@example.com';
    final imageUrl = user?.photoUrl.isNotEmpty == true ? user!.photoUrl : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child:
                  imageUrl == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
            ),
            title: Text(username),
            subtitle: Text(email),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(tr(context, 'profileSettings.profile')),
            onTap: onProfileImage,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(tr(context, 'settings.title')),
            onTap: onSettings,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              tr(context, 'settings.logout'),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
