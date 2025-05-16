import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/domain/models/trip_day.dart';
import 'package:intl/intl.dart';
import 'attraction_item.dart';

class TripDayCard extends StatelessWidget {
  final TripDay day;
  final bool isDesktopView;

  const TripDayCard({Key? key, required this.day, this.isDesktopView = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat(
      'd MMMM',
      Localizations.localeOf(context).languageCode,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      day.dayNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(day.date),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Day description
            Text(
              day.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Attractions title
            Text(
              tr(context, 'tripDetail.attractions'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Attractions list - passing down the isDesktopView flag
            ...day.attractions.map(
              (attraction) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AttractionItem(
                  attraction: attraction,
                  isDesktopView: isDesktopView,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
