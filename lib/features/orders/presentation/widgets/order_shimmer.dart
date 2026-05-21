import 'package:flutter/material.dart';

import '../theme/order_presentation_theme.dart';

class OrderListShimmer extends StatefulWidget {
  const OrderListShimmer({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  State<OrderListShimmer> createState() => _OrderListShimmerState();
}

class _OrderListShimmerState extends State<OrderListShimmer> with SingleTickerProviderStateMixin {
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => _ShimmerCard(animation: _controller),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: OrderPresentationTheme.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: OrderPresentationTheme.brown.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ShimmerBox(animation: animation, width: 48, height: 48, radius: 14),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBox(animation: animation, width: 140, height: 14, radius: 8),
                        const SizedBox(height: 8),
                        _ShimmerBox(animation: animation, width: 100, height: 12, radius: 8),
                      ],
                    ),
                  ),
                  _ShimmerBox(animation: animation, width: 72, height: 26, radius: 10),
                ],
              ),
              const SizedBox(height: 14),
              _ShimmerBox(animation: animation, width: double.infinity, height: 12, radius: 8),
              const SizedBox(height: 8),
              _ShimmerBox(animation: animation, width: 120, height: 12, radius: 8),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.animation,
    required this.width,
    required this.height,
    this.radius = 12,
  });

  final Animation<double> animation;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final t = animation.value;
    final base = OrderPresentationTheme.chipCream;
    final highlight = Colors.white.withValues(alpha: 0.85);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(-1 + t * 2, 0),
          end: Alignment(1 + t * 2, 0),
          colors: [base, highlight, base],
        ),
      ),
    );
  }
}
