import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/utils/debouncer.dart';

class DestinationFieldState extends ChangeNotifier {
  // State variables
  String? _selectedDestination;
  String? _currentDestinationQuery;
  Iterable<String> _lastDestinationOptions = const <String>[];
  late final Debounceable<Iterable<String>?, String>
  _debouncedDestinationSearch;

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
    this.onDestinationChanged,
  }) {
    _debouncedDestinationSearch = Debouncer.debounce<Iterable<String>?, String>(
      _searchPlaces,
      duration: const Duration(milliseconds: 300),
    );
  }

  // API interaction methods
  Future<Iterable<String>?> _searchPlaces(String query) async {
    _currentDestinationQuery = query;

    try {
      final apiKey = dotenv.env['GOOGLE_PLACES_KEY'] ?? "";
      final dio = Dio();
      dio.options.validateStatus = (status) => true;

      // Get the current language from the provider
      final language = getCurrentLanguage();

      final response = await _makeApiRequest(
        dio: dio,
        apiUrl: 'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParams: {
          'input': query,
          'types': '(cities)',
          'language': language,
          'key': apiKey,
        },
      );

      // If another search happened after this one, discard these results
      if (_currentDestinationQuery != query) {
        return null;
      }
      _currentDestinationQuery = null;

      return _processApiResponse(response);
    } catch (error) {
      debugPrint('Error searching places: $error');
      return const Iterable<String>.empty();
    }
  }

  // The rest of the methods remain the same
  Future<Response> _makeApiRequest({
    required Dio dio,
    required String apiUrl,
    required Map<String, String> queryParams,
  }) async {
    final encodedApiUrl = Uri.encodeComponent(
      '$apiUrl?${_buildQueryString(queryParams)}',
    );
    final proxyUrl = 'https://corsproxy.io/?';
    final fullUrl = '$proxyUrl$encodedApiUrl';

    debugPrint('Requesting: $fullUrl');
    return await dio.get(fullUrl);
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

  String _buildQueryString(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
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
