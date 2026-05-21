import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class AppOrderItem {
  const AppOrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  final String productId;
  final String name;
  final int price;
  final int quantity;
  final String? imageUrl;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'id': productId,
        'name': name,
        'price': price,
        'quantity': quantity,
        if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
      };

  factory AppOrderItem.fromMap(Map<String, dynamic> map) {
    return AppOrderItem(
      productId: (map['productId'] ?? map['id'] ?? '') as String,
      name: (map['name'] as String?) ?? '',
      price: _readInt(map['price']),
      quantity: _readInt(map['quantity']).clamp(1, 999),
      imageUrl: (map['imageUrl'] as String?)?.trim(),
    );
  }
}

@immutable
class AppOrder {
  const AppOrder({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.phone,
    required this.items,
    required this.totalPrice,
    required this.deliveryPrice,
    required this.address,
    required this.status,
    required this.createdAt,
    this.orderNumber,
    this.discount = 0,
    this.subtotal = 0,
  });

  final String id;
  final String userId;
  final String customerName;
  final String phone;
  final List<AppOrderItem> items;
  final int totalPrice;
  final int deliveryPrice;
  final String address;
  final String status;
  final DateTime createdAt;
  final String? orderNumber;
  final int discount;
  final int subtotal;

  String get displayNumber => orderNumber ?? id;

  int get itemCount => items.fold<int>(0, (s, e) => s + e.quantity);

  factory AppOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final itemsRaw = data['items'];
    final items = <AppOrderItem>[];
    if (itemsRaw is List) {
      for (final raw in itemsRaw) {
        if (raw is Map<String, dynamic>) {
          items.add(AppOrderItem.fromMap(raw));
        } else if (raw is Map) {
          items.add(AppOrderItem.fromMap(Map<String, dynamic>.from(raw)));
        }
      }
    }

    return AppOrder(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      customerName: (data['customerName'] ?? data['userName'] as String?)?.toString().trim() ?? '',
      phone: (data['phone'] ?? data['customerPhone'] as String?)?.toString().trim() ?? '',
      items: items,
      totalPrice: _readInt(data['totalPrice'] ?? data['total']),
      deliveryPrice: _readInt(data['deliveryPrice'] ?? data['delivery'] ?? data['deliveryFee']),
      address: _parseAddress(data['address']),
      status: (data['status'] as String?)?.trim().toLowerCase() ?? 'pending',
      createdAt: _readDate(data['createdAt']) ?? DateTime.now(),
      orderNumber: (data['orderNumber'] ?? data['orderNo'] as String?)?.toString(),
      discount: _readInt(data['discount']),
      subtotal: _readInt(data['subtotal']),
    );
  }
}

String _parseAddress(dynamic value) {
  if (value is String) return value.trim();
  if (value is Map) {
    final parts = <String>[
      value['line1'],
      value['line2'],
      value['city'],
      value['notes'],
    ].whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty);
    return parts.join(', ');
  }
  return '';
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.replaceAll(RegExp(r'[\s,]'), '')) ?? 0;
  return 0;
}

DateTime? _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
