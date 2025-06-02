import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/models/trip_plan_info.dart';
import '../../../state/providers/language_provider.dart';
import '../../../state/providers/trip_plan_provider.dart';
import '../widgets/trip_card.dart';
import '../../../../core/utils/translation_helper.dart';

class YourTripsContent extends StatefulWidget {
  const YourTripsContent({super.key});

  @override
  State<YourTripsContent> createState() => _YourTripsContentState();
}

class _YourTripsContentState extends State<YourTripsContent> {
  String _sortBy = 'createdAt';
  String _sortDirection = 'desc';

  // Define page sizes for different screen widths
  int getPageSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 4; // Mobile: 4 trips per page
    } else if (width < 1200) {
      return 6; // Tablet: 6 trips per page
    } else {
      return 12; // Desktop: 12 trips per page
    }
  }

  @override
  void initState() {
    super.initState();
    // Load trips when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TripPlanProvider>(context, listen: false);

      // Sync local state with provider state
      setState(() {
        _sortBy = provider.sortBy;
        _sortDirection = provider.sortDirection;
      });

      final language =
          Provider.of<LanguageProvider>(
            context,
            listen: false,
          ).locale.languageCode;

      // Use dynamic page size based on screen width
      final pageSize = getPageSize(context);

      // Load trip plans with the provider's current sort settings
      provider.loadTripPlans(language: language, pageSize: pageSize);
    });
  }

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
    return _buildCommonLayout(
      context,
      padding: const EdgeInsets.all(16.0),
      crossAxisCount: 1,
      childAspectRatio: 1.3,
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return _buildCommonLayout(
      context,
      padding: const EdgeInsets.all(24.0),
      crossAxisCount: 2,
      childAspectRatio: 1.3,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return _buildCommonLayout(
      context,
      padding: const EdgeInsets.all(32.0),
      crossAxisCount: 4,
      childAspectRatio: 1.3,
    );
  }

  Widget _buildCommonLayout(
    BuildContext context, {
    required EdgeInsets padding,
    required int crossAxisCount,
    required double childAspectRatio,
  }) {
    final pageSize = getPageSize(context);

    return Consumer<TripPlanProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.tripPlansPaging == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.tripPlansPaging == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadTripPlans(pageSize: pageSize),
                  child: Text(tr(context, 'yourTrips.retry')),
                ),
              ],
            ),
          );
        }

        final paging = provider.tripPlansPaging;
        if (paging == null || paging.empty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(tr(context, 'yourTrips.empty')),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/trip-planner'),
                  child: Text(tr(context, 'yourTrips.createTrip')),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Improved header section
              _buildHeader(context),
              const SizedBox(height: 24),

              // Grid of trip cards
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: paging.travelPlansInfos.length,
                  itemBuilder: (context, index) {
                    return TripCard(
                      trip: paging.travelPlansInfos[index],
                      onDeleted: () {
                        // Tutaj przeładuj dane
                        final provider = Provider.of<TripPlanProvider>(
                          context,
                          listen: false,
                        );
                        final language =
                            Provider.of<LanguageProvider>(
                              context,
                              listen: false,
                            ).locale.languageCode;

                        // Usuń istniejące dane i pokaż wskaźnik ładowania
                        provider.resetTripsList();

                        // Przeładuj dane
                        provider.loadTripPlans(
                          language: language,
                          pageSize: pageSize,
                        );
                      },
                    );
                  },
                ),
              ),

              // Pagination controls
              if (paging.totalPages > 1)
                _buildPaginationControls(context, paging, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<TripPlanProvider>(
      builder: (context, provider, _) {
        final paging = provider.tripPlansPaging;
        final isSmallScreen = MediaQuery.of(context).size.width < 600;

        if (isSmallScreen) {
          // More compact layout for small screens
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr(context, 'yourTrips.title'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,

                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (paging != null && !paging.empty)
                    _buildSortButton(context, provider),
                ],
              ),
              if (paging != null && !paging.empty) ...[
                const SizedBox(height: 4),
                Text(
                  tr(context, 'yourTrips.subtitle'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${tr(context, 'yourTrips.numberOfYourTrips')} ${paging.totalItems}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          );
        } else {
          // Regular layout for larger screens
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(context, 'yourTrips.title'),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (paging != null && !paging.empty)
                          Text(
                            tr(context, 'yourTrips.subtitle'),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (paging != null && !paging.empty)
                    _buildSortButton(context, provider),
                ],
              ),
              if (paging != null && !paging.empty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${tr(context, 'yourTrips.numberOfYourTrips')} ${paging.totalItems} ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSortButton(BuildContext context, TripPlanProvider provider) {
    final pageSize = getPageSize(context);

    return PopupMenuButton<Map<String, String>>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _sortDirection == 'asc' ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(tr(context, 'yourTrips.sort')),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      onSelected: (Map<String, String> result) {
        setState(() {
          _sortBy = result['sortBy']!;
          _sortDirection = result['sortDirection']!;
        });
        provider.changeSort(_sortBy, _sortDirection, pageSize);
      },
      itemBuilder:
          (BuildContext context) => [
            _buildPopupMenuItem(
              tr(context, 'yourTrips.sortOptions.creationDate'),
              'createdAt',
              'desc',
            ),
            _buildPopupMenuItem(
              tr(context, 'yourTrips.sortOptions.creationDateOldest'),
              'createdAt',
              'asc',
            ),
            _buildPopupMenuItem(
              tr(context, 'yourTrips.sortOptions.startDate'),
              'travelStartDate',
              'asc',
            ),
            _buildPopupMenuItem(
              tr(context, 'yourTrips.sortOptions.startDateLatest'),
              'travelStartDate',
              'desc',
            ),
            _buildPopupMenuItem(
              tr(context, 'yourTrips.sortOptions.tripLength'),
              'tripLength',
              'desc',
            ),
            _buildPopupMenuItem(
              tr(context, 'yourTrips.sortOptions.destinationAZ'),
              'destination',
              'asc',
            ),
            _buildPopupMenuItem(
              tr(context, 'yourTrips.sortOptions.destinationZA'),
              'destination',
              'desc',
            ),
          ],
    );
  }

  PopupMenuItem<Map<String, String>> _buildPopupMenuItem(
    String title,
    String sortBy,
    String direction,
  ) {
    bool isSelected = _sortBy == sortBy && _sortDirection == direction;

    return PopupMenuItem<Map<String, String>>(
      value: {'sortBy': sortBy, 'sortDirection': direction},
      child: Row(
        children: [
          if (isSelected)
            const Icon(Icons.check, size: 16, color: Colors.blue)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(
    BuildContext context,
    TripPlanInfoPaging paging,
    TripPlanProvider provider,
  ) {
    // Check if we need to use a compact layout
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final pageSize = getPageSize(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button - icon-only on small screens
          isSmallScreen
              ? IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed:
                    paging.page > 0
                        ? () => provider.changePage(paging.page - 1, pageSize)
                        : null,
              )
              : OutlinedButton.icon(
                icon: const Icon(Icons.chevron_left),
                label: Text(tr(context, 'yourTrips.pagination.previous')),
                onPressed:
                    paging.page > 0
                        ? () => provider.changePage(paging.page - 1, pageSize)
                        : null,
              ),

          const SizedBox(width: 8),

          // Page indicator - flexible to take minimal needed space
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Text(
              isSmallScreen
                  ? '${paging.page + 1}/${paging.totalPages}'
                  : '${tr(context, 'yourTrips.pagination.page')} ${paging.page + 1} ${tr(context, 'yourTrips.pagination.of')} ${paging.totalPages}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Next button - icon-only on small screens
          isSmallScreen
              ? IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed:
                    paging.page < paging.totalPages - 1
                        ? () => provider.changePage(paging.page + 1, pageSize)
                        : null,
              )
              : OutlinedButton.icon(
                icon: const Icon(Icons.chevron_right),
                label: Text(tr(context, 'yourTrips.pagination.next')),
                onPressed:
                    paging.page < paging.totalPages - 1
                        ? () => provider.changePage(paging.page + 1, pageSize)
                        : null,
              ),
        ],
      ),
    );
  }
}
