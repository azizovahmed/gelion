import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/services/firebase_error_mapper.dart';
import '../../application/menu_providers.dart';
import '../../data/category_icon_registry.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/product_image_picker.dart';
import '../../domain/product_image_prepare.dart';
import '../widgets/category_network_avatar.dart';

/// Admin: kategoriyalar CRUD + rasm (Storage).
class AdminCategoriesPage extends ConsumerWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141018) : const Color(0xFFFFF9F0);
    final catsAsync = ref.watch(adminCategoriesProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(l10n.adminCategoriesTitle),
        backgroundColor: isDark ? const Color(0xFF1E1A22) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2B1E16),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        backgroundColor: const Color(0xFFFF8C00),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.adminCategoryAdd),
      ),
      body: catsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00))),
        error: (e, _) => Center(child: Text(FirebaseErrorMapper.map(l10n, e))),
        data: (cats) {
          if (cats.isEmpty) {
            return Center(child: Text(l10n.adminCategoriesEmpty));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            itemCount: cats.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = cats[i];
              return Material(
                color: isDark ? const Color(0xFF1E1A22) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: ListTile(
                  leading: SizedBox(
                    width: 48,
                    height: 48,
                    child: CategoryNetworkAvatar(
                      category: c,
                      size: 48,
                      icon: CategoryNetworkAvatar.iconFor(c),
                    ),
                  ),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                    '${l10n.adminCategoryOrder}: ${c.order} • ${c.isActive ? "✓" : "—"}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () => _delete(context, ref, c),
                  ),
                  onTap: () => _openEditor(context, ref, existing: c),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, MenuCategory c) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminCategoryDeleteTitle),
        content: Text(l10n.adminCategoryDeleteBody),
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
      await ref.read(catalogAdminRepositoryProvider).deleteCategory(c.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FirebaseErrorMapper.map(l10n, e))),
        );
      }
    }
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref, {MenuCategory? existing}) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryEditorSheet(existing: existing),
    );
  }
}

class _CategoryEditorSheet extends ConsumerStatefulWidget {
  const _CategoryEditorSheet({this.existing});

  final MenuCategory? existing;

  @override
  ConsumerState<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends ConsumerState<_CategoryEditorSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _orderCtrl = TextEditingController(text: '0');
  String _iconName = 'fastfood';
  bool _active = true;
  bool _saving = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameCtrl.text = e.name;
      _descCtrl.text = e.description;
      _orderCtrl.text = '${e.order}';
      _iconName = e.iconName;
      _active = e.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final raw = await pickProductImageBytes();
    if (raw == null) return;
    final bytes = await prepareProductImagePreviewBytes(raw);
    if (mounted) setState(() => _imageBytes = bytes);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final cat = MenuCategory(
        id: widget.existing?.id ?? '',
        name: name,
        description: _descCtrl.text.trim(),
        imageUrl: widget.existing?.imageUrl ?? '',
        iconName: _iconName,
        order: int.tryParse(_orderCtrl.text) ?? 0,
        isActive: _active,
      );
      await ref.read(catalogAdminRepositoryProvider).saveCategory(
            cat,
            imageBytes: _imageBytes,
          );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminCategorySaved)),
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
    final iconKeys = CategoryIconRegistry.icons.keys.toList();

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(20),
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
                widget.existing == null ? l10n.adminCategoryAdd : l10n.adminCategoryEdit,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.profilePhotoGallery),
              ),
              const SizedBox(height: 12),
              TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: l10n.adminCategoryName)),
              const SizedBox(height: 10),
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.adminCategoryDescription),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _orderCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.adminCategoryOrder),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: iconKeys.contains(_iconName) ? _iconName : 'fastfood',
                decoration: InputDecoration(labelText: l10n.adminCategoryIcon),
                items: iconKeys
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _iconName = v ?? 'fastfood'),
              ),
              SwitchListTile(
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                title: Text(l10n.adminFoodActive),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8C00)),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.adminFoodSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
