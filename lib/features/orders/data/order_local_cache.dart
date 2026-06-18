import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/app_order.dart';
import '../domain/entities/order_status_codec.dart';

/// Offline cache for user order history (SharedPreferences).
class OrderLocalCache {
  OrderLocalCache._();

  static String _key(String userId) => 'order_history_cache_$userId';

  static Future<void> save(String userId, List<AppOrder> orders) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = orders.map(_orderToJson).toList();
      await prefs.setString(_key(userId), jsonEncode(payload));
    } catch (_) {}
  }

  static Future<List<AppOrder>> load(String userId) async {
    if (userId.isEmpty) return const [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(userId));
      if (raw == null || raw.isEmpty) return const [];
      final list = jsonDecode(raw) as List<dynamic>;
      final orders = list
          .whereType<Map>()
          .map((e) => _orderFromJson(Map<String, dynamic>.from(e)))
          .where((o) => o.id.isNotEmpty)
          .toList();
      return orders.where((o) {
        final owner = o.userId.trim();
        return owner.isEmpty || owner == userId;
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> clearForUser(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(userId));
    } catch (_) {}
  }

  /// Logout yoki account almashtirganda.
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('order_history_cache_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }

  static Map<String, dynamic> _orderToJson(AppOrder o) => {
        'id': o.id,
        'userId': o.userId,
        'customerName': o.customerName,
        'phone': o.phone,
        'items': o.items
            .map(
              (e) => {
                'productId': e.productId,
                'name': e.name,
                'price': e.price,
                'quantity': e.quantity,
                'imageUrl': e.imageUrl,
              },
            )
            .toList(),
        'totalPrice': o.totalPrice,
        'deliveryPrice': o.deliveryPrice,
        'address': o.address,
        'status': o.status,
        'createdAt': o.createdAt.toIso8601String(),
        'orderNumber': o.orderNumber,
        'orderId': o.orderId,
        'discount': o.discount,
        'subtotal': o.subtotal,
        'paymentMethod': o.paymentMethod,
      };

  static AppOrder _orderFromJson(Map<String, dynamic> m) {
    final itemsRaw = m['items'];
    final items = <AppOrderItem>[];
    if (itemsRaw is List) {
      for (final raw in itemsRaw) {
        if (raw is Map) {
          items.add(AppOrderItem.fromMap(Map<String, dynamic>.from(raw)));
        }
      }
    }
    return AppOrder(
      id: (m['id'] as String?) ?? '',
      userId: (m['userId'] as String?) ?? '',
      customerName: (m['customerName'] as String?) ?? '',
      phone: (m['phone'] as String?) ?? '',
      items: items,
      totalPrice: _readInt(m['totalPrice']),
      deliveryPrice: _readInt(m['deliveryPrice']),
      address: (m['address'] as String?) ?? '',
      status: (m['status'] as String?)?.trim().isNotEmpty == true
          ? (m['status'] as String).trim()
          : OrderStatusCodec.defaultStatus,
      createdAt: DateTime.tryParse((m['createdAt'] as String?) ?? '') ?? DateTime.now(),
      orderNumber: m['orderNumber'] as String?,
      orderId: m['orderId'] as String?,
      discount: _readInt(m['discount']),
      subtotal: _readInt(m['subtotal']),
      paymentMethod: (m['paymentMethod'] as String?) ?? 'cash',
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
