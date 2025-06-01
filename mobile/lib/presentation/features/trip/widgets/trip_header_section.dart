import 'package:flutter/material.dart';
import '../../../../domain/models/trip_plan.dart';
import 'trip_header_image.dart';
import 'trip_header_content.dart';

class TripHeaderSection extends StatelessWidget {
  final TripPlan tripPlan;

  const TripHeaderSection({
    Key? key,
    required this.tripPlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section
        TripHeaderImage(
          tripPlan: tripPlan,
        ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TripHeaderContent(
              tripPlan: tripPlan,
            ),
          ),
      ],
    );
  }
}
