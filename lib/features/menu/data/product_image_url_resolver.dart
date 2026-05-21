import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../domain/food_image_url.dart';
import '../domain/home_product.dart';

/// Storage `gs://`, relative path va noto‘g‘ri URL larni HTTPS ga aylantiradi.
Future<HomeProduct> resolveProductImageUrl(HomeProduct product) async {
  if (product.imageBytes != null && product.imageBytes!.isNotEmpty) {
    final url = normalizeFoodImageUrl(product.imageUrl);
    if (isRenderableNetworkImageUrl(url)) return product;
  }

  var url = await _resolveToHttps(product.imageUrl.trim());
  if (url.isEmpty && product.id.isNotEmpty) {
    url = await _resolveToHttps('foods/${product.id}/cover.jpg');
  }
  if (url.isEmpty || !isRenderableNetworkImageUrl(url)) return product;

  return product.copyWith(imageUrl: url);
}

Future<List<HomeProduct>> resolveProductImageUrls(List<HomeProduct> products) async {
  if (products.isEmpty) return products;

  // Web: har snapshotda o‘nlab Storage so‘rovi UI ni uzoq “loading” qiladi.
  final timeout = kIsWeb ? const Duration(seconds: 4) : const Duration(seconds: 12);
  return Future.wait(
    products.map(
      (p) => resolveProductImageUrl(p).timeout(timeout, onTimeout: () => p),
    ),
  );
}

Future<String> _resolveToHttps(String raw) async {
  var url = normalizeFoodImageUrl(raw);
  if (url.isEmpty) return '';

  if (url.startsWith('gs://')) {
    try {
      return await FirebaseStorage.instance.refFromURL(url).getDownloadURL();
    } catch (_) {
      return '';
    }
  }

  if (isRenderableNetworkImageUrl(url)) return url;

  // foods/abc/cover.jpg
  if (!url.contains('://')) {
    try {
      return await FirebaseStorage.instance.ref(url).getDownloadURL();
    } catch (_) {
      return '';
    }
  }

  return '';
}
