import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import '../../../../domain/models/trip.dart';
import 'trip_day_card.dart';

class TripItinerarySection extends StatelessWidget {
  final TripPlan tripPlan;
  final bool isDesktopView;

  const TripItinerarySection({
    Key? key,
    required this.tripPlan,
    this.isDesktopView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, 'tripDetail.itinerary'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...tripPlan.itinerary.map(
            (day) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TripDayCard(day: day, isDesktopView: isDesktopView),
            ),
          ),
        ],
      ),
    );
  }
}
