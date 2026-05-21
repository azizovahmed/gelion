import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../domain/entities/order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.statusCode,
    this.compact = false,
  });

  final String statusCode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = OrderStatus.fromCode(statusCode);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: compact ? 14 : 15, color: status.color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              status.label(l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: compact ? 10 : 11,
                color: status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
