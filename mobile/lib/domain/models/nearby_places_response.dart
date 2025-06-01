import 'package:frontend/domain/models/attraction.dart';

class NearbyPlacesResponse {
  final String destination;
  final List<Attraction> attractions;

  NearbyPlacesResponse({
    required this.destination,
    required this.attractions,
  });

  factory NearbyPlacesResponse.fromJson(Map<String, dynamic> json) {
    return NearbyPlacesResponse(
      destination: json['destination'] ?? 'Unknown Destination',
      attractions: (json['attractions'] as List<dynamic>?)
              ?.map((item) => Attraction.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}