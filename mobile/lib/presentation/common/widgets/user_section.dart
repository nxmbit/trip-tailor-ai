import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';

class UserSection extends StatelessWidget {
  final VoidCallback onTap;

  const UserSection({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return SizedBox(
            width: 32.0,
            height: 32.0,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
          );
        }
        final user = userProvider.user;

        final imageUrl =
            user?.photoUrl.isNotEmpty == true ? user!.photoUrl : null;

        return InkWell(onTap: onTap, child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child:
          imageUrl == null
              ? const Icon(Icons.person, size: 20, color: Colors.grey)
              : null,
        ));
      },
    );
  }

}
