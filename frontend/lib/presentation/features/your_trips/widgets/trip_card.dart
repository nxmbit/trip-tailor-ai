import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../../../domain/models/trip_plan_info.dart';
import '../../../../core/utils/translation_helper.dart';
import '../../../state/providers/trip_plan_provider.dart';

class TripCard extends StatelessWidget {
  final TripPlanInfo trip;
  final Function? onDeleted;

  const TripCard({Key? key, required this.trip, this.onDeleted})
    : super(key: key);

  Future<void> _confirmAndDeleteTrip(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(tr(context, 'trip.deleteConfirmationTitle')),
              content: Text(tr(context, 'trip.deleteConfirmationMessage')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(tr(context, 'trip.cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text(tr(context, 'trip.delete')),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    // Blokujemy wielokrotne usuwanie przez pokazanie wskaźnika ładowania
    bool isDeleting = true;

    // Pokaż wskaźnik ładowania
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text(tr(context, 'trip.deleting')),
            ],
          ),
          duration: const Duration(seconds: 30),
          // Ignorujemy akcję zamknięcia podczas usuwania
          dismissDirection:
              isDeleting ? DismissDirection.none : DismissDirection.horizontal,
        ),
      );

    try {
      final provider = Provider.of<TripPlanProvider>(context, listen: false);
      await provider.deleteTripPlan(trip.id);

      if (context.mounted) {
        // Ukryj wskaźnik ładowania
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        isDeleting = false;

        // Pokaż komunikat o powodzeniu
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr(context, 'trip.deleteSuccess')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Wywołaj callback po usunięciu - to ponownie załaduje dane
        if (onDeleted != null) {
          // Dodaj małe opóźnienie, żeby nie blokować interfejsu
          Future.delayed(const Duration(milliseconds: 100), () {
            onDeleted!();
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Ukryj wskaźnik ładowania
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        isDeleting = false;

        // Pokaż błąd
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr(context, 'trip.deleteFailed')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/your-trips/${trip.id}'),
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child:
                  trip.imageUrl.isNotEmpty
                      ? Hero(
                        tag: 'trip-image-${trip.id}',
                        child: FadeInImage.memoryNetwork(
                          placeholder:
                              kTransparentImage, // wymaga pakietu transparent_image
                          image: trip.imageUrl,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 300),
                          imageErrorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.3),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        trip.destination,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ),
                      )
                      : Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                trip.destination,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
            // Ikona usuwania w prawym górnym rogu
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmAndDeleteTrip(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            // Destination overlay
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Text(
                  trip.destination,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Date range overlay
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Text(
                  _formatDateRange(trip.travelStartDate, trip.travelEndDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Trip length overlay
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.tripLength} ${tr(context, trip.tripLength == 1 ? 'home.day' : 'home.days')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final DateFormat formatter = DateFormat('d/M/yyyy');

    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
}
