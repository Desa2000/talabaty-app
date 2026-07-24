class MerchantModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final List<String> storeIds;
  double todaysSales;

  MerchantModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.storeIds = const [],
    this.todaysSales = 0.0,
  });
}
