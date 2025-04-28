import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/domain/models/user.dart';

class UserService {
  final UserRepository _userRepository;
  User? _currentUser;

  UserService(this._userRepository);

  // Public getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Initialize user data
  Future<void> initializeUser() async {
    try {
      _currentUser = await _userRepository.getCurrentUser();
    } catch (e) {
      print('Error initializing user: $e');
      _currentUser = null;
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      _currentUser = await _userRepository.getCurrentUser();
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  // Clear user data (for logout)
  void clearUser() {
    _currentUser = null;
  }
}
