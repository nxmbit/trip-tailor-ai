import 'package:frontend/data/api/api_client.dart';
import 'package:frontend/data/api/endpoints.dart';
import 'package:frontend/domain/models/generate_travel_plan.dart';
import 'package:dio/dio.dart';

class GenerateTravelPlanRepository {
  final ApiClient apiClient;

  GenerateTravelPlanRepository(this.apiClient);

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
}
