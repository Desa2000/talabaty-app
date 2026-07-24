import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ─── Route result returned from backend ──────────────────────────────────────
class RouteResult {
  final List<LatLng> points;
  final double distanceInMeters;
  final double durationInSeconds;
  final String
  source; // 'GOOGLE_ROUTES' | 'FALLBACK_OSRM' | 'FALLBACK_HAVERSINE'

  const RouteResult({
    required this.points,
    required this.distanceInMeters,
    required this.durationInSeconds,
    required this.source,
  });
}

// ─── Backend-proxied routing (no Google key in Flutter) ──────────────────────
class RoutingService {
  static const String _backendApiUrl =
      'https://api.mytalabaty.com/api/routing/route';

  /// Fetches a route from the backend.
  /// Falls back to two-point straight line on any network failure.
  Future<RouteResult?> getRoute(
    LatLng start,
    LatLng end, {
    String vehicleType = 'MOTORCYCLE',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_backendApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'origin': {
                'latitude': start.latitude,
                'longitude': start.longitude,
              },
              'destination': {
                'latitude': end.latitude,
                'longitude': end.longitude,
              },
              'vehicleType': vehicleType,
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final encoded = (data['encodedPolyline'] as String?) ?? '';
        final points = encoded.isNotEmpty
            ? _decodePolyline(encoded)
            : [start, end];

        return RouteResult(
          points: points,
          distanceInMeters: (data['distanceMeters'] as num).toDouble(),
          durationInSeconds: (data['durationSeconds'] as num).toDouble(),
          source: data['status'] ?? 'UNKNOWN',
        );
      }
    } catch (e) {
      debugPrint('[RoutingService] backend route failed: $e');
    }

    // Straight-line fallback
    return RouteResult(
      points: [start, end],
      distanceInMeters: _haversineMeters(start, end),
      durationInSeconds: _haversineMeters(start, end) / 8.0, // ~28 km/h
      source: 'FALLBACK_HAVERSINE',
    );
  }

  // ─── Haversine (client-side, diagnostics / fallback only) ──────────────────
  static double _haversineMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLon = _rad(b.longitude - a.longitude);
    final x = (dLat / 2).abs();
    final y = (dLon / 2).abs();
    // simplified — good enough for pre-filtering
    final dist =
        R *
        2 *
        _asin(
          (x * x + _cos(_rad(a.latitude)) * _cos(_rad(b.latitude)) * y * y)
              .clamp(0.0, 1.0)
              .sqrt(),
        );
    return dist;
  }

  // ─── Google encoded-polyline decoder ───────────────────────────────────────
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  static double _rad(double deg) => deg * 3.141592653589793 / 180;
  static double _cos(double v) => v < -1 ? -1 : (v > 1 ? 1 : v);
  static double _asin(double v) {
    // Taylor approximation (accurate enough for display)
    return v + (v * v * v) / 6.0 + (3 * v * v * v * v * v) / 40.0;
  }
}

extension _NumSqrt on double {
  double sqrt() => this < 0 ? 0 : _sqrt(this);
  static double _sqrt(double v) {
    double x = v, y = 1.0;
    while ((x - y) > 0.0001) {
      x = (x + y) / 2;
      y = v / x;
    }
    return x;
  }
}
