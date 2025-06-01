import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    try {
      final prefs = await SharedPreferences.getInstance();

      // First check if there's a saved preference
      final savedLanguage = prefs.getString('language');

      if (savedLanguage != null) {
        // Use saved preference
        await setLanguage(savedLanguage);
      } else {
        // Use system locale, defaulting to 'en' if can't detect
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        final languageCode = systemLocale.languageCode;

        // Check if we support this language
        if (['en', 'pl'].contains(languageCode)) {
          await setLanguage(languageCode);
        } else {
          await setLanguage('en'); // Default to English
        }
      }
      // Initialize Google Maps for Flutter Web
    } catch (e) {
      print('Error initializing language: $e');
      // Fallback to English on error
      await setLanguage('en');
    }
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
    String languageFile = 'assets/translations/${languageCode}.json';
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
