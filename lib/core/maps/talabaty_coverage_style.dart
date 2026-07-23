import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TalabatyCoverageStyle {
  static const Color activeFillColor = Color(0x33FF5722); // 20% opacity Orange
  static const Color activeStrokeColor = Color(0xFFFF5722); // Bold Orange

  static const Color comingSoonFillColor = Color(0x26FFC107); // Amber
  static const Color comingSoonStrokeColor = Color(0xFFFFC107);

  static const Color inactiveFillColor = Color(0x1A9E9E9E); // Muted Gray
  static const Color inactiveStrokeColor = Color(0xFF9E9E9E);

  /// Geofence boundary polygon for Khartoum Locality
  static final List<LatLng> khartoumBounds = [
    const LatLng(15.6100, 32.5000),
    const LatLng(15.6100, 32.6200),
    const LatLng(15.5200, 32.6200),
    const LatLng(15.5200, 32.5000),
  ];

  /// Geofence boundary polygon for Bahri Locality
  static final List<LatLng> bahriBounds = [
    const LatLng(15.7000, 32.5200),
    const LatLng(15.7000, 32.6500),
    const LatLng(15.6150, 32.6500),
    const LatLng(15.6150, 32.5200),
  ];

  /// Geofence boundary polygon for Omdurman Locality
  static final List<LatLng> omdurmanBounds = [
    const LatLng(15.6800, 32.4000),
    const LatLng(15.6800, 32.5000),
    const LatLng(15.5300, 32.5000),
    const LatLng(15.5300, 32.4000),
  ];

  static Set<Polygon> getKhartoumStateCoveragePolygons() {
    return {
      Polygon(
        polygonId: const PolygonId('khartoum_locality'),
        points: khartoumBounds,
        fillColor: activeFillColor,
        strokeColor: activeStrokeColor,
        strokeWidth: 3,
      ),
      Polygon(
        polygonId: const PolygonId('bahri_locality'),
        points: bahriBounds,
        fillColor: activeFillColor,
        strokeColor: activeStrokeColor,
        strokeWidth: 3,
      ),
      Polygon(
        polygonId: const PolygonId('omdurman_locality'),
        points: omdurmanBounds,
        fillColor: activeFillColor,
        strokeColor: activeStrokeColor,
        strokeWidth: 3,
      ),
    };
  }
}
