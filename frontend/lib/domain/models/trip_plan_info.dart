import 'package:intl/intl.dart';

class TripPlanInfo {
  final String id;
  final String language;
  final String destination;
  final String imageUrl;
  final int tripLength;
  final DateTime createdAt;
  final DateTime travelStartDate;
  final DateTime travelEndDate;

  TripPlanInfo({
    required this.id,
    required this.language,
    required this.destination,
    required this.imageUrl,
    required this.tripLength,
    required this.createdAt,
    required this.travelStartDate,
    required this.travelEndDate,
  });

  factory TripPlanInfo.fromJson(Map<String, dynamic> json) {
    return TripPlanInfo(
      id: json['id'],
      language: json['language'],
      destination: json['destination'],
      imageUrl: json['imageUrl'] ?? '',
      tripLength: json['tripLength'],
      createdAt: DateTime.parse(json['createdAt']),
      travelStartDate: DateTime.parse(json['travelStartDate']),
      travelEndDate: DateTime.parse(json['travelEndDate']),
    );
  }

  String get formattedDateRange {
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    return '${formatter.format(travelStartDate)} - ${formatter.format(travelEndDate)}';
  }
}

class TripPlanInfoPaging {
  final List<TripPlanInfo> travelPlansInfos;
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalItems;
  final bool empty;

  TripPlanInfoPaging({
    required this.travelPlansInfos,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
    required this.empty,
  });

  factory TripPlanInfoPaging.fromJson(Map<String, dynamic> json) {
    return TripPlanInfoPaging(
      travelPlansInfos:
          (json['travelPlansInfos'] as List)
              .map((item) => TripPlanInfo.fromJson(item))
              .toList(),
      page: json['page'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
      empty: json['empty'],
    );
  }
}
