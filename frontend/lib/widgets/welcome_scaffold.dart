import 'package:flutter/material.dart';

class WelcomeScaffold extends StatelessWidget {
  const WelcomeScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Stack(children: [SafeArea(child: child)]),
    );
  }
}
