import '../../data/repositories/generate_travel_plan_repository.dart';
import '../models/generate_travel_plan.dart';

class GenerateTravelPlanService {
  final GenerateTravelPlanRepository repository;

  GenerateTravelPlanService(this.repository);

  Future<String> generateTravelPlan({
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? desiredPlaces,
  }) async {
    final generateTravelPlan = GenerateTravelPlan(
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      desiredPlaces: desiredPlaces,
    );

    return await repository.generateTravelPlan(generateTravelPlan);
  }
}
