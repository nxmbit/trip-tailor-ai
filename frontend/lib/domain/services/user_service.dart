import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/domain/models/user.dart';
import 'package:frontend/domain/services/auth_service.dart';

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
}
