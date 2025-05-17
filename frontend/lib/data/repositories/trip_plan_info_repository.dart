import 'package:frontend/data/api/api_client.dart';
import '../../domain/models/trip_plan_info.dart';

class TripPlanInfoRepository {
  final ApiClient apiClient;

  TripPlanInfoRepository(this.apiClient);

  Future<TripPlanInfoPaging> getTripPlans({
    required String language,
    int page = 0,
    int pageSize = 10,
    String sortBy = 'createdAt',
    String sortDirection = 'desc',
  }) async {
    try {
      final response = await apiClient.dio.get(
        'api/travel-plans/plans',
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
}
