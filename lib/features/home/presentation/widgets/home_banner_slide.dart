import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../menu/domain/entities/promo_banner.dart';

class HomeBannerSlide extends StatelessWidget {
  const HomeBannerSlide({
    super.key,
    required this.banner,
    required this.onTap,
  });

  final PromoBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badge = banner.buttonText.isNotEmpty
        ? banner.buttonText
        : (banner.discount.isNotEmpty ? banner.discount : '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _BannerImage(url: banner.imageUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.72),
                    Colors.black.withValues(alpha: 0.28),
                    Colors.black.withValues(alpha: 0.12),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (badge.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEB3B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF5D4037),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  if (badge.isNotEmpty) const SizedBox(height: 8),
                  if (banner.title.isNotEmpty)
                    Text(
                      banner.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                        shadows: [
                          Shadow(
                            color: Color(0x66000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  if (banner.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFF3E0),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: Color(0x55000000),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9100), Color(0xFFFF6D00)],
          ),
        ),
        child: Center(
          child: Icon(Icons.image_outlined, size: 48, color: Colors.white70),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, _) => const ColoredBox(
        color: Color(0xFFFFF3E0),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFF8C00),
            ),
          ),
        ),
      ),
      errorWidget: (_, _, _) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9100), Color(0xFFFF6D00)],
          ),
        ),
        child: Center(
          child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.white70),
        ),
      ),
    );
  }
}
