import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.authRepository,
    required this.onThemeChanged,
    required this.localeController,
  });
  final AuthRepository authRepository;
  final ValueChanged<ThemeMode> onThemeChanged;
  final LocaleController localeController;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  List<_OnboardingItem> _items(AppLocalizations l10n) => [
        _OnboardingItem(
          title: l10n.onboarding1Title,
          body: l10n.onboarding1Body,
          imageAsset: 'assets/onboarding_pizza.png',
          emoji: '🍕',
        ),
        _OnboardingItem(
          title: l10n.onboarding2Title,
          body: l10n.onboarding2Body,
          imageAsset: 'assets/onboarding_icecream.png',
          emoji: '🍦',
        ),
        _OnboardingItem(
          title: l10n.onboarding3Title,
          body: l10n.onboarding3Body,
          imageAsset: 'assets/onboarding_delivery.png',
          emoji: '🚀',
        ),
      ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      FadeRoute(
        child: LoginPage(
          authRepository: widget.authRepository,
          onThemeChanged: widget.onThemeChanged,
          localeController: widget.localeController,
        ),
      ),
    );
  }

  Future<void> _goNext() async {
    final items = _items(context.l10n);
    if (_index < items.length - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _finish();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = _items(l10n);
    final isLast = _index == items.length - 1;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8F0), Color(0xFFFFFDF8)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: -28,
                top: 180,
                child: Icon(
                  Icons.water_drop_outlined,
                  size: 120,
                  color: const Color(0xFFFFA726).withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                right: -20,
                bottom: 24,
                child: Icon(
                  Icons.water_drop_outlined,
                  size: 130,
                  color: const Color(0xFFFFA726).withValues(alpha: 0.08),
                ),
              ),
              Column(
                children: [
                  _TopBar(
                    pageNumber: _index + 1,
                    isLast: isLast,
                    onSkip: _finish,
                    skipLabel: l10n.onboardingSkip,
                    progressLabel: l10n.onboardingProgress,
                    brandTitle: l10n.appTitle,
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: items.length,
                      onPageChanged: (value) => setState(() => _index = value),
                      itemBuilder: (_, index) {
                        final item = items[index];
                        return _OnboardingSlide(item: item, isCompactTitle: index == 0);
                      },
                    ),
                  ),
                  _PageDots(total: items.length, currentIndex: _index),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _PrimaryButton(
                      label: isLast ? l10n.onboardingStart : l10n.onboardingNext,
                      onPressed: _goNext,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      l10n.onboardingSkip,
                      style: const TextStyle(
                        color: Color(0xFF6C6156),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.title,
    required this.body,
    required this.imageAsset,
    required this.emoji,
  });

  final String title;
  final String body;
  final String imageAsset;
  final String emoji;
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.pageNumber,
    required this.isLast,
    required this.onSkip,
    required this.skipLabel,
    required this.progressLabel,
    required this.brandTitle,
  });

  final int pageNumber;
  final bool isLast;
  final VoidCallback onSkip;
  final String skipLabel;
  final String Function(int page) progressLabel;
  final String brandTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
      child: Row(
        children: [
          Text(
            brandTitle,
            style: const TextStyle(
              color: Color(0xFF8E4A09),
              fontWeight: FontWeight.w800,
              fontSize: 34,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          if (isLast)
            Text(
              progressLabel(pageNumber),
              style: const TextStyle(
                color: Color(0xFF7B614B),
                fontSize: 13,
                letterSpacing: 2.2,
              ),
            )
          else
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B5A4A),
                backgroundColor: const Color(0xFFFFECD7),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(skipLabel),
            ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.item, required this.isCompactTitle});

  final _OnboardingItem item;
  final bool isCompactTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(item.imageAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${item.title} ${item.emoji}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isCompactTitle ? 24 : 22,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF3F2A1A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4E4338),
                    fontSize: 17,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.total, required this.currentIndex});

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == currentIndex ? 30 : 9,
          height: 9,
          decoration: BoxDecoration(
            color: i == currentIndex ? const Color(0xFFF9DF1E) : const Color(0xFFFDE7CB),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFFFAA00),
          foregroundColor: const Color(0xFF2E1C08),
          minimumSize: const Size.fromHeight(62),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 33),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 34),
          ],
        ),
      ),
    );
  }
}
