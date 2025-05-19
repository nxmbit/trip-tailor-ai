import 'package:flutter/material.dart';
import 'package:frontend/presentation/features/trip_planner/widgets/destination_field.dart';
import 'package:frontend/presentation/features/trip_planner/widgets/submit_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/translation_helper.dart';
import '../../../state/providers/generate_travel_provider.dart';
import 'date_selection.dart';
import 'desired_places_field.dart';

//TODO: input deleting during resizing
//TODO: better error messages for user
class TripPlannerForm extends StatefulWidget {
  const TripPlannerForm({super.key});

  @override
  State<TripPlannerForm> createState() => _TripPlannerFormState();
}

class _TripPlannerFormState extends State<TripPlannerForm> {
  // Form data
  DateTime? startDate;
  DateTime? endDate;
  String? selectedDestination;
  List<String> desiredPlaces = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DestinationField(
          initialDestination: selectedDestination,
          onDestinationChanged: _onDestinationChanged,
        ),
        DesiredPlacesField(
          destination: selectedDestination,
          initialPlaces: desiredPlaces,
          onPlacesChanged: _onDesiredPlacesChanged,
        ),
        DateSelectionRow(
          initialStartDate: startDate,
          initialEndDate: endDate,
          onDatesChanged: _onDatesChanged,
        ),
        SubmitButton(onPressed: _submitForm),
      ],
    );
  }

  void _onDestinationChanged(String? newDestination) {
    setState(() {
      selectedDestination = newDestination;
    });
  }

  void _onDesiredPlacesChanged(List<String> newPlaces) {
    setState(() {
      desiredPlaces = newPlaces;
    });
  }

  void _onDatesChanged(DateTime? newStartDate, DateTime? newEndDate) {
    setState(() {
      startDate = newStartDate;
      endDate = newEndDate;
    });
  }

  void _submitForm() {
    if (selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, 'tripPlanner.selectDestination'))),
      );
      return;
    }

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, 'tripPlanner.selectDates'))),
      );
      return;
    }

    debugPrint('Form Submitted:');
    debugPrint('Destination: $selectedDestination');
    debugPrint('Desired Places: $desiredPlaces');
    debugPrint('Start Date: $startDate');
    debugPrint('End Date: $endDate');

    // Get the provider
    final generateTravelProvider = Provider.of<GenerateTravelProvider>(
      context,
      listen: false,
    );

    // Reset any previous state
    generateTravelProvider.resetState();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Get screen width for responsive adjustments
        final screenWidth = MediaQuery.of(context).size.width;

        // Match your existing responsive breakpoints
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1200;

        return WillPopScope(
          onWillPop: () async => false, // Prevent closing with back button
          child: Dialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            ),
            child: Padding(
              // Match padding with your layout sizes
              padding: EdgeInsets.all(
                isMobile
                    ? 16.0
                    : isTablet
                    ? 24.0
                    : 32.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress indicator size based on your breakpoints
                  SizedBox(
                    height: isMobile ? 45 : 60,
                    width: isMobile ? 45 : 60,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      strokeWidth: isMobile ? 3 : 4,
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 24),
                  Text(
                    tr(context, 'tripPlanner.generatingPlan'),
                    textAlign: TextAlign.center,
                    style:
                        isMobile
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(context, 'tripPlanner.generatingPlanWaitMessage'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Generate travel plan
    generateTravelProvider
        .generateTravelPlan(
          destination: selectedDestination!,
          startDate: startDate,
          endDate: endDate,
          desiredPlaces: desiredPlaces.isNotEmpty ? desiredPlaces : null,
        )
        .then((_) {
          // Close loading dialog
          Navigator.of(context, rootNavigator: true).pop();

          if (generateTravelProvider.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(tr(context, 'planGenerated'))),
            );

            // Navigate to trip details page with the ID
            if (generateTravelProvider.tripId != null) {
              context.go('/your-trips/${generateTravelProvider.tripId}');
            }
          } else if (generateTravelProvider.error != null) {
            // Keep existing error handling
          }
        });
  }
}
