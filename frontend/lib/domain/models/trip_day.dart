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
    return TripDay(
      dayNumber: json['dayNumber'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      attractions:
          (json['attractions'] as List)
              .map((attraction) => Attraction.fromJson(attraction))
              .toList(),
    );
  }
}
