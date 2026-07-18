class ProductOption {
  final String id;
  final String name;
  final double extraPrice;

  ProductOption({required this.id, required this.name, required this.extraPrice});
}

class ProductOptionGroup {
  final String id;
  final String name;
  final bool isRequired;
  final int minSelection;
  final int maxSelection;
  final List<ProductOption> options;

  ProductOptionGroup({
    required this.id,
    required this.name,
    this.isRequired = false,
    this.minSelection = 0,
    this.maxSelection = 1,
    this.options = const [],
  });
}

class ProductAddOn {
  final String id;
  final String name;
  final double price;
  final bool isAvailable;

  ProductAddOn({
    required this.id, 
    required this.name, 
    required this.price,
    this.isAvailable = true,
  });
}

class ProductModel {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final String image;
  final String category;
  final double price;
  final double? discountPrice;
  int stockQuantity;
  final int lowStockThreshold;
  final int preparationTimeMinutes;
  bool isAvailable;
  final bool isFeatured;
  final bool allowCustomerNotes;
  final List<ProductOptionGroup> optionGroups;
  final List<ProductAddOn> addOns;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.price,
    this.discountPrice,
    required this.stockQuantity,
    this.lowStockThreshold = 5,
    this.preparationTimeMinutes = 15,
    this.isAvailable = true,
    this.isFeatured = false,
    this.allowCustomerNotes = true,
    this.optionGroups = const [],
    this.addOns = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  ProductModel copyWith({
    String? id,
    String? storeId,
    String? name,
    String? description,
    String? image,
    String? category,
    double? price,
    double? discountPrice,
    int? stockQuantity,
    int? lowStockThreshold,
    int? preparationTimeMinutes,
    bool? isAvailable,
    bool? isFeatured,
    bool? allowCustomerNotes,
    List<ProductOptionGroup>? optionGroups,
    List<ProductAddOn>? addOns,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      preparationTimeMinutes: preparationTimeMinutes ?? this.preparationTimeMinutes,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      allowCustomerNotes: allowCustomerNotes ?? this.allowCustomerNotes,
      optionGroups: optionGroups ?? this.optionGroups,
      addOns: addOns ?? this.addOns,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
