import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';

/// Rasmdagidek splash: gradient fon, to'liq, logo, markaziy rasm animatsiyasi,
/// pastda yuklash indikatori.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const _imageAsset = 'assets/splash_food.png';

  late final AnimationController _imageController;
  late final Animation<Offset> _imageSlide;
  late final Animation<double> _imageFade;

  late final AnimationController _progressController;
  late final Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );
    _imageSlide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _imageController, curve: Curves.easeOutCubic));
    _imageFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeOut),
    );
    _imageController.forward();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _progressValue = Tween<double>(begin: 0.22, end: 0.92).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _imageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.sizeOf(context);
    final imageHeight = (size.height * 0.40).clamp(220.0, 420.0);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF2C2),
                  Color(0xFFFFFDF5),
                  Color(0xFFFFFFFF),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: CustomPaint(
              painter: _WaveHeaderPainter(),
              size: Size(size.width, 160),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        height: 0.95,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: l10n.appTitle.split(' ').first,
                          style: const TextStyle(color: Color(0xFF5D4037)),
                        ),
                        const TextSpan(text: '\n'),
                        TextSpan(
                          text: l10n.appTitle.contains('&')
                              ? l10n.appTitle.substring(l10n.appTitle.indexOf('&'))
                              : l10n.appTitle,
                          style: const TextStyle(color: Color(0xFFC0CA33)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.splashTagline,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6D4C41),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SlideTransition(
                    position: _imageSlide,
                    child: FadeTransition(
                      opacity: _imageFade,
                      child: Container(
                        width: double.infinity,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x28000000),
                              blurRadius: 24,
                              offset: Offset(0, 14),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(29),
                          child: Image.asset(
                            _imageAsset,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFFFE0B2),
                              child: const Center(
                                child: Icon(
                                  Icons.local_pizza_rounded,
                                  size: 72,
                                  color: Color(0xFF8D6E63),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Color(0xFFF5A623), width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_pizza_outlined,
                      color: Color(0xFFF5A623),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.splashLoading,
                    style: TextStyle(
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      width: 160,
                      child: AnimatedBuilder(
                        animation: _progressValue,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _progressValue.value,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFECEFF1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFB300),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Yuqori sariq–olov gradentli to'lqin bosh qism.
class _WaveHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFFE082),
        const Color(0xFFFFB74D),
        const Color(0xFFFFA726),
      ],
    );

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.55)
      ..quadraticBezierTo(w * 0.75, h * 0.95, w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.25, h * 0.48, 0, h * 0.62)
      ..close();

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
