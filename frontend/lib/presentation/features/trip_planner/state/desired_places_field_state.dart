import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../data/api/api_client.dart';

//TODO: currently user can add desired places from all over the world (
// it should depend on the selected destination)
class DesiredPlacesFieldState extends ChangeNotifier {
  // State variables
  final List<String> _desiredPlaces = [];
  String? _currentDesiredPlaceQuery;
  Iterable<String> _lastDesiredPlaceOptions = const <String>[];
  late final Debounceable<Iterable<String>?, String>
  _debouncedDesiredPlacesSearch;
  final TextEditingController textController = TextEditingController();
  static const int _minSearchLength = 3;
  // Destination dependency
  String? _currentDestination;

  // ApiClient instance
  final ApiClient apiClient;

  // Getters
  List<String> get desiredPlaces => List.unmodifiable(_desiredPlaces);
  bool get hasPlaces => _desiredPlaces.isNotEmpty;
  bool get isEnabled => _currentDestination != null;

  // Language function
  final String Function() getCurrentLanguage;

  // Event callbacks
  Function(List<String>)? onPlacesChanged;

  // Constructor
  DesiredPlacesFieldState({
    required this.getCurrentLanguage,
    required this.apiClient,
    this.onPlacesChanged,
    String? initialDestination,
    List<String>? initialPlaces,
  }) {
    _currentDestination = initialDestination;

    if (initialPlaces != null) {
      _desiredPlaces.addAll(initialPlaces);
    }

    _debouncedDesiredPlacesSearch =
        Debouncer.debounce<Iterable<String>?, String>(
          _searchDesiredPlaces,
          duration: const Duration(milliseconds: 300),
        );
  }

  String _sanitizeQuery(String query) {
    // Keep only alphanumeric chars, spaces and simple punctuation
    final sanitized = query.replaceAll(RegExp(r'[^\w\s.,\-]'), '');
    return sanitized.trim();
  }

  Future<Iterable<String>?> _searchDesiredPlaces(String query) async {
    if (query.isEmpty) return const Iterable<String>.empty();

    // Sanitize the query
    final sanitizedQuery = _sanitizeQuery(query);
    if (sanitizedQuery.isEmpty) return const Iterable<String>.empty();
    if (sanitizedQuery.length < _minSearchLength) {
      return const Iterable<String>.empty();
    }
    _currentDesiredPlaceQuery = sanitizedQuery;

    try {
      final language = getCurrentLanguage();

      // Use apiClient.dio directly with the full URL and query parameters
      final url = '/api/autocomplete/proxy';
      final queryParams = {
        'input': '$sanitizedQuery in $_currentDestination',
        'types': 'establishment',
        'language': language,
      };

      final response = await apiClient.dio.get(
        url,
        queryParameters: queryParams,
      );

      // If another search happened after this one, discard these results
      if (_currentDesiredPlaceQuery != sanitizedQuery) {
        return null;
      }
      _currentDesiredPlaceQuery = null;

      return _processApiResponse(response);
    } catch (error) {
      debugPrint('Error searching desired places: $error');
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
  Future<Iterable<String>> desiredPlacesOptionsBuilder(
    TextEditingValue textEditingValue,
  ) async {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<String>.empty();
    }

    if (_currentDestination == null) {
      return const <String>["Please select a destination first"];
    }

    final Iterable<String>? options = await _debouncedDesiredPlacesSearch(
      textEditingValue.text,
    );
    if (options == null) {
      return _lastDesiredPlaceOptions;
    }
    _lastDesiredPlaceOptions = options;
    return options;
  }

  void onDesiredPlaceSelected(String selection) {
    if (selection != "Please select a destination first") {
      if (!_desiredPlaces.contains(selection)) {
        _desiredPlaces.add(selection);

        // First notify listeners to update UI
        notifyListeners();

        // Then notify parent after the current build cycle completes
        _notifyParent();

        debugPrint('Added desired place: $selection');
      }
      // Clear the field after selection
      textController.clear();
    }
  }

  void removePlace(String place) {
    if (_desiredPlaces.contains(place)) {
      _desiredPlaces.remove(place);

      // First notify listeners to update UI
      notifyListeners();

      // Then notify parent after the current build cycle completes
      _notifyParent();
    }
  }

  void removePlaceAt(int index) {
    if (index >= 0 && index < _desiredPlaces.length) {
      _desiredPlaces.removeAt(index);

      // First notify listeners to update UI
      notifyListeners();

      // Then notify parent after the current build cycle completes
      _notifyParent();
    }
  }

  void updateDestination(String? newDestination) {
    if (newDestination != _currentDestination) {
      _currentDestination = newDestination;
      // Clear places when destination changes
      _desiredPlaces.clear();
      textController.clear();

      // First notify listeners to update UI
      notifyListeners();

      // Then notify parent after the current build cycle completes
      _notifyParent();
    }
  }

  void updateCallback(Function(List<String>)? newCallback) {
    onPlacesChanged = newCallback;
  }

  void clearPlaces() {
    if (_desiredPlaces.isNotEmpty) {
      _desiredPlaces.clear();

      // First notify listeners to update UI
      notifyListeners();

      // Then notify parent after the current build cycle completes
      _notifyParent();
    }
  }

  // Separate method to notify parent on next frame
  void _notifyParent() {
    if (onPlacesChanged != null) {
      // Use a microtask to ensure this happens after the current build cycle
      Future.microtask(() {
        onPlacesChanged!(_desiredPlaces);
      });
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
