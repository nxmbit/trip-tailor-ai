class GenerateTravelPlan {
  final String destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? desiredAttractions;

  const GenerateTravelPlan({
    required this.destination,
    this.startDate,
    this.endDate,
    this.desiredAttractions,
  });

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (desiredAttractions != null && desiredAttractions!.isNotEmpty)
        'desiredAttractions': desiredAttractions,
    };
  }

  List<Object?> get props => [destination, startDate, endDate, desiredAttractions];
}