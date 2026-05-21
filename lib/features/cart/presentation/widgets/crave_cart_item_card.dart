import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../menu/domain/home_product.dart';
import '../../../menu/presentation/widgets/product_cover_image.dart';
import '../theme/cart_palette.dart';
import '../utils/format_sum.dart';
import '../utils/product_copy.dart';
import 'scale_tap.dart';

/// Premium cart row: image, copy, price, quantity, remove.
class CraveCartItemCard extends StatelessWidget {
  const CraveCartItemCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    this.animationIndex = 0,
  });

  final HomeProduct product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final int animationIndex;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final desc = resolveProductDescription(product, AppLocalizations.of(context));

    return Dismissible(
      key: ValueKey('cart-${product.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Colors.red.shade400.withValues(alpha: 0.05),
              Colors.red.shade600.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: CartPalette.cardSurface(context),
            boxShadow: CartPalette.cardLift(dark),
            border: Border.all(
              color: dark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.9),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Thumb(product: product),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                    color: CartPalette.textPrimary(context),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              ScaleTap(
                                onTap: onRemove,
                                minScale: 0.88,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: dark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: CartPalette.textSecondary(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                              color: CartPalette.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: dark
                                      ? const [Color(0xFFFFB74D), Color(0xFFFF6D00)]
                                      : const [Color(0xFFE65100), Color(0xFFFF8F00)],
                                ).createShader(bounds),
                                child: Text(
                                  '${formatSum(product.price)} ${AppLocalizations.of(context).currencySom}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              _QtyControl(
                                quantity: quantity,
                                onMinus: onDecrement,
                                onPlus: onIncrement,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
    )
        .animate(delay: (40 * animationIndex).ms)
        .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.06, curve: Curves.easeOutCubic);
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.product});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 92,
        height: 92,
        child: ProductCoverImage(
          product: product,
          fit: BoxFit.cover,
          height: 92,
          borderRadius: 20,
        ),
      ),
    );

    return Hero(
      tag: craveProductHeroTag(product.id),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: CartPalette.orangeMain.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: dark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFFFF6ED),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFFE0B2),
        ),
        boxShadow: CartPalette.glassEdge(dark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTap(
            onTap: onMinus,
            child: _RoundIcon(
              icon: Icons.remove_rounded,
              filled: false,
              iconColor: CartPalette.textPrimary(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Text(
                '$quantity',
                key: ValueKey<int>(quantity),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: CartPalette.textPrimary(context),
                ),
              ),
            ),
          ),
          ScaleTap(
            onTap: onPlus,
            child: const _RoundIcon(
              icon: Icons.add_rounded,
              filled: true,
              iconColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.filled,
    required this.iconColor,
  });

  final IconData icon;
  final bool filled;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: filled
            ? const LinearGradient(
                colors: [Color(0xFFFF9100), Color(0xFFFF6D00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: filled ? null : Colors.transparent,
        boxShadow: filled
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6D00).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        size: 22,
        color: filled ? Colors.white : iconColor,
      ),
    );
  }
}

/// Hero tag shared with home product thumbnails.
String craveProductHeroTag(String productId) => 'crave-product-$productId';
