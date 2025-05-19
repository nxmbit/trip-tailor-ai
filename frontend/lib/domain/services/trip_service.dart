import 'package:frontend/data/repositories/trip_repository.dart';
import '../models/trip_plan.dart';

class TripService {
  final TripRepository repository;

  TripService(this.repository);

  Future<TripPlan> getTripPlan(String id, {required String language}) async {
    return await repository.getTripPlan(id, language: language);
  }
}
