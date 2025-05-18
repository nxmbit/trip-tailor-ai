import 'package:flutter/material.dart';
import 'package:frontend/presentation/features/trip_planner/widgets/trip_planner_form.dart';
import '../widgets/head_section.dart';

//TODO: autocompletion tiles are stretched to infinity

class TripPlannerContent extends StatelessWidget {
  const TripPlannerContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (MediaQuery.of(context).size.width < 600) {
          return _buildMobileLayout(context, constraints);
        } else if (MediaQuery.of(context).size.width < 1200) {
          return _buildTabletLayout(context, constraints);
        } else {
          return _buildDesktopLayout(context, constraints);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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

  Widget _buildTabletLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const HeadSection(),
                  const SizedBox(height: 32),
                  TripPlannerForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const HeadSection(),
                  const SizedBox(height: 32),
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
