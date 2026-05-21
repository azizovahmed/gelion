import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/services/firebase_error_mapper.dart';
import '../../application/menu_providers.dart';
import '../../domain/cart_product_rules.dart';
import '../../domain/home_product.dart';
import '../../domain/product_image_debug.dart';
import '../../domain/product_image_picker.dart';
import '../../domain/product_image_prepare.dart';
import '../widgets/product_cover_image.dart';

/// Admin: taomlar + rasm → Storage → Firestore `image` (HTTPS).
class AdminFoodsPage extends ConsumerWidget {
  const AdminFoodsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141018) : const Color(0xFFFFF9F0);
    final foodsAsync = ref.watch(adminFoodsProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(l10n.adminFoodsTitle),
        backgroundColor: isDark ? const Color(0xFF1E1A22) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2B1E16),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        backgroundColor: const Color(0xFFFF8C00),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.adminFoodAdd),
      ),
      body: foodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00))),
        error: (e, _) => Center(child: Text(FirebaseErrorMapper.map(l10n, e))),
        data: (foods) {
          if (foods.isEmpty) {
            return Center(
              child: Text(
                l10n.adminFoodsEmpty,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : Colors.brown.shade600,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            itemCount: foods.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final f = foods[i];
              return _AdminFoodTile(
                food: f,
                isDark: isDark,
                onTap: () => _openEditor(context, ref, existing: f),
                onDelete: () => _delete(context, ref, f),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, HomeProduct food) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminFoodDeleteTitle),
        content: Text(l10n.adminFoodDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.profileCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l10n.adminFeedbackDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(catalogAdminRepositoryProvider).deleteFood(food.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FirebaseErrorMapper.map(l10n, e))),
        );
      }
    }
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref, {HomeProduct? existing}) async {
    final initialBytes = existing?.imageBytes;
    ref.read(adminProductImageDraftProvider.notifier).state = initialBytes;
    printProductImageDebug('openEditor', initialBytes);

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (ctx) => _FoodEditorSheet(existing: existing),
    );

    if (saved != true) {
      ref.read(adminProductImageDraftProvider.notifier).state = null;
    }
  }
}

class _AdminFoodTile extends StatelessWidget {
  const _AdminFoodTile({
    required this.food,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  final HomeProduct food;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF1E1A22) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: ProductCoverImage(
                    product: food,
                    fit: BoxFit.cover,
                    height: 72,
                    borderRadius: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF2B1E16),
                      ),
                    ),
                    Text(
                      '${food.price} • ${food.isActive ? 'Active' : 'Off'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.brown.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodEditorSheet extends ConsumerStatefulWidget {
  const _FoodEditorSheet({this.existing});

  final HomeProduct? existing;

  @override
  ConsumerState<_FoodEditorSheet> createState() => _FoodEditorSheetState();
}

