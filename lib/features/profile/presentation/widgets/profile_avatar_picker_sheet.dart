import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../menu/application/menu_providers.dart';
import '../../../menu/data/category_icon_registry.dart';
import '../../../menu/domain/entities/menu_category.dart';
import '../../../menu/domain/home_product.dart';
import '../../domain/entities/profile_avatar_item.dart';
import '../../domain/profile_avatar_catalog.dart';

const _kPickerAccent = Color(0xFFFF8C00);

/// Profil rasmini tahrirlash: kategoriya → avatarlar (modal).
Future<ProfileAvatarItem?> showProfileAvatarPickerSheet(BuildContext context) {
  return showModalBottomSheet<ProfileAvatarItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ProfileAvatarPickerSheet(),
  );
}

class ProfileAvatarPickerSheet extends ConsumerStatefulWidget {
  const ProfileAvatarPickerSheet({super.key});

  @override
  ConsumerState<ProfileAvatarPickerSheet> createState() => _ProfileAvatarPickerSheetState();
}

class _ProfileAvatarPickerSheetState extends ConsumerState<ProfileAvatarPickerSheet> {
  MenuCategory? _selectedCategory;

  void _selectCategory(MenuCategory category) {
    setState(() => _selectedCategory = category);
  }

  void _goBack() {
    setState(() => _selectedCategory = null);
  }

  void _pickAvatar(ProfileAvatarItem item) {
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.78;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _kPickerAccent.withValues(alpha: 0.2),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.brown.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    if (_selectedCategory != null)
                      IconButton(
                        onPressed: _goBack,
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: const Color(0xFF5D4037),
                        tooltip: l10n.profileAvatarPickBack,
                      ),
                    Expanded(
                      child: Text(
                        _selectedCategory == null
                            ? l10n.profileAvatarPickTitle
                            : _selectedCategory!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Color(0xFF2B1E16),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.brown.shade400,
                    ),
                  ],
                ),
              ),
              if (_selectedCategory == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.profileAvatarPickSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown.shade600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: _selectedCategory == null
                      ? _CategoryListView(
                          key: const ValueKey('categories'),
                          onCategoryTap: _selectCategory,
                        )
                      : _AvatarGridView(
                          key: ValueKey('avatars_${_selectedCategory!.id}'),
                          category: _selectedCategory!,
                          onPick: _pickAvatar,
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryListView extends ConsumerWidget {
  const _CategoryListView({super.key, required this.onCategoryTap});

  final ValueChanged<MenuCategory> onCategoryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return categoriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: _kPickerAccent)),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.homeCategoriesEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.brown.shade600, fontWeight: FontWeight.w600),
        ),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.homeCategoriesEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.brown.shade600, fontWeight: FontWeight.w600),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          shrinkWrap: true,
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final c = categories[index];
            return _CategoryTile(category: c, onTap: () => onCategoryTap(c));
          },
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final MenuCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = CategoryIconRegistry.resolve(category.iconName);

    return Material(
      color: const Color(0xFFFFF8F0),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB74D), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF2B1E16),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.brown.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarGridView extends ConsumerWidget {
  const _AvatarGridView({
    super.key,
    required this.category,
    required this.onPick,
  });

  final MenuCategory category;
  final ValueChanged<ProfileAvatarItem> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final foodsAsync = ref.watch(activeFoodsProvider);

    return foodsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: _kPickerAccent)),
      ),
      error: (_, __) => _buildGrid(context, l10n, const []),
      data: (allFoods) {
        final foods = allFoods.where((f) => f.categoryId == category.id).toList();
        return _buildGrid(context, l10n, foods);
      },
    );
  }

  Widget _buildGrid(BuildContext context, AppLocalizations l10n, List<HomeProduct> foods) {
    final avatars = ProfileAvatarCatalog.avatarsForCategory(category, foods);

    if (avatars.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.profileAvatarPickEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.brown.shade600,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        return _AvatarTile(
          item: avatars[index],
          onTap: () => onPick(avatars[index]),
        );
      },
    );
  }
}

class _AvatarTile extends StatefulWidget {
  const _AvatarTile({required this.item, required this.onTap});

  final ProfileAvatarItem item;
  final VoidCallback onTap;

  @override
  State<_AvatarTile> createState() => _AvatarTileState();
}

class _AvatarTileState extends State<_AvatarTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _pressed ? _kPickerAccent : const Color(0xFFFFE0B2),
              width: _pressed ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _kPickerAccent.withValues(alpha: _pressed ? 0.35 : 0.15),
                blurRadius: _pressed ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(child: _AvatarImage(item: widget.item)),
        ),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.item});

  final ProfileAvatarItem item;

  @override
  Widget build(BuildContext context) {
    if (item.isAsset) {
      return Image.asset(
        item.assetPath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => const _AvatarFallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.networkUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, _) => const ColoredBox(
        color: Color(0xFFFFF3E0),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: _kPickerAccent),
          ),
        ),
      ),
      errorWidget: (_, _, _) => const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFFFF3E0),
      child: Center(
        child: Icon(Icons.fastfood_rounded, color: _kPickerAccent, size: 28),
      ),
    );
  }
}
