import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../application/menu_providers.dart';
import '../../domain/home_product.dart' show OnAddToCart;
import '../widgets/crave_food_product_card.dart';
import 'product_detail_page.dart';

/// Sevimli taomlar ro‘yxati.
class FavoriteFoodsPage extends ConsumerWidget {
  const FavoriteFoodsPage({
    super.key,
    required this.onAddToCart,
  });

  final OnAddToCart onAddToCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoriteIdsProvider).valueOrNull ?? {};
    final foodsAsync = ref.watch(activeFoodsProvider);

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF141018) : const Color(0xFFFFF9F0),
      appBar: AppBar(
        title: Text(l10n.favoritesTitle),
        backgroundColor: dark ? const Color(0xFF1E1A22) : Colors.white,
        foregroundColor: dark ? Colors.white : const Color(0xFF2B1E16),
        elevation: 0,
      ),
      body: foodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00))),
        error: (_, _) => _ErrorRetry(onRetry: () => ref.invalidate(activeFoodsProvider)),
        data: (all) {
          final list = all.where((p) => favorites.contains(p.id)).toList();
          if (favorites.isEmpty || list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.favoritesEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white60 : Colors.brown.shade600,
                  ),
                ),
              ),
            );
          }
          final sw = MediaQuery.sizeOf(context).width;
          final cross = sw < 400 ? 1 : 2;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: cross == 1 ? 1.35 : 0.72,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final p = list[i];
              return CraveFoodProductCard(
                product: p,
                onAdd: () => onAddToCart(p),
                onOpen: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => ProductDetailPage(
                      product: p,
                      onAddToCart: onAddToCart,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.homeFoodsLoadError),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: Text(l10n.retryLoad),
          ),
        ],
      ),
    );
  }
}
