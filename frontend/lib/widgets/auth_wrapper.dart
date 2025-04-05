import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;
  final AuthService authService;

  const AuthWrapper({
    super.key,
    required this.child,
    required this.authService,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late StreamSubscription<void> _logoutSubscription;

  @override
  void initState() {
    super.initState();
    _logoutSubscription = widget.authService.onLogout.listen((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please login again.')),
        );
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    });
  }

  @override
  void dispose() {
    _logoutSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
