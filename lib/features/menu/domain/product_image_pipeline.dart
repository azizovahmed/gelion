import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../../core/firebase/firebase_media_api.dart';
import 'food_image_url.dart';
import 'home_product.dart';

/// Mahsulot rasmi: Firestore → Storage → download URL → UI.
class ProductImageResolveResult {
  const ProductImageResolveResult({
    this.downloadUrl,
    this.storagePath = '',
    this.storageExists = false,
    this.error,
    this.renderStatus = 'unknown',
    this.source = 'none',
  });

  final String? downloadUrl;
  final String storagePath;
  final bool storageExists;
  final String? error;
  final String renderStatus;
  final String source;

  bool get canRender =>
      downloadUrl != null && isRenderableNetworkImageUrl(downloadUrl!);
}

abstract final class ProductImagePipeline {
  static const _logName = 'ProductImage';
  static const _maxStorageAttempts = 3;

  static void _log(String message) {
    if (!kDebugMode) return;
    developer.log(message, name: _logName);
  }

  static void logFirestoreFields(String productId, Map<String, dynamic> data) {
    final imagePath = '${data['imagePath'] ?? data['image_path'] ?? ''}';
    final imageUrl = _short('${data['imageUrl'] ?? data['image_url'] ?? ''}');
    final image = _short('${data['image'] ?? ''}');
    _log(
      'productId=$productId\n'
      'imagePath=$imagePath\n'
      'imageUrl=$imageUrl\n'
      'image=$image',
    );
  }

  static String _short(String value, [int max = 72]) {
    final v = value.trim();
    if (v.length <= max) return v.isEmpty ? '(empty)' : v;
    return '${v.substring(0, max)}…';
  }

  static List<String> storagePathCandidates(HomeProduct product) {
    final paths = <String>{};
    final fromPath = product.imagePath.trim();
    if (fromPath.isNotEmpty) paths.add(fromPath);

    // `image` maydoni Storage yo‘li bo‘lishi mumkin (admin panel).
    final rawImage = product.image.trim();
    if (rawImage.isNotEmpty &&
        !rawImage.startsWith('http') &&
        isFoodStorageRelativePath(rawImage)) {
      paths.add(rawImage);
    }

    if (product.id.isNotEmpty) {
      paths.add(defaultFoodCoverPath(product.id));
    }
    return paths.toList();
  }

  static Future<bool> storageFileExists(String storagePath) async {
    final path = storagePath.trim();
    if (path.isEmpty) return false;
    try {
      await FirebaseMediaApi.ref(path).getMetadata();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> downloadUrlForPath(String storagePath) async {
    final path = storagePath.trim();
    if (path.isEmpty) return null;

    if (path.startsWith('gs://')) {
      try {
        return await FirebaseMediaApi.storage.refFromURL(path).getDownloadURL();
      } catch (_) {
        return null;
      }
    }

    if (isRenderableNetworkImageUrl(path)) return path;

    if (!path.startsWith('foods/') &&
        !path.startsWith('products/') &&
        !path.startsWith('categories/') &&
        !path.startsWith('banners/')) {
      return null;
    }

    try {
      return await FirebaseMediaApi.ref(path).getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  /// Fallback: imageUrl → image (https) → imagePath / image (path) → Storage URL.
  static Future<ProductImageResolveResult> resolveForProduct(
    HomeProduct product, {
    Map<String, dynamic>? firestoreRaw,
  }) async {
    final id = product.id.isNotEmpty ? product.id : 'unknown';
    final imagePath = product.imagePath.trim();
    final imageUrl = product.imageUrl.trim();
    final rawImage = product.image.trim();

    if (firestoreRaw != null) {
      logFirestoreFields(id, firestoreRaw);
    } else {
      _log(
        'productId=$id\n'
        'imagePath=${imagePath.isEmpty ? "(empty)" : imagePath}\n'
        'imageUrl=${imageUrl.isEmpty ? "(empty)" : _short(imageUrl)}\n'
        'image=${rawImage.isEmpty ? "(empty)" : _short(rawImage)}',
      );
    }

    // 1. imageUrl (HTTPS)
    final normalizedUrl = FirebaseMediaApi.normalizeDownloadUrl(
      resolveDisplayImageUrl(imageUrl),
    );
    if (isRenderableNetworkImageUrl(normalizedUrl)) {
      _log(
        'productId=$id\n'
        'resolved via imageUrl\n'
        'render status=success',
      );
      return ProductImageResolveResult(
        downloadUrl: normalizedUrl,
        storagePath: imagePath,
        storageExists: true,
        renderStatus: 'success',
        source: 'imageUrl',
      );
    }

    // 2. image (HTTPS)
    final imageAsUrl = FirebaseMediaApi.normalizeDownloadUrl(
      resolveDisplayImageUrl(rawImage),
    );
    if (isRenderableNetworkImageUrl(imageAsUrl)) {
      _log(
        'productId=$id\n'
        'resolved via image\n'
        'render status=success',
      );
      return ProductImageResolveResult(
        downloadUrl: imageAsUrl,
        storagePath: imagePath,
        storageExists: true,
        renderStatus: 'success',
        source: 'image',
      );
    }

    // 3. imagePath / image (Storage path) → getDownloadURL
    var attempts = 0;
    for (final path in storagePathCandidates(product)) {
      if (attempts >= _maxStorageAttempts) break;
      attempts++;

      final url = await downloadUrlForPath(path);
      if (url != null && isRenderableNetworkImageUrl(url)) {
        final exists = await storageFileExists(path);
        _log(
          'productId=$id\n'
          'imagePath=$path\n'
          'resolved via Storage download URL\n'
          'render status=success',
        );
        return ProductImageResolveResult(
          downloadUrl: url,
          storagePath: path,
          storageExists: exists,
          renderStatus: 'success',
          source: 'imagePath',
        );
      }
    }

    _log(
      'productId=$id\n'
      'imagePath=$imagePath\n'
      'render status=placeholder',
    );
    return ProductImageResolveResult(
      storagePath: imagePath,
      storageExists: false,
      error: 'Storage fayl topilmadi yoki download URL olinmadi',
      renderStatus: 'placeholder',
      source: 'none',
    );
  }

  static void logRenderStatus({
    required String productId,
    required String status,
    String? url,
    Object? error,
  }) {
    _log(
      'productId=$productId\n'
      'render status=$status'
      '${url != null ? '\nurl=${_short(url)}' : ''}'
      '${error != null ? '\nerror=$error' : ''}',
    );
  }
}
