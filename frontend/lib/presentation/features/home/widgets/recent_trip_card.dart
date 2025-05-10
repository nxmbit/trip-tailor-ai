import 'package:flutter/material.dart';
import 'package:frontend/presentation/features/home/widgets/recent_trip_section.dart';

import '../../../../core/utils/translation_helper.dart';

class RecentTripCard extends StatelessWidget {
  final RecentTripData tripData;

  const RecentTripCard({Key? key, required this.tripData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle tap event
        print("Trip tapped: ${tripData.destination}");
      },
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      tripData.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.error)),
                          ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withOpacity(0.6),
                      ),
                      child: Text(
                        tripData.destination,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Row(
                      mainAxisSize:
                          MainAxisSize
                              .min, // Important to prevent Row from taking full width
                      children: [
                        // User image
                        CircleAvatar(
                          backgroundImage:
                              tripData.userImageUrl != ""
                                  ? NetworkImage(tripData.userImageUrl)
                                  : null,
                          radius: 16,
                        ),

                        const SizedBox(
                          width: 8,
                        ), // Space between avatar and username
                        // Username with container styling
                        Container(
                          constraints: const BoxConstraints(
                            maxWidth:
                                130, // Limit the width of the text container
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withOpacity(0.6),
                          ),
                          child: Text(
                            tripData.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withOpacity(0.6),
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize
                                .min, // Keep the row as small as possible
                        children: [
                          // Add clock icon
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 14, // Small icon to match text
                          ),
                          const SizedBox(
                            width: 4,
                          ), // Small spacing between icon and text
                          Text(
                            '${tripData.getDays()} ${tr(context, 'home.days')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
