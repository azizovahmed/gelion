import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../menu/application/banner_link_handler.dart';
import '../../../menu/application/menu_providers.dart';
import '../../../menu/domain/home_product.dart' show OnAddToCart;
import 'home_banner_shimmer.dart';
import 'home_banner_slide.dart';

/// Bosh sahifa — Firestore `banners` real-time karusel.
class HomeBannerCarousel extends ConsumerStatefulWidget {
  const HomeBannerCarousel({super.key, required this.onAddToCart});

  final OnAddToCart onAddToCart;

  @override
  ConsumerState<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends ConsumerState<HomeBannerCarousel> {
  final PageController _controller = PageController();
  int _index = 0;
  Timer? _timer;
  int _lastSlideCount = 0;

  static const _autoInterval = Duration(seconds: 4);

  double _bannerHeight(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width - 36;
    return (w * 0.46).clamp(160.0, 210.0);
  }

  void _restartTimer(int count) {
    _timer?.cancel();
    if (count <= 1) return;
    _timer = Timer.periodic(_autoInterval, (_) {
      if (!mounted || !_controller.hasClients || count < 2) return;
      final next = (_index + 1) % count;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = _bannerHeight(context);
    final bannersAsync = ref.watch(activeBannersProvider);

    return bannersAsync.when(
      loading: () => HomeBannerShimmer(height: height),
      error: (_, __) => const SizedBox.shrink(),
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();

        if (banners.length != _lastSlideCount) {
          _lastSlideCount = banners.length;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _restartTimer(banners.length);
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: banners.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => HomeBannerSlide(
                      banner: banners[i],
                      onTap: () => openBannerLink(
                        context,
                        banner: banners[i],
                        onAddToCart: widget.onAddToCart,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (banners.length > 1) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(banners.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFFF8C00) : const Color(0xFFFFD9B0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ],
          ],
        );
      },
    );
  }
}
