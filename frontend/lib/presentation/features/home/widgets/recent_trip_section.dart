import 'package:flutter/material.dart';
import 'package:frontend/presentation/features/home/widgets/recent_trip_card.dart';

import '../../../../core/utils/translation_helper.dart';

//TODO: split into state
class RecentTripSection extends StatelessWidget {
  final int crossAxisCount;

  const RecentTripSection({Key? key, required this.crossAxisCount})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Demo data
    final trips = [
      RecentTripData(
        username: "john_doe",
        userImageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        destination: 'Paris, France',
        imageUrl:
            'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
        startDate: "2023-06-15",
        endDate: "2023-06-22",
      ),
      RecentTripData(
        username: "Jane",
        userImageUrl:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
        destination: 'Tokyo, Japan',
        imageUrl:
            'https://images.unsplash.com/photo-1513407030348-c983a97b98d8',
        startDate: "2023-06-15",
        endDate: "2023-06-22",
      ),
      RecentTripData(
        username: "long_username",
        userImageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        destination: 'New York, USA',
        imageUrl:
            'https://images.unsplash.com/photo-1522083165195-3424ed129620',
        startDate: "2023-06-15",
        endDate: "2023-06-22",
      ),
      RecentTripData(
        username: "very_very_very_long_username",
        userImageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        destination: 'Bali, Indonesia',
        imageUrl:
            'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
        startDate: "2023-06-15",
        endDate: "2023-06-22",
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'home.recentTripsTitle'),
          style: Theme.of(context).textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: trips.length,
          itemBuilder:
              (context, index) => RecentTripCard(tripData: trips[index]),
        ),
      ],
    );
  }
}

class RecentTripData {
  final String username;
  final String userImageUrl;
  final String imageUrl;
  final String destination;
  final String startDate;
  final String endDate;

  RecentTripData({
    required this.username,
    required this.userImageUrl,
    required this.imageUrl,
    required this.destination,
    required this.startDate,
    required this.endDate,
  });
  int getDays() {
    DateTime startDate = DateTime.parse(this.startDate);
    DateTime endDate = DateTime.parse(this.endDate);
    return endDate.difference(startDate).inDays + 1;
  }
}
