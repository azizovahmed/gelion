import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../menu/application/menu_providers.dart';
import '../../../menu/domain/food_display_sort.dart';
import '../../../menu/domain/home_product.dart';
import '../../../menu/presentation/widgets/product_cover_image.dart';

const Color _kCream = Color(0xFFFFF8F0);
const Color _kBrown = Color(0xFF8B5E3C);
const Color _kBrownDark = Color(0xFF5D4037);
const Color _kOrange = Color(0xFFFF9800);
const Color _kWhite = Color(0xFFFFFFFF);

/// Qidiruv tabi — mahsulotlarni Firestore’dan o‘qiydi va matn bo‘yicha filtrlash.
class SearchBrowseTab extends ConsumerStatefulWidget {
  const SearchBrowseTab({super.key, this.onProductTap});

  final ValueChanged<HomeProduct>? onProductTap;

  @override
  ConsumerState<SearchBrowseTab> createState() => _SearchBrowseTabState();
}

class _SearchBrowseTabState extends ConsumerState<SearchBrowseTab> {
  final _query = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final top = MediaQuery.paddingOf(context).top;
    final foodsAsync = ref.watch(activeFoodsProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF141018) : _kCream;
    final titleColor = dark ? _kWhite : _kBrownDark;
    final hintMuted = dark ? Colors.white70 : _kBrown.withValues(alpha: 0.85);

    return ColoredBox(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: top + 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              l10n.searchTabTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _query,
              onChanged: (v) => setState(() => _filter = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: l10n.searchTabHint,
                prefixIcon: const Icon(Icons.search_rounded, color: _kBrown),
                filled: true,
                fillColor: dark ? const Color(0xFF1E1A22) : _kWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: _kBrown.withValues(alpha: 0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(color: _kOrange, width: 1.6),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Builder(
              builder: (context) {
                final raw = foodsAsync.valueOrNull ?? const <HomeProduct>[];
                if (foodsAsync.hasError && raw.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.homeFoodsLoadError, style: TextStyle(color: hintMuted)),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => ref.invalidate(activeFoodsProvider),
                          child: Text(l10n.retryLoad),
                        ),
                      ],
                    ),
                  );
                }
                if (foodsAsync.isLoading && raw.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: _kOrange));
                }
                var list = sortFoodsForDisplay(raw, categoryId: null);
                list = filterFoodsBySearch(list, _filter);
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      _filter.isEmpty ? l10n.searchTabEmpty : l10n.searchTabNoResults,
                      style: TextStyle(color: hintMuted),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final p = list[index];
                    return Material(
                      color: dark ? const Color(0xFF1E1A22) : _kWhite,
                      borderRadius: BorderRadius.circular(20),
                      elevation: 2,
                      shadowColor: _kBrown.withValues(alpha: 0.1),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => widget.onProductTap?.call(p),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ProductCoverImage(
                                  product: p,
                                  fit: BoxFit.cover,
                                  borderRadius: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: dark ? _kWhite : _kBrownDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


