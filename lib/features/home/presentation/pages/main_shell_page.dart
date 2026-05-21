import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/services/firebase_error_mapper.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/pages/register_page.dart';
import '../../../cart/domain/entities/cart_line.dart';
import '../../../cart/presentation/pages/crave_cart_page.dart';
import '../../../feedback/data/firebase_feedback_repository.dart';
import '../../../feedback/domain/repositories/feedback_repository.dart';
import '../../../menu/domain/home_product.dart';
import '../../../orders/data/firebase_order_repository.dart';
import '../../../settings/presentation/pages/account_settings_page.dart';
import '../widgets/crave_floating_bottom_nav.dart';
import 'home_feed_page.dart';

const _kAvatarPlaceholderAsset = 'assets/onboarding_pizza.png';

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
        builder: (_) => RegisterPage(
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
        authRepository: widget.authRepository,
        feedbackRepository: _feedbackRepository,
        onThemeChanged: widget.onThemeChanged,
        onLogout: _logout,
        localeController: widget.localeController,
        onProfileUpdated: _loadProfile,
        onAvatarUploaded: (url) {
          if (!mounted) return;
          final p = _profile;
          if (p != null) {
            setState(() => _profile = p.copyWithPhotoUrl(url));
          }
        },
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF6ED),
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
                      color: const Color(0xFFFF8C00).withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: const Color(0xFFFF8C00), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFFFB74D)),
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
    required this.authRepository,
    required this.feedbackRepository,
    required this.onThemeChanged,
    required this.onLogout,
    required this.localeController,
    required this.onProfileUpdated,
    required this.onAvatarUploaded,
  });

  final AppUser? profile;
  final AuthRepository authRepository;
  final FeedbackRepository feedbackRepository;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onLogout;
  final LocaleController localeController;
  final Future<void> Function() onProfileUpdated;
  final ValueChanged<String> onAvatarUploaded;

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> with SingleTickerProviderStateMixin {
  bool _busyPhoto = false;
  int _photoNonce = 0;
  Uint8List? _localAvatarBytes;
  late final AnimationController _editTapCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 160),
  );
  late final Animation<double> _editTapScale = CurvedAnimation(
    parent: _editTapCtrl,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void dispose() {
    _editTapCtrl.dispose();
    super.dispose();
  }

  String? _photoUrl() {
    final u = widget.profile?.photoUrl?.trim();
    if (u != null && u.isNotEmpty) return u;
    return null;
  }

  Future<void> _showPhotoOptions() async {
    if (_busyPhoto) return;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottom = MediaQuery.paddingOf(sheetContext).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottom),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8C00).withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.profilePhotoTitle,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  _PhotoSourceTile(
                    icon: Icons.photo_camera_rounded,
                    label: l10n.profilePhotoCamera,
                    onTap: () => Navigator.of(sheetContext).pop(1),
                  ),
                  const SizedBox(height: 10),
                  _PhotoSourceTile(
                    icon: Icons.photo_library_rounded,
                    label: l10n.profilePhotoGallery,
                    onTap: () => Navigator.of(sheetContext).pop(2),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text(l10n.profileCancel, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    if (selected == 1) {
      await _pickCropUpload(ImageSource.camera);
      return;
    }
    if (selected == 2) {
      await _pickCropUpload(ImageSource.gallery);
    }
  }

  List<PlatformUiSettings> _cropUiSettings() {
    final l10n = context.l10n;
    if (kIsWeb) {
      final w = MediaQuery.sizeOf(context).width;
      return [
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: CropperSize(
            width: (w - 48).clamp(280, 640).toInt(),
            height: 520,
          ),
          modal: true,
          barrierColor: Colors.black54,
        ),
      ];
    }
    return [
      AndroidUiSettings(
        toolbarTitle: l10n.profilePhotoTitle,
        toolbarWidgetColor: Colors.white,
        toolbarColor: const Color(0xFFFF8C00),
        backgroundColor: Colors.black,
        activeControlsWidgetColor: const Color(0xFFFFB300),
        dimmedLayerColor: Colors.black87,
        cropFrameColor: Colors.white,
        cropGridColor: Colors.white70,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
        title: l10n.profilePhotoTitle,
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
      ),
    ];
  }

  Future<void> _pickCropUpload(ImageSource source) async {
    final l10n = context.l10n;
    final picker = ImagePicker();
    try {
      final x = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 92,
      );
      if (x == null || !mounted) return;

      final cropped = await ImageCropper().cropImage(
        sourcePath: x.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 88,
        uiSettings: _cropUiSettings(),
      );
      if (!mounted) return;
      if (cropped == null) return;

      final bytes = await XFile(cropped.path).readAsBytes();
      if (bytes.isEmpty) return;

      final mem = Uint8List.fromList(bytes);
      setState(() {
        _localAvatarBytes = mem;
        _busyPhoto = true;
      });
      try {
        final url = await widget.authRepository.updateProfilePhotoBytes(bytes, contentType: 'image/jpeg');
        widget.onAvatarUploaded(url);
        if (!mounted) return;
        setState(() {
          _localAvatarBytes = null;
          _photoNonce++;
        });
        await widget.onProfileUpdated();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2A2218),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFFFB74D)),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.profilePhotoUploadSuccess, style: const TextStyle(fontWeight: FontWeight.w700))),
              ],
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          setState(() => _localAvatarBytes = null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF3E2723),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFFFAB91)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(FirebaseErrorMapper.map(l10n, e), style: const TextStyle(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _busyPhoto = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _localAvatarBytes = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF3E2723),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFFFAB91)),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.profilePhotoUploadFailed, style: const TextStyle(fontWeight: FontWeight.w700))),
              ],
            ),
          ),
        );
      }
    }
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
    final compact = width < 380;
    final avatarRadius = (width * 0.125).clamp(38.0, 58.0);
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(18, 14, 18, compact ? 96 : 108),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFA726), Color(0xFFFF7A00)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8C00).withValues(alpha: 0.32),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(radius: 21, backgroundImage: AssetImage('assets/onboarding_pizza.png')),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.appTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              height: 1.05,
                            ),
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.profileCartHintSnack)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -(avatarRadius + 22),
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Hero(
                          tag: 'profile_avatar_hero',
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 380),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, anim) {
                                  return FadeTransition(
                                    opacity: anim,
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.92, end: 1).animate(anim),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _ProfileAvatarFace(
                                  key: ValueKey<String>(
                                    '${_photoUrl() ?? 'p'}_${_localAvatarBytes?.length ?? 0}_$_photoNonce',
                                  ),
                                  radius: avatarRadius,
                                  photoUrl: _photoUrl(),
                                  memoryBytes: _localAvatarBytes,
                                  cacheVersion: _photoNonce,
                                ),
                              ),
                              if (_busyPhoto)
                                Container(
                                  width: avatarRadius * 2,
                                  height: avatarRadius * 2,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.35),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ScaleTransition(
                          scale: Tween<double>(begin: 1, end: 0.96).animate(_editTapScale),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            elevation: 2,
                            shadowColor: const Color(0xFFFF8C00).withValues(alpha: 0.35),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              splashColor: const Color(0xFFFF8C00).withValues(alpha: 0.12),
                              highlightColor: const Color(0xFFFF8C00).withValues(alpha: 0.06),
                              onTap: _busyPhoto
                                  ? null
                                  : () async {
                                      await _editTapCtrl.forward();
                                      await _editTapCtrl.reverse();
                                      if (mounted) await _showPhotoOptions();
                                    },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.edit_rounded, size: 19, color: Color(0xFFFF8C00)),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.profileEditPhoto,
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: avatarRadius + 36),
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
                onTap: () => _openWithTransition(const _OrderHistoryPage()),
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

