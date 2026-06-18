import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';

import '../../features/menu/domain/food_image_url.dart';
import '../firebase/firebase_media_api.dart';

/// API / Storage dan kelgan to‘liq HTTPS URL — yuklanish va xato holati bilan.
class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cacheKey,
    this.memCacheWidth,
    this.onRetry,
    this.onLoadFailed,
    this.loadingColor,
    this.errorLabel,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? cacheKey;
  final int? memCacheWidth;
  final VoidCallback? onRetry;
  final VoidCallback? onLoadFailed;
  final Color? loadingColor;
  final String? errorLabel;

  @override
  Widget build(BuildContext context) {
    final url = FirebaseMediaApi.normalizeDownloadUrl(
      resolveDisplayImageUrl(imageUrl),
    );
    if (!isRenderableNetworkImageUrl(url)) {
      return _ErrorBox(
        label: errorLabel ?? 'Rasm URL yo‘q',
        onRetry: onRetry,
        width: width,
        height: height,
      );
    }

    final accent = loadingColor ?? const Color(0xFFFF8C00);

    // Web: HtmlImage (<img>) — Firebase Storage OPTIONS preflight xatosini oldini oladi.
    if (kIsWeb) {
      return Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _LoadingBox(
            width: width,
            height: height,
            color: accent,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            debugPrint('SafeNetworkImage web error: $url | $error');
          }
          onLoadFailed?.call();
          return _ErrorBox(
            label: errorLabel ?? 'Yuklanmadi',
            onRetry: onRetry,
            width: width,
            height: height,
            detail: kDebugNetworkImageErrors ? '$error' : null,
          );
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      cacheKey: cacheKey ?? url,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      httpHeaders: const {'Accept': 'image/*'},
      fadeInDuration: const Duration(milliseconds: 280),
      fadeOutDuration: const Duration(milliseconds: 120),
      placeholder: (_, _) => _LoadingBox(
        width: width,
        height: height,
        color: accent,
      ),
      errorWidget: (_, failedUrl, error) {
        if (kDebugMode) {
          debugPrint('SafeNetworkImage error: $failedUrl | $error');
        }
        onLoadFailed?.call();
        return _ErrorBox(
          label: errorLabel ?? 'Yuklanmadi',
          onRetry: onRetry,
          width: width,
          height: height,
          detail: kDebugNetworkImageErrors ? '$error' : null,
        );
      },
    );
  }
}

/// Debug rejimida xato matnini ko‘rsatish.
bool kDebugNetworkImageErrors = false;

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({this.width, this.height, required this.color});

  final double? width;
  final double? height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: const Color(0xFFFFF2E2),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({
    required this.label,
    this.onRetry,
    this.width,
    this.height,
    this.detail,
  });

  final String label;
  final VoidCallback? onRetry;
  final double? width;
  final double? height;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: const Color(0xFFFFF3E0),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.brown.shade600,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Qayta', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
