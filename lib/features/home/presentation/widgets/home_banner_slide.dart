import 'package:flutter/material.dart';

import '../../../menu/domain/entities/promo_banner.dart';
import '../../../menu/presentation/widgets/banner_cover_image.dart';

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
            BannerCoverImage(banner: banner, fit: BoxFit.cover),
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

