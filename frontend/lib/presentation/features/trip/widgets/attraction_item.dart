import 'package:flutter/material.dart';
import 'package:frontend/domain/models/attraction.dart';

import '../../../../core/utils/translation_helper.dart';

class AttractionItem extends StatelessWidget {
  final Attraction attraction;
  final bool isDesktopView;

  const AttractionItem({
    Key? key,
    required this.attraction,
    // Default to false, parent will override when needed
    this.isDesktopView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the passed flag instead of checking screen size again
    if (isDesktopView) {
      return _buildDesktopLayout(context);
    } else {
      return _buildMobileTabletLayout(context);
    }
  }

  // Mobile and tablet layout (original expandable design)
  Widget _buildMobileTabletLayout(BuildContext context) {
    return ExpansionTile(
      title: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                attraction.visitOrder.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              attraction.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      subtitle:
          attraction.averageRating > 0
              ? Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${attraction.averageRating.toStringAsFixed(1)} (${attraction.numberOfUserRatings})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (attraction.visitDuration != null &&
                      attraction.visitDuration! > 0) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${(attraction.visitDuration! / 60).round()} ${tr(context, "tripDetail.hour")}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              )
              : null,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image if available - now with tap to enlarge
              if (attraction.imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap:
                        () => _showEnlargedImage(context, attraction.imageUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        attraction.imageUrl.isNotEmpty
                            ? attraction.imageUrl
                            : '',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Description
              Text(
                attraction.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Desktop layout (new card design with small square image)
  Widget _buildDesktopLayout(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Number and content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visit order number in circle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        attraction.visitOrder.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attraction.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          attraction.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Rating and duration footer
                        Row(
                          children: [
                            // Rating
                            if (attraction.averageRating > 0) ...[
                              Icon(Icons.star, size: 20, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                '${attraction.averageRating.toStringAsFixed(1)}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${attraction.numberOfUserRatings})',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 16),
                            ],

                            // Duration
                            if (attraction.visitDuration != null &&
                                attraction.visitDuration! > 0) ...[
                              Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${(attraction.visitDuration! / 60).round()} ${tr(context, "tripDetail.hour")}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right side: Small square image
            if (attraction.imageUrl.isNotEmpty) ...[
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _showEnlargedImage(context, attraction.imageUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.network(
                      attraction.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 30),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEnlargedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                // Enlarged image
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 64),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }
}
