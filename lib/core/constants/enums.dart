enum UserRole {
  customer,
  merchant,
  courier,
  admin,
}

enum OrderStatus {
  pending,
  acceptedByMerchant,
  rejectedByMerchant,
  preparing,
  readyForPickup,
  searchingCourier,
  assignedToCourier,
  courierGoingToStore,
  courierArrivedStore,
  pickedUp,
  onTheWay,
  courierArrivedCustomer,
  delivered,
  cancelled,
}

enum PaymentMethod {
  cashOnDelivery,
  bankak,
  cashi,
}

enum PaymentStatus {
  unpaid,
  paid,
  failed,
  pending_cash_collection,
  refunded,
}

enum VehicleType {
  motorcycle,
  car,
  electricBike,
  bicycle,
}

enum StoreType {
  restaurant,
  supermarket,
  pharmacy,
  gift,
}

enum CourierStatus {
  available,
  busy,
  offline,
}

extension OrderStatusExtension on OrderStatus {
  String get arabicLabel {
    switch (this) {
      case OrderStatus.pending:
        return 'في انتظار قبول المحل';
      case OrderStatus.acceptedByMerchant:
        return 'تم قبول الطلب';
      case OrderStatus.rejectedByMerchant:
        return 'تم رفض الطلب';
      case OrderStatus.preparing:
        return 'جاري تجهيز الطلب';
      case OrderStatus.readyForPickup:
        return 'الطلب جاهز للاستلام';
      case OrderStatus.searchingCourier:
        return 'جاري البحث عن مندوب';
      case OrderStatus.assignedToCourier:
        return 'تم تعيين مندوب';
      case OrderStatus.courierGoingToStore:
        return 'المندوب في الطريق للمحل';
      case OrderStatus.courierArrivedStore:
        return 'المندوب وصل للمحل';
      case OrderStatus.pickedUp:
        return 'تم استلام الطلب';
      case OrderStatus.onTheWay:
        return 'الطلب في الطريق إليك';
      case OrderStatus.courierArrivedCustomer:
        return 'المندوب وصل لموقع العميل';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'تم الإلغاء';
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get arabicLabel {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'غير مدفوع';
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.failed:
        return 'فشلت العملية';
      case PaymentStatus.pending_cash_collection:
        return 'في انتظار التحصيل النقدي';
      case PaymentStatus.refunded:
        return 'تم الاسترجاع';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get arabicLabel {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return 'الدفع عند الاستلام';
      case PaymentMethod.bankak:
        return 'تطبيق بنكك';
      case PaymentMethod.cashi:
        return 'كاشي';
    }
  }
}
