import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../domain/models/trip_plan.dart';
import 'package:url_launcher/url_launcher.dart';

class TripMapSection extends StatefulWidget {
  final TripPlan tripPlan;

  const TripMapSection({Key? key, required this.tripPlan}) : super(key: key);

  @override
  State<TripMapSection> createState() => _TripMapSectionState();
}

class _TripMapSectionState extends State<TripMapSection> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Map<int, Color> _dayColors = {};
  CameraPosition? _initialPosition;
  bool _isMapReady = false;
  bool _isError = false;
  String _errorMessage = "";
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Delay map initialization to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _setupMap();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_controller.isCompleted) {
      _controller.future.then((controller) => controller.dispose());
    }
    super.dispose();
  }

  Color _getColorForDay(int dayNumber) {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.teal,
    ];
    return colors[(dayNumber - 1) % colors.length];
  }

  // Create a default marker using BitmapDescriptor.defaultMarker
  BitmapDescriptor _getDefaultMarker(Color color) {
    // Convert color to a hue value (0-360)
    final hue = HSVColor.fromColor(color).hue;
    return BitmapDescriptor.defaultMarkerWithHue(hue);
  }

  // Funkcja do generowania niestandardowego markera z numerem i kolorem
  Future<BitmapDescriptor> _createCustomMarker(int dayNumber, int visitOrder) async {
    final int size = 90;
    final Color color = _getColorForDay(dayNumber);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..color = color;
    // Rysuj kółko
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.5, paint);
    // Rysuj numer
    final textPainter = TextPainter(
      text: TextSpan(
        text: visitOrder.toString(),
        style: TextStyle(
          fontSize: size / 2.2,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );
    final img = await recorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  void _openInGoogleMaps(String placeId) async {
    final url = 'https://www.google.com/maps/place/?q=place_id:$placeId';

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr(context, 'common.cannotOpenUrl'))),
        );
      }
    }
  }

  void _setupMap() async {
    if (_isDisposed || !mounted) return;

    try {
      _markers = {};
      _dayColors = {};
      LatLng? firstAttractionPosition;
      _initialPosition = const CameraPosition(
        target: LatLng(48.8566, 2.3522),
        zoom: 5,
      );
      List<Future<Marker>> markerFutures = [];
      for (int i = 0; i < widget.tripPlan.itinerary.length; i++) {
        if (_isDisposed || !mounted) return;
        final day = widget.tripPlan.itinerary[i];
        final dayNumber = day.dayNumber;
        _dayColors[dayNumber] = _getColorForDay(dayNumber);
        for (final attraction in day.attractions) {
          if (_isDisposed || !mounted) return;
          if (attraction.latitude != null && attraction.longitude != null) {
            final position = LatLng(
              attraction.latitude!,
              attraction.longitude!,
            );
            firstAttractionPosition ??= position;
            markerFutures.add(_createCustomMarker(dayNumber, attraction.visitOrder).then((markerIcon) {
              final String infoTitle = attraction.name;
              return Marker(
                markerId: MarkerId('${dayNumber}_${attraction.visitOrder}_${attraction.name}'),
                position: position,
                infoWindow: InfoWindow(title: infoTitle),
                icon: markerIcon,
              );
            }));
          }
        }
      }
      final markers = await Future.wait(markerFutures);
      _markers = markers.toSet();
      if (firstAttractionPosition != null) {
        _initialPosition = CameraPosition(
          target: firstAttractionPosition,
          zoom: 13,
        );
      }
      if (!_isDisposed && mounted) {
        setState(() {
          _isMapReady = true;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isMapReady = true;
          _isError = true;
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error setting up map: ${e.toString()}")),
        );
      }
    }
  }

  Widget _buildMapLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          widget.tripPlan.itinerary.map((day) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _dayColors[day.dayNumber] ?? Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text('${tr(context, 'tripDetail.day')} ${day.dayNumber}'),
              ],
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context, 'tripDetail.mapView'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: _buildMapContent(),
        ),
        if (_isMapReady &&
            !_isError &&
            widget.tripPlan.itinerary.isNotEmpty &&
            _dayColors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildMapLegend(),
          ),
      ],
    );
  }

  Widget _buildMapContent() {
    if (!_isMapReady || _initialPosition == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading map..."),
          ],
        ),
      );
    }

    if (_isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Could not load the map. Please try again later.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isMapReady = false;
                    _isError = false;
                  });
                  _setupMap();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // Use the simpler GoogleMap implementation
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GoogleMap(
        initialCameraPosition: _initialPosition!,
        markers: _markers,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          if (!_controller.isCompleted) {
            _controller.complete(controller);
          }

        },
        myLocationEnabled: false,
        compassEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
        // Enable lite mode to improve performance
        liteModeEnabled: false,
        // Improve responsiveness
        cameraTargetBounds: CameraTargetBounds.unbounded,
      ),
    );
  }
}
