// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:frontend/core/utils/translation_helper.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../../../../domain/models/trip_plan.dart';
// import 'dart:js' as js;
//
// class TripMapSection extends StatefulWidget {
//   final TripPlan tripPlan;
//
//   const TripMapSection({Key? key, required this.tripPlan}) : super(key: key);
//
//   @override
//   State<TripMapSection> createState() => _TripMapSectionState();
// }
//
// class _TripMapSectionState extends State<TripMapSection> {
//   final Completer<GoogleMapController> _controller = Completer();
//   late Set<Marker> _markers;
//   late Map<int, Color> _dayColors;
//   CameraPosition? _initialPosition;
//   bool _isMapReady = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _setupMap();
//   }
//
//   // Define color palette for days
//   Color _getColorForDay(int dayNumber) {
//     List<Color> colors = [
//       Colors.red,
//       Colors.blue,
//       Colors.green,
//       Colors.orange,
//       Colors.purple,
//       Colors.cyan,
//       Colors.pink,
//       Colors.amber,
//       Colors.indigo,
//       Colors.teal,
//     ];
//     return colors[(dayNumber - 1) % colors.length];
//   }
//
//   Future<BitmapDescriptor> _createCustomMarkerBitmap(
//     Color color,
//     int visitOrder,
//   ) async {
//     // Create a PictureRecorder to record drawing operations
//     final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
//     final Canvas canvas = Canvas(pictureRecorder);
//     final Paint paint = Paint()..color = color;
//     final TextPainter textPainter = TextPainter(
//       text: TextSpan(
//         text: visitOrder.toString(),
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 20, // Smaller font size (was 30)
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     );
//
//     // Measure the text
//     textPainter.layout();
//
//     // Size for the marker
//     const double size = 35; // Smaller overall size (was 80)
//     const double circleRadius = size / 2;
//
//     // Draw a circle
//     canvas.drawCircle(
//       const Offset(circleRadius, circleRadius),
//       circleRadius,
//       paint,
//     );
//
//     // Draw border
//     const double borderWidth = 2.0; // Slightly thinner border (was 2.5)
//     canvas.drawCircle(
//       const Offset(circleRadius, circleRadius),
//       circleRadius - borderWidth / 2,
//       Paint()
//         ..color = Colors.white
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = borderWidth,
//     );
//
//     // Position the text in the center
//     final double textX = (size - textPainter.width) / 2;
//     final double textY = (size - textPainter.height) / 2;
//     textPainter.paint(canvas, Offset(textX, textY));
//
//     // Rest of method unchanged
//     final ui.Image image = await pictureRecorder.endRecording().toImage(
//       size.toInt(),
//       size.toInt(),
//     );
//     final ByteData? byteData = await image.toByteData(
//       format: ui.ImageByteFormat.png,
//     );
//
//     if (byteData == null) {
//       throw Exception('Failed to generate marker image');
//     }
//
//     return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
//   }
//
//   void _openInGoogleMaps(String placeId) {
//     final url = 'https://www.google.com/maps/place/?q=place_id:$placeId';
//
//     // If running on the web, use js.context to open in a new tab
//     if (kIsWeb) {
//       js.context.callMethod('open', [url, '_blank']);
//     } else {
//       // For mobile, you would use url_launcher package
//       // launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     }
//   }
//
//   void _setupMap() async {
//     // Initialize collections
//     _markers = {};
//     _dayColors = {};
//     List<LatLng> validPositions = [];
//     LatLng? firstAttractionPosition;
//
//     // Create cache of custom markers for better performance
//     Map<String, BitmapDescriptor> customMarkerCache = {};
//
//     // Process each day in the itinerary
//     for (int i = 0; i < widget.tripPlan.itinerary.length; i++) {
//       final day = widget.tripPlan.itinerary[i];
//       final dayNumber = day.dayNumber;
//
//       // Assign a color for this day
//       _dayColors[dayNumber] = _getColorForDay(dayNumber);
//
//       // Create a marker for each attraction in this day
//       // Create a marker for each attraction in this day
//       for (final attraction in day.attractions) {
//         if (attraction.latitude != null && attraction.longitude != null) {
//           final position = LatLng(attraction.latitude!, attraction.longitude!);
//           validPositions.add(position);
//
//           // Save position of first valid attraction
//           firstAttractionPosition ??= position;
//
//           // Cache key for the custom marker
//           final cacheKey = '${dayNumber}_${attraction.visitOrder}';
//
//           // Create the custom marker if not already in cache
//           if (!customMarkerCache.containsKey(cacheKey)) {
//             final customMarker = await _createCustomMarkerBitmap(
//               _dayColors[dayNumber]!,
//               attraction.visitOrder,
//             );
//             customMarkerCache[cacheKey] = customMarker;
//           }
//
//           // Prepare info window content
//           final String infoTitle = attraction.name;
//           String infoSnippet = '';
//
//           // Add "View on Google Maps" link if place has a Google Places ID
//           if (attraction.googlePlacesId != null &&
//               attraction.googlePlacesId!.isNotEmpty) {
//             infoSnippet += tr(context, 'tripDetail.viewOnGoogleMaps');
//
//             _markers.add(
//               Marker(
//                 markerId: MarkerId(
//                   '${dayNumber}_${attraction.visitOrder}_${attraction.name}',
//                 ),
//                 position: position,
//                 infoWindow: InfoWindow(
//                   title: infoTitle,
//                   snippet: infoSnippet,
//                   onTap: () {
//                     _openInGoogleMaps(attraction.googlePlacesId!);
//                   },
//                 ),
//                 icon: customMarkerCache[cacheKey]!,
//               ),
//             );
//           } else {
//             // No Google Places ID, just show regular info window
//             _markers.add(
//               Marker(
//                 markerId: MarkerId(
//                   '${dayNumber}_${attraction.visitOrder}_${attraction.name}',
//                 ),
//                 position: position,
//                 infoWindow: InfoWindow(title: infoTitle, snippet: infoSnippet),
//                 icon: customMarkerCache[cacheKey]!,
//               ),
//             );
//           }
//         }
//       }
//     }
//
//     // Set initial camera position
//     if (firstAttractionPosition != null) {
//       _initialPosition = CameraPosition(
//         target: firstAttractionPosition,
//         zoom: 14,
//       );
//     } else {
//       _initialPosition = CameraPosition(target: const LatLng(0, 0), zoom: 10);
//     }
//
//     setState(() {
//       _isMapReady = true;
//     });
//   }
//
//   // Build a legend to explain marker colors
//   Widget _buildMapLegend() {
//     return Wrap(
//       spacing: 16,
//       runSpacing: 8,
//       children:
//           widget.tripPlan.itinerary.map((day) {
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 16,
//                   height: 16,
//                   decoration: BoxDecoration(
//                     color: _dayColors[day.dayNumber],
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 Text('${tr(context, 'tripDetail.day')} ${day.dayNumber}'),
//               ],
//             );
//           }).toList(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           tr(context, 'tripDetail.mapView'),
//           style: Theme.of(
//             context,
//           ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         Container(
//           height: 300,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: Theme.of(context).colorScheme.outlineVariant,
//             ),
//           ),
//           child:
//               _isMapReady
//                   ? ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: GoogleMap(
//                       initialCameraPosition: _initialPosition!,
//                       markers: _markers,
//                       mapType: MapType.normal,
//                       onMapCreated: (GoogleMapController controller) {
//                         _controller.complete(controller);
//                       },
//                       myLocationEnabled: false,
//                       compassEnabled: true,
//                       zoomControlsEnabled: true,
//                     ),
//                   )
//                   : const Center(child: CircularProgressIndicator()),
//         ),
//         if (_isMapReady && widget.tripPlan.itinerary.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(top: 12),
//             child: _buildMapLegend(),
//           ),
//       ],
//     );
//   }
// }
