import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/main_scaffold.dart';

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
      if (!result) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/signin', (route) => false);
      } else {
        _showSnackBar(context, result);
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await _authService.logout(notifyServer: true);
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  }

  Future<void> _handleRefreshToken(BuildContext context) async {
    if (await _authService.refreshTokens() == false && context.mounted) {
      _authService.logout(notifyServer: false);
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/signin', (route) => false);
    } else {
      final token = await _authService.getToken();
      print('New token: $token');
    }
  }

  Future<void> _handleToken(BuildContext context) async {
    await _authService.verifyTokenStorage();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      child: Center(
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
            ElevatedButton(
              onPressed: () => _handleRefreshToken(context),
              child: const Text('Refresh Token'),
            ),
            ElevatedButton(
              onPressed: () => _handleToken(context),
              child: const Text('Verify Token Storage'),
            ),
          ],
        ),
      ),
    );
  }
}
