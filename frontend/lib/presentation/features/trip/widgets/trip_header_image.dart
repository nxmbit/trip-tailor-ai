import 'package:flutter/material.dart';
import '../../../../domain/models/trip.dart';

class TripHeaderImage extends StatelessWidget {
  final TripPlan tripPlan;
  final bool isDesktopView;
  final bool isTabletView;

  const TripHeaderImage({
    Key? key,
    required this.tripPlan,
    this.isDesktopView = false,
    this.isTabletView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adjust hero image height based on screen size
    final imageHeight = isDesktopView ? 300.0 : (isTabletView ? 250.0 : 200.0);

    return SizedBox(
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
    );
  }
}
