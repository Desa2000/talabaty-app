import '../../core/constants/enums.dart';

class AddressModel {
  final String id;
  final String title;
  final String city;
  final String area;
  final String street;
  final String landmark;
  final double latitude;
  final double longitude;
  final String phone;

  AddressModel({
    required this.id,
    required this.title,
    required this.city,
    required this.area,
    required this.street,
    required this.landmark,
    required this.latitude,
    required this.longitude,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'area': area,
      'street': street,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
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
}

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String password;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;
  final String? fcmToken;
  final List<AddressModel>? savedAddresses;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.password,
    required this.role,
    this.profileImage,
    required this.createdAt,
    this.fcmToken,
    this.savedAddresses,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      password: json['password'] ?? '',
      role: UserRole.values.firstWhere((e) => e.toString() == json['role'], orElse: () => UserRole.customer),
      profileImage: json['profileImage'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      fcmToken: json['fcmToken'],
      savedAddresses: json['savedAddresses'] != null 
          ? (json['savedAddresses'] as List).map((i) => AddressModel.fromJson(i)).toList() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'role': role.toString(),
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'fcmToken': fcmToken,
      'savedAddresses': savedAddresses?.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomerProfile {
  final String userId;
  final List<AddressModel> addresses;
  final String? defaultAddressId;

  CustomerProfile({
    required this.userId,
    this.addresses = const [],
    this.defaultAddressId,
  });
}

class CourierProfile {
  final String userId;
  final String nationalId;
  final String dateOfBirth;
  final String emergencyPhone;
  final VehicleType vehicleType;
  final String? vehiclePlate;
  final String? vehicleColor;
  final String? vehicleModel;
  final bool hasDeliveryBox;
  final List<String> workingAreas;
  final double maxDeliveryDistance;
  double? currentLat;
  double? currentLng;
  CourierStatus status;
  final double rating;
  final int totalDeliveries;
  final double todayEarnings;
  final double cashCollected;

  CourierProfile({
    required this.userId,
    required this.nationalId,
    required this.dateOfBirth,
    required this.emergencyPhone,
    required this.vehicleType,
    this.vehiclePlate,
    this.vehicleColor,
    this.vehicleModel,
    this.hasDeliveryBox = false,
    this.workingAreas = const [],
    this.maxDeliveryDistance = 5.0,
    this.currentLat,
    this.currentLng,
    this.status = CourierStatus.offline,
    this.rating = 5.0,
    this.totalDeliveries = 0,
    this.todayEarnings = 0.0,
    this.cashCollected = 0.0,
  });
}

class MerchantProfile {
  final String userId;
  final String ownerName;
  final String storeId;

  MerchantProfile({
    required this.userId,
    required this.ownerName,
    required this.storeId,
  });
}
