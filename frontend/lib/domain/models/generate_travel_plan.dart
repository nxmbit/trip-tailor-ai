class GenerateTravelPlan {
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? desiredPlaces;

  const GenerateTravelPlan({
    required this.destination,
    this.startDate,
    this.endDate,
    this.desiredPlaces,
  });

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (desiredPlaces != null && desiredPlaces!.isNotEmpty)
        'desiredPlaces': desiredPlaces,
    };
  }

  List<Object?> get props => [destination, startDate, endDate, desiredPlaces];
}
