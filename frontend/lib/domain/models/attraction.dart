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
      visitOrder: json['visitOrder'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      visitDuration: json['visitDuration'],
      googlePlacesId: json['googlePlacesId'] ?? '',
      numberOfUserRatings: json['numberOfUserRatings'],
      averageRating: json['averageRating'],
    );
  }
}
