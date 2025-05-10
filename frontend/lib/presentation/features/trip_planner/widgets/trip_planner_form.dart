import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../state/providers/language_provider.dart';

//TODO: input deleting during resizing
class TripPlannerForm extends StatefulWidget {
  const TripPlannerForm({super.key});

  @override
  State<TripPlannerForm> createState() => _TripPlannerFormState();
}

class _TripPlannerFormState extends State<TripPlannerForm> {
  // Form data
  DateTime? startDate;
  DateTime? endDate;
  String? selectedDestination;
  List<String> desiredPlaces = [];

  // Search state
  String? _currentDestinationQuery;
  String? _currentDesiredPlaceQuery;
  Iterable<String> _lastDestinationOptions = const <String>[];
  Iterable<String> _lastDesiredPlaceOptions = const <String>[];
  final TextEditingController _desiredPlacesController =
      TextEditingController();
  // Debounced search functions
  late final _Debounceable<Iterable<String>?, String>
  _debouncedDestinationSearch;
  late final _Debounceable<Iterable<String>?, String>
  _debouncedDesiredPlacesSearch;

  @override
  void initState() {
    super.initState();
    _debouncedDestinationSearch = _debounce<Iterable<String>?, String>(
      _searchPlaces,
    );
    _debouncedDesiredPlacesSearch = _debounce<Iterable<String>?, String>(
      _searchDesiredPlaces,
    );
  }

