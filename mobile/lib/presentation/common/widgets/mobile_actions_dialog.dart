import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:frontend/presentation/state/layout_state.dart';
import 'package:provider/provider.dart';

class MobileActionsDialog extends StatelessWidget {
  const MobileActionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutState = LayoutState();

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
              layoutState.showProfileImageDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(tr(context, 'settings.title')),
            onTap: () {
              Navigator.pop(context);
              layoutState.showSettingsDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              tr(context, 'settings.logout'),
              style: const TextStyle(color: Colors.red),
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
}