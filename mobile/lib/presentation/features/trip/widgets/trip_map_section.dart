// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:frontend/core/utils/translation_helper.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import '../../../../domain/models/trip_plan.dart';
// import 'package:url_launcher/url_launcher.dart';
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
//   Set<Marker> _markers = {};
//   Map<int, Color> _dayColors = {};
//   CameraPosition? _initialPosition;
//   bool _isMapReady = false;
//   bool _isError = false;
//   String _errorMessage = "";
//   bool _isDisposed = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // Delay map initialization to ensure context is available
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_isDisposed) {
//         _setupMap();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     if (_controller.isCompleted) {
//       _controller.future.then((controller) => controller.dispose());
//     }
//     super.dispose();
//   }
//
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
//   // Create a default marker using BitmapDescriptor.defaultMarker
//   BitmapDescriptor _getDefaultMarker(Color color) {
//     // Convert color to a hue value (0-360)
//     final hue = HSVColor.fromColor(color).hue;
//     return BitmapDescriptor.defaultMarkerWithHue(hue);
//   }
//
//   void _openInGoogleMaps(String placeId) async {
//     final url = 'https://www.google.com/maps/place/?q=place_id:$placeId';
//
//     try {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(tr(context, 'common.cannotOpenUrl'))),
//         );
//       }
//     }
//   }
//
//   void _setupMap() async {
//     if (_isDisposed || !mounted) return;
//
//     try {
//       _markers = {};
//       _dayColors = {};
//       LatLng? firstAttractionPosition;
//
//       // Set a default position (centered on Europe as a fallback)
//       _initialPosition = const CameraPosition(
//         target: LatLng(48.8566, 2.3522), // Paris coordinates as default
//         zoom: 5,
//       );
//
//       for (int i = 0; i < widget.tripPlan.itinerary.length; i++) {
//         if (_isDisposed || !mounted) return;
//
//         final day = widget.tripPlan.itinerary[i];
//         final dayNumber = day.dayNumber;
//
//         _dayColors[dayNumber] = _getColorForDay(dayNumber);
//
//         for (final attraction in day.attractions) {
//           if (_isDisposed || !mounted) return;
//
//           if (attraction.latitude != null && attraction.longitude != null) {
//             final position = LatLng(
//               attraction.latitude!,
//               attraction.longitude!,
//             );
//
//             // Set first found attraction position
//             firstAttractionPosition ??= position;
//
//             // Use default markers instead of custom ones
//             final markerIcon = _getDefaultMarker(_dayColors[dayNumber]!);
//
//             final String infoTitle = attraction.name;
//             String infoSnippet = '';
//
//             if (attraction.googlePlacesId != null &&
//                 attraction.googlePlacesId!.isNotEmpty) {
//               infoSnippet +=
//                   mounted ? tr(context, 'tripDetail.viewOnGoogleMaps') : '';
//
//               _markers.add(
//                 Marker(
//                   markerId: MarkerId(
//                     '${dayNumber}_${attraction.visitOrder}_${attraction.name}',
//                   ),
//                   position: position,
//                   infoWindow: InfoWindow(
//                     title: infoTitle,
//                     snippet: infoSnippet,
//                     onTap: () {
//                       if (attraction.googlePlacesId != null) {
//                         _openInGoogleMaps(attraction.googlePlacesId!);
//                       }
//                     },
//                   ),
//                   icon: markerIcon,
//                 ),
//               );
//             } else {
//               _markers.add(
//                 Marker(
//                   markerId: MarkerId(
//                     '${dayNumber}_${attraction.visitOrder}_${attraction.name}',
//                   ),
//                   position: position,
//                   infoWindow: InfoWindow(title: infoTitle),
//                   icon: markerIcon,
//                 ),
//               );
//             }
//           }
//         }
//       }
//
//       if (firstAttractionPosition != null) {
//         _initialPosition = CameraPosition(
//           target: firstAttractionPosition,
//           zoom: 13,
//         );
//       }
//
//       if (!_isDisposed && mounted) {
//         setState(() {
//           _isMapReady = true;
//         });
//       }
//     } catch (e) {
//       if (!_isDisposed && mounted) {
//         setState(() {
//           _isMapReady = true;
//           _isError = true;
//           _errorMessage = e.toString();
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error setting up map: ${e.toString()}")),
//         );
//       }
//     }
//   }
//
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
//                     color: _dayColors[day.dayNumber] ?? Colors.grey,
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
//           child: _buildMapContent(),
//         ),
//         if (_isMapReady &&
//             !_isError &&
//             widget.tripPlan.itinerary.isNotEmpty &&
//             _dayColors.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(top: 12),
//             child: _buildMapLegend(),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildMapContent() {
//     if (!_isMapReady || _initialPosition == null) {
//       return const Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text("Loading map..."),
//           ],
//         ),
//       );
//     }
//
//     if (_isError) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.error_outline,
//                 color: Theme.of(context).colorScheme.error,
//                 size: 48,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 "Could not load the map. Please try again later.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Theme.of(context).colorScheme.error),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _isMapReady = false;
//                     _isError = false;
//                   });
//                   _setupMap();
//                 },
//                 child: const Text("Retry"),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     // Use the simpler GoogleMap implementation
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: GoogleMap(
//         initialCameraPosition: _initialPosition!,
//         markers: _markers,
//         mapType: MapType.normal,
//         onMapCreated: (GoogleMapController controller) {
//           if (!_controller.isCompleted) {
//             _controller.complete(controller);
//           }
//
//           // Apply custom map style to avoid gray tiles issue
//           _setMapStyle(controller);
//         },
//         myLocationEnabled: false,
//         compassEnabled: true,
//         zoomControlsEnabled: true,
//         mapToolbarEnabled: false,
//         // Enable lite mode to improve performance
//         liteModeEnabled: false,
//         // Improve responsiveness
//         cameraTargetBounds: CameraTargetBounds.unbounded,
//       ),
//     );
//   }
//
//   // Add map style to ensure tiles load correctly
//   Future<void> _setMapStyle(GoogleMapController controller) async {
//     try {
//       String style = '''
//       [
//         {
//           "featureType": "all",
//           "elementType": "all",
//           "stylers": [
//             {
//               "visibility": "on"
//             }
//           ]
//         }
//       ]
//       ''';
//       await controller.setMapStyle(style);
//     } catch (e) {
//       print("Error setting map style: $e");
//     }
//   }
// }
