import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

import '../../../core/firebase/firebase_media_api.dart';
import '../domain/food_image_url.dart';
import '../domain/home_product.dart';
import '../domain/product_image_pipeline.dart';

/// `imagePath` → Firebase Storage `getDownloadURL()`.
Future<HomeProduct> resolveProductImageUrl(HomeProduct product) async {
  if (product.imageBytes != null && product.imageBytes!.isNotEmpty) {
    return product;
  }

  final normalizedUrl = FirebaseMediaApi.normalizeDownloadUrl(
    resolveDisplayImageUrl(product.imageUrl),
  );
  if (isRenderableNetworkImageUrl(normalizedUrl)) {
    if (normalizedUrl == product.imageUrl.trim()) return product;
    return product.copyWith(imageUrl: normalizedUrl);
  }

  if (product.imagePath.isEmpty && product.id.isEmpty) {
    return product;
  }

  final result = await ProductImagePipeline.resolveForProduct(product);
  if (result.canRender) {
    return product.copyWith(
      imageUrl: result.downloadUrl!,
      imagePath: result.storagePath.isNotEmpty ? result.storagePath : product.imagePath,
    );
  }

  final fallback = await FirebaseMediaApi.resolveFullImageUrl(
    imageUrl: product.imageUrl,
    imagePath: product.imagePath.isNotEmpty
        ? product.imagePath
        : product.firestoreImage,
  );
  if (isRenderableNetworkImageUrl(fallback)) {
    return product.copyWith(imageUrl: fallback);
  }

  if (kDebugMode) {
    developer.log(
      'resolveProductImageUrl: no URL for ${product.id} | ${result.error}',
      name: 'ProductImage',
    );
  }
  return product;
}

Future<List<HomeProduct>> resolveProductImageUrls(List<HomeProduct> products) async {
  if (products.isEmpty) return products;

  final timeout = kIsWeb ? const Duration(seconds: 15) : const Duration(seconds: 20);
  final resolved = <HomeProduct>[];

  for (final p in products) {
    try {
      final item = await resolveProductImageUrl(p).timeout(
        timeout,
        onTimeout: () {
          if (kDebugMode) {
            developer.log(
              'resolveProductImageUrl TIMEOUT id=${p.id} path=${p.imagePath}',
              name: 'ProductImage',
            );
          }
          return p;
        },
      );
      resolved.add(item);
    } catch (e) {
      if (kDebugMode) {
        developer.log('resolveProductImageUrl ERROR id=${p.id} $e', name: 'ProductImage');
      }
      resolved.add(p);
    }
  }

  if (kDebugMode) {
    final ok = resolved.where((p) => isRenderableNetworkImageUrl(p.imageUrl)).length;
    developer.log(
      'resolveProductImageUrls: $ok/${products.length} via Storage download URL',
      name: 'ProductImage',
    );
  }

  return resolved;
}
