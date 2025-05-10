import 'package:flutter/material.dart';
import 'package:frontend/presentation/features/trip_planner/widgets/trip_planner_form.dart';
import '../widgets/head_section.dart';

class TripPlannerContent extends StatelessWidget {
  const TripPlannerContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (MediaQuery.of(context).size.width < 600) {
          return _buildMobileLayout(context);
        } else if (MediaQuery.of(context).size.width < 1200) {
          return _buildTabletLayout(context);
        } else {
          return _buildDesktopLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeadSection(),
            const SizedBox(height: 24),
            TripPlannerForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeadSection(),
            const SizedBox(height: 32),
            TripPlannerForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeadSection(),
            const SizedBox(height: 32),
            TripPlannerForm(),
          ],
        ),
      ),
    );
  }
}
