import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/domain/services/user_service.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileImageScreen extends StatelessWidget {
  const ProfileImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: const ProfileImageContent(),
    );
  }
}

class ProfileImageContent extends StatefulWidget {
  const ProfileImageContent({super.key});

  @override
  State<ProfileImageContent> createState() => _ProfileImageContentState();
}

class _ProfileImageContentState extends State<ProfileImageContent> {
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProfileImagePreview(selectedImage: _selectedImage),
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
            // Action buttons
            ProfileImageActions(
              isLoading: _isLoading,
              selectedImage: _selectedImage,
              onPickImage: _pickImage,
              onResetImage: _resetProfileImage,
              onSaveImage: _saveImage,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileImagePreview extends StatelessWidget {
  final XFile? selectedImage;

  const ProfileImagePreview({
    super.key,
    this.selectedImage,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String? currentImageUrl = user?.photoUrl;

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: selectedImage != null
          ? ClipOval(
        child: kIsWeb
            ? Image.network(
          selectedImage!.path,
          fit: BoxFit.cover,
        )
            : Image.file(
          File(selectedImage!.path),
          fit: BoxFit.cover,
        ),
      )
          : ClipOval(
        child: currentImageUrl != null && currentImageUrl.isNotEmpty
            ? Image.network(
          currentImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
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
          color:
          Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }
}

class ProfileImageActions extends StatelessWidget {
  final bool isLoading;
  final XFile? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onResetImage;
  final VoidCallback onSaveImage;

  const ProfileImageActions({
    super.key,
    required this.isLoading,
    this.selectedImage,
    required this.onPickImage,
    required this.onResetImage,
    required this.onSaveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Select new image button
        OutlinedButton(
          onPressed: isLoading ? null : onPickImage,
          child: Text(tr(context, 'profileImage.selectNew')),
        ),
        const SizedBox(height: 12),
        // Reset image button
        OutlinedButton(
          onPressed: isLoading ? null : onResetImage,
          child: Text(tr(context, 'profileImage.reset')),
        ),
        const SizedBox(height: 12),
        // Save button
        FilledButton(
          onPressed: isLoading || selectedImage == null ? null : onSaveImage,
          child: isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(tr(context, 'profileImage.save')),
        ),
      ],
    );
  }
}