import 'package:flutter/material.dart';
import 'package:frontend/presentation/features/home/widgets/example_trip_item.dart';

import '../../../../core/utils/translation_helper.dart';

//TODO: Split into state

class ExampleTripSection extends StatelessWidget {
  const ExampleTripSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Demo data
    final destinations = [
      ExampleTripItemData(
        destination: 'Rome, Italy',
        imageUrl:
            'https://images.unsplash.com/photo-1552832230-c0197dd311b5?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        days: 5,
      ),
      ExampleTripItemData(
        destination: 'Barcelona, Spain',
        imageUrl:
            'https://images.unsplash.com/photo-1583422409516-2895a77efded?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        days: 7,
      ),
      ExampleTripItemData(
        destination: 'Santorini, Greece',
        imageUrl:
            'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        days: 4,
      ),
      ExampleTripItemData(
        destination: 'Dubai, UAE',
        imageUrl:
            'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        days: 6,
      ),
      ExampleTripItemData(
        destination: 'Sydney, Australia',
        imageUrl:
            'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
        days: 8,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'home.exampleTripsTitle'),
          style: Theme.of(context).textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: destinations.length,
          itemBuilder:
              (context, index) => ExampleTripItem(data: destinations[index]),
        ),
      ],
    );
  }
}

class ExampleTripItemData {
  final String destination;
  final String imageUrl;
  final int days;

  ExampleTripItemData({
    required this.destination,
    required this.imageUrl,
    required this.days,
  });
}
