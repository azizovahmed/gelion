import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../theme/cart_palette.dart';

class CartAddressSection extends StatelessWidget {
  const CartAddressSection({
    super.key,
    required this.controller,
    this.errorText,
  });

  final TextEditingController controller;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cartAddressLabel,
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
              color: hasError
                  ? Colors.redAccent
                  : (dark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFFE0B2)),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
          child: TextField(
            controller: controller,
            maxLines: 3,
            minLines: 2,
            textInputAction: TextInputAction.newline,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: CartPalette.textPrimary(context),
              height: 1.35,
            ),
            decoration: InputDecoration(
              hintText: l10n.cartAddressHint,
              hintStyle: TextStyle(
                color: CartPalette.textSecondary(context),
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              errorText: hasError ? null : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
