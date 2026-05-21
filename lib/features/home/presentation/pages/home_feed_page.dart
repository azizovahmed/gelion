import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../menu/application/menu_providers.dart';
import '../../../menu/data/category_icon_registry.dart';
import '../../../menu/domain/entities/menu_category.dart';
import '../../../menu/domain/food_display_sort.dart';
import '../../../menu/domain/home_product.dart' show HomeProduct, OnAddToCart;
import '../../../menu/presentation/widgets/category_network_avatar.dart';
import '../../../menu/presentation/pages/category_products_page.dart';
import '../../../menu/presentation/pages/product_detail_page.dart';
import '../../../menu/presentation/widgets/crave_food_product_card.dart';
import '../widgets/home_banner_carousel.dart';

abstract final class _HomeTokens {
  static const Color creamBg = Color(0xFFFFF9F0);
  static const Color creamBgDark = Color(0xFF141018);
  static const Color ink = Color(0xFF2B1E16);
  static const Color orange = Color(0xFFFF8C00);
  static const Color orangeDeep = Color(0xFFFF6B00);
}

/// Bosh sahifa — mahalliy katalog, kategoriyalar, qidiruv, kategoriya sahifasi (uzoq bosish).
class HomeTabPage extends ConsumerStatefulWidget {
  const HomeTabPage({
    super.key,
    required this.profile,
    required this.onAddToCart,
    this.onOpenCart,
  });

  final AppUser? profile;
  final OnAddToCart onAddToCart;
  final VoidCallback? onOpenCart;

