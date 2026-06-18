import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../menu/application/banner_link_handler.dart';
import '../../../menu/application/menu_providers.dart';
import '../../../menu/domain/home_product.dart' show OnAddToCart;
import 'home_banner_shimmer.dart';
import 'home_banner_slide.dart';

/// Bosh sahifa — Firestore `banners` real-time karusel (cheklovsiz son).
class HomeBannerCarousel extends ConsumerStatefulWidget {
  const HomeBannerCarousel({super.key, required this.onAddToCart});

  final OnAddToCart onAddToCart;

  @override
  ConsumerState<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends ConsumerState<HomeBannerCarousel> {
  PageController? _controller;
  int _index = 0;
  Timer? _timer;
  int _lastSlideCount = 0;

  static const _autoInterval = Duration(seconds: 4);
  static const _maxDotIndicators = 12;

  double _bannerHeight(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width - 36;
    return (w * 0.46).clamp(160.0, 210.0);
  }

  PageController _ensureController() {
    _controller ??= PageController();
    return _controller!;
  }

  void _restartTimer(int count) {
    _timer?.cancel();
    if (count <= 1) return;
    _timer = Timer.periodic(_autoInterval, (_) {
      if (!mounted || _controller == null || !_controller!.hasClients || count < 2) {
        return;
      }
      final next = (_index + 1) % count;
      _controller!.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _syncSlideCount(int count) {
    if (count == _lastSlideCount) return;
    _lastSlideCount = count;
    if (_index >= count) {
      _index = 0;
      if (_controller?.hasClients == true) {
        _controller!.jumpToPage(0);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _restartTimer(count);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = _bannerHeight(context);
    final bannersAsync = ref.watch(activeBannersProvider);

    return bannersAsync.when(
      loading: () => HomeBannerShimmer(height: height),
      error: (_, __) => HomeBannerShimmer(height: height),
      data: (banners) {
        // Provider allaqachon faol + dedupe qilgan; qo‘shimcha filtrlash yo‘q limit.
        final visible = banners.where((b) => b.isActive).toList();
        if (visible.isEmpty) return const SizedBox.shrink();

        _syncSlideCount(visible.length);

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
                    key: ValueKey('banners_${visible.length}_${visible.first.id}'),
                    controller: _ensureController(),
                    itemCount: visible.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => HomeBannerSlide(
                      key: ValueKey(visible[i].id),
                      banner: visible[i],
                      onTap: () => openBannerLink(
                        context,
                        banner: visible[i],
                        onAddToCart: widget.onAddToCart,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (visible.length > 1) ...[
              const SizedBox(height: 8),
              _BannerPagerIndicator(
                count: visible.length,
                index: _index,
                maxDots: _maxDotIndicators,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BannerPagerIndicator extends StatelessWidget {
  const _BannerPagerIndicator({
    required this.count,
    required this.index,
    required this.maxDots,
  });

  final int count;
  final int index;
  final int maxDots;

  @override
  Widget build(BuildContext context) {
    if (count <= maxDots) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == index;
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
      );
    }

    return Text(
      '${index + 1} / $count',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.brown.shade600,
      ),
    );
  }
}
