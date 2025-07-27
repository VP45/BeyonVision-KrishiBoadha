import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class Farm {
  final List<LatLng> polygonPoints;
  final double area;
  final String? placeName;
  final String? address;

  Farm({
    required this.polygonPoints,
    required this.area,
    this.placeName,
    this.address,
  });
}

class FarmProvider with ChangeNotifier {
  Farm? _farm;
  final List<gmf.LatLng> _polygonPoints = [];
  bool _isConfirmed = false;

  Farm? get farm => _farm;
  List<gmf.LatLng> get polygonPoints => _polygonPoints;
  bool get isConfirmed => _isConfirmed;

  void addPolygonPoint(gmf.LatLng point) {
    _polygonPoints.add(point);
    notifyListeners();
  }

  void clearPolygonPoints() {
    _polygonPoints.clear();
    _isConfirmed = false;
    _farm = null;
    notifyListeners();
  }

  // Calculate polygon area using the shoelace formula
  double _calculatePolygonArea(List<gmf.LatLng> points) {
    if (points.length < 3) return 0.0;

    double area = 0.0;
    int j = points.length - 1;

    for (int i = 0; i < points.length; i++) {
      // Convert lat/lng to x/y coordinates (approximate)
      double xi =
          points[i].longitude *
          111320 *
          math.cos(points[i].latitude * math.pi / 180);
      double yi = points[i].latitude * 110540;
      double xj =
          points[j].longitude *
          111320 *
          math.cos(points[j].latitude * math.pi / 180);
      double yj = points[j].latitude * 110540;

      area += (xj + xi) * (yj - yi);
      j = i;
    }

    return (area / 2.0).abs();
  }

  void createFarm() async {
    if (_polygonPoints.length > 2) {
      // Calculate the actual area
      final area = _calculatePolygonArea(_polygonPoints);

      // Get the center point for geocoding
      final centerLat =
          _polygonPoints.map((p) => p.latitude).reduce((a, b) => a + b) /
          _polygonPoints.length;
      final centerLng =
          _polygonPoints.map((p) => p.longitude).reduce((a, b) => a + b) /
          _polygonPoints.length;

      String? placeName;
      String? address;

      try {
        final placemarks = await placemarkFromCoordinates(centerLat, centerLng);
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          placeName =
              placemark.locality ??
              placemark.subAdministrativeArea ??
              placemark.administrativeArea;
          address =
              '${placemark.street ?? ''} ${placemark.locality ?? ''} ${placemark.administrativeArea ?? ''} ${placemark.country ?? ''}'
                  .trim();
        }
      } catch (e) {
        // Geocoding failed, continue without place info
      }

      _farm = Farm(
        polygonPoints: List.from(_polygonPoints),
        area: area,
        placeName: placeName,
        address: address,
      );
      _isConfirmed = true;
    }
    notifyListeners();
  }
}
