import 'product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  // Map of OptionGroupID -> List of selected OptionIDs
  Map<String, List<String>> selectedOptions;
  List<ProductAddOn> selectedAddOns;
  String notes;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedOptions = const {},
    this.selectedAddOns = const [],
    this.notes = '',
  });

  double get totalPrice {
    double base = product.discountPrice ?? product.price;
    
    // Add extra price from options
    double optionsPrice = 0.0;
    product.optionGroups.forEach((group) {
      if (selectedOptions.containsKey(group.id)) {
        final selectedIds = selectedOptions[group.id]!;
        for (var optId in selectedIds) {
          final opt = group.options.firstWhere((o) => o.id == optId, orElse: () => ProductOption(id: '', name: '', extraPrice: 0));
          optionsPrice += opt.extraPrice;
        }
      }
    });

    double addOnsPrice = selectedAddOns.fold(0, (sum, addOn) => sum + addOn.price);
    return (base + optionsPrice + addOnsPrice) * quantity;
  }
}
