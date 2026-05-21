import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../application/order_providers.dart';
import '../../domain/entities/app_order.dart';
import '../theme/order_presentation_theme.dart';
import '../widgets/order_history_card.dart';
import '../widgets/order_history_empty_state.dart';
import '../widgets/order_shimmer.dart';
import 'order_detail_page.dart';

class UserOrderHistoryPage extends ConsumerWidget {
  const UserOrderHistoryPage({
    super.key,
    this.userId,
  });

  /// Agar berilmasa, [FirebaseAuth.instance.currentUser.uid] ishlatiladi.
  final String? userId;

  String _resolveUserId() {
    final explicit = userId?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final resolvedId = _resolveUserId();

    final ordersAsync = resolvedId.isEmpty
        ? const AsyncValue<List<AppOrder>>.data([])
        : ref.watch(userOrdersProvider(resolvedId));

    return Scaffold(
      backgroundColor: OrderPresentationTheme.cream,
      appBar: AppBar(
        backgroundColor: OrderPresentationTheme.white,
        foregroundColor: OrderPresentationTheme.brownDark,
        elevation: 0,
        title: Text(
          l10n.orderHistoryTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: resolvedId.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  l10n.orderHistoryAuthRequired,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: OrderPresentationTheme.brown.withValues(alpha: 0.9),
                  ),
                ),
              ),
            )
          : ordersAsync.when(
              loading: () => const OrderListShimmer(),
              error: (err, _) {
                final msg = err is FirebaseException
                    ? '${err.code}: ${err.message}'
                    : l10n.adminOrdersLoadError;
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: OrderPresentationTheme.brown.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                );
              },
              data: (orders) {
                if (orders.isEmpty) {
                  return const OrderHistoryEmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  physics: const BouncingScrollPhysics(),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return OrderHistoryCard(
                      order: order,
                      onTap: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => OrderDetailPage(order: order),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
