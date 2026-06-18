import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/firebase/firebase_media_api.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../cart/domain/entities/cart_line.dart';
import '../../../cart/presentation/pages/crave_cart_page.dart';
import '../../../feedback/data/firebase_feedback_repository.dart';
import '../../../feedback/domain/repositories/feedback_repository.dart';
import '../../../menu/domain/home_product.dart';
import '../../../orders/data/firebase_order_repository.dart';
import '../../../orders/presentation/pages/user_order_history_page.dart';
import '../../../profile/application/profile_photo_crop_helper.dart';
import '../../../profile/application/profile_photo_file_picker.dart';
import '../../../profile/application/profile_photo_local_cache.dart';
import '../../../profile/application/profile_photo_permissions.dart';
import '../../../menu/domain/food_image_url.dart';
import '../../../settings/presentation/pages/account_settings_page.dart';
import '../widgets/crave_floating_bottom_nav.dart';
import 'home_feed_page.dart';

String _cacheBustedProfileImageUrl(String url, int version) {
  if (version <= 0) return url;
  try {
    final uri = Uri.parse(url);
    final q = Map<String, String>.from(uri.queryParameters);
    q['_fv'] = '$version';
    return uri.replace(queryParameters: q).toString();
  } catch (_) {
    return url.contains('?') ? '$url&_fv=$version' : '$url?_fv=$version';
  }
}

class MainShellPage extends StatefulWidget {
  const MainShellPage({
    super.key,
    required this.authRepository,
    required this.onThemeChanged,
    required this.localeController,
  });

