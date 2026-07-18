import '../../core/constants/enums.dart';

class StoreModel {
  final String id;
  final String ownerId;
  final String name;
  final StoreType type;
  final String? logo;
  final String? coverImage;
  final String phone;
  final String area;
  final String street;
  final String landmark;
  final double latitude;
  final double longitude;
  final String openingTime;
  final String closingTime;
  final String preparationTime;
  final double minimumOrder;
  final double deliveryFee;
  final String status;
  final double rating;
  final int ratingCount;

  StoreModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    this.logo,
    this.coverImage,
    required this.phone,
    required this.area,
    required this.street,
    required this.landmark,
    required this.latitude,
    required this.longitude,
    required this.openingTime,
    required this.closingTime,
    required this.preparationTime,
    required this.minimumOrder,
    required this.deliveryFee,
    this.status = 'active',
    this.rating = 5.0,
    this.ratingCount = 1,
  });

  String get imageUrl => logo ?? '';
  String get address => '$street, $area';
  String get merchantId => ownerId;


  StoreModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    StoreType? type,
    String? logo,
    String? coverImage,
    String? phone,
    String? area,
    String? street,
    String? landmark,
    double? latitude,
    double? longitude,
    String? openingTime,
    String? closingTime,
    String? preparationTime,
    double? minimumOrder,
    double? deliveryFee,
    String? status,
    double? rating,
    int? ratingCount,
  }) {
    return StoreModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      phone: phone ?? this.phone,
      area: area ?? this.area,
      street: street ?? this.street,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      preparationTime: preparationTime ?? this.preparationTime,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}
