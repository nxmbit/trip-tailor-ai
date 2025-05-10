import 'package:frontend/data/api/api_client.dart';
import 'package:frontend/domain/models/generate_travel_plan.dart';

class GenerateTravelPlanRepository {
  final ApiClient apiClient;

  GenerateTravelPlanRepository(this.apiClient);

  Future<void> generateTravelPlan(GenerateTravelPlan generateTravelPlan) async {
    try {
      await apiClient.dio.post(
        '/api/travel-plans/generate',
        data: generateTravelPlan.toJson(),
      );
    } on Exception catch (e) {
      throw Exception('Failed to generate travel plan: $e');
    }
  }
}
