import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/services/firebase_error_mapper.dart';
import '../../application/menu_providers.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/food_image_url.dart';
import '../../domain/product_image_picker.dart';
import '../../domain/product_image_prepare.dart';

/// Admin: bannerlar CRUD + rasm (Storage).
class AdminBannersPage extends ConsumerWidget {
  const AdminBannersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF141018) : const Color(0xFFFFF9F0);
    final bannersAsync = ref.watch(adminBannersProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(l10n.adminBannersTitle),
        backgroundColor: isDark ? const Color(0xFF1E1A22) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2B1E16),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        backgroundColor: const Color(0xFFFF8C00),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.adminBannerAdd),
      ),
      body: bannersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00))),
        error: (e, _) => Center(child: Text(FirebaseErrorMapper.map(l10n, e))),
        data: (banners) {
          if (banners.isEmpty) {
            return Center(child: Text(l10n.adminBannersEmpty));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            itemCount: banners.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final b = banners[i];
              final url = normalizeFoodImageUrl(b.imageUrl);
              return Material(
                color: isDark ? const Color(0xFF1E1A22) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: isRenderableNetworkImageUrl(url)
                          ? CachedNetworkImage(imageUrl: url, fit: BoxFit.cover)
                          : const ColoredBox(
                              color: Color(0xFFFFF3E0),
                              child: Icon(Icons.image_outlined),
                            ),
                    ),
                  ),
                  title: Text(b.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(b.subtitle),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () => _delete(context, ref, b),
                  ),
                  onTap: () => _openEditor(context, existing: b),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, PromoBanner b) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminBannerDeleteTitle),
        content: Text(l10n.adminBannerDeleteBody),
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
      await ref.read(catalogAdminRepositoryProvider).deleteBanner(b.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FirebaseErrorMapper.map(l10n, e))),
        );
      }
    }
  }

  void _openEditor(BuildContext context, {PromoBanner? existing}) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BannerEditorSheet(existing: existing),
    );
  }
}

class _BannerEditorSheet extends ConsumerStatefulWidget {
  const _BannerEditorSheet({this.existing});

  final PromoBanner? existing;

  @override
  ConsumerState<_BannerEditorSheet> createState() => _BannerEditorSheetState();
}

class _BannerEditorSheetState extends ConsumerState<_BannerEditorSheet> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _buttonCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _orderCtrl = TextEditingController(text: '0');
  final _discountCtrl = TextEditingController();
  bool _active = true;
  bool _saving = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _subtitleCtrl.text = e.subtitle;
      _buttonCtrl.text = e.buttonText;
      _linkCtrl.text = e.link;
      _orderCtrl.text = '${e.order}';
      _discountCtrl.text = e.discount;
      _active = e.isActive;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _buttonCtrl.dispose();
    _linkCtrl.dispose();
    _orderCtrl.dispose();
    _discountCtrl.dispose();
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
    if (_titleCtrl.text.trim().isEmpty) return;
    if (widget.existing == null && (_imageBytes == null || _imageBytes!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminBannerImageRequired)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final banner = PromoBanner(
        id: widget.existing?.id ?? '',
        title: _titleCtrl.text.trim(),
        subtitle: _subtitleCtrl.text.trim(),
        imageUrl: widget.existing?.imageUrl ?? '',
        buttonText: _buttonCtrl.text.trim(),
        link: _linkCtrl.text.trim(),
        discount: _discountCtrl.text.trim(),
        isActive: _active,
        order: int.tryParse(_orderCtrl.text) ?? 0,
      );
      await ref.read(catalogAdminRepositoryProvider).saveBanner(
            banner,
            imageBytes: _imageBytes,
            setCreatedAt: widget.existing == null,
          );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminBannerSaved)),
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
                widget.existing == null ? l10n.adminBannerAdd : l10n.adminBannerEdit,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.profilePhotoGallery),
              ),
              const SizedBox(height: 12),
              TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: l10n.adminBannerTitle)),
              const SizedBox(height: 10),
              TextField(controller: _subtitleCtrl, decoration: InputDecoration(labelText: l10n.adminBannerSubtitle)),
              const SizedBox(height: 10),
              TextField(controller: _buttonCtrl, decoration: InputDecoration(labelText: l10n.adminBannerButton)),
              const SizedBox(height: 10),
              TextField(
                controller: _linkCtrl,
                decoration: InputDecoration(
                  labelText: l10n.adminBannerLink,
                  hintText: 'category:ID yoki product:ID',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _orderCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.adminCategoryOrder),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _discountCtrl,
                decoration: InputDecoration(labelText: l10n.adminBannerDiscount),
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
                child: Text(l10n.adminFoodSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
