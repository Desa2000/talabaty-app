import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum DeliveryPhase {
  courierToStore,
  storeToCustomer,
  completed,
}

class TalabatyRouteStyle {
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color deepOrange = Color(0xFFD84315);
  static const Color mutedGray = Color(0xFF9E9E9E);

  /// Build Branded Polyline based on order delivery phase
  static Polyline buildRoutePolyline({
    required String polylineId,
    required List<LatLng> points,
    required DeliveryPhase phase,
  }) {
    Color routeColor = primaryOrange;
    int width = 6;
    List<PatternItem> patterns = [];

    if (phase == DeliveryPhase.courierToStore) {
      routeColor = primaryOrange; // Bright Talabaty Orange for first leg
      width = 7;
    } else if (phase == DeliveryPhase.storeToCustomer) {
      routeColor = deepOrange; // Deep Orange for final delivery leg
      width = 7;
    } else {
      routeColor = mutedGray;
      patterns = [PatternItem.dash(20), PatternItem.gap(10)];
    }

    return Polyline(
      polylineId: PolylineId(polylineId),
      points: points,
      color: routeColor,
      width: width,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      patterns: patterns,
    );
  }
}