class _FoodEditorSheetState extends ConsumerState<_FoodEditorSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  String? _categoryId;
  bool _popular = true;
  bool _recommended = false;
  bool _active = true;
  bool _saving = false;

  /// Tanlangan rasm — modal ichida saqlanadi, create bosilganda yo‘qolmaydi.
  Uint8List? selectedImageBytes;

  @override
  void initState() {
    super.initState();
    selectedImageBytes = ref.read(adminProductImageDraftProvider);
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _priceCtrl.text = '${e.price}';
      _stockCtrl.text = e.stock < 0 ? '' : '${e.stock}';
      _descCtrl.text = e.description ?? '';
      _ingredientsCtrl.text = e.ingredients ?? '';
      _categoryId = e.categoryId;
      _popular = e.isPopular;
      _recommended = e.isRecommended;
      _active = e.isActive;
      selectedImageBytes ??= e.imageBytes;
    }
    printProductImageDebug('initState', selectedImageBytes);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    _ingredientsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final raw = await pickProductImageBytes();
    if (raw == null || raw.isEmpty) return;

    final bytes = await prepareProductImagePreviewBytes(raw);
    if (!mounted) return;

    selectedImageBytes = bytes;
    ref.read(adminProductImageDraftProvider.notifier).state = bytes;
    printProductImageDebug('pickImage', selectedImageBytes);
    setState(() {});
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final price = int.tryParse(_priceCtrl.text.replaceAll(RegExp(r'[\s,]'), '')) ?? 0;
    final stockRaw = _stockCtrl.text.trim();
    final stock = stockRaw.isEmpty
        ? CartProductRules.unlimitedStock
        : (int.tryParse(stockRaw) ?? CartProductRules.unlimitedStock);

    // Create bosilganda rasm state dan olinadi (modal yopilishidan oldin).
    final Uint8List? bytesForSave =
        selectedImageBytes ?? ref.read(adminProductImageDraftProvider);
    if (widget.existing == null &&
        (bytesForSave == null || bytesForSave.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminFoodImageRequired)),
      );
      return;
    }

    logProductImageDebug(
      'createProduct:beforeSave',
      imageBytes: bytesForSave,
      productId: widget.existing?.id,
    );

    setState(() => _saving = true);
    try {
      String? categoryName;
      final cats = ref.read(adminCategoriesProvider).valueOrNull;
      if (_categoryId != null && cats != null) {
        for (final c in cats) {
          if (c.id == _categoryId) {
            categoryName = c.name;
            break;
          }
        }
      }

      final food = HomeProduct(
        id: widget.existing?.id ?? '',
        name: name,
        price: price,
        imageUrl: widget.existing?.imageUrl ?? '',
        imageBytes: bytesForSave,
        category: categoryName,
        categoryId: _categoryId,
        description: _descCtrl.text.trim(),
        ingredients: _ingredientsCtrl.text.trim().isEmpty
            ? null
            : _ingredientsCtrl.text.trim(),
        isPopular: _popular,
        isRecommended: _recommended,
        isActive: _active,
        stock: stock,
      );

      logProductImageDebug(
        'createProduct:payload',
        imageBytes: food.imageBytes,
        productId: food.id,
        payload: food.toMap(),
      );

      await ref.read(catalogAdminRepositoryProvider).saveFood(
            food,
            imageBytes: bytesForSave,
            setCreatedAt: widget.existing == null,
          );

      selectedImageBytes = null;
      ref.read(adminProductImageDraftProvider.notifier).state = null;

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminFoodSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FirebaseErrorMapper.map(l10n, e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final categoriesAsync = ref.watch(adminCategoriesProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existing == null ? l10n.adminFoodAdd : l10n.adminFoodEdit,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: selectedImageBytes != null && selectedImageBytes!.isNotEmpty
                      ? Image.memory(
                          selectedImageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 160,
                          gaplessPlayback: true,
                        )
                      : widget.existing != null
                          ? ProductCoverImage(
                              product: widget.existing!,
                              fit: BoxFit.cover,
                              height: 160,
                              borderRadius: 18,
                            )
                          : const ColoredBox(
                              color: Color(0xFFFFF3E0),
                              child: Center(child: Icon(Icons.add_photo_alternate_outlined, size: 48)),
                            ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.profilePhotoGallery),
              ),
              const SizedBox(height: 12),
              TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: l10n.adminFoodName)),
              const SizedBox(height: 10),
              TextField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.adminFoodPrice),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _stockCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.adminFoodStock,
                  hintText: l10n.adminFoodStockHint,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.adminFoodDescription),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ingredientsCtrl,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.adminFoodIngredients),
              ),
              const SizedBox(height: 10),
              categoriesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (cats) {
                  final validIds = cats.map((c) => c.id).toSet();
                  final selected =
                      _categoryId != null && validIds.contains(_categoryId) ? _categoryId : null;
                  return DropdownButtonFormField<String?>(
                    // ignore: deprecated_member_use
                    value: selected,
                    decoration: InputDecoration(labelText: l10n.adminFoodCategory),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('—')),
                      ...cats.map(
                        (c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _categoryId = v),
                  );
                },
              ),
              SwitchListTile(
                value: _popular,
                onChanged: (v) => setState(() => _popular = v),
                title: Text(l10n.adminFoodPopular),
              ),
              SwitchListTile(
                value: _recommended,
                onChanged: (v) => setState(() => _recommended = v),
                title: Text(l10n.adminFoodRecommended),
              ),
              SwitchListTile(
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                title: Text(l10n.adminFoodActive),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        widget.existing == null ? l10n.adminFoodCreate : l10n.adminFoodSave,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
