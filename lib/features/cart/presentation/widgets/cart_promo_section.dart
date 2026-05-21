import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../theme/cart_palette.dart';
import 'scale_tap.dart';

/// Promo code field + warm apply chip.
class CartPromoSection extends StatelessWidget {
  const CartPromoSection({
    super.key,
    required this.controller,
    required this.onApply,
    this.appliedMessage,
  });

  final TextEditingController controller;
  final VoidCallback onApply;
  final String? appliedMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cartPromoLabel,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: CartPalette.textPrimary(context),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: CartPalette.cardSurface(context),
            boxShadow: CartPalette.cardLift(dark),
            border: Border.all(
              color: dark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFFE0B2),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onApply(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: CartPalette.textPrimary(context),
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.cartPromoHint,
                    hintStyle: TextStyle(
                      color: CartPalette.textSecondary(context),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              ScaleTap(
                onTap: onApply,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFFAB00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFAB00).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    l10n.cartPromoApply,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (appliedMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            appliedMessage!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CartPalette.orangeDeep,
            ),
          ),
        ],
      ],
    );
  }
}
