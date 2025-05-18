import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/trip.dart';

class TripHeaderSection extends StatelessWidget {
  final TripPlan tripPlan;
  final bool isDesktopView;
  final bool isTabletView;

  const TripHeaderSection({
    Key? key,
    required this.tripPlan,
    this.isDesktopView = false,
    this.isTabletView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d/M/yyyy');

    // Adjust hero image height based on screen size
    final imageHeight = isDesktopView ? 300.0 : (isTabletView ? 250.0 : 200.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero image with gradient overlay - better sized for different screens
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with better handling
              ClipRRect(
                borderRadius: BorderRadius.circular(isDesktopView ? 12 : 0),
                child: Image.network(
                  tripPlan.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    );
                  },
                ),
              ),
              // Gradient overlay with stronger contrast for better text visibility
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isDesktopView ? 12 : 0),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(
                        0.8,
                      ), // Darker for better readability
                    ],
                    stops: const [0.5, 1.0], // Adjust gradient position
                  ),
                ),
              ),
              // Destination name with improved positioning and visibility
              Positioned(
                bottom: 16,
                left: 16,
                right: 16, // Add right constraint to ensure text wraps properly
                child: Text(
                  tripPlan.destination,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    // Adjust font size for smaller screens
                    fontSize: isDesktopView ? null : (isTabletView ? 24 : 22),
                    shadows: [
                      // Add text shadow for better readability
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ],
                  ),
                  maxLines: 2, // Allow 2 lines for long destination names
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.all(isDesktopView ? 24.0 : 16.0),
          child: Column(
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tripPlan.destinationHistory,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
