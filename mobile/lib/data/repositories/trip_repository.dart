import 'package:frontend/data/api/api_client.dart';
import '../../domain/models/trip_plan.dart';
import '../../domain/models/trip_plan_info.dart';
import 'package:frontend/domain/models/generate_travel_plan.dart';
import 'package:dio/dio.dart';
import 'package:frontend/data/api/endpoints.dart';

class TripRepository {
  final ApiClient apiClient;

  TripRepository(this.apiClient);

  Future<TripPlan> getTripPlan(String id, {required String language}) async {
    try {
      final response = await apiClient.dio.get(
        '${Endpoints.tripPlanEndpoint}$id',
        queryParameters: {'language': language},
      );
      if (response.statusCode == 200) {
        return TripPlan.fromJson(response.data);
      } else {
        throw Exception('Failed to load trip plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting trip plan: $e');
    }
  }
  Future<TripPlanInfoPaging> getTripPlans({
    required String language,
    int page = 0,
    int pageSize = 10,
    String sortBy = 'createdAt',
    String sortDirection = 'desc',
  }) async {
    try {
      final response = await apiClient.dio.get(
        Endpoints.tripPlansEndpoint,
        queryParameters: {
          'language': language,
          'page': page,
          'pageSize': pageSize,
          'sortBy': sortBy,
          'sortDirection': sortDirection,
        },
      );
      if (response.statusCode == 200) {
        return TripPlanInfoPaging.fromJson(response.data);
      } else {
        throw Exception('Failed to load travel plans: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting travel plans: $e');
    }
  }
  Future<String> generateTravelPlan(
      GenerateTravelPlan generateTravelPlan,
      ) async {
    try {
      // Create options with extended timeout values
      final options = Options(
        // Set receive timeout to 5 minutes for long-running plan generation
        receiveTimeout: const Duration(minutes: 5),
        // Also increase connect timeout to be safe
        sendTimeout: const Duration(seconds: 30),
      );

      final response = await apiClient.dio.post(
        Endpoints.generateTravelPlanEndpoint,
        data: generateTravelPlan.toJson(),
        options: options, // Pass our custom options
      );
      // Extract the trip ID from the response
      if (response.data != null) {
        return response.data["id"] as String;
      } else {
        throw Exception('Failed to get trip data from response');
      }
    } on Exception catch (e) {
      throw Exception('Failed to generate travel plan: $e');
    }
  }
  Future<bool> deleteTripPlan(String id) async {
    try {
      final response = await apiClient.dio.delete(
        '${Endpoints.tripPlanEndpoint}$id',
      );
      if (response.statusCode == 204) {
        return true; // Successfully deleted
      } else {
        throw Exception('Failed to delete trip plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting trip plan: $e');
    }
  }
}
