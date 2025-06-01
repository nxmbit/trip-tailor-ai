import 'dart:core';

class NearbyPlacesRequest {
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final int maxAttractions;
  final String language;

  const NearbyPlacesRequest({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 3000, // Default radius of 3 km
    this.maxAttractions = 5, // Default to 5 attractions
    this.language = 'en', // Default language is English
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'maxAttractions': maxAttractions,
      'language': language,
    };
  }

  List<Object?> get props => [latitude, longitude, radiusMeters, maxAttractions, language];
}