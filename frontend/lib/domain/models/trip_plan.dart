import 'package:frontend/domain/models/trip_day.dart';

class TripPlan {
  final String id;
  final String language;
  final String destination;
  final String description;
  final String bestTimeToVisit;
  final String destinationHistory;
  final String googlePlacesId;
  final DateTime travelStartDate;
  final DateTime travelEndDate;
  final String imageUrl;
  final DateTime createdAt;
  final List<String> localCuisineRecommendations;
  final List<TripDay> itinerary;

  TripPlan({
    required this.id,
    required this.language,
    required this.destination,
    required this.description,
    required this.bestTimeToVisit,
    required this.destinationHistory,
    required this.googlePlacesId,
    required this.travelStartDate,
    required this.travelEndDate,
    required this.imageUrl,
    required this.createdAt,
    required this.localCuisineRecommendations,
    required this.itinerary,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    // Helper function for parsing dates with fallback
    DateTime parseDateSafely(String? dateStr, {DateTime? defaultDate}) {
      if (dateStr == null) return defaultDate ?? DateTime.now();
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return defaultDate ?? DateTime.now();
      }
    }

    // Get current date as fallback
    final now = DateTime.now();

    return TripPlan(
      id: json['travelPlanId'] ?? 'unknown-id',
      language: json['language'] ?? 'en',
      destination: json['destination'] ?? 'Unknown Destination',
      description: json['description'] ?? 'No description available',
      bestTimeToVisit: json['bestTimeToVisit'] ?? '',
      destinationHistory: json['destinationHistory'] ?? '',
      googlePlacesId: json['googlePlacesId'] ?? '',
      travelStartDate: parseDateSafely(
        json['travelStartDate'],
        defaultDate: now,
      ),
      travelEndDate: parseDateSafely(
        json['travelEndDate'],
        defaultDate: now.add(const Duration(days: 7)),
      ),
      imageUrl: json['imageUrl'] ?? '',
      createdAt: parseDateSafely(json['createdAt'], defaultDate: now),
      localCuisineRecommendations:
          json['localCuisineRecommendations'] is List
              ? List<String>.from(
                json['localCuisineRecommendations'].map(
                  (item) => item?.toString() ?? '',
                ),
              )
              : [],
      itinerary:
          json['itinerary'] is List
              ? (json['itinerary'] as List)
                  .map((day) => TripDay.fromJson(day ?? {}))
                  .toList()
              : [],
    );
  }
}
