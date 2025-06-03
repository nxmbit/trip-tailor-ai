import 'package:flutter/material.dart';
import 'package:frontend/domain/models/nearby_places_response.dart';
import '../../../domain/models/nearby_places_request.dart';
import '../../../domain/services/nearby_places_service.dart';

class NearbyPlacesProvider extends ChangeNotifier {
  final NearbyPlacesService service;

  bool _isLoading = false;
  String? _error;
  NearbyPlacesResponse? _nearbyPlaces;

  bool get isLoading => _isLoading;
  String? get error => _error;
  NearbyPlacesResponse? get nearbyPlaces => _nearbyPlaces;

  NearbyPlacesProvider({required this.service});

  Future<void> fetchNearbyPlaces({
    required double longitude,
    required double latitude,
    int radiusMeters = 5000,
    int maxAttractions = 10 ,
    required String language,

}) async {
    _isLoading = true;
    _error = null;
    _nearbyPlaces = null;
    notifyListeners();

    try {
      final request = NearbyPlacesRequest(latitude: latitude, longitude: longitude, language: language,
          radiusMeters: radiusMeters, maxAttractions: maxAttractions);
      final response = await service.getNearbyPlaces(request);
      _nearbyPlaces = response;
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
    _nearbyPlaces = null;
    notifyListeners();
  }
}