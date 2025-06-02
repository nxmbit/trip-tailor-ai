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
  String? _success;

  // Controllers for form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Form keys for validation
  final _usernameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Tab controller
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Pre-fill the username field with the current username
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      _usernameController.text = userProvider.user!.username;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
        _error = tr(context, 'profileSettings.image.pickError');
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

      setState(() {
        _isLoading = false;
        _success = tr(context, 'profileSettings.image.updateSuccess');
      });
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
      _selectedImage = null; // <-- Add this line to clear the picked image
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Reset the profile image
      await userService.resetProfileImage();

      // Refresh user data to get the updated profile
      await userProvider.initializeUser();

      setState(() {
        _isLoading = false;
        _success = tr(context, 'profileSettings.image.resetSuccess');
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUsername() async {
    if (_usernameFormKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await userService.updateUsername(_usernameController.text.trim());

      // Refresh user data to get the updated username
      await userProvider.initializeUser();

      setState(() {
        _isLoading = false;
        _selectedImage = null; // Clear selected image after update
        _success = tr(context, 'profileSettings.username.updateSuccess');
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePassword() async {
    if (_passwordFormKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);

      await userService.updatePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      setState(() {
        _isLoading = false;
        _success = tr(context, 'profileSettings.password.updateSuccess');
        // Clear password fields after successful update
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Validation for username
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr(context, 'profileSettings.username.required');
    }
    if (value.length < 3) {
      return tr(context, 'profileSettings.username.tooShort');
    }
    if (value.length > 20) {
      return tr(context, 'profileSettings.username.tooLong');
    }
    //if its the same as before
    if (value == _usernameController.text.trim()) {
      return tr(context, 'profileSettings.username.noChange');
    }
    return null;
  }

  // Validation for current password
  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return tr(context, 'profileSettings.password.currentRequired');
    }
    return null;
  }

  // Validation for new password
  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return tr(context, 'profileSettings.password.newRequired');
    }
    if (value.length < 6) {
      return tr(context, 'profileSettings.password.tooShort');
    }
    return null;
  }

  // Validation for confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return tr(context, 'profileSettings.password.confirmRequired');
    }
    if (value != _newPasswordController.text) {
      return tr(context, 'profileSettings.password.mismatch');
    }
    return null;
  }

  Widget _buildProfileImageTab() {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final String? currentImageUrl = user?.photoUrl;

    return SingleChildScrollView(
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

            // Select new image button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _pickImage,
                child: Text(tr(context, 'profileSettings.image.selectNew')),
              ),
            ),
            const SizedBox(height: 12),
            // Reset image button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _resetProfileImage,
                child: Text(tr(context, 'profileSettings.image.reset')),
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
                    _isLoading && _selectedTabIndex == 0
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

  Widget _buildUsernameTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _usernameFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'profileSettings.username.title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(tr(context, 'profileSettings.username.description')),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: tr(context, 'profileSettings.username.label'),
                  border: const OutlineInputBorder(),
                ),
                validator: _validateUsername,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _updateUsername,
                  child:
                      _isLoading && _selectedTabIndex == 1
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(tr(context, 'profileSettings.username.save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'profileSettings.password.title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(tr(context, 'profileSettings.password.description')),
              const SizedBox(height: 24),
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: tr(context, 'profileSettings.password.current'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validateCurrentPassword,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: tr(context, 'profileSettings.password.new'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validateNewPassword,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: tr(context, 'profileSettings.password.confirm'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator: _validateConfirmPassword,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  child:
                      _isLoading && _selectedTabIndex == 2
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(tr(context, 'profileSettings.password.save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: DefaultTabController(
        length: 3,
        initialIndex: _selectedTabIndex,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 320,
            maxWidth: 420,
            minHeight: 0,
            maxHeight: 600,
          ),
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
                          tr(context, 'profileSettings.title'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const Divider(height: 1),
              TabBar(
                onTap: (index) {
                  setState(() {
                    _error = null;
                    _success = null;
                    _selectedTabIndex = index;
                  });
                },
                tabs: [
                  Tab(text: tr(context, 'profileSettings.photoTab')),
                  Tab(text: tr(context, 'profileSettings.usernameTab')),
                  Tab(text: tr(context, 'profileSettings.passwordTab')),
                ],
              ),
              if (_error != null || _success != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      _error != null
                          ? Text(
                            _error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          )
                          : Text(
                            _success!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildProfileImageTab(),
                    _buildUsernameTab(),
                    _buildPasswordTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
