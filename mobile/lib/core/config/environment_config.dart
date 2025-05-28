import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  static const String _defaultBaseUrl = 'http://localhost:8080/';

  static String get baseUrl {
    // First try to get from dotenv
    final envValue = dotenv.env['API_BASE_URL'];
    if (envValue != null && envValue.isNotEmpty) {
      return envValue;
    }

    // Fall back to compile-time default
    return _defaultBaseUrl;
  }
}