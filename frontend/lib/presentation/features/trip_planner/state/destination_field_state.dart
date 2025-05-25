import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/api/api_client.dart';

class DestinationFieldState extends ChangeNotifier {
  // State variables
  String? _selectedDestination;
  String? _currentDestinationQuery;
  Iterable<String> _lastDestinationOptions = const <String>[];
  late final Debounceable<Iterable<String>?, String>
  _debouncedDestinationSearch;

  // ApiClient instance
  final ApiClient apiClient;

  // Getters
  String? get selectedDestination => _selectedDestination;
  Iterable<String> get lastDestinationOptions => _lastDestinationOptions;

  // Language function
  final String Function() getCurrentLanguage;

  // Event callback
  final Function(String?)? onDestinationChanged;

  // Constructor
  DestinationFieldState({
    required this.getCurrentLanguage,
    required this.apiClient,
    this.onDestinationChanged,
  }) {
    _debouncedDestinationSearch = Debouncer.debounce<Iterable<String>?, String>(
      _searchPlaces,
      duration: const Duration(milliseconds: 300),
    );
  }

  // API interaction methods
  String _sanitizeQuery(String query) {
    // Keep only alphanumeric chars, spaces and simple punctuation
    final sanitized = query.replaceAll(RegExp(r'[^\w\s.,\-]'), '');
    return sanitized.trim();
  }

  Future<Iterable<String>?> _searchPlaces(String query) async {
    if (query.isEmpty) return const Iterable<String>.empty();

    // Sanitize the query
    final sanitizedQuery = _sanitizeQuery(query);
    if (sanitizedQuery.isEmpty) return const Iterable<String>.empty();

    _currentDestinationQuery = sanitizedQuery;

    try {
      // Get the current language from the provider
      final language = getCurrentLanguage();

      // Use apiClient.dio directly with the full URL and query parameters
      final url = 'api/autocomplete/proxy';
      final queryParams = {
        'input': sanitizedQuery,
        'types': '(cities)',
        'language': language,
      };

      final response = await apiClient.dio.get(
        url,
        queryParameters: queryParams,
      );

      // If another search happened after this one, discard these results
      if (_currentDestinationQuery != sanitizedQuery) {
        return null;
      }
      _currentDestinationQuery = null;

      return _processApiResponse(response);
    } catch (error) {
      debugPrint('Error searching places: $error');
      return const Iterable<String>.empty();
    }
  }

  Iterable<String> _processApiResponse(Response response) {
    if (response.statusCode != 200) {
      debugPrint('API request failed with status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      return const Iterable<String>.empty();
    }

    if (response.data['predictions'] != null) {
      final predictions = response.data['predictions'] as List;
      if (predictions.isEmpty) {
        return const Iterable<String>.empty();
      }
      return predictions
          .map<String>((prediction) => prediction['description'] as String)
          .toList();
    } else {
      debugPrint('No predictions in response: ${response.data}');
      return const Iterable<String>.empty();
    }
  }

  // Public methods
  Future<Iterable<String>> destinationOptionsBuilder(
    TextEditingValue textEditingValue,
  ) async {
    if (textEditingValue.text.isEmpty) {
      clearDestination();
      return const Iterable<String>.empty();
    }

    final Iterable<String>? options = await _debouncedDestinationSearch(
      textEditingValue.text,
    );
    if (options == null) {
      return _lastDestinationOptions;
    }
    _lastDestinationOptions = options;
    return options;
  }

  void onDestinationSelected(String selection) {
    if (_selectedDestination != selection) {
      _selectedDestination = selection;
      debugPrint('Selected destination: $selection');

      if (onDestinationChanged != null) {
        onDestinationChanged!(_selectedDestination);
      }

      notifyListeners();
    }
  }

  void handleDestinationFieldChange(String value) {
    if (value.isEmpty && _selectedDestination != null) {
      clearDestination();
    }
  }

  void clearDestination() {
    if (_selectedDestination != null) {
      _selectedDestination = null;
      if (onDestinationChanged != null) {
        onDestinationChanged!(null);
      }
      notifyListeners();
      debugPrint('Destination cleared');
    }
  }
}
