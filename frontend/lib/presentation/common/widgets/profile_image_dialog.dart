import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/domain/services/user_service.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileImageDialog extends StatefulWidget {
  final VoidCallback onBackPressed;

  const ProfileImageDialog({Key? key, required this.onBackPressed})
    : super(key: key);

  @override
  State<ProfileImageDialog> createState() => _ProfileImageDialogState();
}

class _ProfileImageDialogState extends State<ProfileImageDialog> {
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
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final double maxWidth = size.width * 0.9;
    final double maxHeight = size.height * 0.8;
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String? currentImageUrl = user?.photoUrl;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.05,
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        width: 400, // Fixed width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: widget.onBackPressed,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        tr(context, 'profileImage.title'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the row
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                                                (context, error, stackTrace) =>
                                                    Icon(
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.5),
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
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
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
                              _isLoading || _selectedImage == null
                                  ? null
                                  : _saveImage,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(tr(context, 'profileImage.save')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
