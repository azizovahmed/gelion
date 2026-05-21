import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/app_l10n.dart';
import '../../home/presentation/pages/home_feed_page.dart' show OnAddToCart;
import '../domain/entities/banner_link_target.dart';
import '../domain/entities/menu_category.dart';
import '../domain/entities/promo_banner.dart';
import '../domain/home_product.dart';
import '../presentation/pages/category_products_page.dart';
import '../presentation/pages/product_detail_page.dart';

/// Banner bosilganda `link` bo‘yicha kategoriya yoki mahsulot ochiladi.
Future<void> openBannerLink(
  BuildContext context, {
  required PromoBanner banner,
  required OnAddToCart onAddToCart,
}) async {
  final link = banner.link.trim();
  final hasExplicitPrefix = link.contains(':') || link.contains('/');
  final target = BannerLinkTarget.parse(banner.link);

  if (!hasExplicitPrefix && target.kind == BannerLinkKind.product && target.id.isNotEmpty) {
    final product = await _fetchProduct(target.id);
    if (product != null) {
      if (!context.mounted) return;
      await _openProduct(context, product.id, onAddToCart: onAddToCart);
      return;
    }
    final category = await _fetchCategory(target.id);
    if (category != null) {
      if (!context.mounted) return;
      await _openCategory(context, category.id, onAddToCart: onAddToCart);
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(context.l10n.homeFoodsLoadError),
        ),
      );
    }
    return;
  }

  if (!context.mounted) return;

  switch (target.kind) {
    case BannerLinkKind.none:
      return;
    case BannerLinkKind.category:
      await _openCategory(context, target.id, onAddToCart: onAddToCart);
    case BannerLinkKind.product:
      await _openProduct(context, target.id, onAddToCart: onAddToCart);
  }
}

Future<void> _openCategory(
  BuildContext context,
  String categoryId, {
  required OnAddToCart onAddToCart,
}) async {
  if (categoryId.isEmpty) return;
  final l10n = context.l10n;
  final category = await _fetchCategory(categoryId);
  final title = category != null
      ? l10n.categoryAssortmentTitle(category.name)
      : l10n.homeAllFoodsTitle;

  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => CategoryProductsPage(
        pageTitle: title,
        categoryId: categoryId,
        onAddToCart: onAddToCart,
      ),
    ),
  );
}

Future<void> _openProduct(
  BuildContext context,
  String productId, {
  required OnAddToCart onAddToCart,
}) async {
  if (productId.isEmpty) return;
  final product = await _fetchProduct(productId);
  if (product == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(context.l10n.homeFoodsLoadError),
        ),
      );
    }
    return;
  }
  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => ProductDetailPage(product: product, onAddToCart: onAddToCart),
    ),
  );
}

Future<MenuCategory?> _fetchCategory(String id) async {
  final doc = await FirebaseFirestore.instance.collection('categories').doc(id).get();
  if (!doc.exists) return null;
  return MenuCategory.fromDoc(doc);
}

Future<HomeProduct?> _fetchProduct(String id) async {
  final doc = await FirebaseFirestore.instance.collection('foods').doc(id).get();
  if (!doc.exists) return null;
  final product = HomeProduct.fromDoc(doc);
  if (!product.isActive) return null;
  return product;
}
