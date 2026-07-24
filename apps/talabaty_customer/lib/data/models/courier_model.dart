import '../../core/constants/enums.dart';

class Courier {
  final String id;
  final String name;
  final String phone;
  final String imageUrl;
  final VehicleType vehicleType;
  CourierStatus status;
  final double rating;
  final int completedDeliveries;
  final double todayEarnings;

  Courier({
    required this.id,
    required this.name,
    required this.phone,
    required this.imageUrl,
    required this.vehicleType,
    this.status = CourierStatus.offline,
    required this.rating,
    this.completedDeliveries = 0,
    this.todayEarnings = 0.0,
  });
}
