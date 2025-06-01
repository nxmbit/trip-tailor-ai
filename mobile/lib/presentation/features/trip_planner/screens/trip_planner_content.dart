import 'package:flutter/material.dart';
import 'package:frontend/presentation/features/trip_planner/widgets/trip_planner_form.dart';
import '../widgets/head_section.dart';

class TripPlannerContent extends StatelessWidget {
  const TripPlannerContent({Key? key}) : super(key: key);

  @override
Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height-200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const HeadSection(),
                  const SizedBox(height: 24),
                  TripPlannerForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
