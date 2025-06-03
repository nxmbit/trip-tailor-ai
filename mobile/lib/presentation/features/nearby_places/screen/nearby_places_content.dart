import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/presentation/state/providers/nearby_places_provider.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/presentation/features/trip/widgets/attraction_item.dart';

class NearbyPlacesContent extends StatefulWidget {
  const NearbyPlacesContent({Key? key}) : super(key: key);

  @override
  State<NearbyPlacesContent> createState() => _NearbyPlacesContentState();
}

class _NearbyPlacesContentState extends State<NearbyPlacesContent> {
  bool _isLoading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};
  CameraPosition? _initialPosition;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndNearbyPlaces();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationAndNearbyPlaces() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(tr(context, 'location.permissionDenied'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(tr(context, 'location.permissionPermanentlyDenied'));
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Set initial map position
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        );
      });

      // Get nearby places
      final provider = Provider.of<NearbyPlacesProvider>(context, listen: false);
      final language = Provider.of<LanguageProvider>(context, listen: false)
          .locale.languageCode;

      await provider.fetchNearbyPlaces(
        latitude: position.latitude,
        longitude: position.longitude,
        language: language,
      );

      // Create markers for places
      if (provider.nearbyPlaces != null) {
        final places = provider.nearbyPlaces!;
        final markers = <Marker>{};

        // Add current location marker
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(title: tr(context, 'nearbyPlaces.currentLocation')),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );

        // Add attraction markers
        for (final attraction in places.attractions) {
          if (attraction.latitude != null && attraction.longitude != null) {
            markers.add(
              Marker(
                markerId: MarkerId(attraction.name),
                position: LatLng(attraction.latitude!, attraction.longitude!),
                infoWindow: InfoWindow(
                  title: attraction.name,
                  snippet: attraction.description,
                ),
                onTap: () {
                  // When marker is tapped, animate to its position
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(attraction.latitude!, attraction.longitude!),
                        zoom: 16,
                      ),
                    ),
                  );
                },
              ),
            );
          }
        }

        setState(() {
          _markers = markers;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildContent(),
          // Back button positioned at the top left, matching trip detail style
          if(!_isLoading)
          Positioned(top: 16, left: 16, child: _buildBackButton(context)),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => context.go('/home'),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(tr(context, 'nearbyPlaces.loading')),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getCurrentLocationAndNearbyPlaces,
                child: Text(tr(context, 'nearbyPlaces.retry')),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<NearbyPlacesProvider>(
      builder: (context, provider, _) {
        final places = provider.nearbyPlaces;

        return Column(
          children: [
            // Add padding at the top to make space for the back button
            const SizedBox(height: 32),
            // Reduced map height (was flex: 3, now flex: 2)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _initialPosition != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: _initialPosition!,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
                )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "${tr(context, 'nearbyPlaces.title')} ${places?.destination}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Expanded list section (was flex: 2, now flex: 3)
            Expanded(
              flex: 3,
              child: places != null && places.attractions.isNotEmpty
                  ? ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: places.attractions.length,
                itemBuilder: (context, index) {
                  final attraction = places.attractions[index];
                  return GestureDetector(
                    onTap: () {
                      // When list item is tapped, focus on the marker
                      if (attraction.latitude != null && attraction.longitude != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(attraction.latitude!, attraction.longitude!),
                              zoom: 16,
                            ),
                          ),
                        );
                      }
                    },
                    // Use the AttractionItem widget that already exists
                    child: AttractionItem(attraction: attraction),
                  );
                },
              )
                  : Center(child: Text(tr(context, 'nearbyPlaces.noPlacesFound'))),
            ),
          ],
        );
      },
    );
  }
}