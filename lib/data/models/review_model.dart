class ReviewModel {
  final String id;
  final String orderId;
  final String customerId;
  final String targetId; // could be storeId or courierId
  final double rating;
  final String? comment;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.targetId,
    required this.rating,
    this.comment,
  });
}
