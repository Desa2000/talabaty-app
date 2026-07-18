import 'dart:convert';
import '../models/user_model.dart';
import '../models/store_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../../core/constants/enums.dart';

class DataMapper {
  static String encodeUsers(List<UserModel> users) {
    return jsonEncode(users.map((u) => <String, dynamic>{
      'id': u.id,
      'name': u.name,
      'phone': u.phone,
      'email': u.email,
      'password': u.password,
      'role': u.role.name,
      'profileImage': u.profileImage,
      'createdAt': u.createdAt.toIso8601String(),
    }).toList());
  }

  static List<UserModel> decodeUsers(String jsonStr) {
    final List<dynamic> data = jsonDecode(jsonStr);
    return List<UserModel>.from(data.map((d) => UserModel(
      id: d['id'] ?? '',
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'],
      password: d['password'] ?? '',
      role: UserRole.values.firstWhere((e) => e.name == d['role'], orElse: () => UserRole.customer),
      profileImage: d['profileImage'],
      createdAt: d['createdAt'] != null ? DateTime.tryParse(d['createdAt']) ?? DateTime.now() : DateTime.now(),
    )));
  }

  static String encodeStores(List<StoreModel> stores) {
    return jsonEncode(stores.map((s) => <String, dynamic>{
      'id': s.id,
      'ownerId': s.ownerId,
      'name': s.name,
      'type': s.type.name,
      'logo': s.logo,
      'coverImage': s.coverImage,
      'phone': s.phone,
      'area': s.area,
      'street': s.street,
      'landmark': s.landmark,
      'latitude': s.latitude,
      'longitude': s.longitude,
      'openingTime': s.openingTime,
      'closingTime': s.closingTime,
      'preparationTime': s.preparationTime,
      'minimumOrder': s.minimumOrder,
      'deliveryFee': s.deliveryFee,
      'status': s.status,
      'rating': s.rating,
    }).toList());
  }

  static List<StoreModel> decodeStores(String jsonStr) {
    final List<dynamic> data = jsonDecode(jsonStr);
    return List<StoreModel>.from(data.map((d) => StoreModel(
      id: d['id'] ?? '',
      ownerId: d['ownerId'] ?? '',
      name: d['name'] ?? '',
      type: StoreType.values.firstWhere((e) => e.name == d['type'], orElse: () => StoreType.restaurant),
      logo: d['logo'],
      coverImage: d['coverImage'],
      phone: d['phone'] ?? '',
      area: d['area'] ?? '',
      street: d['street'] ?? '',
      landmark: d['landmark'] ?? '',
      latitude: (d['latitude'] ?? 0).toDouble(),
      longitude: (d['longitude'] ?? 0).toDouble(),
      openingTime: d['openingTime'] ?? '',
      closingTime: d['closingTime'] ?? '',
      preparationTime: d['preparationTime'] ?? '',
      minimumOrder: (d['minimumOrder'] ?? 0).toDouble(),
      deliveryFee: (d['deliveryFee'] ?? 0).toDouble(),
      status: d['status'] ?? 'active',
      rating: d['rating']?.toDouble() ?? 5.0,
    )));
  }

  static String encodeProducts(List<ProductModel> products) {
    return jsonEncode(products.map((p) => <String, dynamic>{
      'id': p.id,
      'storeId': p.storeId,
      'name': p.name,
      'description': p.description,
      'price': p.price,
      'image': p.image,
      'category': p.category,
      'stockQuantity': p.stockQuantity,
    }).toList());
  }

  static List<ProductModel> decodeProducts(String jsonStr) {
    final List<dynamic> data = jsonDecode(jsonStr);
    return List<ProductModel>.from(data.map((d) => ProductModel(
      id: d['id'] ?? '',
      storeId: d['storeId'] ?? '',
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      price: (d['price'] ?? 0).toDouble(),
      image: d['image'] ?? '',
      category: d['category'] ?? '',
      stockQuantity: d['stockQuantity'] ?? 0,
      createdAt: DateTime.now(), // Simplified
      updatedAt: DateTime.now(),
    )));
  }

  static String encodeCouriers(List<CourierProfile> couriers) {
    return jsonEncode(couriers.map((c) => <String, dynamic>{
      'userId': c.userId,
      'nationalId': c.nationalId,
      'dateOfBirth': c.dateOfBirth,
      'emergencyPhone': c.emergencyPhone,
      'vehicleType': c.vehicleType.name,
      'vehiclePlate': c.vehiclePlate,
      'vehicleColor': c.vehicleColor,
      'vehicleModel': c.vehicleModel,
      'hasDeliveryBox': c.hasDeliveryBox,
      'status': c.status.name,
    }).toList());
  }

  static List<CourierProfile> decodeCouriers(String jsonStr) {
    final List<dynamic> data = jsonDecode(jsonStr);
    return List<CourierProfile>.from(data.map((d) => CourierProfile(
      userId: d['userId'] ?? '',
      nationalId: d['nationalId'] ?? '',
      dateOfBirth: d['dateOfBirth'] ?? '',
      emergencyPhone: d['emergencyPhone'] ?? '',
      vehicleType: VehicleType.values.firstWhere((e) => e.name == d['vehicleType'], orElse: () => VehicleType.motorcycle),
      vehiclePlate: d['vehiclePlate'],
      vehicleColor: d['vehicleColor'],
      vehicleModel: d['vehicleModel'],
      hasDeliveryBox: d['hasDeliveryBox'] ?? false,
      status: CourierStatus.values.firstWhere((e) => e.name == d['status'], orElse: () => CourierStatus.offline),
    )));
  }
}
