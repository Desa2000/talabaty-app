import '../../data/models/order_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/store_model.dart';
import '../../core/constants/enums.dart';

class FirebaseMapper {
  // ---------------- STORE ----------------
  static Map<String, dynamic> storeToJson(StoreModel store) {
    return {
      'id': store.id,
      'ownerId': store.ownerId,
      'name': store.name,
      'type': store.type.toString(),
      'logo': store.logo,
      'coverImage': store.coverImage,
      'phone': store.phone,
      'area': store.area,
      'street': store.street,
      'landmark': store.landmark,
      'latitude': store.latitude,
      'longitude': store.longitude,
      'openingTime': store.openingTime,
      'closingTime': store.closingTime,
      'preparationTime': store.preparationTime,
      'minimumOrder': store.minimumOrder,
      'deliveryFee': store.deliveryFee,
      'status': store.status,
      'rating': store.rating,
      'ratingCount': store.ratingCount,
    };
  }

  static StoreModel storeFromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? '',
      type: StoreType.values.firstWhere((e) => e.toString() == json['type'], orElse: () => StoreType.restaurant),
      logo: json['logo'],
      coverImage: json['coverImage'],
      phone: json['phone'] ?? '',
      area: json['area'] ?? '',
      street: json['street'] ?? '',
      landmark: json['landmark'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      preparationTime: json['preparationTime'] ?? '',
      minimumOrder: (json['minimumOrder'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      rating: (json['rating'] ?? 5.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 1,
    );
  }

  // ---------------- ORDER ----------------
  static Map<String, dynamic> orderToJson(OrderModel order) {
    return {
      'id': order.id,
      'customerId': order.customerId,
      'storeId': order.storeId,
      'courierId': order.courierId,
      'items': order.items.map((i) => cartItemToJson(i)).toList(),
      'address': addressToJson(order.address),
      'customerLat': order.customerLat,
      'customerLng': order.customerLng,
      'storeLat': order.storeLat,
      'storeLng': order.storeLng,
      'courierLat': order.courierLat,
      'courierLng': order.courierLng,
      'status': order.status.toString(),
      'statusHistory': order.statusHistory.map((h) => historyToJson(h)).toList(),
      'paymentMethod': order.paymentMethod.toString(),
      'paymentStatus': order.paymentStatus.toString(),
      'subtotal': order.subtotal,
      'deliveryFee': order.deliveryFee,
      'serviceFee': order.serviceFee,
      'discount': order.discount,
      'total': order.total,
      'createdAt': order.createdAt.toIso8601String(),
      'deliveredAt': order.deliveredAt?.toIso8601String(),
    };
  }

  static OrderModel orderFromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      storeId: json['storeId'] ?? '',
      courierId: json['courierId'],
      items: (json['items'] as List?)?.map((i) => cartItemFromJson(Map<String, dynamic>.from(i as Map))).toList() ?? [],
      address: addressFromJson(Map<String, dynamic>.from(json['address'] as Map)),
      customerLat: (json['customerLat'] ?? 0).toDouble(),
      customerLng: (json['customerLng'] ?? 0).toDouble(),
      storeLat: (json['storeLat'] ?? 0).toDouble(),
      storeLng: (json['storeLng'] ?? 0).toDouble(),
      courierLat: json['courierLat'] != null ? (json['courierLat'] as num).toDouble() : null,
      courierLng: json['courierLng'] != null ? (json['courierLng'] as num).toDouble() : null,
      status: OrderStatus.values.firstWhere((e) => e.toString() == json['status'], orElse: () => OrderStatus.pending),
      statusHistory: (json['statusHistory'] as List?)?.map((h) => historyFromJson(Map<String, dynamic>.from(h as Map))).toList() ?? [],
      paymentMethod: PaymentMethod.values.firstWhere((e) => e.toString() == json['paymentMethod'], orElse: () => PaymentMethod.cashOnDelivery),
      paymentStatus: PaymentStatus.values.firstWhere((e) => e.toString() == json['paymentStatus'], orElse: () => PaymentStatus.unpaid),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      serviceFee: (json['serviceFee'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      deliveredAt: json['deliveredAt'] != null ? DateTime.tryParse(json['deliveredAt']) : null,
    );
  }

  // ---------------- CART ITEM ----------------
  static Map<String, dynamic> cartItemToJson(CartItem item) {
    return {
      'product': productToJson(item.product),
      'quantity': item.quantity,
      'selectedOptions': item.selectedOptions,
      'selectedAddOns': item.selectedAddOns.map((a) => addOnToJson(a)).toList(),
      'notes': item.notes,
    };
  }

  static CartItem cartItemFromJson(Map<String, dynamic> json) {
    // Need to safely cast Map<String, dynamic> to Map<String, List<String>>
    Map<String, List<String>> safeSelectedOptions = {};
    if (json['selectedOptions'] != null) {
      final Map<String, dynamic> rawOptions = json['selectedOptions'];
      rawOptions.forEach((key, value) {
        if (value is List) {
          safeSelectedOptions[key] = value.map((e) => e.toString()).toList();
        }
      });
    }

    return CartItem(
      product: productFromJson(Map<String, dynamic>.from(json['product'] as Map)),
      quantity: json['quantity'] ?? 1,
      selectedOptions: safeSelectedOptions,
      selectedAddOns: (json['selectedAddOns'] as List?)?.map((a) => addOnFromJson(Map<String, dynamic>.from(a as Map))).toList() ?? [],
      notes: json['notes'] ?? '',
    );
  }

  // ---------------- PRODUCT ----------------
  static Map<String, dynamic> productToJson(ProductModel product) {
    return {
      'id': product.id,
      'storeId': product.storeId,
      'name': product.name,
      'description': product.description,
      'image': product.image,
      'category': product.category,
      'price': product.price,
      'discountPrice': product.discountPrice,
      'stockQuantity': product.stockQuantity,
      'lowStockThreshold': product.lowStockThreshold,
      'preparationTimeMinutes': product.preparationTimeMinutes,
      'isAvailable': product.isAvailable,
      'isFeatured': product.isFeatured,
      'allowCustomerNotes': product.allowCustomerNotes,
      'optionGroups': product.optionGroups.map((g) => optionGroupToJson(g)).toList(),
      'addOns': product.addOns.map((a) => addOnToJson(a)).toList(),
      'createdAt': product.createdAt.toIso8601String(),
      'updatedAt': product.updatedAt.toIso8601String(),
    };
  }

  static ProductModel productFromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discountPrice'] != null ? (json['discountPrice'] as num).toDouble() : null,
      stockQuantity: json['stockQuantity'] ?? 0,
      lowStockThreshold: json['lowStockThreshold'] ?? 5,
      preparationTimeMinutes: json['preparationTimeMinutes'] ?? 15,
      isAvailable: json['isAvailable'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      allowCustomerNotes: json['allowCustomerNotes'] ?? true,
      optionGroups: (json['optionGroups'] as List?)?.map((g) => optionGroupFromJson(Map<String, dynamic>.from(g as Map))).toList() ?? [],
      addOns: (json['addOns'] as List?)?.map((a) => addOnFromJson(Map<String, dynamic>.from(a as Map))).toList() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  // ---------------- OPTION GROUP ----------------
  static Map<String, dynamic> optionGroupToJson(ProductOptionGroup group) {
    return {
      'id': group.id,
      'name': group.name,
      'isRequired': group.isRequired,
      'minSelection': group.minSelection,
      'maxSelection': group.maxSelection,
      'options': group.options.map((o) => optionToJson(o)).toList(),
    };
  }

  static ProductOptionGroup optionGroupFromJson(Map<String, dynamic> json) {
    return ProductOptionGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isRequired: json['isRequired'] ?? false,
      minSelection: json['minSelection'] ?? 0,
      maxSelection: json['maxSelection'] ?? 1,
      options: (json['options'] as List?)?.map((o) => optionFromJson(Map<String, dynamic>.from(o as Map))).toList() ?? [],
    );
  }

  // ---------------- OPTION ----------------
  static Map<String, dynamic> optionToJson(ProductOption option) {
    return {
      'id': option.id,
      'name': option.name,
      'extraPrice': option.extraPrice,
    };
  }

  static ProductOption optionFromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      extraPrice: (json['extraPrice'] ?? 0).toDouble(),
    );
  }

