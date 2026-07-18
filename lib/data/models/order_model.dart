import '../../core/constants/enums.dart';
import 'cart_item_model.dart';
import 'user_model.dart';

class OrderStatusHistory {
  final OrderStatus status;
  final DateTime timestamp;
  final String changedBy;
  final String note;

  OrderStatusHistory({
    required this.status,
    required this.timestamp,
    required this.changedBy,
    this.note = '',
  });
}

class OrderModel {
  final String id;
  final String customerId;
  final String storeId;
  String? courierId;
  final List<CartItem> items;
  final AddressModel address;
  final double customerLat;
  final double customerLng;
  final double storeLat;
  final double storeLng;
  double? courierLat;
  double? courierLng;
  OrderStatus status;
  final List<OrderStatusHistory> statusHistory;
  final PaymentMethod paymentMethod;
  PaymentStatus paymentStatus;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double discount;
  final double total;
  final DateTime createdAt;
  DateTime? deliveredAt;

  double get totalAmount => total;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.storeId,
    this.courierId,
    required this.items,
    required this.address,
    required this.customerLat,
    required this.customerLng,
    required this.storeLat,
    required this.storeLng,
    this.courierLat,
    this.courierLng,
    required this.status,
    List<OrderStatusHistory>? statusHistory,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    this.discount = 0.0,
    required this.total,
    required this.createdAt,
    this.deliveredAt,
  }) : statusHistory = statusHistory ?? [OrderStatusHistory(status: status, timestamp: createdAt, changedBy: 'System', note: 'Order placed')];

  void updateStatus(OrderStatus newStatus, String changedBy, {String note = ''}) {
    status = newStatus;
    statusHistory.add(OrderStatusHistory(status: newStatus, timestamp: DateTime.now(), changedBy: changedBy, note: note));
    if (newStatus == OrderStatus.delivered) {
      deliveredAt = DateTime.now();
    }
  }
}
