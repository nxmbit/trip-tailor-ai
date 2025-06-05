import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/state/providers/trip_plan_provider.dart';
import '../../../state/providers/language_provider.dart';
import '../widgets/trip_header_content.dart';
import '../widgets/trip_header_image.dart';
import '../widgets/trip_header_section.dart';
import '../widgets/trip_cuisine_section.dart';
import '../widgets/trip_itirenary_section.dart';
import '../widgets/trip_map_section.dart';

class TripPlanDetailContent extends StatefulWidget {
  final String tripId;

  const TripPlanDetailContent({Key? key, required this.tripId})
    : super(key: key);

  @override
  State<TripPlanDetailContent> createState() => _TripPlanDetailContentState();
}

class _TripPlanDetailContentState extends State<TripPlanDetailContent> {
  String? _lastLanguageCode;
  bool _isLoadingLanguageChange = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final language =
          Provider.of<LanguageProvider>(
            context,
            listen: false,
          ).locale.languageCode;
      _lastLanguageCode = language;
      setState(() => _isLoadingLanguageChange = true);
      await Provider.of<TripPlanProvider>(
        context,
        listen: false,
      ).loadTripPlan(widget.tripId, language: language);
      if (mounted) setState(() => _isLoadingLanguageChange = false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Provider.of<LanguageProvider>(context).locale.languageCode;
    if (_lastLanguageCode != language && !_isLoadingLanguageChange) {
      _lastLanguageCode = language;
      setState(() => _isLoadingLanguageChange = true);
      Provider.of<TripPlanProvider>(
        context,
        listen: false,
      ).loadTripPlan(widget.tripId, language: language).then((_) {
        if (mounted) setState(() => _isLoadingLanguageChange = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripPlanProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isLoading;
        final error = provider.error;
        final tripPlan = provider.tripPlan;

        Widget content;
        if (isLoading || tripPlan == null) {
          content = const Center(child: CircularProgressIndicator());
        } else if (error != null) {
          content = Center(child: Text('Error: $error'));
        } else {
          content = LayoutBuilder(
            builder: (context, constraints) {
              if (MediaQuery.of(context).size.width < 600) {
                return _buildMobileLayout(context, tripPlan);
              } else if (MediaQuery.of(context).size.width < 1200) {
                return _buildTabletLayout(context, tripPlan);
              } else {
                return _buildDesktopLayout(context, tripPlan);
              }
            },
          );
        }

        // Overlay a loading indicator if language is changing
        return Stack(
          children: [
            content,
            if (_isLoadingLanguageChange)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, tripPlan) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              TripHeaderSection(
                tripPlan: tripPlan,
                isDesktopView: false,
                isTabletView: false,
              ),
              const SizedBox(height: 16),
              TripCuisineSection(
                recommendations: tripPlan.localCuisineRecommendations,
              ),
              const SizedBox(height: 16),
              TripItinerarySection(tripPlan: tripPlan, isDesktopView: false),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TripMapSection(tripPlan: tripPlan),
              ),
            ],
          ),
        ),
        Positioned(top: 16, left: 16, child: _buildBackButton(context)),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, tripPlan) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 48),
                TripHeaderSection(
                  tripPlan: tripPlan,
                  isDesktopView: false,
                  isTabletView: true,
                ),
                const SizedBox(height: 16),
                TripCuisineSection(
                  recommendations: tripPlan.localCuisineRecommendations,
                ),
                const SizedBox(height: 24),
                TripItinerarySection(tripPlan: tripPlan, isDesktopView: true),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: TripMapSection(tripPlan: tripPlan),
                ),
              ],
            ),
          ),
        ),
        Positioned(top: 16, left: 16, child: _buildBackButton(context)),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, tripPlan) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                TripHeaderImage(
                  tripPlan: tripPlan,
                  isDesktopView: true,
                  isTabletView: false,
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 24.0),
                            child: TripHeaderContent(
                              tripPlan: tripPlan,
                              isDesktopView: true,
                              isTabletView: false,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TripItinerarySection(
                            tripPlan: tripPlan,
                            isDesktopView: true,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TripCuisineSection(
                            recommendations:
                                tripPlan.localCuisineRecommendations,
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: TripMapSection(tripPlan: tripPlan),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(top: 16, left: 24, child: _buildBackButton(context)),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
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