  // ---------------- ADD-ON ----------------
  static Map<String, dynamic> addOnToJson(ProductAddOn addOn) {
    return {
      'id': addOn.id,
      'name': addOn.name,
      'price': addOn.price,
      'isAvailable': addOn.isAvailable,
    };
  }

  static ProductAddOn addOnFromJson(Map<String, dynamic> json) {
    return ProductAddOn(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  // ---------------- ADDRESS ----------------
  static Map<String, dynamic> addressToJson(AddressModel address) {
    return {
      'id': address.id,
      'title': address.title,
      'city': address.city,
      'area': address.area,
      'street': address.street,
      'landmark': address.landmark,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'phone': address.phone,
    };
  }

  static AddressModel addressFromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      street: json['street'] ?? '',
      landmark: json['landmark'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      phone: json['phone'] ?? '',
    );
  }

  // ---------------- STATUS HISTORY ----------------
  static Map<String, dynamic> historyToJson(OrderStatusHistory history) {
    return {
      'status': history.status.toString(),
      'timestamp': history.timestamp.toIso8601String(),
      'changedBy': history.changedBy,
      'note': history.note,
    };
  }

  static OrderStatusHistory historyFromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      status: OrderStatus.values.firstWhere((e) => e.toString() == json['status'], orElse: () => OrderStatus.pending),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      changedBy: json['changedBy'] ?? '',
      note: json['note'] ?? '',
    );
  }
}
