import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_order_repository.dart';
import '../data/order_local_cache.dart';
import '../data/order_user_scope.dart';
import '../domain/entities/app_order.dart';
import '../domain/entities/order_status.dart';
import '../domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return FirebaseOrderRepository();
});

/// Auth o‘zgarganda avtomatik yangilanadi.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserIdProvider = Provider<String>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.valueOrNull?.uid ?? '';
});

/// Sahifa hajmi (pagination) — auth almashganda UI qayta o‘rnatadi.
final userOrdersLimitProvider = StateProvider<int>(
  (_) => FirebaseOrderRepository.defaultPageSize,
);

/// Faqat login qilgan user buyurtmalari (boshqa UID → bo‘sh ro‘yxat).
final userOrdersProvider = StreamProvider.autoDispose<List<AppOrder>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid.isEmpty) {
    return Stream.value(const <AppOrder>[]);
  }
  final limit = ref.watch(userOrdersLimitProvider);
  return ref.watch(orderRepositoryProvider).watchUserOrders(uid, limit: limit);
});

final cachedUserOrdersProvider = FutureProvider.autoDispose<List<AppOrder>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid.isEmpty) return const [];
  final cached = await OrderLocalCache.load(uid);
  return filterOrdersForUser(cached, uid);
});

final userOrderDetailProvider = StreamProvider.autoDispose
    .family<AppOrder?, String>((ref, orderId) {
  if (orderId.isEmpty) {
    return Stream.value(null);
  }
  final uid = ref.watch(currentUserIdProvider);
  if (uid.isEmpty) {
    return Stream.value(null);
  }
  return ref.watch(orderRepositoryProvider).watchUserOrder(uid, orderId);
});

/// Admin: yangi/kutilmoqda buyurtmalar soni (badge).
final adminPendingOrdersCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(orderRepositoryProvider).watchAllOrders().map(
        (orders) => orders
            .where((o) => OrderStatus.fromCode(o.status) == OrderStatus.pending)
            .length,
      );
});
