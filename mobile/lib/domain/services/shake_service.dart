import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/app/router.dart';

class ShakeService {
  static const platform = MethodChannel('com.nxmbit_xq100sh.frontend/shake_detector');
  static ShakeService? _instance;

  // Private constructor
  ShakeService._internal() {
    _setupMethodCallHandler();
  }

  // Factory constructor
  factory ShakeService.initialize() {
    _instance ??= ShakeService._internal();
    return _instance!;
  }

  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      debugPrint("Method call received: ${call.method}");
      if (call.method == 'onShakeDetected') {
        _navigateToNearbyPlaces();
      }
      return null;
    });
  }

  void _navigateToNearbyPlaces() {
    debugPrint("Navigating to nearby places from shake");
    // Use the navigatorKey to navigate
    if (navigatorKey.currentContext != null) {
      GoRouter.of(navigatorKey.currentContext!).go('/nearby-places');
    } else {
      debugPrint("Cannot navigate: no valid context");
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    platform.setMethodCallHandler(null);
    _instance = null;
  }
}