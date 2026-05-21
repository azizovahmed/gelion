import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/utils/format_sum.dart';
import '../../../cart/presentation/utils/product_copy.dart';
import '../../../cart/presentation/widgets/crave_cart_item_card.dart';
import '../../application/menu_providers.dart';
import '../../domain/cart_product_rules.dart';
import '../../domain/home_product.dart';
import 'product_cover_image.dart';

/// Bosh sahifa / kategoriya — taom kartasi: rasm, sevimlilar (Firestore/local), narx.
class CraveFoodProductCard extends ConsumerWidget {
  const CraveFoodProductCard({
    super.key,
    required this.product,
    required this.onAdd,
    this.onOpen,
  });

  final HomeProduct product;
  final VoidCallback onAdd;
  final VoidCallback? onOpen;

  static const _ink = Color(0xFF2B1E16);
  static const _yellowAdd = Color(0xFFFFE135);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoriteIdsProvider).valueOrNull ?? {};
    final isFavorite = favorites.contains(product.id);
    final rawDesc = product.description ?? '';
    final desc = rawDesc.isNotEmpty ? rawDesc : resolveProductDescription(product, l10n);
    final sw = MediaQuery.sizeOf(context).width;
    final compact = sw < 380;
    final imageHeight = compact ? 132.0 : 145.0;
    final titleSize = compact ? 13.0 : 14.0;
    final bodySize = compact ? 10.5 : 11.0;
    final priceSize = compact ? 15.0 : 16.0;
    final outOfStock = CartProductRules.isOutOfStock(product);

    return Material(
      color: dark ? const Color(0xFF1E1A22) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFFE0B2).withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.35 : 0.07),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: imageHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: craveProductHeroTag(product.id),
                        child: ProductCoverImage(
                          product: product,
                          fit: BoxFit.cover,
                          height: imageHeight,
                          borderRadius: 22,
                          topCornersOnly: true,
                        ),
                      ),
                    ),
                    if (outOfStock)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l10n.productOutOfStockLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    else if (product.isPopular)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8C00),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l10n.adminFoodPopular,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => ref.read(favoritesRepositoryProvider).toggle(product.id),
                          child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Icon(
                              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 20,
                              color: isFavorite ? Colors.redAccent : _ink.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: titleSize,
                        height: 1.2,
                        color: dark ? Colors.white : _ink,
                      ),
                    ),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: bodySize,
                          height: 1.25,
                          color: dark ? Colors.white60 : Colors.brown.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatSum(product.price),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: dark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                                  fontWeight: FontWeight.w900,
                                  fontSize: priceSize,
                                ),
                              ),
                              Text(
                                l10n.currencySom,
                                style: TextStyle(
                                  fontSize: compact ? 10 : 11,
                                  fontWeight: FontWeight.w600,
                                  color: dark ? Colors.white70 : Colors.brown.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: outOfStock ? Colors.grey.shade300 : _yellowAdd,
                          elevation: outOfStock ? 0 : 2,
                          shadowColor: const Color(0x44FFCA28),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: outOfStock ? null : onAdd,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(compact ? 7 : 8),
                              child: Icon(
                                Icons.add_rounded,
                                color: outOfStock ? Colors.grey : const Color(0xFF3E2723),
                                size: compact ? 22 : 24,
                              ),
                            ),
                          ),
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
    );
  }
}
