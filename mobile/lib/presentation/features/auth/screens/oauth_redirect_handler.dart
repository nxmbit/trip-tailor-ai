import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/domain/services/auth_service.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:frontend/core/utils/translation_helper.dart';

class OAuthRedirectHandler extends StatefulWidget {
  const OAuthRedirectHandler({Key? key}) : super(key: key);

  @override
  State<OAuthRedirectHandler> createState() => _OAuthRedirectHandlerState();
}

class _OAuthRedirectHandlerState extends State<OAuthRedirectHandler> {
  bool _isProcessing = true;
  String? _message; // Make nullable to prevent initialization errors
  bool _navigating = false; // Add flag to prevent multiple navigations

  @override
  void initState() {
    super.initState();

    // Delay to ensure providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _message = tr(context, 'oauth.processingMessage');
        });
        _processOAuthRedirect();
      }
    });
  }

  Future<void> _processOAuthRedirect() async {
    if (!mounted) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Get the current route information from GoRouter
      final GoRouterState state = GoRouterState.of(context);
      final Map<String, String> queryParams = state.uri.queryParameters;

      // Extract only the refresh token from query parameters
      final String? refreshToken = queryParams['refresh_token'];

      if (refreshToken != null) {
        // Use AuthService to exchange refresh token for JWT token pair
        final success = await authService.handleOAuthRefreshToken(refreshToken);

        if (success) {
          setState(() {
            _message = tr(context, 'oauth.successMessage');
          });

          // Refresh user data after successful authentication
          await userProvider.initializeUser();

          if (mounted && !_navigating) {
            _navigating = true;
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) context.go('/home');
            });
          }
        } else {
          setState(() {
            _isProcessing = false;
            _message = tr(context, 'oauth.failedMessage');
          });
        }
      } else {
        setState(() {
          _isProcessing = false;
          _message = tr(context, 'oauth.failedMessage');
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _message = "${tr(context, 'oauth.errorMessage')} $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              // Use null coalescing to provide a default value
              _message ?? tr(context, 'oauth.processingMessage'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            if (!_isProcessing)
              ElevatedButton(
                onPressed: () {
                  if (!_navigating) {
                    _navigating = true;
                    context.go('/signin');
                  }
                },
                child: Text(tr(context, 'oauth.returnToLogin')),
              ),
          ],
        ),
      ),
    );
  }
}
