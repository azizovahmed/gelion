import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../menu/domain/cart_product_rules.dart';
import '../../menu/domain/home_product.dart';
import '../domain/entities/cart_line.dart';

/// Savatni qurilma xotirasida saqlash (app qayta ochilganda tiklanadi).
abstract final class CartPersistence {
  static const _key = 'gelion_cart_v1';

  static Future<List<CartLine>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final lines = <CartLine>[];
      for (final item in list) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item);
        final id = (m['id'] as String?)?.trim() ?? '';
        final name = (m['name'] as String?)?.trim() ?? '';
        if (id.isEmpty || name.isEmpty) continue;
        final qty = (m['quantity'] as num?)?.toInt() ?? 1;
        if (qty < 1) continue;
        lines.add(
          CartLine(
            product: HomeProduct(
              id: id,
              name: name,
              price: (m['price'] as num?)?.toInt() ?? 0,
              imageUrl: (m['imageUrl'] as String?)?.trim() ?? '',
              categoryId: (m['categoryId'] as String?)?.trim(),
              stock: (m['stock'] as num?)?.toInt() ?? CartProductRules.unlimitedStock,
              isActive: m['isActive'] as bool? ?? true,
            ),
            quantity: qty,
          ),
        );
      }
      return lines;
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<CartLine> lines) async {
    final prefs = await SharedPreferences.getInstance();
    if (lines.isEmpty) {
      await prefs.remove(_key);
      return;
    }
    final encoded = jsonEncode(
      lines
          .map(
            (e) => {
              'id': e.product.id,
              'name': e.product.name,
              'price': e.product.price,
              'imageUrl': e.product.imageUrl,
              'categoryId': e.product.categoryId,
              'stock': e.product.stock,
              'isActive': e.product.isActive,
              'quantity': e.quantity,
            },
          )
          .toList(),
    );
    await prefs.setString(_key, encoded);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
