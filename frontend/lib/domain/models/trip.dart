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
    return TripPlan(
      id: json['travelPlanId'],
      language: json['language'],
      destination: json['destination'],
      description: json['description'],
      bestTimeToVisit: json['bestTimeToVisit'],
      destinationHistory: json['destinationHistory'],
      googlePlacesId: json['googlePlacesId'],
      travelStartDate: DateTime.parse(json['travelStartDate']),
      travelEndDate: DateTime.parse(json['travelEndDate']),
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      localCuisineRecommendations: List<String>.from(
        json['localCuisineRecommendations'],
      ),
      itinerary:
          (json['itinerary'] as List)
              .map((day) => TripDay.fromJson(day))
              .toList(),
    );
  }
}
