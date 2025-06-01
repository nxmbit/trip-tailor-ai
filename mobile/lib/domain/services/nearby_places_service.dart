//service to use nearby places repository
import 'package:frontend/domain/models/nearby_places_response.dart';

import '../../data/repositories/nearby_places_repository.dart';
import '../models/nearby_places_request.dart';

class NearbyPlacesService {
  final NearbyPlacesRepository repository;

  NearbyPlacesService(this.repository);

  Future<NearbyPlacesResponse> getNearbyPlaces(NearbyPlacesRequest request) async {
    return await repository.getNearbyPlaces(request);
  }
}
