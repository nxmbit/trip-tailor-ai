import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  HomeScreen({super.key});

  void _showSnackBar(BuildContext context, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Test successful!' : 'Test failed'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _handleTestAuth(BuildContext context) async {
    final result = await _authService.test();
    if (context.mounted) {
      _showSnackBar(context, result);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await _authService.logout();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _handleTestAuth(context),
              child: const Text('Test Authentication'),
            ),
            ElevatedButton(
              onPressed: () => _handleLogout(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