  final AuthRepository authRepository;
  final ValueChanged<ThemeMode> onThemeChanged;
  final LocaleController localeController;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;
  AppUser? _profile;
  final List<CartLine> _cart = [];
  final FirebaseOrderRepository _orderRepository = FirebaseOrderRepository();
  final FeedbackRepository _feedbackRepository = FirebaseFeedbackRepository();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await widget.authRepository.currentUserProfile();
    if (!mounted) return;
    setState(() => _profile = user);
  }

  Future<void> _logout() async {
    await widget.authRepository.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          authRepository: widget.authRepository,
          onThemeChanged: widget.onThemeChanged,
          localeController: widget.localeController,
        ),
      ),
      (route) => false,
    );
  }

  void _addToCart(HomeProduct p, {int count = 1}) {
    setState(() {
      final i = _cart.indexWhere((e) => e.product.id == p.id);
      if (i >= 0) {
        _cart[i].quantity += count;
      } else {
        _cart.add(CartLine(product: p, quantity: count));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.cartAddedSimple(p.name))),
    );
  }

  int get _cartCount => _cart.fold<int>(0, (s, e) => s + e.quantity);

  Future<String?> _placeOrder({
    required List<CartLine> lines,
    required int subtotal,
    required int delivery,
    required int discount,
    required int total,
    required String address,
  }) async {
    final user = _profile;
    if (user == null || lines.isEmpty) return null;

    try {
      final orderNo = await _orderRepository.placeOrder(
        userId: user.uid,
        customerName: user.fullName,
        phone: user.phone,
        customerEmail: user.email,
        lines: lines,
        subtotal: subtotal,
        deliveryPrice: delivery,
        discount: discount,
        totalPrice: total,
        address: address,
      );
      if (orderNo != null && mounted) {
        setState(() => _cart.clear());
      }
      return orderNo;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeTabPage(
        profile: _profile,
        onAddToCart: _addToCart,
        onOpenCart: () => setState(() => _index = 1),
      ),
      CraveCartPage(
        profile: _profile,
        lines: _cart,
        cartCount: _cartCount,
        onIncrement: (i) => setState(() => _cart[i].quantity++),
        onDecrement: (i) {
          setState(() {
            if (_cart[i].quantity > 1) {
              _cart[i].quantity--;
            } else {
              _cart.removeAt(i);
            }
          });
        },
        onRemove: (i) => setState(() => _cart.removeAt(i)),
        onPlaceOrder: _placeOrder,
        onGoShopping: () => setState(() => _index = 0),
      ),
      _ProfileBody(
        profile: _profile,
        profileTabActive: _index == 2,
        authRepository: widget.authRepository,
        feedbackRepository: _feedbackRepository,
        onThemeChanged: widget.onThemeChanged,
        onLogout: _logout,
        localeController: widget.localeController,
        onProfileUpdated: _loadProfile,
        onOpenCart: () => setState(() => _index = 1),
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey<int>(_index),
          child: pages[_index],
        ),
      ),
      bottomNavigationBar: CraveFloatingBottomNav(
        index: _index,
        cartBadge: _cartCount,
        onSelect: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _PhotoSourceTile extends StatelessWidget {
  const _PhotoSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? const Color(0xFFC62828) : const Color(0xFFFF8C00);
    final bg = destructive ? const Color(0xFFFFEBEE) : const Color(0xFFFFF6ED);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: destructive ? const Color(0xFFB71C1C) : const Color(0xFF2B1E16),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: destructive ? const Color(0xFFEF9A9A) : const Color(0xFFFFB74D)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody({
    required this.profile,
    required this.profileTabActive,
    required this.authRepository,
    required this.feedbackRepository,
    required this.onThemeChanged,
    required this.onLogout,
    required this.localeController,
    required this.onProfileUpdated,
    required this.onOpenCart,
  });

  final AppUser? profile;
  final bool profileTabActive;
  final AuthRepository authRepository;
  final FeedbackRepository feedbackRepository;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onLogout;
  final LocaleController localeController;
  final Future<void> Function() onProfileUpdated;
  final VoidCallback onOpenCart;

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  String? _loadedUid;

  @override
  void initState() {
    super.initState();
    _syncProfileScope();
    widget.onProfileUpdated();
  }

  @override
  void didUpdateWidget(covariant _ProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile?.uid != widget.profile?.uid) {
      _syncProfileScope();
      widget.onProfileUpdated();
    }
  }

  void _syncProfileScope() {
    final uid = widget.profile?.uid ?? '';
    if (_loadedUid == uid) return;
    _loadedUid = uid;
  }



  Future<void> _confirmLogout() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileLogoutTitle),
        content: Text(l10n.profileLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.profileCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF8C00)),
            child: Text(l10n.profileLogout),
          ),
        ],
      ),
    );
    if (ok == true) {
      widget.onLogout();
    }
  }

  void _openWithTransition(Widget page) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final width = MediaQuery.sizeOf(context).width;
    final bg = isDark ? const Color(0xFF141018) : const Color(0xFFFFF9F0);
    final name = widget.profile?.fullName ?? l10n.guestName;
    final email = widget.profile?.email ?? 'email@gelion.uz';

    return Container(
      color: bg,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18, top + 10, 18, 120),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFA726), Color(0xFFFF7A00)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8C00).withValues(alpha: 0.32),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white24,
                            backgroundImage: AssetImage('assets/onboarding_pizza.png'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.appTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                                height: 1.05,
                              ),
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.profileCartHintSnack)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1A22) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        l10n.profileGoldMember,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF8E4A09)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.brown.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _ProfileActionTile(
                icon: Icons.history_rounded,
                title: l10n.profileOrdersTitle,
                subtitle: l10n.profileOrdersSubtitle,
                onTap: () => _openWithTransition(
                  UserOrderHistoryPage(
                    onStartShopping: () {
                      Navigator.of(context).pop();
                      widget.onOpenCart();
                    },
                  ),
                ),
              ),
              _ProfileActionTile(
                icon: Icons.settings_rounded,
                title: l10n.profileSettingsTitle,
                subtitle: l10n.profileSettingsSubtitle,
                onTap: () {
                  Navigator.of(context)
                      .push<bool?>(
                    PageRouteBuilder<bool?>(
                      pageBuilder: (context, animation, secondaryAnimation) => AccountSettingsPage(
                        authRepository: widget.authRepository,
                        feedbackRepository: widget.feedbackRepository,
                        onThemeChanged: widget.onThemeChanged,
                      ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                        return FadeTransition(
                          opacity: curve,
                          child: SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(curve),
                            child: child,
                          ),
                        );
                      },
                    ),
                  )
                      .then((saved) async {
                    if (saved == true) await widget.onProfileUpdated();
                  });
                },
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1A22) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.profileLanguageTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: widget.localeController,
                      builder: (context, _) {
                        final code = widget.localeController.locale.languageCode;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          switchInCurve: Curves.easeOutCubic,
                          child: Row(
                            key: ValueKey<String>(code),
                            children: [
                              _LanguageButton(
                                code: 'UZ',
                                selected: code == 'uz',
                                onTap: () => widget.localeController.setLocale(const Locale('uz')),
                              ),
                              const SizedBox(width: 8),
                              _LanguageButton(
                                code: 'RU',
                                selected: code == 'ru',
                                onTap: () => widget.localeController.setLocale(const Locale('ru')),
                              ),
                              const SizedBox(width: 8),
                              _LanguageButton(
                                code: 'EN',
                                selected: code == 'en',
                                onTap: () => widget.localeController.setLocale(const Locale('en')),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.profileSignOut),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB53F22),
                    side: const BorderSide(color: Color(0xFFFFCCBC), width: 1.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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




class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? const Color(0xFF1E1A22) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF8C00), size: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(subtitle, style: TextStyle(color: Colors.brown.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: selected ? const Color(0xFFFF8C00) : const Color(0xFFFFF3E0),
            foregroundColor: selected ? Colors.white : const Color(0xFF8E4A09),
            elevation: selected ? 2 : 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(code, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