  @override
  void dispose() {
    // Make sure to dispose the controller
    _desiredPlacesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDestinationField(),
        _buildDesiredPlacesField(),
        _buildDateSelectionRow(),
        _buildSubmitButton(),
      ],
    );
  }

  // WIDGET BUILDING METHODS

  Widget _buildDestinationField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Autocomplete<String>(
        optionsBuilder: _destinationOptionsBuilder,
        onSelected: _onDestinationSelected,
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted,
        ) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: 'Destination',
              hintText: 'Enter a location',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onSubmitted: (String value) {
              onFieldSubmitted();
            },
            onChanged: (value) {
              _handleDestinationFieldChange(value);
            },
          );
        },
      ),
    );
  }

  // Now update your desired places field to use this controller
  Widget _buildDesiredPlacesField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: _desiredPlacesOptionsBuilder,
            onSelected: (String selection) {
              _onDesiredPlaceSelected(selection);
              // Clear the field after selection
              _desiredPlacesController.clear();
            },
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              // Synchronize the controllers
              textEditingController.text = _desiredPlacesController.text;
              // Listen to changes from the autocomplete controller
              textEditingController.addListener(() {
                if (_desiredPlacesController.text !=
                    textEditingController.text) {
                  _desiredPlacesController.text = textEditingController.text;
                }
              });

              return TextField(
                controller:
                    textEditingController, // Use the Autocomplete's controller
                focusNode: focusNode,
                enabled: selectedDestination != null,
                decoration: InputDecoration(
                  labelText: 'Add Desired Places',
                  hintText:
                      selectedDestination != null
                          ? 'Add attractions in $selectedDestination'
                          : 'Select a destination first',
                  prefixIcon: const Icon(Icons.add_location),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onSubmitted: (String value) {
                  if (selectedDestination != null && value.isNotEmpty) {
                    // Add to desired places if not already there
                    if (!desiredPlaces.contains(value)) {
                      setState(() {
                        desiredPlaces.add(value);
                        debugPrint('Added desired place: $value');
                      });
                    }
                    // Clear the field after adding
                    textEditingController.clear();
                    // Keep focus for convenient multiple entries
                    FocusScope.of(context).requestFocus(focusNode);
                  }
                },
              );
            },
          ),
          _buildDesiredPlacesChips(),
        ],
      ),
    );
  }

  Widget _buildDesiredPlacesChips() {
    if (desiredPlaces.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children:
            desiredPlaces
                .map(
                  (place) => Chip(
                    label: Text(place),
                    deleteIcon: const Icon(Icons.cancel, size: 18),
                    onDeleted: () {
                      setState(() {
                        desiredPlaces.remove(place);
                      });
                    },
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildDateSelectionRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildDateField(
              isStartDate: true,
              labelText: 'Start Date',
              date: startDate,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDateField(
              isStartDate: false,
              labelText: 'End Date',
              date: endDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required bool isStartDate,
    required String labelText,
    required DateTime? date,
  }) {
    return InkWell(
      onTap: () => _selectDate(context, isStartDate: isStartDate),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Select date',
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Generate Trip Plan'),
      ),
    );
  }

  // EVENT HANDLERS

  Future<Iterable<String>> _destinationOptionsBuilder(
    TextEditingValue textEditingValue,
  ) async {
    if (textEditingValue.text.isEmpty) {
      _clearDestination();
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

  void _onDestinationSelected(String selection) {
    setState(() {
      // If destination changed, clear the desired places
      if (selectedDestination != selection) {
        desiredPlaces.clear();
        _desiredPlacesController.clear();
      }
      selectedDestination = selection;
      debugPrint('Selected destination: $selection');
    });
  }

  void _handleDestinationFieldChange(String value) {
    if (value.isEmpty && selectedDestination != null) {
      _clearDestination();
    }
  }

  void _clearDestination() {
    setState(() {
      selectedDestination = null;
      desiredPlaces = [];
      _desiredPlacesController.clear();
      debugPrint('Destination cleared, desired places reset');
    });
  }

  Future<Iterable<String>> _desiredPlacesOptionsBuilder(
    TextEditingValue textEditingValue,
  ) async {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<String>.empty();
    }

    if (selectedDestination == null) {
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

  void _onDesiredPlaceSelected(String selection) {
    if (selection != "Please select a destination first") {
      setState(() {
        if (!desiredPlaces.contains(selection)) {
          desiredPlaces.add(selection);
        }
        debugPrint('Added desired place: $selection');
      });
    }
  }

  void _submitForm() {
    debugPrint('Form Submitted:');
    debugPrint('Destination: $selectedDestination');
    debugPrint('Desired Places: $desiredPlaces');
    debugPrint('Start Date: $startDate');
    debugPrint('End Date: $endDate');

    // Here you would send this data to your backend or process it
  }

  // API INTERACTION METHODS

  Future<Iterable<String>?> _searchPlaces(String query) async {
    _currentDestinationQuery = query;

    try {
      final apiKey = dotenv.env['GOOGLE_PLACES_KEY'] ?? "";
      final dio = Dio();
      dio.options.validateStatus = (status) => true;

      final language = _getCurrentLanguage();

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

      // If another search happened after this one, throw away these results
      if (_currentDestinationQuery != query) {
        return null;
      }
      _currentDestinationQuery = null;

      return _processApiResponse(response, 'places');
    } catch (error) {
      debugPrint('Error searching places: $error');
      return Iterable<String>.empty();
    }
  }

  Future<Iterable<String>?> _searchDesiredPlaces(String query) async {
    _currentDesiredPlaceQuery = query;

    try {
      if (selectedDestination == null) {
        return <String>["Please select a destination first"];
      }

      final apiKey = dotenv.env['GOOGLE_PLACES_KEY'] ?? "";
      final dio = Dio();
      dio.options.validateStatus = (status) => true;

      final language = _getCurrentLanguage();

      final response = await _makeApiRequest(
        dio: dio,
        apiUrl: 'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParams: {
          'input': '$query in $selectedDestination',
          'types': 'establishment',
          'language': language,
          'key': apiKey,
        },
      );

      // If another search happened after this one, throw away these results
      if (_currentDesiredPlaceQuery != query) {
        return null;
      }
      _currentDesiredPlaceQuery = null;

      return _processApiResponse(response, 'desired places');
    } catch (error) {
      debugPrint('Error searching desired places: $error');
      return Iterable<String>.empty();
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

  Iterable<String> _processApiResponse(Response response, String searchType) {
    if (response.statusCode != 200) {
      debugPrint('API request failed with status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      return const Iterable<String>.empty();
    }

    if (response.data['predictions'] != null) {
      final predictions = response.data['predictions'] as List;
      if (predictions.isEmpty) {
        return const Iterable<String>.empty();
        ;
      }
      return predictions
          .map<String>((prediction) => prediction['description'] as String)
          .toList();
    } else {
      debugPrint('No predictions in response: ${response.data}');
      return const Iterable<String>.empty();
    }
  }

  String _getCurrentLanguage() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    return languageProvider.locale.languageCode;
  }

  String _buildQueryString(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  // DATE SELECTION

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    final initialDate = _getInitialDate(isStartDate);
    final firstDate =
        isStartDate ? DateTime.now() : (startDate ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 10)),
      locale: languageProvider.locale,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    _updateSelectedDate(picked, isStartDate);
  }

  DateTime _getInitialDate(bool isStartDate) {
    if (isStartDate) {
      return startDate ?? DateTime.now();
    } else {
      return endDate ??
          (startDate != null
              ? startDate!.add(const Duration(days: 1))
              : DateTime.now().add(const Duration(days: 1)));
    }
  }

  void _updateSelectedDate(DateTime? picked, bool isStartDate) {
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          debugPrint('Selected start date: $startDate');
          // If end date is before the new start date, reset it
          if (endDate != null && endDate!.isBefore(picked)) {
            endDate = null;
          }
        } else {
          endDate = picked;
          debugPrint('Selected end date: $endDate');
        }
      });
    }
  }
}

// UTILITY CLASSES FOR DEBOUNCING

typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

/// Returns a new function that is a debounced version of the given function.
///
/// This means that the original function will be called only after no calls
/// have been made for the given Duration.
_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } on _CancelException {
      return null;
    }
    return function(parameter);
  };
}

class _DebounceTimer {
  _DebounceTimer() {
    _timer = Timer(const Duration(milliseconds: 500), _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

class _CancelException implements Exception {
  const _CancelException();
}
