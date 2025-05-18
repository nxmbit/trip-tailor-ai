import 'package:flutter/material.dart';
import '../../../../domain/models/trip.dart';
import 'trip_header_image.dart';
import 'trip_header_content.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section
        TripHeaderImage(
          tripPlan: tripPlan,
          isDesktopView: isDesktopView,
          isTabletView: isTabletView,
        ),

        // Content section (only for non-desktop views)
        if (!isDesktopView)
          Padding(
            padding: EdgeInsets.all(isDesktopView ? 24.0 : 16.0),
            child: TripHeaderContent(
              tripPlan: tripPlan,
              isDesktopView: isDesktopView,
              isTabletView: isTabletView,
            ),
          ),
      ],
    );
  }
}
