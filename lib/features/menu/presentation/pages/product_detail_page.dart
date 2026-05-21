import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../cart/presentation/utils/format_sum.dart';
import '../../../cart/presentation/utils/product_copy.dart';
import '../../../cart/presentation/widgets/crave_cart_item_card.dart';
import '../../application/menu_providers.dart';
import '../../domain/cart_product_rules.dart';
import '../../domain/home_product.dart' show HomeProduct, OnAddToCart;
import '../widgets/crave_food_product_card.dart';
import '../widgets/product_cover_image.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  final HomeProduct product;
  final OnAddToCart onAddToCart;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = widget.product;
    final ing = resolveProductDescription(p, l10n);
    final categoryId = p.categoryId ?? '';
    final rec = categoryId.isEmpty
        ? const <HomeProduct>[]
        : ref.watch(recommendedFoodsProvider(categoryId)).where((e) => e.id != p.id).toList();

    final outOfStock = CartProductRules.isOutOfStock(p);
    final maxQty = CartProductRules.tracksStock(p) ? p.stock : 99;

    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF141018) : const Color(0xFFFFF9F0);
    final textColor = dark ? Colors.white : const Color(0xFF2B1E16);
    final muted = dark ? Colors.white70 : Colors.brown.shade700;

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: outOfStock
                ? null
                : () {
              widget.onAddToCart(p, count: _qty);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(l10n.productAddedSnack(p.name, _qty)),
                ),
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: Text(
              l10n.productAddToCart(formatSum(p.price * _qty), l10n.currencySom),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFFFF8C00),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: craveProductHeroTag(p.id),
                child: ProductCoverImage(
                  product: p,
                  fit: BoxFit.cover,
                  height: 280,
                  borderRadius: 0,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.1, color: textColor),
                        ),
                      ),
                      if (p.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8C00).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l10n.adminFoodPopular,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: Color(0xFFFF8C00),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${formatSum(p.price)} ${l10n.currencySom}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF8C00),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.productIngredients,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ing,
                    style: TextStyle(color: muted, height: 1.45, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(l10n.productQuantity, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const Spacer(),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFF3E0)),
                        onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                        icon: const Icon(Icons.remove, color: Color(0xFFFF8C00)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFFFF8C00)),
                        onPressed: _qty >= maxQty ? null : () => setState(() => _qty++),
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  if (rec.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      l10n.productRecommendations,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: rec.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final item = rec[i];
                          return SizedBox(
                            width: 160,
                            child: CraveFoodProductCard(
                              product: item,
                              onAdd: () => widget.onAddToCart(item),
                              onOpen: () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => ProductDetailPage(
                                    product: item,
                                    onAddToCart: widget.onAddToCart,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
