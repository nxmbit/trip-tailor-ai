import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/utils/debouncer.dart';

class DesiredPlacesFieldState extends ChangeNotifier {
  // State variables
  final List<String> _desiredPlaces = [];
  String? _currentDesiredPlaceQuery;
  Iterable<String> _lastDesiredPlaceOptions = const <String>[];
  late final Debounceable<Iterable<String>?, String>
  _debouncedDesiredPlacesSearch;
  final TextEditingController textController = TextEditingController();

  // Destination dependency
  String? _currentDestination;

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

  // API interaction methods
  Future<Iterable<String>?> _searchDesiredPlaces(String query) async {
    _currentDesiredPlaceQuery = query;

    try {
      if (_currentDestination == null) {
        return const <String>["Please select a destination first"];
      }

      final apiKey = dotenv.env['GOOGLE_PLACES_KEY'] ?? "";
      final dio = Dio();
      dio.options.validateStatus = (status) => true;

      final language = getCurrentLanguage();

      final response = await _makeApiRequest(
        dio: dio,
        apiUrl: 'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParams: {
          'input': '$query in $_currentDestination',
          'types': 'establishment',
          'language': language,
          'key': apiKey,
        },
      );

      // If another search happened after this one, discard these results
      if (_currentDesiredPlaceQuery != query) {
        return null;
      }
      _currentDesiredPlaceQuery = null;

      return _processApiResponse(response);
    } catch (error) {
      debugPrint('Error searching desired places: $error');
      return const Iterable<String>.empty();
    }
  }

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
