import 'package:flutter/material.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:provider/provider.dart';

String tr(BuildContext context, String key) {
  final languageProvider = Provider.of<LanguageProvider>(
    context,
    listen: false,
  );
  return languageProvider.translate(key);
}
