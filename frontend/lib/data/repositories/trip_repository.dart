import 'package:frontend/data/api/api_client.dart';

import '../../domain/models/trip_plan.dart';

class TripRepository {
  final ApiClient apiClient;

  TripRepository(this.apiClient);

  Future<TripPlan> getTripPlan(String id, {required String language}) async {
    try {
      final response = await apiClient.dio.get(
        '/api/travel-plans/$id',
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
}
