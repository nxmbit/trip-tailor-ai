import 'package:flutter/material.dart';
import '../../../domain/models/trip_plan_info.dart';
import '../../../domain/services/trip_plan_info_service.dart';

class TripPlanInfoProvider extends ChangeNotifier {
  final TripPlanInfoService service;

  bool _isLoading = false;
  String? _error;
  TripPlanInfoPaging? _tripPlansPaging;
  int _currentPage = 0;
  int _pageSize = 10;
  String _sortBy = 'createdAt';
  String _sortDirection = 'desc';

  bool get isLoading => _isLoading;
  String? get error => _error;
  TripPlanInfoPaging? get tripPlansPaging => _tripPlansPaging;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  String get sortBy => _sortBy;
  String get sortDirection => _sortDirection;

  TripPlanInfoProvider({required this.service});

  // Modify the provider's methods to ensure pageSize is set correctly
  Future<void> loadTravelPlans({
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
      loadTravelPlans(pageSize: pageSize);
    }
  }

  void changeSort(String sortBy, String direction, int pageSize) {
    if (sortBy != _sortBy || direction != _sortDirection) {
      _sortBy = sortBy;
      _sortDirection = direction;
      _currentPage = 0; // Reset to first page when changing sort
      loadTravelPlans(pageSize: pageSize);
    }
  }
}
