import 'package:frontend/domain/models/attraction.dart';

class TripDay {
  final int dayNumber;
  final String description;
  final DateTime date;
  final List<Attraction> attractions;

  TripDay({
    required this.dayNumber,
    required this.description,
    required this.date,
    required this.attractions,
  });

  factory TripDay.fromJson(Map<String, dynamic> json) {
    // Handle date parsing with fallback
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date'] ?? '');
    } catch (e) {
      parsedDate = DateTime.now(); // Fallback to current date
    }

    return TripDay(
      dayNumber: json['dayNumber'] ?? 0,
      description: json['description'] ?? 'No description for this day',
      date: parsedDate,
      attractions:
          json['attractions'] is List
              ? (json['attractions'] as List)
                  .map((attraction) => Attraction.fromJson(attraction ?? {}))
                  .toList()
              : [],
    );
  }
}
