import 'dart:math';

/// Unified delivery fee and service fee calculator for the Talabaty app.
/// 
/// Rules:
///   Delivery fee = distance_km × 3000 SDG
///   Service fee  = subtotal    × 6%
class DeliveryFeeService {
  static const double _feePerKm = 3000.0;   // SDG per kilometer
  static const double _serviceRate = 0.06;  // 6 %

  /// Calculates the straight-line (Haversine) distance in kilometres between
  /// two geographic coordinates.
  static double distanceKm(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    const double earthRadius = 6371.0; // km
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double deg) => deg * pi / 180.0;

  /// Delivery fee for the given distance.
  static double deliveryFee(double distanceKm) =>
      (distanceKm * _feePerKm).ceilToDouble();

  /// Delivery fee calculated directly from two coordinates.
  static double deliveryFeeFromCoords(
    double customerLat, double customerLng,
    double storeLat,    double storeLng,
  ) {
    final km = distanceKm(customerLat, customerLng, storeLat, storeLng);
    return deliveryFee(km);
  }

  /// 6% service / platform fee on the products subtotal.
  static double serviceFee(double subtotal) =>
      (subtotal * _serviceRate).ceilToDouble();

  /// Full order total.
  static double orderTotal({
    required double subtotal,
    required double deliveryFee,
    required double serviceFee,
    double discount = 0,
  }) => subtotal + deliveryFee + serviceFee - discount;

  /// Human-readable price summary map — handy for UI widgets.
  static Map<String, double> priceSummary({
    required double subtotal,
    required double customerLat,
    required double customerLng,
    required double storeLat,
    required double storeLng,
    double discount = 0,
  }) {
    final km    = distanceKm(customerLat, customerLng, storeLat, storeLng);
    final dFee  = deliveryFee(km);
    final sFee  = serviceFee(subtotal);
    return {
      'subtotal':     subtotal,
      'deliveryFee':  dFee,
      'serviceFee':   sFee,
      'discount':     discount,
      'total':        orderTotal(subtotal: subtotal, deliveryFee: dFee, serviceFee: sFee, discount: discount),
      'distanceKm':   double.parse(km.toStringAsFixed(2)),
    };
  }
}
