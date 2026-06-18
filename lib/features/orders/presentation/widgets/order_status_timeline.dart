import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
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

    final activeIndex = current.timelineIndex.clamp(0, OrderStatus.timelineFlow.length - 1);
    final allDone = current == OrderStatus.completed;

    return Column(
      children: [
        for (var i = 0; i < OrderStatus.timelineFlow.length; i++) ...[
          _TimelineStep(
            status: OrderStatus.timelineFlow[i],
            label: OrderStatus.timelineFlow[i].label(l10n),
            isActive: !allDone && i == activeIndex,
            isCompleted: allDone ? true : i < activeIndex,
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
    final accent = status.color;
    final dotColor = isCompleted || isActive ? accent : Colors.grey.shade300;
    final lineColor = isCompleted ? accent.withValues(alpha: 0.45) : Colors.grey.shade300;
    final textColor = isActive || isCompleted
        ? const Color(0xFF5D4037)
        : Colors.brown.shade400;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: isActive ? 0.22 : 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor,
                      width: isActive ? 2.5 : 1.5,
                    ),
                  ),
                  child: Icon(
                    isCompleted && !isActive
                        ? Icons.check_rounded
                        : status.icon,
                    size: 15,
                    color: dotColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: CustomPaint(
                      painter: _DashedLinePainter(color: lineColor),
                      child: const SizedBox(width: 2),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 4),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 14,
                  color: textColor,
                ),
                child: Text(label),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 5.0;
    const gap = 4.0;
    var y = 4.0;
    while (y < size.height - 4) {
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, y + dashHeight), paint);
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => oldDelegate.color != color;
}
