import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/domain/services/user_service.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';

class ProfileManagementState extends ChangeNotifier {
  final UserService userService;
  final UserProvider userProvider;

  ProfileManagementState({
    required this.userService,
    required this.userProvider,
  }) {
    final user = userProvider.user;
    if (user != null) {
      _originalUsername = user.username;
      usernameController.text = user.username;
    } else {
      _originalUsername = '';
    }
  }
  XFile? selectedImage;
  bool isLoading = false;
  String? error;
  String? success;

  // Controllers for form fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Form keys for validation
  final GlobalKey<FormState> usernameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  int selectedTabIndex = 0;
  late String _originalUsername;

  void setTab(int index) {
    selectedTabIndex = index;
    error = null;
    success = null;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        selectedImage = image;
        error = null;
        notifyListeners();
      }
    } catch (e) {
      error = 'profileSettings.image.pickError';
      notifyListeners();
    }
  }

  Future<void> saveImage() async {
    if (selectedImage == null) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await userService.updateProfileImage(selectedImage!);
      await userProvider.initializeUser();
      isLoading = false;
      success = 'profileSettings.image.updateSuccess';
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetProfileImage() async {
    isLoading = true;
    error = null;
    selectedImage = null;
    notifyListeners();

    try {
      await userService.resetProfileImage();
      await userProvider.initializeUser();
      isLoading = false;
      success = 'profileSettings.image.resetSuccess';
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUsername() async {
    if (usernameFormKey.currentState?.validate() != true) return;
    isLoading = true;
    error = null;
    success = null;
    notifyListeners();

    try {
      await userService.updateUsername(usernameController.text.trim());
      await userProvider.initializeUser();
      isLoading = false;
      selectedImage = null;
      success = 'profileSettings.username.updateSuccess';
      _originalUsername = usernameController.text.trim();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePassword() async {
    if (passwordFormKey.currentState?.validate() != true) return;
    isLoading = true;
    error = null;
    success = null;
    notifyListeners();

    try {
      await userService.updatePassword(
        currentPasswordController.text,
        newPasswordController.text,
      );
      isLoading = false;
      success = 'profileSettings.password.updateSuccess';
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      notifyListeners();
    } on DioError catch (e) {
      // DioError is thrown for HTTP errors
      if (e.response?.statusCode == 400) {
        error =
            'profileSettings.password.wrongCurrent'; // <-- Add this key to your translations
      } else {
        error = e.toString();
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  String? validateUsername(
    String? value,
    BuildContext context,
    String Function(BuildContext, String) tr,
  ) {
    if (value == null || value.trim().isEmpty) {
      return tr(context, 'profileSettings.username.required');
    }
    if (value.length < 3) {
      return tr(context, 'profileSettings.username.tooShort');
    }
    if (value.length > 20) {
      return tr(context, 'profileSettings.username.tooLong');
    }
    if (value.trim() == _originalUsername) {
      return tr(context, 'profileSettings.username.noChange');
    }
    return null;
  }

  String? validateCurrentPassword(
    String? value,
    BuildContext context,
    String Function(BuildContext, String) tr,
  ) {
    if (value == null || value.isEmpty) {
      return tr(context, 'profileSettings.password.currentRequired');
    }
    return null;
  }

  String? validateNewPassword(
    String? value,
    BuildContext context,
    String Function(BuildContext, String) tr,
  ) {
    if (value == null || value.isEmpty) {
      return tr(context, 'profileSettings.password.newRequired');
    }
    if (value.length < 8) {
      return tr(context, 'profileSettings.password.tooShort');
    }
    return null;
  }

  String? validateConfirmPassword(
    String? value,
    BuildContext context,
    String Function(BuildContext, String) tr,
  ) {
    if (value == null || value.isEmpty) {
      return tr(context, 'profileSettings.password.confirmRequired');
    }
    if (value != newPasswordController.text) {
      return tr(context, 'profileSettings.password.mismatch');
    }
    return null;
  }
}
