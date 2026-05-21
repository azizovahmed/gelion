import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../application/menu_providers.dart';
import '../../domain/food_display_sort.dart';
import '../../domain/home_product.dart' show HomeProduct, OnAddToCart;
import '../widgets/crave_food_product_card.dart';
import 'product_detail_page.dart';

/// Kategoriya bo‘yicha to‘liq ro‘yxat: banner, qidiruv, panjara.
class CategoryDetailScreen extends ConsumerStatefulWidget {
  const CategoryDetailScreen({
    super.key,
    required this.pageTitle,
    required this.categoryId,
    required this.onAddToCart,
  });

  /// `null` yoki `''` — barcha mahsulotlar.
  final String? categoryId;
  final String pageTitle;
  final OnAddToCart onAddToCart;

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class CategoryProductsPage extends CategoryDetailScreen {
  const CategoryProductsPage({
    super.key,
    required super.pageTitle,
    required super.categoryId,
    required super.onAddToCart,
  });
}

enum _SortType { popular, cheap, newest }

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  final TextEditingController _search = TextEditingController();
  String _q = '';
  _SortType _sort = _SortType.popular;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _q = _search.text));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<HomeProduct> _sorted(List<HomeProduct> source) {
    final q = _q.trim().toLowerCase();
    var list = source;
    if (q.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    final sorted = List<HomeProduct>.from(list);
    switch (_sort) {
      case _SortType.popular:
        sorted.sort((a, b) {
          final p = (b.isPopular ? 1 : 0).compareTo(a.isPopular ? 1 : 0);
          if (p != 0) return p;
          return a.name.compareTo(b.name);
        });
        break;
      case _SortType.cheap:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _SortType.newest:
        sorted.sort((a, b) => b.id.compareTo(a.id));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF141018) : const Color(0xFFFFF9F0),
      body: Consumer(
        builder: (context, ref, _) {
          final foodsAsync = ref.watch(categoryFoodsProvider(widget.categoryId));
          return foodsAsync.when(
            loading: () => _buildScroll(context, loading: true, items: const []),
            error: (e, _) => Center(child: Text(context.l10n.homeFoodsLoadError)),
            data: (raw) {
              final sorted = sortFoodsForDisplay(raw, categoryId: widget.categoryId);
              final items = _sorted(sorted);
              return _buildScroll(context, loading: false, items: items);
            },
          );
        },
      ),
    );
  }

  Widget _buildScroll(
    BuildContext context, {
    required bool loading,
    required List<HomeProduct> items,
  }) {
    final l10n = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.sizeOf(context).width;
    final crossAxisCount = sw < 370 ? 1 : 2;
    final gridRatio = crossAxisCount == 1 ? 1.42 : (sw < 420 ? 0.55 : 0.58);

    return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 168,
            backgroundColor: const Color(0xFFFF8C00),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.pageTitle,
                style: const TextStyle(fontWeight: FontWeight.w900, shadows: [Shadow(blurRadius: 8)]),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF8C00), Color(0xFFFF6B00)],
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(Icons.restaurant_menu_rounded, size: 120, color: Colors.white.withValues(alpha: 0.12)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: l10n.categorySearchHint,
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF8C00)),
                      filled: true,
                      fillColor: dark ? const Color(0xFF1E1A22) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _SortChip(
                        label: l10n.sortPopular,
                        selected: _sort == _SortType.popular,
                        onTap: () => setState(() => _sort = _SortType.popular),
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: l10n.sortCheap,
                        selected: _sort == _SortType.cheap,
                        onTap: () => setState(() => _sort = _SortType.cheap),
                      ),
                      const SizedBox(width: 8),
                      _SortChip(
                        label: l10n.sortNew,
                        selected: _sort == _SortType.newest,
                        onTap: () => setState(() => _sort = _SortType.newest),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0B2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.categoryItemCount(items.length),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (loading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: gridRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const _SkeletonCard(),
                  childCount: crossAxisCount == 1 ? 3 : 4,
                ),
              ),
            )
          else if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyCategory(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: gridRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final p = items[i];
                    return CraveFoodProductCard(
                      key: ValueKey<String>(p.id),
                      product: p,
                      onAdd: () {
                        widget.onAddToCart(p);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(milliseconds: 1200),
                            content: Text(l10n.cartAddedSimple(p.name)),
                          ),
                        );
                      },
                      onOpen: () => Navigator.of(context).push<void>(
                        PageRouteBuilder<void>(
                          pageBuilder: (context, animation, secondaryAnimation) => ProductDetailPage(
                            product: p,
                            onAddToCart: widget.onAddToCart,
                          ),
                          transitionsBuilder: (context, anim, secondaryAnim, child) {
                            final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
                            return FadeTransition(
                              opacity: curve,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.04),
                                  end: Offset.zero,
                                ).animate(curve),
                                child: child,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
        ],
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFFFE0B2),
      backgroundColor: Colors.white,
      checkmarkColor: const Color(0xFFE65100),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? const Color(0xFF5D4037) : const Color(0xFF8D6E63),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: selected ? const Color(0xFFFF8C00) : const Color(0xFFFFE0B2)),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBD5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 56),
                SizedBox(height: 8),
                _SkeletonLine(width: 132),
                SizedBox(height: 8),
                _SkeletonLine(width: 96),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFFFFDDBA),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E0),
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.ramen_dining_rounded, size: 58, color: Color(0xFFFF8C00)),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.categoryEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.categoryEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.brown.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
