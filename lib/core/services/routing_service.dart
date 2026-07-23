import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceInMeters;
  final double durationInSeconds;

  RouteResult({
    required this.points,
    required this.distanceInMeters,
    required this.durationInSeconds,
  });
}

class RoutingService {
  static const String _backendApiUrl = 'https://api.mytalabaty.com/api/routing/route';
  static const String _osrmUrl = 'http://router.project-osrm.org/route/v1/driving';

  Future<RouteResult?> getRoute(LatLng start, LatLng end, {String vehicleType = 'MOTORCYCLE'}) async {
    // 1. Try Backend Routes API Endpoint
    try {
      final response = await http.post(
        Uri.parse(_backendApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'origin': {'latitude': start.latitude, 'longitude': start.longitude},
          'destination': {'latitude': end.latitude, 'longitude': end.longitude},
          'vehicleType': vehicleType,
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['encodedPolyline'] != null && (data['encodedPolyline'] as String).isNotEmpty) {
          final points = _decodePolyline(data['encodedPolyline']);
          return RouteResult(
            points: points,
            distanceInMeters: (data['distanceMeters'] as num).toDouble(),
            durationInSeconds: (data['durationSeconds'] as num).toDouble(),
          );
        }
      }
    } catch (e) {
      debugPrint('Backend routing fallback to OSRM: $e');
    }

    // 2. Fallback to OSRM
    try {
      final url = Uri.parse(
          '$_osrmUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');
      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;

          final List<LatLng> points = coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();

          return RouteResult(
            points: points,
            distanceInMeters: (route['distance'] as num).toDouble(),
            durationInSeconds: (route['duration'] as num).toDouble(),
          );
        }
      }
    } catch (e) {
      debugPrint('OSRM routing failed, using straight-line fallback: $e');
    }

    // 3. Fallback to Straight-Line
    return RouteResult(
      points: [start, end],
      distanceInMeters: 2500,
      durationInSeconds: 600,
    );
  }

  /// Decode Google Encoded Polyline String to List of LatLng points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
