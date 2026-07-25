import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../network/api_client.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceInMeters;
  final double durationInSeconds;
  final String source;

  const RouteResult({
    required this.points,
    required this.distanceInMeters,
    required this.durationInSeconds,
    required this.source,
  });
}

class RoutingService {
  Future<RouteResult?> getRoute(
    LatLng start,
    LatLng end, {
    String vehicleType = 'MOTORCYCLE',
  }) async {
    try {
      final response = await ApiClient().dio.post(
        '/routing/route',
        data: {
          'origin': {
            'latitude': start.latitude,
            'longitude': start.longitude,
          },
          'destination': {
            'latitude': end.latitude,
            'longitude': end.longitude,
          },
          'vehicleType': vehicleType,
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      final dynamic rawData = response.data;

      if (rawData is! Map) {
        return null;
      }

      final data = Map<String, dynamic>.from(rawData);

      final encoded =
          data['encodedPolyline']?.toString() ?? '';

      // Do not draw a fake straight-line route.
      if (encoded.isEmpty) {
        debugPrint(
          '[RoutingService] No road polyline returned '
          '(source: ${data['status']}).',
        );
        return null;
      }

      final distance =
          (data['distanceMeters'] as num?)?.toDouble();

      final duration =
          (data['durationSeconds'] as num?)?.toDouble();

      if (distance == null || duration == null) {
        return null;
      }

      final points = _decodePolyline(encoded);

      if (points.length < 2) {
        return null;
      }

      return RouteResult(
        points: points,
        distanceInMeters: distance,
        durationInSeconds: duration,
        source: data['status']?.toString() ?? 'UNKNOWN',
      );
    } catch (e) {
      debugPrint(
        '[RoutingService] Secure backend route failed: $e',
      );

      // No fabricated route on failure.
      return null;
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];

    int index = 0;
    int latitude = 0;
    int longitude = 0;

    try {
      while (index < encoded.length) {
        int result = 0;
        int shift = 0;
        int byte;

        do {
          if (index >= encoded.length) {
            return const [];
          }

          byte = encoded.codeUnitAt(index++) - 63;
          result |= (byte & 0x1f) << shift;
          shift += 5;
        } while (byte >= 0x20);

        final latitudeChange =
            (result & 1) != 0
                ? ~(result >> 1)
                : result >> 1;

        latitude += latitudeChange;

        result = 0;
        shift = 0;

        do {
          if (index >= encoded.length) {
            return const [];
          }

          byte = encoded.codeUnitAt(index++) - 63;
          result |= (byte & 0x1f) << shift;
          shift += 5;
        } while (byte >= 0x20);

        final longitudeChange =
            (result & 1) != 0
                ? ~(result >> 1)
                : result >> 1;

        longitude += longitudeChange;

        points.add(
          LatLng(
            latitude / 1e5,
            longitude / 1e5,
          ),
        );
      }
    } catch (e) {
      debugPrint(
        '[RoutingService] Invalid encoded polyline: $e',
      );
      return const [];
    }

    return points;
  }
}