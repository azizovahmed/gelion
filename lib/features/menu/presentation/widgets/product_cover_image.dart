import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/food_image_url.dart';
import '../../domain/home_product.dart';

/// Firestore `image` (Storage HTTPS) → [CachedNetworkImage], yo‘q bo‘lsa placeholder.
class ProductCoverImage extends StatelessWidget {
  const ProductCoverImage({
    super.key,
    required this.product,
    this.memoryOverride,
    this.fit = BoxFit.cover,
    this.height,
    this.borderRadius = 16,
    this.topCornersOnly = false,
  });

  final HomeProduct product;
  /// Admin preview (saqlashdan oldin); mobil — faqat [product.image].
  final Uint8List? memoryOverride;
  final BoxFit fit;
  final double? height;
  final double borderRadius;
  final bool topCornersOnly;

  String get _networkUrl {
    final url = normalizeFoodImageUrl(product.image);
    if (isRenderableNetworkImageUrl(url)) return url;
    return '';
  }

  Uint8List? get _fallbackBytes {
    final b = product.imageBytes;
    if (b != null && b.isNotEmpty) return b;
    return null;
  }

  BorderRadius get _radius => topCornersOnly
      ? BorderRadius.vertical(top: Radius.circular(borderRadius))
      : BorderRadius.circular(borderRadius);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final url = _networkUrl;
    final localPreview = memoryOverride;

    return ClipRRect(
      borderRadius: _radius,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final h = height ??
              (constraints.maxHeight.isFinite && constraints.maxHeight > 0
                  ? constraints.maxHeight
                  : 140.0);

          Widget child;

          if (url.isNotEmpty) {
            final dpr = MediaQuery.devicePixelRatioOf(context);
            final memCacheWidth = (width * dpr).round().clamp(128, 1400);
            child = CachedNetworkImage(
              imageUrl: url,
              cacheKey: '${product.id}|$url',
              fit: fit,
              width: width,
              height: h,
              memCacheWidth: memCacheWidth,
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 120),
              placeholder: (_, _) => _LoadingBox(dark: dark),
              errorWidget: (_, _, error) => _DefaultFoodIcon(dark: dark),
            );
          } else if (localPreview != null && localPreview.isNotEmpty) {
            child = Image.memory(
              localPreview,
              width: width,
              height: h,
              fit: fit,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) => _DefaultFoodIcon(dark: dark),
            );
          } else {
            final bytes = _fallbackBytes;
            if (bytes != null) {
              child = Image.memory(
                bytes,
                width: width,
                height: h,
                fit: fit,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => _DefaultFoodIcon(dark: dark),
              );
            } else {
              child = _DefaultFoodIcon(dark: dark);
            }
          }

          return SizedBox(width: width, height: h, child: child);
        },
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: dark ? const Color(0xFF2A2430) : const Color(0xFFFFF2E2),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: dark ? const Color(0xFFFFB74D) : const Color(0xFFFF8C00),
          ),
        ),
      ),
    );
  }
}

class _DefaultFoodIcon extends StatelessWidget {
  const _DefaultFoodIcon({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: dark ? const Color(0xFF2A2430) : const Color(0xFFFFF3E0),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 44,
          color: dark ? const Color(0xFFFFB74D) : const Color(0xFFFF8C00),
        ),
      ),
    );
  }
}
