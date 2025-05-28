import 'package:flutter/material.dart';
import 'package:frontend/domain/models/user.dart';
import 'package:frontend/domain/services/user_service.dart';
import 'package:frontend/domain/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final UserService userService;
  final AuthService authService; // Add AuthService directly

  // State variables for UI updates
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false; // Add explicit auth tracking

  UserProvider({required this.userService, required this.authService}) {
    // No initialization here - it will be done by the splash screen
  }

  // Getters for UI state
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => userService.currentUser;
  bool get isAuthenticated => _isAuthenticated;

  // Refresh user data
  Future<void> initializeUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await userService.initializeUser();
      _isAuthenticated = userService.isAuthenticated;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Logout user - improved version
  Future<void> logoutUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First, set auth state to false and clear user to trigger router

      _isAuthenticated = false;
      userService.clearUser(); // You'll need to add this method

      // Notify listeners BEFORE token clearing to ensure router responds
      notifyListeners();

      // Then perform actual logout with token clearing
      await authService.logout();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void updateAuthState(bool isAuthenticated) {
    if (_isAuthenticated != isAuthenticated) {
      _isAuthenticated = isAuthenticated;
      notifyListeners();
    }
  }
}
