import 'package:flutter/material.dart';

class HomeBannerShimmer extends StatefulWidget {
  const HomeBannerShimmer({super.key, required this.height});

  final double height;

  @override
  State<HomeBannerShimmer> createState() => _HomeBannerShimmerState();
}

class _HomeBannerShimmerState extends State<HomeBannerShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
              colors: const [
                Color(0xFFFFF2E2),
                Color(0xFFFFFBF5),
                Color(0xFFFFF2E2),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
        );
      },
    );
  }
}
