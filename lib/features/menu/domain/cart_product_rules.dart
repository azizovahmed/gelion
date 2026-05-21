import 'home_product.dart';

/// Zaxira: `stock < 0` cheksiz; `0` tugagan; `> 0` miqdorli.
abstract final class CartProductRules {
  static const int unlimitedStock = -1;

  static bool tracksStock(HomeProduct product) => product.stock >= 0;

  static bool isOutOfStock(HomeProduct product) =>
      !product.isActive || product.stock == 0;

  static bool canAddMore(HomeProduct product, int cartQuantity) {
    if (isOutOfStock(product)) return false;
    if (!tracksStock(product)) return true;
    return cartQuantity < product.stock;
  }

  /// `null` — qo‘shish mumkin; `out` | `stock` | `inactive`
  static String? blockReason({
    required HomeProduct product,
    required int cartQuantityForProduct,
    required int addCount,
  }) {
    if (!product.isActive) return 'inactive';
    if (product.stock == 0) return 'out';
    if (!tracksStock(product)) return null;
    final next = cartQuantityForProduct + addCount;
    if (next > product.stock) return 'stock';
    return null;
  }
}