  @override
  ConsumerState<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends ConsumerState<HomeTabPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  int _categoryIndexFor(List<MenuCategory> categories, String? selectedId) {
    if (selectedId == null || selectedId.isEmpty) return 0;
    final i = categories.indexWhere((c) => c.id == selectedId);
    return i < 0 ? 0 : i + 1;
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      ref.read(homeSearchQueryProvider.notifier).state = _searchCtrl.text;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openCategoryFullPage(BuildContext context, List<MenuCategory> categories) {
    final l10n = context.l10n;
    final selectedId = ref.read(homeSelectedCategoryIdProvider);
    if (selectedId == null || selectedId.isEmpty) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => CategoryProductsPage(
            pageTitle: l10n.homeAllFoodsTitle,
            categoryId: null,
            onAddToCart: widget.onAddToCart,
          ),
        ),
      );
      return;
    }
    final idx = categories.indexWhere((c) => c.id == selectedId);
    if (idx < 0) return;
    final c = categories[idx];
    final title = l10n.categoryAssortmentTitle(c.name);
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CategoryProductsPage(
          pageTitle: title,
          categoryId: c.id,
          onAddToCart: widget.onAddToCart,
        ),
      ),
    );
  }

  List<HomeProduct> _filterBySearch(List<HomeProduct> source) {
    return filterFoodsBySearch(source, ref.watch(homeSearchQueryProvider));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final topPad = MediaQuery.paddingOf(context).top;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? _HomeTokens.creamBgDark : _HomeTokens.creamBg;
    final categoriesAsync = ref.watch(activeCategoriesProvider);
    final productsAsync = ref.watch(categoryFoodsProvider(ref.watch(homeSelectedCategoryIdProvider)));

    final categories = categoriesAsync.valueOrNull ?? const <MenuCategory>[];
    final categoryId = ref.watch(homeSelectedCategoryIdProvider);
    final categoryIndex = _categoryIndexFor(categories, categoryId);

    final rawProducts = productsAsync.valueOrNull ?? const <HomeProduct>[];
    final allProducts = sortFoodsForDisplay(rawProducts, categoryId: categoryId);
    final products = _filterBySearch(allProducts);

    final sectionTitle = categoryIndex == 0 || categories.isEmpty
        ? l10n.homeAllFoodsTitle
        : l10n.homeSectionAssortment(categories[categoryIndex - 1].name);

    final firebaseError = categoriesAsync.hasError
        ? categoriesAsync.error
        : productsAsync.hasError
            ? productsAsync.error
            : null;

    final categoriesLoading = categoriesAsync.isLoading && categories.isEmpty;
    final productsLoading = productsAsync.isLoading && rawProducts.isEmpty;

    return ColoredBox(
      color: bg,
      child: _buildHomeStack(
        context: context,
        l10n: l10n,
        topPad: topPad,
        dark: dark,
        bg: bg,
        categories: categories,
        categoriesLoading: categoriesLoading,
        productsLoading: productsLoading,
        products: products,
        sectionTitle: sectionTitle,
        sectionSubtitle: l10n.homeProductCount(products.length),
        categoryId: categoryId,
        categoryIndex: categoryIndex,
        firebaseError: firebaseError,
      ),
    );
  }

  Widget _buildHomeStack({
    required BuildContext context,
    required AppLocalizations l10n,
    required double topPad,
    required bool dark,
    required Color bg,
    required List<MenuCategory> categories,
    required bool categoriesLoading,
    required bool productsLoading,
    required List<HomeProduct> products,
    required String sectionTitle,
    required String sectionSubtitle,
    required String? categoryId,
    required int categoryIndex,
    required Object? firebaseError,
  }) {

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: bg,
            child: RefreshIndicator(
                    color: _HomeTokens.orange,
                    onRefresh: () async {
                      ref.invalidate(activeCategoriesProvider);
                      ref.invalidate(categoryFoodsProvider(categoryId));
                    },
                    child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              if (firebaseError != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, topPad + 8, 18, 0),
                    child: Material(
                      color: Colors.red.shade700.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.homeFoodsLoadError,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ref.invalidate(activeCategoriesProvider);
                                ref.invalidate(categoryFoodsProvider(categoryId));
                              },
                              child: Text(l10n.retryLoad, style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, firebaseError != null ? 8 : topPad + 10, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopChrome(
                        profile: widget.profile,
                        onOpenCart: widget.onOpenCart,
                        greeting: l10n.homeGreeting,
                        brandTitle: l10n.appTitle,
                        notificationsSoon: l10n.homeNotificationsSoon,
                      ),
                      const SizedBox(height: 16),
                      _HomeSearchField(controller: _searchCtrl, hint: l10n.homeSearchHint),
                      const SizedBox(height: 18),
                      HomeBannerCarousel(onAddToCart: widget.onAddToCart),
                      const SizedBox(height: 22),
                      if (categoriesLoading)
                        const SizedBox(
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _HomeTokens.orange,
                            ),
                          ),
                        )
                      else if (categories.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            l10n.categoryEmptyTitle,
                            style: TextStyle(
                              color: dark ? Colors.white60 : Colors.brown.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        _CategoryRow(
                          l10n: l10n,
                          categories: categories,
                          selectedIndex: categoryIndex,
                          onSelect: (i) {
                            final id = i == 0 ? null : categories[i - 1].id;
                            ref.read(homeSelectedCategoryIdProvider.notifier).state = id;
                          },
                          onOpenFullCatalog: () =>
                              _openCategoryFullPage(context, categories),
                          onCategoryLongPress: (i) {
                            if (i == 0) {
                              _openCategoryFullPage(context, categories);
                            } else {
                              final c = categories[i - 1];
                              final title =
                                  l10n.categoryAssortmentTitle(c.name);
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => CategoryProductsPage(
                                    pageTitle: title,
                                    categoryId: c.id,
                                    onAddToCart: widget.onAddToCart,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sectionTitle,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    color: dark ? Colors.white : _HomeTokens.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  sectionSubtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: dark ? Colors.white60 : Colors.brown.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                _openCategoryFullPage(context, categories),
                            icon: const Icon(Icons.open_in_new_rounded, size: 18),
                            label: Text(l10n.homeFullList),
                            style: TextButton.styleFrom(
                              foregroundColor: _HomeTokens.orange,
                              textStyle: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                sliver: SliverToBoxAdapter(
                  child: productsLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _HomeTokens.orange,
                            ),
                          ),
                        )
                      : _ProductGridBody(
                          key: ValueKey<String>(
                            '${categoryId ?? 'all'}|${ref.watch(homeSearchQueryProvider)}',
                          ),
                          products: products,
                          onAddToCart: widget.onAddToCart,
                        ),
                ),
              ),
            ],
            ),
          ),
        ),
        ),
        Positioned(
          right: 18,
          bottom: 102,
                  child: Material(
                    elevation: 8,
                    shadowColor: Colors.black38,
                    shape: const CircleBorder(),
                    color: const Color(0xFF6D4C41),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text(l10n.homeSupportSoon),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}

class _ProductGridBody extends StatelessWidget {
  const _ProductGridBody({
    super.key,
    required this.products,
    required this.onAddToCart,
  });

  final List<HomeProduct> products;
  final OnAddToCart onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.brown.shade300),
            const SizedBox(height: 12),
            Text(
              context.l10n.homeSearchEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.brown.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: KeyedSubtree(
        key: ValueKey(products.map((e) => e.id).join('|')),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 14,
              childAspectRatio: 0.56,
          ),
          itemBuilder: (context, index) {
            final p = products[index];
            return CraveFoodProductCard(
              key: ValueKey<String>(
                '${p.id}-${p.imageBytes?.length ?? 0}-${p.imageUrl}',
              ),
              product: p,
              onAdd: () => onAddToCart(p),
              onOpen: () => Navigator.of(context).push<void>(
                PageRouteBuilder<void>(
                  pageBuilder: (_, __, ___) => ProductDetailPage(product: p, onAddToCart: onAddToCart),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut), child: child),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopChrome extends StatelessWidget {
  const _TopChrome({
    required this.profile,
    this.onOpenCart,
    required this.greeting,
    required this.brandTitle,
    required this.notificationsSoon,
  });

  final AppUser? profile;
  final VoidCallback? onOpenCart;
  final String greeting;
  final String brandTitle;
  final String notificationsSoon;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1E1A22) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFFE0B2).withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.35 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFFFE0B2),
            child: ClipOval(
              child: Image.asset(
                'assets/onboarding_pizza.png',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, color: Colors.brown.shade700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 14,
                    color: dark ? Colors.white70 : const Color(0xFF8D6E63),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile?.fullName ?? context.l10n.guestName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: dark ? Colors.white : _HomeTokens.ink,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(behavior: SnackBarBehavior.floating, content: Text(notificationsSoon)),
                );
            },
            icon: Icon(Icons.notifications_none_rounded, color: _HomeTokens.orange.withValues(alpha: 0.9)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                brandTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: _HomeTokens.orange,
                  shadows: [
                    Shadow(
                      color: _HomeTokens.orange.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
              if (onOpenCart != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 32),
                  onPressed: onOpenCart,
                  icon: Icon(Icons.shopping_bag_outlined, color: _HomeTokens.orange.withValues(alpha: 0.9)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeSearchField extends StatelessWidget {
  const _HomeSearchField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_HomeTokens.orange, _HomeTokens.orangeDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _HomeTokens.orange.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TextField(
        controller: controller,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.l10n,
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
    required this.onOpenFullCatalog,
    required this.onCategoryLongPress,
  });

  final AppLocalizations l10n;
  final List<MenuCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onOpenFullCatalog;
  final ValueChanged<int> onCategoryLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.homeCategoriesTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : _HomeTokens.ink,
              ),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: l10n.homeCategoryTooltip,
                  onPressed: onOpenFullCatalog,
                  icon: const Icon(Icons.grid_view_rounded, color: _HomeTokens.orange),
                ),
                TextButton(
                  onPressed: () => onSelect(0),
                  child: Text(
                    l10n.homeCategoryAll,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _HomeTokens.orange,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final dark = Theme.of(context).brightness == Brightness.dark;
              final isAll = i == 0;
              final active = selectedIndex == i;
              final cat = isAll ? null : categories[i - 1];
              final label = isAll ? l10n.homeCategoryAll : cat!.name;
              final icon = isAll
                  ? Icons.grid_view_rounded
                  : CategoryIconRegistry.resolve(cat!.iconName);
              final inactiveFill = dark ? const Color(0xFF252030) : Colors.white;
              final inactiveBorder = dark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFFFE0B2);
              final inactiveIcon = dark ? Colors.white70 : const Color(0xFF8D6E63);
              final inactiveLabel = dark ? Colors.white60 : const Color(0xFF6D4C41);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                onLongPress: () => onCategoryLongPress(i),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? _HomeTokens.orange : inactiveFill,
                        border: Border.all(
                          color: active ? _HomeTokens.orange : inactiveBorder,
                          width: 2,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: _HomeTokens.orange.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: CategoryNetworkAvatar(
                        category: cat,
                        size: 66,
                        icon: icon,
                        active: active,
                        inactiveIconColor: active ? Colors.white : inactiveIcon,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 76,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                          color: active ? _HomeTokens.orange : inactiveLabel,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
