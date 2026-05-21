import '../../../menu/domain/home_product.dart';

/// Single row in the food cart (mutable quantity; shell owns the list).
class CartLine {
  CartLine({required this.product, this.quantity = 1});

  final HomeProduct product;
  int quantity;
}
