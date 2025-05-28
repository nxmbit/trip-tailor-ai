class Attraction {
  final int visitOrder;
  final String name;
  final String description;
  final String imageUrl;
  final double? latitude;
  final double? longitude;
  final int? visitDuration;
  final String? googlePlacesId;
  final int numberOfUserRatings;
  final double averageRating;

  Attraction({
    required this.visitOrder,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.latitude,
    this.longitude,
    this.visitDuration,
    this.googlePlacesId,
    required this.numberOfUserRatings,
    required this.averageRating,
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      visitOrder: json['visitOrder'] ?? 0,
      name: json['name'] ?? 'Unnamed Attraction',
      description: json['description'] ?? 'No description available',
      imageUrl: json['imageUrl'] ?? '',
      latitude: json['latitude'] is num ? json['latitude'].toDouble() : null,
      longitude: json['longitude'] is num ? json['longitude'].toDouble() : null,
      visitDuration:
          json['visitDuration'] is int ? json['visitDuration'] : null,
      googlePlacesId: json['googlePlacesId'] ?? '',
      numberOfUserRatings: json['numberOfUserRatings'] ?? 0,
      averageRating:
          json['averageRating'] is num ? json['averageRating'].toDouble() : 0.0,
    );
  }
}
