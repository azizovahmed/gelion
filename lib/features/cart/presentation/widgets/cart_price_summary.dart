import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../theme/cart_palette.dart';
import '../utils/format_sum.dart';

class CartPriceSummary extends StatelessWidget {
  const CartPriceSummary({
    super.key,
    required this.subtotal,
    required this.delivery,
    required this.discount,
    required this.total,
  });

  final int subtotal;
  final int delivery;
  final int discount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cur = l10n.currencySom;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF2A242F), Color(0xFF1F1B24)]
              : const [Color(0xFFFFF4E6), Color(0xFFFFE8D2)],
        ),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.85),
        ),
        boxShadow: CartPalette.cardLift(dark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cartSummaryTitle,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: CartPalette.textPrimary(context),
            ),
          ),
          const SizedBox(height: 14),
          _Row(label: l10n.cartRowProducts, value: subtotal, currency: cur),
          const SizedBox(height: 10),
          _Row(label: l10n.cartRowDelivery, value: delivery, currency: cur),
          const SizedBox(height: 10),
          _Row(
            label: l10n.cartRowDiscount,
            value: -discount,
            currency: cur,
            emphasize: discount > 0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              color: CartPalette.textSecondary(context).withValues(alpha: 0.22),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.cartRowTotal,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: CartPalette.textPrimary(context),
                ),
              ),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFFF6F00)],
                ).createShader(bounds),
                child: Text(
                  '${formatSum(total)} $cur',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: -0.6,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.currency,
    this.emphasize = false,
  });

  final String label;
  final int value;
  final String currency;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final sign = value < 0 ? '-' : '';
    final abs = value.abs();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: CartPalette.textSecondary(context),
          ),
        ),
        Text(
          '$sign${formatSum(abs)} $currency',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: emphasize ? const Color(0xFF2E7D32) : CartPalette.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
