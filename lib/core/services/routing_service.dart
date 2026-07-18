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
  static const String _baseUrl = 'http://router.project-osrm.org/route/v1/driving';

  Future<RouteResult?> getRoute(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');
          
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          
          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          final List<LatLng> points = coordinates.map((coord) {
            // OSRM returns [longitude, latitude]
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();
          
          return RouteResult(
            points: points,
            distanceInMeters: route['distance']?.toDouble() ?? 0.0,
            durationInSeconds: route['duration']?.toDouble() ?? 0.0,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch route from OSRM: $e');
    }
    return null;
  }
}
