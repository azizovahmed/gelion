import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cart/domain/entities/cart_line.dart';
import '../domain/entities/app_order.dart';
import '../domain/entities/order_status_codec.dart';
import '../domain/repositories/order_repository.dart';
import 'order_local_cache.dart';
import 'order_user_scope.dart';

class FirebaseOrderRepository implements OrderRepository {
  FirebaseOrderRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const int defaultPageSize = 20;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  CollectionReference<Map<String, dynamic>> _userOrdersMirror(String userId) =>
      _db.collection('users').doc(userId).collection('orders');

  static List<AppOrder> _parseAndSort(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String ownerUserId,
  ) {
    final seen = <String>{};
    final list = <AppOrder>[];
    for (final doc in docs) {
      if (!seen.add(doc.id)) continue;
      list.add(AppOrder.fromDoc(doc));
    }
    return filterOrdersForUser(list, ownerUserId)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static bool _isIndexError(Object error) {
    return error is FirebaseException &&
        (error.code == 'failed-precondition' ||
            error.message?.toLowerCase().contains('index') == true);
  }

  @override
  Stream<List<AppOrder>> watchAllOrders() {
    return _orders
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) {
          final list = <AppOrder>[];
          final seen = <String>{};
          for (final doc in snap.docs) {
            if (!seen.add(doc.id)) continue;
            list.add(AppOrder.fromDoc(doc));
          }
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  @override
  Stream<List<AppOrder>> watchUserOrders(
    String userId, {
    int limit = defaultPageSize,
  }) {
    final uid = resolveOrdersUserId(userId);
    if (uid.isEmpty) {
      return Stream.value(const <AppOrder>[]);
    }

    final controller = StreamController<List<AppOrder>>.broadcast();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;
    var useFallback = false;

    void publish(List<AppOrder> orders) {
      if (!controller.isClosed) {
        OrderLocalCache.save(uid, orders);
        controller.add(orders);
      }
    }

    void listenFallback() {
      useFallback = true;
      sub?.cancel();
      sub = _orders.where('userId', isEqualTo: uid).snapshots().listen(
        (snap) {
          final sorted = _parseAndSort(snap.docs, uid);
          publish(sorted.take(limit).toList());
        },
        onError: (Object e, StackTrace _) {
          if (!controller.isClosed) controller.addError(e);
        },
      );
    }

    void listenIndexed() {
      sub = _orders
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .listen(
        (snap) {
          publish(_parseAndSort(snap.docs, uid));
        },
        onError: (Object e, StackTrace _) {
          if (!useFallback && _isIndexError(e)) {
            listenFallback();
          } else if (!controller.isClosed) {
            controller.addError(e);
          }
        },
      );
    }

    listenIndexed();

    controller.onCancel = () async {
      await sub?.cancel();
    };

    return controller.stream;
  }

  @override
  Stream<AppOrder?> watchUserOrder(String userId, String orderId) {
    final uid = resolveOrdersUserId(userId);
    if (uid.isEmpty || orderId.isEmpty) {
      return Stream.value(null);
    }

    return _orders.doc(orderId).snapshots().map((snap) {
      if (!snap.exists) return null;
      final order = AppOrder.fromDoc(snap);
      final owned = filterOrdersForUser([order], uid);
      return owned.isEmpty ? null : owned.first;
    });
  }

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
    String paymentMethod = 'cash',
  }) async {
    final uid = resolveOrdersUserId(userId);
    if (uid.isEmpty || lines.isEmpty) return null;
    final trimmedAddress = address.trim();
    if (trimmedAddress.isEmpty) return null;

    final name = customerName.trim();
    final phoneTrim = phone.trim();
    final email = customerEmail.trim();
    final pay = paymentMethod.trim().toLowerCase().isEmpty
        ? 'cash'
        : paymentMethod.trim().toLowerCase();

    final orderId = 'CM-${DateTime.now().millisecondsSinceEpoch}';

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

    final payload = <String, dynamic>{
      'orderId': orderId,
      'orderNumber': orderId,
      'orderNo': orderId,
      'userId': uid,
      'customerName': name,
      'userName': name,
      'customerPhone': phoneTrim,
      'phone': phoneTrim,
      if (email.isNotEmpty) ...{
        'customerEmail': email,
        'userEmail': email,
      },
      'address': trimmedAddress,
      'items': lines.map((e) {
        return {
          'foodId': e.product.id,
          'productId': e.product.id,
          'id': e.product.id,
          'name': e.product.name,
          'image': e.product.imageUrl,
          'imageUrl': e.product.imageUrl,
          'price': e.product.price,
          'quantity': e.quantity,
        };
      }).toList(),
      'totalPrice': totalPrice,
      'subtotal': subtotal,
      'deliveryPrice': deliveryPrice,
      'delivery': deliveryPrice,
      'deliveryFee': deliveryPrice,
      'discount': discount,
      'finalPrice': totalPrice,
      'total': totalPrice,
      'paymentMethod': pay,
      'status': OrderStatusCodec.defaultStatus,
      'itemCount': lines.fold<int>(0, (s, e) => s + e.quantity),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _orders.doc(orderId).set(payload);

    try {
      await _userOrdersMirror(uid).doc(orderId).set(payload);
    } catch (_) {}

    return orderId;
  }

  @override
  Future<void> updateOrderStatus({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    if (orderId.isEmpty) return;
    final firestoreStatus = OrderStatusCodec.toFirestoreFromCode(status);
    final data = {
      'status': firestoreStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _orders.doc(orderId).update(data);

    final uid = userId.trim();
    if (uid.isNotEmpty) {
      try {
        await _userOrdersMirror(uid).doc(orderId).update(data);
      } catch (_) {}
    }
  }
}

/// Logout yoki account almashtirganda chaqiriladi.
Future<void> clearOrderHistorySession() async {
  await OrderLocalCache.clearAll();
}
