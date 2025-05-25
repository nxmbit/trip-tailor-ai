import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';

class TripCuisineSection extends StatelessWidget {
  final List<String> recommendations;

  const TripCuisineSection({Key? key, required this.recommendations})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(context, 'tripDetail.localCuisine'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                recommendations
                    .map(
                      (dish) => Chip(
                        label: Text(dish),
                        avatar: const Icon(Icons.restaurant),
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}
