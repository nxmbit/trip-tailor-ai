import 'package:flutter/material.dart';
  import 'package:transparent_image/transparent_image.dart';
  import '../../../../domain/models/trip_plan.dart';

  class TripHeaderImage extends StatelessWidget {
    final TripPlan tripPlan;

    const TripHeaderImage({
      Key? key,
      required this.tripPlan,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      final imageHeight = 200.0;
      final hasImage = tripPlan.imageUrl.isNotEmpty;

      return SizedBox(
        height: imageHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ulepszona obsługa obrazu z animacją ładowania
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: hasImage
                ? FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: tripPlan.imageUrl,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 300),
                    imageErrorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage(context);
                    },
                  )
                : _buildPlaceholderImage(context),
            ),
            // Gradient overlay (bez zmian)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Destination name (bez zmian)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                tripPlan.destination,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildPlaceholderImage(BuildContext context) {
      return Container(
        color: Theme.of(context).colorScheme.primary,
        child: const Center(
          child: Icon(Icons.image, size: 50, color: Colors.white),
        ),
      );
    }
  }