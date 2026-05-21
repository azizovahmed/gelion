import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/order_status.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({super.key, required this.currentStatusCode});

  final String currentStatusCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = OrderStatus.fromCode(currentStatusCode);

    if (current == OrderStatus.cancelled) {
      return _CancelledBanner(status: current, l10n: l10n);
    }

    final activeIndex = current.timelineIndex < 0 ? 0 : current.timelineIndex;

    return Column(
      children: [
        for (var i = 0; i < OrderStatus.timelineFlow.length; i++) ...[
          _TimelineStep(
            status: OrderStatus.timelineFlow[i],
            label: OrderStatus.timelineFlow[i].label(l10n),
            isActive: i == activeIndex,
            isCompleted: i < activeIndex || current == OrderStatus.completed,
            isLast: i == OrderStatus.timelineFlow.length - 1,
          ),
        ],
      ],
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner({required this.status, required this.l10n});

  final OrderStatus status;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(status.icon, color: status.color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status.label(l10n),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.status,
    required this.label,
    required this.isActive,
    required this.isCompleted,
    required this.isLast,
  });

  final OrderStatus status;
  final String label;
  final bool isActive;
  final bool isCompleted;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = isCompleted || isActive ? status.color : Colors.grey.shade300;
    final lineColor = isCompleted ? status.color.withValues(alpha: 0.5) : Colors.grey.shade300;
    final textColor = isActive || isCompleted ? const Color(0xFF5D4037) : Colors.brown.shade400;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: isActive ? 0.2 : 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: isActive ? 2.5 : 1.5),
                  ),
                  child: Icon(
                    status.icon,
                    size: 15,
                    color: dotColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 4),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
