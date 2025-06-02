import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import '../../state/profile_management_state.dart';

class ProfileImageTab extends StatelessWidget {
  final ProfileManagementState state;
  const ProfileImageTab({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final user = state.userProvider.user;
    final String? currentImageUrl = user?.photoUrl;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  state.selectedImage != null
                      ? ClipOval(
                        child:
                            kIsWeb
                                ? Image.network(
                                  state.selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                                : Image.file(
                                  File(state.selectedImage!.path),
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
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: state.isLoading ? null : state.pickImage,
                child: Text(tr(context, 'profileSettings.image.selectNew')),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: state.isLoading ? null : state.resetProfileImage,
                child: Text(tr(context, 'profileSettings.image.reset')),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    state.isLoading || state.selectedImage == null
                        ? null
                        : state.saveImage,
                child:
                    state.isLoading && state.selectedTabIndex == 0
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(tr(context, 'profileSettings.image.save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
