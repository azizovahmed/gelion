import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_order_repository.dart';
import '../domain/entities/app_order.dart';
import '../domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return FirebaseOrderRepository();
});

final currentUserIdProvider = Provider<String>((ref) {
  return FirebaseAuth.instance.currentUser?.uid ?? '';
});

final userOrdersProvider = StreamProvider.autoDispose.family<List<AppOrder>, String>((ref, userId) {
  if (userId.isEmpty) {
    return Stream.value(const <AppOrder>[]);
  }
  return ref.watch(orderRepositoryProvider).watchUserOrders(userId);
});
