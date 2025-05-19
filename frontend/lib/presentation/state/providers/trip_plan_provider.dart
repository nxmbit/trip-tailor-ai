import 'package:flutter/material.dart';
import '../../../domain/models/trip_plan.dart';
import '../../../domain/services/trip_service.dart';

class TripPlanProvider extends ChangeNotifier {
  final TripService service;

  bool _isLoading = false;
  String? _error;
  TripPlan? _tripPlan;

  bool get isLoading => _isLoading;
  String? get error => _error;
  TripPlan? get tripPlan => _tripPlan;

  TripPlanProvider({required this.service});

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
}
