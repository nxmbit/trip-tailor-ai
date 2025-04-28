import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  // Default language
  Locale _locale = Locale(
    WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );
  Map<String, dynamic> _translations = {};
  bool _isLoaded = false;

  Locale get locale => _locale;
  bool get isLoaded => _isLoaded;

  // Initialize from saved preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language') ?? 'en';
    await setLanguage(savedLanguage);
  }

  // Inside your LanguageProvider class
  String translate(String key) {
    if (!_isLoaded) return key;

    // Handle nested paths using dot notation
    final List<String> keys = key.split('.');
    dynamic value = _translations;

    for (String k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Key not found, return the original key
      }
    }

    return value is String ? value : key;
  }

  // Change language
  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _locale.languageCode && _isLoaded) return; // No change
    // Load the translations
    String languageFile = 'translations/${languageCode}.json';
    String jsonString = await rootBundle.loadString(languageFile);
    _translations = json.decode(jsonString);

    // Update locale
    _locale = Locale(languageCode, languageCode == 'en' ? 'US' : 'PL');
    _isLoaded = true;

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);

    notifyListeners();
  }
}
