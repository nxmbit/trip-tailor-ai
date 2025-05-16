import 'package:flutter/material.dart';
import 'package:frontend/presentation/features/trip_planner/widgets/destination_field.dart';
import 'package:frontend/presentation/features/trip_planner/widgets/submit_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../state/providers/generate_travel_provider.dart';
import 'date_selection.dart';
import 'desired_places_field.dart';

//TODO: PREVENT SENDING REQUEST WHEN USER FILLS IN SPECIAL CHARS f.e: "/"
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
        const SnackBar(content: Text('Please select a destination')),
      );
      return;
    }

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
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
        return WillPopScope(
          onWillPop: () async => false, // Prevent closing with back button
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating your travel plan...\nThis may take a minute.'),
              ],
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
              const SnackBar(
                content: Text('Travel plan generated successfully!'),
              ),
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
