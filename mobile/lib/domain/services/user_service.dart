import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/domain/models/user.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class UserService {
  final UserRepository _userRepository;
  final AuthService _authService;
  User? _currentUser;

  UserService(this._userRepository, this._authService);

  // Public getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Refresh user data
  Future<void> initializeUser() async {
    try {
      _currentUser = await _userRepository.getCurrentUser();
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  // Clear user data only (for logout)
  void clearUser() {
    _currentUser = null;
  }

  // Handle complete logout
  Future<void> logoutUser() async {
    _currentUser = null;
    await _authService.logout();
  }

  // Update profile image
  Future<User?> updateProfileImage(XFile imageFile) async {
    final updatedUser = await _userRepository.updateProfileImage(imageFile);
    if (updatedUser != null) {
      _currentUser = updatedUser;
    }
    return _currentUser;
  }

  // Reset profile image to default
  Future<User?> resetProfileImage() async {
    final updatedUser = await _userRepository.resetProfileImage();
    if (updatedUser != null) {
      _currentUser = updatedUser;
    }
    return _currentUser;
  }
}
