import 'package:flutter/material.dart';

class AppColors {
  static const seedColor = Color.fromARGB(255, 2, 136, 46); // Indigo

  static final lightColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  static final darkColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );
}
