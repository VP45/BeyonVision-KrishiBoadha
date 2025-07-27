import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myapp/providers/farm_providers.dart';
import 'package:myapp/features/onboarding/providers/onboarding_provider.dart';
import 'package:myapp/providers/ai_voice_providers.dart';

// Create a provider for FarmProvider
final farmProvider = ChangeNotifierProvider((ref) => FarmProvider());

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Polygon> _polygons = {};
  bool _hasGivenInitialGuidance = false;

  @override
  void initState() {
    super.initState();
    // Give initial voice guidance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _giveInitialGuidance();
    });
  }

  Future<void> _giveInitialGuidance() async {
    if (_hasGivenInitialGuidance) return;

    try {
      final aiService = ref.read(aiVoiceServiceProvider);
      await Future.delayed(const Duration(milliseconds: 500));
      await aiService.speak(
        'अब आपको अपने खेत की सीमा मैप पर दिखानी होगी। स्क्रीन पर टैप करके अपने खेत के कोने-कोने को चिह्नित करें। कम से कम तीन पॉइंट बनाने के बाद टिक का बटन दबाएं।',
      );
      _hasGivenInitialGuidance = true;
    } catch (e) {
      debugPrint('Error giving initial guidance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProviderNotifier = ref.watch(farmProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Map Your Farm', style: GoogleFonts.oswald()),
        actions: [
          if (!farmProviderNotifier.isConfirmed &&
              farmProviderNotifier.polygonPoints.length > 2)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                farmProviderNotifier.createFarm();

                // Voice confirmation
                try {
                  final aiService = ref.read(aiVoiceServiceProvider);
                  await aiService.speak(
                    'बहुत बढ़िया! आपके खेत की सीमा सफलतापूर्वक चिह्नित हो गई है।',
                  );
                } catch (e) {
                  debugPrint('Error speaking confirmation: $e');
                }

                setState(() {
                  _polygons.add(
                    Polygon(
                      polygonId: const PolygonId('farm'),
                      points: farmProviderNotifier.polygonPoints,
                      strokeWidth: 3,
                      strokeColor: Colors.green,
                      fillColor: Colors.green.withValues(alpha: 0.3),
                    ),
                  );
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              farmProviderNotifier.clearPolygonPoints();
              setState(() {
                _polygons.clear();
              });
            },
          ),
        ],
      ),
      body:
          farmProviderNotifier.isConfirmed
              ? _buildSplitView(farmProviderNotifier)
              : _buildFullScreenMap(farmProviderNotifier),
      floatingActionButton:
          farmProviderNotifier.isConfirmed
              ? FloatingActionButton.extended(
                onPressed: () async {
                  // Voice completion message
                  try {
                    final aiService = ref.read(aiVoiceServiceProvider);
                    await aiService.speak(
                      'बधाई हो! आपका पंजीकरण सफलतापूर्वक पूरा हो गया है। अब आप होम स्क्रीन पर जा रहे हैं।',
                    );
                  } catch (e) {
                    debugPrint('Error speaking completion message: $e');
                  }

                  // Complete the onboarding flow and move to home screen
                  ref
                      .read(onboardingProvider.notifier)
                      .completeMapFarmDetails();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User profile created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                label: const Text('Complete Setup'),
                icon: const Icon(Icons.check_circle),
                backgroundColor: Colors.green,
              )
              : null,
    );
  }

  Widget _buildFullScreenMap(FarmProvider farmProviderNotifier) {
    return GoogleMap(
      mapType: MapType.satellite,
      initialCameraPosition: const CameraPosition(
        target: LatLng(20.5937, 78.9629),
        zoom: 5,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      onTap: (point) {
        if (!farmProviderNotifier.isConfirmed) {
          farmProviderNotifier.addPolygonPoint(point);
          setState(() {
            _polygons = {
              Polygon(
                polygonId: const PolygonId('farm_preview'),
                points: [...farmProviderNotifier.polygonPoints],
                strokeWidth: 2,
                strokeColor: Colors.blue,
                fillColor: Colors.blue.withValues(alpha: 0.2),
              ),
            };
          });
        }
      },
      polygons: _polygons,
    );
  }

  Widget _buildSplitView(FarmProvider farmProviderNotifier) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.5937, 78.9629),
              zoom: 5,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              // Zoom to fit the polygon
              if (farmProviderNotifier.polygonPoints.isNotEmpty) {
                _fitPolygonBounds(
                  controller,
                  farmProviderNotifier.polygonPoints,
                );
              }
            },
            polygons: _polygons,
            zoomControlsEnabled: false,
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child:
                farmProviderNotifier.farm == null
                    ? const Center(
                      child: Text('Draw on the map to see details'),
                    )
                    : _buildFarmDetails(farmProviderNotifier.farm!),
          ),
        ),
      ],
    );
  }

  Widget _buildFarmDetails(Farm farm) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm Details',
            style: GoogleFonts.oswald(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 20),

          // Location Info Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Location',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (farm.placeName != null)
                    Text(
                      farm.placeName!,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (farm.address != null)
                    Text(
                      farm.address!,
                      style: GoogleFonts.roboto(fontSize: 14),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Area Info Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.landscape, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Area',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${farm.area.toStringAsFixed(2)} sq. meters',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    '${(farm.area / 10000).toStringAsFixed(4)} hectares',
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
                  Text(
                    '${(farm.area * 0.000247105).toStringAsFixed(4)} acres',
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Coordinates Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gps_fixed, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Coordinates',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Number of points: ${farm.polygonPoints.length}',
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: farm.polygonPoints.length,
                      itemBuilder: (context, index) {
                        final point = farm.polygonPoints[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            'Point ${index + 1}: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                            style: GoogleFonts.roboto(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fitPolygonBounds(GoogleMapController controller, List<LatLng> points) {
    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }
}
