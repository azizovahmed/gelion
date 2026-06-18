import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

import '../../../core/firebase/firebase_media_api.dart';
import '../domain/banner_image_pipeline.dart';
import '../domain/banner_list_utils.dart';
import '../domain/entities/promo_banner.dart';
import '../domain/food_image_url.dart';

/// Banner `imagePath` → Firebase Storage `getDownloadURL()`.
Future<PromoBanner> resolveBannerImageUrl(PromoBanner banner) async {
  final normalizedUrl = FirebaseMediaApi.normalizeDownloadUrl(
    resolveDisplayImageUrl(banner.imageUrl),
  );
  if (isRenderableNetworkImageUrl(normalizedUrl)) {
    if (normalizedUrl == banner.imageUrl.trim()) return banner;
    return banner.copyWith(imageUrl: normalizedUrl);
  }

  if (banner.imagePath.isEmpty && banner.id.isEmpty) return banner;

  final result = await BannerImagePipeline.resolveForBanner(banner);
  if (result.canRender) {
    return banner.copyWith(
      imageUrl: result.downloadUrl!,
      imagePath: result.storagePath.isNotEmpty ? result.storagePath : banner.imagePath,
    );
  }

  final fallback = await FirebaseMediaApi.resolveFullImageUrl(
    imageUrl: banner.imageUrl,
    imagePath: banner.imagePath,
  );
  if (isRenderableNetworkImageUrl(fallback)) {
    return banner.copyWith(imageUrl: fallback);
  }

  if (kDebugMode) {
    developer.log(
      'resolveBannerImageUrl: no URL for ${banner.id} | ${result.error}',
      name: 'BannerImage',
    );
  }
  return banner;
}

Future<List<PromoBanner>> resolveBannerImageUrls(List<PromoBanner> banners) async {
  if (banners.isEmpty) return banners;

  final unique = dedupeBannersById(banners);
  final timeout = kIsWeb ? const Duration(seconds: 15) : const Duration(seconds: 20);
  final resolved = <PromoBanner>[];

  for (final banner in unique) {
    try {
      final item = await resolveBannerImageUrl(banner).timeout(
        timeout,
        onTimeout: () {
          if (kDebugMode) {
            developer.log(
              'resolveBannerImageUrl TIMEOUT id=${banner.id} path=${banner.imagePath}',
              name: 'BannerImage',
            );
          }
          return banner;
        },
      );
      resolved.add(item);
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          'resolveBannerImageUrl ERROR id=${banner.id} $e',
          name: 'BannerImage',
        );
      }
      resolved.add(banner);
    }
  }

  if (kDebugMode) {
    final ok = resolved.where((b) => isRenderableNetworkImageUrl(b.imageUrl)).length;
    developer.log(
      'resolveBannerImageUrls: $ok/${unique.length} via Storage download URL',
      name: 'BannerImage',
    );
  }

  return resolved;
}
