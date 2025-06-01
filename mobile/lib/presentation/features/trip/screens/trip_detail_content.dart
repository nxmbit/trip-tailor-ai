import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/providers/trip_plan_provider.dart';
import '../../../state/providers/language_provider.dart';
import '../widgets/trip_header_section.dart';
import '../widgets/trip_cuisine_section.dart';
import '../widgets/trip_itirenary_section.dart';
import '../widgets/trip_map_section.dart'; // You'll need to create this file

class TripPlanDetailContent extends StatefulWidget {
  final String tripId;

  const TripPlanDetailContent({Key? key, required this.tripId})
    : super(key: key);

  @override
  State<TripPlanDetailContent> createState() => _TripPlanDetailContentState();
}

class _TripPlanDetailContentState extends State<TripPlanDetailContent> {
  @override
  void initState() {
    super.initState();
    // Load trip data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final language =
          Provider.of<LanguageProvider>(
            context,
            listen: false,
          ).locale.languageCode;
      Provider.of<TripPlanProvider>(
        context,
        listen: false,
      ).loadTripPlan(widget.tripId, language: language);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripPlanProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        final tripPlan = provider.tripPlan;
        if (tripPlan == null) {
          return const Center(child: Text('No trip plan found'));
        }

        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add padding at the top to make space for the back button
                  const SizedBox(height: 48),
                  TripHeaderSection(
                    tripPlan: tripPlan,
                  ),
                  const SizedBox(height: 16),
                  // Cuisine section moved right after header
                  TripCuisineSection(
                    recommendations: tripPlan.localCuisineRecommendations,
                  ),
                  const SizedBox(height: 16),
                  TripItinerarySection(tripPlan: tripPlan),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TripMapSection(tripPlan: tripPlan),
                  ),
                ],
              ),
            ),
            // Back button positioned at the top left
            Positioned(top: 16, left: 16, child: _buildBackButton(context)),
          ],
        );
      },
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          // Navigate to your-trips page instead of trying to pop
          context.go('/your-trips');
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [const Icon(Icons.arrow_back), const SizedBox(width: 8)],
          ),
        ),
      ),
    );
  }
}
