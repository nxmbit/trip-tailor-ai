import '../../data/repositories/trip_plan_info_repository.dart';
import '../models/trip_plan_info.dart';

class TripPlanInfoService {
  final TripPlanInfoRepository repository;

  TripPlanInfoService(this.repository);

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
}
