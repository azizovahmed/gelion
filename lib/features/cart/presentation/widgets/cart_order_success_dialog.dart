import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../presentation/utils/format_sum.dart';

/// Buyurtma muvaffaqiyatli yaratilgandan keyin ko‘rsatiladi.
Future<void> showCartOrderSuccessDialog({
  required BuildContext context,
  required String orderNo,
  required int total,
}) {
  final l10n = context.l10n;
  final totalText = '${formatSum(total)} ${l10n.currencySom}';

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF66BB6A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.cartOrderSuccessTitle,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Text(
        l10n.cartOrderSuccessMessage(orderNo, totalText),
        style: const TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w600),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF8C00),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            l10n.cartOrderSuccessOk,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}
