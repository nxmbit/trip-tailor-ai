//import nearby places request and response models
import 'package:frontend/data/api/api_client.dart';
import 'package:frontend/data/api/endpoints.dart';
import 'package:frontend/domain/models/nearby_places_request.dart';
import 'package:frontend/domain/models/nearby_places_response.dart';
import 'package:dio/dio.dart';


class NearbyPlacesRepository {
  final ApiClient apiClient;

  NearbyPlacesRepository(this.apiClient);

  //method to send nearby places request and get response
  Future<NearbyPlacesResponse> getNearbyPlaces(
    NearbyPlacesRequest nearbyPlacesRequest,
  ) async {
    try {
      // Create options with extended timeout values
      final options = Options(
        // Set receive timeout to 5 minutes for long-running requests
        receiveTimeout: const Duration(minutes: 5),
        // Also increase connect timeout to be safe
        sendTimeout: const Duration(seconds: 30),
      );

      final response = await apiClient.dio.post(
        Endpoints.nearbySummaryEndpoint,
        data: nearbyPlacesRequest.toJson(),
        options: options, // Pass our custom options
      );

      // Check if response data is not null and parse it
      if (response.data != null) {
        return NearbyPlacesResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get nearby places from response');
      }
    } on Exception catch (e) {
      throw Exception('Failed to get nearby places: $e');
    }
  }
}

