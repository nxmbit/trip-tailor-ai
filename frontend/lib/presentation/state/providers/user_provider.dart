import 'package:flutter/material.dart';
import 'package:frontend/domain/models/user.dart';
import 'package:frontend/domain/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService userService;

  // State variables for UI updates
  bool _isLoading = false;
  String? _error;

  UserProvider({required this.userService}) {
    // Initialize user data when provider is created
    // _initializeUser();
  }

  // Getters for UI state
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => userService.currentUser;
  bool get isAuthenticated => userService.isAuthenticated;

  // Refresh user data
  Future<void> initializeUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await userService.initializeUser();
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
}
