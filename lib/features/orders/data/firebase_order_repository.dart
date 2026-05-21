import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cart/domain/entities/cart_line.dart';
import '../domain/entities/app_order.dart';
import '../domain/repositories/order_repository.dart';

class FirebaseOrderRepository implements OrderRepository {
  FirebaseOrderRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _orders => _db.collection('orders');

  @override
  @override
  Stream<List<AppOrder>> watchAllOrders() {
    return _orders.snapshots().map((snap) {
      final list = snap.docs.map(AppOrder.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  @override
  Stream<List<AppOrder>> watchUserOrders(String userId) {
    if (userId.isEmpty) {
      return Stream.value(const <AppOrder>[]);
    }
    return _orders.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs.map(AppOrder.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  @override
  Future<String?> placeOrder({
    required String userId,
    required String customerName,
    required String phone,
    String customerEmail = '',
    required List<CartLine> lines,
    required int subtotal,
    required int deliveryPrice,
    required int discount,
    required int totalPrice,
    required String address,
  }) async {
    if (userId.isEmpty || lines.isEmpty) return null;
    final trimmedAddress = address.trim();
    if (trimmedAddress.isEmpty) return null;

    final name = customerName.trim();
    final phoneTrim = phone.trim();
    final email = customerEmail.trim();

    final now = DateTime.now();
    final orderNo = 'CM-${now.millisecondsSinceEpoch % 100000}'.padLeft(7, '0');
    final ref = _orders.doc();

    await _db.runTransaction((tx) async {
      for (final line in lines) {
        final p = line.product;
        if (p.stock < 0) continue;
        final foodRef = _db.collection('foods').doc(p.id);
        final snap = await tx.get(foodRef);
        if (!snap.exists) continue;
        final current = (snap.data()?['stock'] as num?)?.toInt();
        if (current == null || current < 0) continue;
        final next = current - line.quantity;
        tx.update(foodRef, {'stock': next < 0 ? 0 : next});
      }
    });

    await _db.runTransaction((tx) async {
      for (final line in lines) {
        final p = line.product;
        if (p.stock < 0) continue;
        final foodRef = _db.collection('foods').doc(p.id);
        final snap = await tx.get(foodRef);
        if (!snap.exists) continue;
        final current = (snap.data()?['stock'] as num?)?.toInt();
        if (current == null || current < 0) continue;
        final next = current - line.quantity;
        tx.update(foodRef, {'stock': next < 0 ? 0 : next});
      }
    });

    await ref.set({
      'id': ref.id,
      'orderNumber': orderNo,
      'orderNo': orderNo,
      'userId': userId,
      'customerName': name,
      'userName': name,
      'phone': phoneTrim,
      'customerPhone': phoneTrim,
      if (email.isNotEmpty) ...{
        'customerEmail': email,
        'userEmail': email,
      },
      'items': lines.map((e) {
        return {
          'productId': e.product.id,
          'id': e.product.id,
          'name': e.product.name,
          'imageUrl': e.product.imageUrl,
          'price': e.product.price,
          'quantity': e.quantity,
        };
      }).toList(),
      'subtotal': subtotal,
      'deliveryPrice': deliveryPrice,
      'delivery': deliveryPrice,
      'deliveryFee': deliveryPrice,
      'discount': discount,
      'totalPrice': totalPrice,
      'total': totalPrice,
      'address': trimmedAddress,
      'status': 'pending',
      'itemCount': lines.fold<int>(0, (s, e) => s + e.quantity),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return orderNo;
  }

  @override
  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    if (orderId.isEmpty) return;
    await _orders.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
