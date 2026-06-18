import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../orders/presentation/pages/user_order_history_page.dart';

/// Crave & Melt — brand ranglari (Material 3 + premium food delivery).
abstract final class CraveProfileColors {
  static const Color orange = Color(0xFFFF9800);
  static const Color orangeDeep = Color(0xFFFF6D00);
  static const Color cream = Color(0xFFFFF8F0);
  static const Color brown = Color(0xFF8B5E3C);
  static const Color brownDark = Color(0xFF5D4037);
  static const Color white = Color(0xFFFFFFFF);
  static const Color chipCream = Color(0xFFFFF2E2);
  static const Color badgeGold = Color(0xFFFFEB3B);
}

/// Premium profil tabi — to‘liq ishlaydigan UI (til saqlash, sozlamalar, buyurtmalar, chiqish).
class CraveMeltProfileTab extends StatefulWidget {
  const CraveMeltProfileTab({
    super.key,
    required this.profile,
    required this.onThemeChanged,
    required this.onLogout,
    this.onOpenCart,
  });

  final AppUser? profile;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onLogout;
  final VoidCallback? onOpenCart;

  @override
  State<CraveMeltProfileTab> createState() => _CraveMeltProfileTabState();
}

class _CraveMeltProfileTabState extends State<CraveMeltProfileTab> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  String _languageCode = 'uz';

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _entranceController.forward();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('profile_language') ?? 'uz';
    if (!mounted) return;
    setState(() => _languageCode = saved);
  }

  Future<void> _setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_language', code);
    if (!mounted) return;
    setState(() => _languageCode = code);
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  String get _displayName =>
      (widget.profile?.fullName.trim().isNotEmpty ?? false) ? widget.profile!.fullName : 'Mehmon';

  String get _displayEmail {
    final e = widget.profile?.email.trim() ?? '';
    if (e.isNotEmpty) return e;
    return 'hisob@craveandmelt.com';
  }

  String get _initials {
    final parts = _displayName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) {
      final s = parts.first.toUpperCase();
      if (s.length >= 2) return s.substring(0, 2);
      return '${s}M';
    }
    final a = parts.first.isNotEmpty ? parts.first[0] : 'C';
    final b = parts.last.isNotEmpty ? parts.last[0] : 'M';
    return ('$a$b').toUpperCase();
  }

  Future<void> _openOrderHistory(BuildContext context) async {
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => const UserOrderHistoryPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CraveProfileColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CraveProfileColors.brown.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sozlamalar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: CraveProfileColors.brownDark,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ilova ko‘rinishi va xavfsizlik',
                  style: TextStyle(color: CraveProfileColors.brown.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 20),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Qorong‘i mavzu'),
                  value: isDark,
                  activeThumbColor: CraveProfileColors.orange,
                  onChanged: (v) {
                    widget.onThemeChanged(v ? ThemeMode.dark : ThemeMode.light);
                    Navigator.of(ctx).pop();
                  },
                ),
                const Divider(height: 32),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info_outline_rounded, color: CraveProfileColors.brown),
                  title: const Text('Ilova versiyasi'),
                  subtitle: const Text('1.0.0+1'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final heroHeight = (media.size.height * 0.38).clamp(320.0, 380.0);

    return Container(
      color: CraveProfileColors.cream,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _ProfilePremiumAppBar(
                  initials: _initials,
                  onCart: widget.onOpenCart,
                ),
              ),
              SliverToBoxAdapter(
                child: _ProfileHeroHeader(
                  height: heroHeight,
                  displayName: _displayName,
                  displayEmail: _displayEmail,
                  photoUrl: null,
                  initials: _initials,
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -36),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      children: [
                        _PremiumActionCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'Buyurtmalar tarixi',
                          subtitle: 'Oldingi buyurtmalaringizni ko‘ring',
                          onTap: () => _openOrderHistory(context),
                        ),
                        const SizedBox(height: 14),
                        _PremiumActionCard(
                          icon: Icons.settings_rounded,
                          title: 'Sozlamalar',
                          subtitle: 'Ilova sozlamalari va xavfsizlik',
                          onTap: () => _openSettings(context),
                        ),
                        const SizedBox(height: 14),
                        _LanguageCard(
                          selectedCode: _languageCode,
                          onSelect: _setLanguage,
                        ),
                        const SizedBox(height: 24),
                        _AnimatedLogoutButton(onLogout: widget.onLogout),
                        SizedBox(height: media.padding.bottom + 88),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePremiumAppBar extends StatelessWidget {
  const _ProfilePremiumAppBar({
    required this.initials,
    this.onCart,
  });

  final String initials;
  final VoidCallback? onCart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CraveProfileColors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: CraveProfileColors.white,
          boxShadow: [
            BoxShadow(
              color: CraveProfileColors.brown.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 14),
            child: Row(
              children: [
                _MiniAvatar(initials: initials),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gelion',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: CraveProfileColors.brownDark,
                        ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: onCart,
                  style: IconButton.styleFrom(
                    backgroundColor: CraveProfileColors.chipCream,
                    foregroundColor: CraveProfileColors.brown,
                  ),
                  icon: const Icon(Icons.shopping_basket_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            CraveProfileColors.orange.withValues(alpha: 0.9),
            CraveProfileColors.orangeDeep.withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: CraveProfileColors.orange.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: CraveProfileColors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ProfileHeroHeader extends StatelessWidget {
  const _ProfileHeroHeader({
    required this.height,
    required this.displayName,
    required this.displayEmail,
    required this.initials,
    this.photoUrl,
  });

  final double height;
  final String displayName;
  final String displayEmail;
  final String initials;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeroBottomCurveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFB74D),
              CraveProfileColors.orange,
              CraveProfileColors.orangeDeep,
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                _HeroAvatar(photoUrl: photoUrl, initials: initials),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: CraveProfileColors.badgeGold,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: CraveProfileColors.badgeGold.withValues(alpha: 0.55),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('⭐', style: TextStyle(fontSize: 15)),
                      SizedBox(width: 6),
                      Text(
                        'Oltin a’zo',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: CraveProfileColors.brownDark,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CraveProfileColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    displayEmail,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CraveProfileColors.white.withValues(alpha: 0.92),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 24)
      ..quadraticBezierTo(size.width * 0.75, size.height - 48, size.width, size.height - 36)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar({this.photoUrl, required this.initials});

  final String? photoUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.14).clamp(52.0, 72.0);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CraveProfileColors.white,
        boxShadow: [
          BoxShadow(
            color: CraveProfileColors.orange.withValues(alpha: 0.45),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: CraveProfileColors.chipCream,
        backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty) ? NetworkImage(photoUrl!) : null,
        child: (photoUrl == null || photoUrl!.isEmpty)
            ? Text(
                initials,
                style: TextStyle(
                  fontSize: radius * 0.55,
                  fontWeight: FontWeight.w900,
                  color: CraveProfileColors.brown,
                ),
              )
            : null,
      ),
    );
  }
}

class _PremiumActionCard extends StatefulWidget {
  const _PremiumActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_PremiumActionCard> createState() => _PremiumActionCardState();
}

class _PremiumActionCardState extends State<_PremiumActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: CraveProfileColors.white,
        borderRadius: BorderRadius.circular(30),
        elevation: 3,
        shadowColor: CraveProfileColors.brown.withValues(alpha: 0.12),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: CraveProfileColors.chipCream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(widget.icon, color: CraveProfileColors.brown, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: CraveProfileColors.brownDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: CraveProfileColors.brown.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: CraveProfileColors.brown.withValues(alpha: 0.65),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.selectedCode,
    required this.onSelect,
  });

  final String selectedCode;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CraveProfileColors.white,
      borderRadius: BorderRadius.circular(30),
      elevation: 3,
      shadowColor: CraveProfileColors.brown.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: CraveProfileColors.chipCream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.language_rounded, color: CraveProfileColors.brown, size: 26),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Til',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: CraveProfileColors.brownDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _LangChip(
                    label: 'UZ',
                    selected: selectedCode == 'uz',
                    onTap: () => onSelect('uz'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LangChip(
                    label: 'RU',
                    selected: selectedCode == 'ru',
                    onTap: () => onSelect('ru'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LangChip(
                    label: 'EN',
                    selected: selectedCode == 'en',
                    onTap: () => onSelect('en'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected ? CraveProfileColors.brownDark : CraveProfileColors.chipCream,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: CraveProfileColors.orange.withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
            border: Border.all(
              color: selected ? CraveProfileColors.orange.withValues(alpha: 0.35) : Colors.transparent,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: selected ? CraveProfileColors.white : CraveProfileColors.brown,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogoutButton extends StatefulWidget {
  const _AnimatedLogoutButton({required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<_AnimatedLogoutButton> createState() => _AnimatedLogoutButtonState();
}

class _AnimatedLogoutButtonState extends State<_AnimatedLogoutButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onLogout,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: CraveProfileColors.brown, width: 1.8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: CraveProfileColors.brownDark),
              SizedBox(width: 10),
              Text(
                'Chiqish',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: CraveProfileColors.brownDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
