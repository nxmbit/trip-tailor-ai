import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/trip_plan.dart';

class TripHeaderContent extends StatelessWidget {
  final TripPlan tripPlan;

  const TripHeaderContent({
    Key? key,
    required this.tripPlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d/M/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trip dates
        Row(
          children: [
            const Icon(Icons.date_range, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${dateFormat.format(tripPlan.travelStartDate)} - ${dateFormat.format(tripPlan.travelEndDate)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          tr(context, 'tripDetail.description'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        // Description
        Text(
          tripPlan.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        // Best time to visit
        if (tripPlan.bestTimeToVisit.isNotEmpty) ...[
          Text(
            tr(context, 'tripDetail.bestTimeToVisit'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            tripPlan.bestTimeToVisit,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
        ],

        // Destination history
        if (tripPlan.destinationHistory.isNotEmpty) ...[
          Text(
            tr(context, 'tripDetail.destinationHistory'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            tripPlan.destinationHistory,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}
