import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/widgets/safe_network_image.dart';
import '../../../cart/presentation/utils/format_sum.dart';
import '../../application/order_providers.dart';
import '../../domain/entities/app_order.dart';
import '../../domain/entities/payment_method_labels.dart';
import '../theme/order_presentation_theme.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_status_timeline.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.order});

  final AppOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserIdProvider);
    if (uid.isEmpty ||
        (order.userId.trim().isNotEmpty && order.userId.trim() != uid)) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l10n.orderHistoryAuthRequired)),
      );
    }
    final live = ref.watch(userOrderDetailProvider(order.id));
    final resolved = live.when(
      data: (o) => o ?? order,
      loading: () => order,
      error: (_, __) => order,
    );
    return _OrderDetailBody(key: ValueKey(resolved.status), order: resolved);
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({super.key, required this.order});

  final AppOrder order;

  int get _subtotal {
    if (order.subtotal > 0) return order.subtotal;
    return order.items.fold<int>(0, (s, e) => s + e.price * e.quantity);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loc = Localizations.localeOf(context).toLanguageTag();
    final when = DateFormat.yMMMd(loc).add_Hm().format(order.createdAt);

    return Scaffold(
      backgroundColor: OrderPresentationTheme.cream,
      appBar: AppBar(
        backgroundColor: OrderPresentationTheme.white,
        foregroundColor: OrderPresentationTheme.brownDark,
        elevation: 0,
        title: Text(
          l10n.orderHistoryOrder(order.displayNumber),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.orderDetailPlacedAt,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: OrderPresentationTheme.brown.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    OrderStatusBadge(statusCode: order.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  when,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: OrderPresentationTheme.brownDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderDetailTimeline,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: OrderPresentationTheme.brownDark,
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  child: OrderStatusTimeline(
                    key: ValueKey<String>(order.status),
                    currentStatusCode: order.status,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adminOrderItems,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: OrderPresentationTheme.brownDark,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.map((item) => _OrderItemRow(item: item)),
                if (order.items.isEmpty)
                  Text(
                    '—',
                    style: TextStyle(
                      color: OrderPresentationTheme.brown.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderDetailPayment,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: OrderPresentationTheme.brownDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  paymentMethodLabel(l10n, order.paymentMethod),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: OrderPresentationTheme.brown.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adminOrderDeliveryAddress,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: OrderPresentationTheme.brownDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  order.address.isNotEmpty ? order.address : '—',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: OrderPresentationTheme.brown.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            child: Column(
              children: [
                _PriceRow(
                  label: l10n.cartRowProducts,
                  value: '${formatSum(_subtotal)} ${l10n.currencySom}',
                ),
                const SizedBox(height: 8),
                _PriceRow(
                  label: l10n.cartRowDelivery,
                  value: '${formatSum(order.deliveryPrice)} ${l10n.currencySom}',
                ),
                if (order.discount > 0) ...[
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: l10n.cartRowDiscount,
                    value: '-${formatSum(order.discount)} ${l10n.currencySom}',
                    valueColor: const Color(0xFF66BB6A),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _PriceRow(
                  label: l10n.cartRowTotal,
                  value: '${formatSum(order.totalPrice)} ${l10n.currencySom}',
                  emphasize: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderPresentationTheme.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: OrderPresentationTheme.brown.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final AppOrderItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lineTotal = item.price * item.quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: OrderPresentationTheme.chipCream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SafeNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      width: 44,
                      height: 44,
                      errorLabel: '',
                    ),
                  )
                : const Icon(Icons.fastfood_rounded, color: OrderPresentationTheme.orange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: OrderPresentationTheme.brownDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '×${item.quantity} • ${formatSum(item.price)} ${l10n.currencySom}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: OrderPresentationTheme.brown.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${formatSum(lineTotal)} ${l10n.currencySom}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: OrderPresentationTheme.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
              fontSize: emphasize ? 16 : 14,
              color: OrderPresentationTheme.brownDark.withValues(alpha: emphasize ? 1 : 0.85),
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: emphasize ? 18 : 14,
              color: valueColor ?? (emphasize ? OrderPresentationTheme.orange : OrderPresentationTheme.brownDark),
            ),
          ),
        ),
      ],
    );
  }
}
