import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/translation_helper.dart';
import '../../../../domain/services/auth_service.dart';

//TODO: possibly make it be shown only when the app is loading
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    // Give the splash screen time to be visible
    await Future.delayed(const Duration(seconds: 1));

    // Get the current URL path from the browser with hash-routing support
    String path = '';
    try {
      // Get the full URL from Uri.base
      final Uri uri = Uri.parse(Uri.base.toString());

      // For hash-based routing, we need to check the fragment
      if (uri.hasFragment) {
        path = uri.fragment;
        debugPrint('Extracted path from fragment: $path');
      } else {
        path = uri.path;
        debugPrint('Extracted path from URI path: $path');
      }

      // Debug print to see what's happening
      debugPrint('Current URL: ${Uri.base.toString()}');

      // Ensure path starts with / for consistency with route names
      if (!path.startsWith('/') && path.isNotEmpty) {
        path = '/$path';
        debugPrint('Added leading slash: $path');
      }

      // Normalize the path (remove trailing slash except for root path)
      if (path.endsWith('/') && path.length > 1) {
        path = path.substring(0, path.length - 1);
        debugPrint('Normalized path: $path');
      }
    } catch (e) {
      debugPrint('Error extracting path: $e');
    }

    // Get valid routes that require authentication
    final validSecureRoutes = ['/home', '/trip-planner', '/your-trips'];

    // Check if extracted path matches any of our routes (with more detailed logging)
    debugPrint(
      'Path: "$path", isEmpty: ${path.isEmpty}, isRoot: ${path == '/'}',
    );
    for (final route in validSecureRoutes) {
      debugPrint('Checking if path matches $route: ${path == route}');
    }

    // Determine target route based on current path
    String targetRoute = '/home'; // Default route
    if (path.isNotEmpty && path != '/' && validSecureRoutes.contains(path)) {
      targetRoute = path;
      debugPrint('Using current path as target: $targetRoute');
    } else {
      // See if path contains any of our routes (for nested URLs)
      for (final route in validSecureRoutes) {
        if (path.contains(route)) {
          targetRoute = route;
          debugPrint('Found matching route in path: $targetRoute');
          break;
        }
      }
      debugPrint('Using target route: $targetRoute');
    }

    // Check if user is authenticated
    final isAuthenticated = await authService.isAuthenticated();

    if (mounted) {
      debugPrint('Authentication status: $isAuthenticated');
      debugPrint(
        'Navigating to: ${isAuthenticated ? targetRoute : '/welcome'}',
      );

      if (isAuthenticated) {
        Navigator.of(context).pushReplacementNamed(targetRoute);
      } else {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr(context, 'app.title'),
              style: textTheme.displayLarge?.copyWith(
                color: colorScheme.primary,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
