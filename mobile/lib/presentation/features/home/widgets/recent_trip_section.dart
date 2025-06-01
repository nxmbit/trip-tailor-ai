import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/translation_helper.dart';
import '../../../state/providers/language_provider.dart';
import '../../../state/providers/trip_plan_provider.dart';
import '../../your_trips/widgets/trip_card.dart';

class RecentTripSection extends StatefulWidget {
  final int crossAxisCount;

  const RecentTripSection({Key? key, required this.crossAxisCount})
    : super(key: key);

  @override
  State<RecentTripSection> createState() => _RecentTripSectionState();
}

class _RecentTripSectionState extends State<RecentTripSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TripPlanProvider>(
        context,
        listen: false,
      );

      final language =
          Provider.of<LanguageProvider>(
            context,
            listen: false,
          ).locale.languageCode;

      // Load just the 4 most recent trips
      provider.loadRecentTripPlans(language: language, pageSize: 4);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                tr(context, 'home.recentTripsTitle'),
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: TextButton(
                onPressed: () => context.go('/your-trips'),
                child: Text(
                  tr(context, 'home.viewAllTrips'),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTripsList(),
      ],
    );
  }

  Widget _buildTripsList() {
    return Consumer<TripPlanProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.tripPlansPaging == null) {
          return _buildLoadingState();
        }

        if (provider.error != null && provider.tripPlansPaging == null) {
          return _buildErrorState(provider);
        }

        final paging = provider.tripPlansPaging;
        if (paging == null || paging.empty) {
          return _buildEmptyState();
        }

        // Show the trips in a grid
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: paging.travelPlansInfos.length,
          itemBuilder:
              (context, index) =>
                  TripCard(
                    trip: paging.travelPlansInfos[index],
                    onDeleted: () {
                      // Tutaj przeładuj dane
                      final provider = Provider.of<TripPlanProvider>(context, listen: false);
                      final language = Provider.of<LanguageProvider>(context, listen: false).locale.languageCode;

                      // Usuń istniejące dane i pokaż wskaźnik ładowania
                      provider.resetTripsList();

                      // Przeładuj dane
                      provider.loadTripPlans(language: language, pageSize: 4);
                    },
                  ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(TripPlanProvider provider) {
    final language =
        Provider.of<LanguageProvider>(
          context,
          listen: false,
        ).locale.languageCode;
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr(context, 'home.errorLoadingTrips'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadRecentTripPlans(language: language,
                  pageSize: 4),
              child: Text(tr(context, 'general.retry')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              tr(context, 'home.noTripsYet'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