class _ProfileAvatarFace extends StatelessWidget {
  const _ProfileAvatarFace({
    super.key,
    required this.radius,
    this.photoUrl,
    this.memoryBytes,
    this.cacheVersion = 0,
  });

  final double radius;
  final String? photoUrl;
  final Uint8List? memoryBytes;
  final int cacheVersion;

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    final borderW = (radius * 0.085).clamp(3.0, 5.0);
    final trimmed = photoUrl?.trim();
    final hasUrl = trimmed != null && trimmed.isNotEmpty;
    final useMemory = memoryBytes != null && memoryBytes!.isNotEmpty;
    final requestUrl = hasUrl ? _cacheBustedProfileImageUrl(trimmed, cacheVersion) : null;

    Widget inner;
    if (useMemory) {
      final b = memoryBytes!;
      inner = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) {
          return Opacity(
            opacity: v,
            child: Image.memory(
              b,
              width: d,
              height: d,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          );
        },
      );
    } else if (requestUrl != null) {
      inner = Image.network(
        requestUrl,
        width: d,
        height: d,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeOutCubic,
            child: child,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFFFF3E0),
            alignment: Alignment.center,
            child: SizedBox(
              width: radius * 0.55,
              height: radius * 0.55,
              child: const CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFFF8C00)),
            ),
          );
        },
        errorBuilder: (_, _, _) => _AvatarPlaceholder(radius: radius),
      );
    } else {
      inner = _AvatarPlaceholder(radius: radius);
    }

    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: borderW),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C00).withValues(alpha: 0.32),
            blurRadius: (radius * 0.42).clamp(14, 22),
            spreadRadius: 0,
            offset: Offset(0, (radius * 0.14).clamp(6, 12)),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipOval(child: inner),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    return Container(
      width: d,
      height: d,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80), Color(0xFFFFA726)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _kAvatarPlaceholderAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.02),
                  Colors.black.withValues(alpha: 0.18),
                ],
              ),
            ),
          ),
          Icon(Icons.person_rounded, size: radius * 1.15, color: Colors.white.withValues(alpha: 0.92)),
        ],
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

class _OrderHistoryPage extends StatelessWidget {
  const _OrderHistoryPage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        title: Text(l10n.orderHistoryTitle),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final idSuffix = 21 + index;
          final count = 2 + (index % 3);
          final amount = 38000 + index * 6400;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: const Color(0xFFFFF1DF), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFFF8C00)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.orderHistoryOrder('CM-90$idSuffix'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.orderHistoryLine(count, amount, l10n.currencySom),
                        style: TextStyle(color: Colors.brown.shade600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: 6,
      ),
    );
  }
}
