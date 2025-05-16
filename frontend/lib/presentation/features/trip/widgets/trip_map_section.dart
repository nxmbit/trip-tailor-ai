import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import '../../../../domain/models/trip.dart';

class TripMapSection extends StatelessWidget {
  final TripPlan tripPlan;

  const TripMapSection({Key? key, required this.tripPlan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'tripDetail.mapView'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: const Center(
            child: Text(
              "Google Maps will be integrated here",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          // TODO: Implement Google Maps integration
          // This would display all attractions from the trip with markers
        ),
      ],
    );
  }
}
