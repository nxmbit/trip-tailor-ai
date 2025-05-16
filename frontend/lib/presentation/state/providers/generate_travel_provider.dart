import 'package:flutter/material.dart';
import '../../../domain/services/generate_travel_plan_service..dart';

class GenerateTravelProvider extends ChangeNotifier {
  final GenerateTravelPlanService service;

  bool _isLoading = false;
  String? _error;
  bool _isSuccess = false;
  String? _tripId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSuccess => _isSuccess;
  String? get tripId => _tripId;
  GenerateTravelProvider({required this.service});

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
        desiredPlaces: desiredPlaces,
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
}
