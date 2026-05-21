import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../cart/presentation/utils/format_sum.dart';
import '../../domain/entities/app_order.dart';
import '../theme/order_presentation_theme.dart';
import 'order_status_badge.dart';

class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final AppOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loc = Localizations.localeOf(context).toLanguageTag();
    final when = DateFormat.yMMMd(loc).add_Hm().format(order.createdAt);

    return Material(
      color: OrderPresentationTheme.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      shadowColor: OrderPresentationTheme.brown.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: OrderPresentationTheme.chipCream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: OrderPresentationTheme.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.orderHistoryOrder(order.displayNumber),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: OrderPresentationTheme.brownDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _MetaRow(
                      icon: Icons.shopping_bag_outlined,
                      label: l10n.orderHistoryItemCount(order.itemCount),
                    ),
                    const SizedBox(height: 4),
                    _MetaRow(
                      icon: Icons.payments_outlined,
                      label: l10n.orderHistoryTotal(
                        formatSum(order.totalPrice),
                        l10n.currencySom,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _MetaRow(icon: Icons.calendar_today_outlined, label: when),
                    const SizedBox(height: 8),
                    OrderStatusBadge(statusCode: order.status),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: OrderPresentationTheme.brown,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: OrderPresentationTheme.brown.withValues(alpha: 0.85)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: OrderPresentationTheme.brown.withValues(alpha: 0.95),
            ),
          ),
        ),
      ],
    );
  }
}
