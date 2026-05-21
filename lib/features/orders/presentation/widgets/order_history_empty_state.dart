import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../theme/order_presentation_theme.dart';

class OrderHistoryEmptyState extends StatelessWidget {
  const OrderHistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: OrderPresentationTheme.chipCream,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: OrderPresentationTheme.orange.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 44,
                color: OrderPresentationTheme.orange,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.orderHistoryEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                height: 1.45,
                fontWeight: FontWeight.w800,
                color: OrderPresentationTheme.brownDark.withValues(alpha: 0.92),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.orderHistoryEmptyHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: OrderPresentationTheme.brown.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
