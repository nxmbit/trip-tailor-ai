import 'package:frontend/data/repositories/trip_repository.dart';
import '../models/trip_plan.dart';
import '../models/trip_plan_info.dart';
import '../models/generate_travel_plan.dart';

class TripService {
  final TripRepository repository;

  TripService(this.repository);

  Future<TripPlan> getTripPlan(String id, {required String language}) async {
    return await repository.getTripPlan(id, language: language);
  }

  Future<TripPlanInfoPaging> getTripPlans({
    required String language,
    int page = 0,
    int pageSize = 10,
    String sortBy = 'createdAt',
    String sortDirection = 'desc',
  }) {
    return repository.getTripPlans(
      language: language,
      page: page,
      pageSize: pageSize,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }

  Future<String> generateTravelPlan({
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? desiredAttractions,
  }) async {
    final generateTravelPlan = GenerateTravelPlan(
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      desiredAttractions: desiredAttractions,
    );

    return await repository.generateTravelPlan(generateTravelPlan);
  }

  Future<bool> deleteTripPlan(String id) async {
    return await repository.deleteTripPlan(id);
  }
}
