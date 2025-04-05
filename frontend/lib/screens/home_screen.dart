import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await _authService.test();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result ? 'Test successful!' : 'Test failed'),
                    backgroundColor: result ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Test Authentication'),
            ),
          ],
        ),
      ),
    );
  }
}
