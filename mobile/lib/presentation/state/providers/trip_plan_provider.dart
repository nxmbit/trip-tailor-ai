import 'package:flutter/material.dart';
import '../../../domain/models/trip_plan.dart';
import '../../../domain/models/trip_plan_info.dart';
import '../../../domain/services/trip_service.dart';

class TripPlanProvider extends ChangeNotifier {
  final TripService service;

  //TRIP DETAIL
  bool _isLoading = false;
  String? _error;
  TripPlan? _tripPlan;

  bool get isLoading => _isLoading;
  String? get error => _error;
  TripPlan? get tripPlan => _tripPlan;

  //YOUR TRIPS
  TripPlanInfoPaging? _tripPlansPaging;
  int _currentPage = 0;
  int _pageSize = 10;
  String _sortBy = 'createdAt';
  String _sortDirection = 'desc';
  TripPlanInfoPaging? get tripPlansPaging => _tripPlansPaging;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  String get sortBy => _sortBy;
  String get sortDirection => _sortDirection;
  TripPlanProvider({required this.service});

  //TRIP GENERATION
  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;
  String? _tripId;
  String? get tripId => _tripId;

  Future<void> loadTripPlan(String tripId, {String language = 'en'}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate tripId format before making request
      if (tripId.isEmpty) {
        throw Exception('Invalid trip ID: empty string');
      }

      final trip = await service.getTripPlan(tripId, language: language);
      _tripPlan = trip;
    } catch (e) {
      debugPrint('Error loading trip plan: $e');
      _error = 'Failed to load trip plan. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> loadRecentTripPlans({
    String language = 'en',
    int pageSize = 4, // Set default to 4
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await service.getTripPlans(
        language: language,
        page: _currentPage,
        pageSize: pageSize, // Use the parameter
        sortBy: "createdAt",
        sortDirection: "desc",
      );

      _tripPlansPaging = result;
    } catch (e) {
      debugPrint('Error loading travel plans: $e');
      _error = 'Error getting travel plans: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Modify the provider's methods to ensure pageSize is set correctly
  Future<void> loadTripPlans({
    String language = 'en',
    int pageSize = 4, // Set default to 4
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await service.getTripPlans(
        language: language,
        page: _currentPage,
        pageSize: pageSize, // Use the parameter
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );

      _tripPlansPaging = result;
    } catch (e) {
      debugPrint('Error loading travel plans: $e');
      _error = 'Error getting travel plans: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changePage(int page, int pageSize) {
    if (page != _currentPage) {
      _currentPage = page;
      loadTripPlans(pageSize: pageSize);
    }
  }

  void changeSort(String sortBy, String direction, int pageSize) {
    if (sortBy != _sortBy || direction != _sortDirection) {
      _sortBy = sortBy;
      _sortDirection = direction;
      _currentPage = 0; // Reset to first page when changing sort
      loadTripPlans(pageSize: pageSize);
    }
  }
  Future<void> generateTravelPlan({
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? desiredPlaces,
  }) async {
    _isLoading = true;
    _error = null;
    _isSuccess = false;
    notifyListeners();

    try {
      _tripId = await service.generateTravelPlan(
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        desiredAttractions: desiredPlaces,
      );
      _isSuccess = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetState() {
    _isLoading = false;
    _error = null;
    _isSuccess = false;
    notifyListeners();
  }

    //delete trip plan
  Future<bool> deleteTripPlan(String tripId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await service.deleteTripPlan(tripId);
      // Usuwamy plan podróży z lokalnej listy
      if (_tripPlansPaging != null) {
        _tripPlansPaging!.travelPlansInfos.removeWhere((trip) => trip.id == tripId);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  void resetTripsList() {
    _tripPlansPaging = null;
    _isLoading = true;
    _error = null;
    notifyListeners();
  }
}
