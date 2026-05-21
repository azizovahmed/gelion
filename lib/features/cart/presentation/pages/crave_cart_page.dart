import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/cart_line.dart';
import '../theme/cart_palette.dart';
import '../utils/format_sum.dart';
import '../widgets/cart_address_section.dart';
import '../widgets/cart_checkout_button.dart';
import '../widgets/cart_price_summary.dart';
import '../widgets/cart_promo_section.dart';
import '../widgets/cart_wave_header.dart';
import '../widgets/crave_cart_app_bar.dart';
import '../widgets/crave_cart_item_card.dart';

/// Premium food-delivery cart experience (Crave & Melt).
class CraveCartPage extends StatefulWidget {
  const CraveCartPage({
    super.key,
    required this.profile,
    required this.lines,
    required this.cartCount,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onPlaceOrder,
    this.onGoShopping,
  });

  final AppUser? profile;
  final List<CartLine> lines;
  final int cartCount;
  final void Function(int index) onIncrement;
  final void Function(int index) onDecrement;
  final void Function(int index) onRemove;
  final Future<String?> Function({
    required List<CartLine> lines,
    required int subtotal,
    required int delivery,
    required int discount,
    required int total,
    required String address,
  }) onPlaceOrder;
  final VoidCallback? onGoShopping;

  @override
  State<CraveCartPage> createState() => _CraveCartPageState();
}

enum _PromoFb { none, empty, invalid, pct10, fix5000, pct15 }

class _CraveCartPageState extends State<CraveCartPage> {
  final TextEditingController _promoCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  int _discountSoM = 0;
  _PromoFb _promoFb = _PromoFb.none;
  String? _addressError;

  static const int _deliveryFee = 15_000;

  @override
  void dispose() {
    _promoCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CraveCartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final code = _promoCtrl.text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (code == 'DELISH10' || code == 'CRAVE10') {
      final next = (_subtotal * 0.10).round();
      if (next != _discountSoM) setState(() => _discountSoM = next);
    } else if (code == 'CRAVE15') {
      final next = (_subtotal * 0.15).round();
      if (next != _discountSoM) setState(() => _discountSoM = next);
    }
  }

  int get _subtotal =>
      widget.lines.fold<int>(0, (sum, e) => sum + e.product.price * e.quantity);

  int get _discount => _discountSoM.clamp(0, _subtotal);

  int get _delivery => widget.lines.isEmpty ? 0 : _deliveryFee;

  int get _total => (_subtotal + _delivery - _discount).clamp(0, 1 << 30);

  void _applyPromo() {
    final raw = _promoCtrl.text.trim();
    final code = raw.toUpperCase().replaceAll(RegExp(r'\s+'), '');
    setState(() {
      if (code.isEmpty) {
        _promoFb = _PromoFb.empty;
        _discountSoM = 0;
        return;
      }
      _discountSoM = 0;
      if (code == 'DELISH10' || code == 'CRAVE10') {
        _discountSoM = (_subtotal * 0.10).round();
        _promoFb = _PromoFb.pct10;
      } else if (code == 'MELT5000') {
        _discountSoM = 5000;
        _promoFb = _PromoFb.fix5000;
      } else if (code == 'CRAVE15') {
        _discountSoM = (_subtotal * 0.15).round();
        _promoFb = _PromoFb.pct15;
      } else {
        _promoFb = _PromoFb.invalid;
      }
    });
  }

  String? _promoMessage(AppLocalizations l10n) {
    return switch (_promoFb) {
      _PromoFb.none => null,
      _PromoFb.empty => l10n.cartPromoEnter,
      _PromoFb.invalid => l10n.cartPromoNotFound,
      _PromoFb.pct10 => l10n.cartPromo10,
      _PromoFb.fix5000 => l10n.cartPromo5000,
      _PromoFb.pct15 => l10n.cartPromo15,
    };
  }

  Future<void> _checkout() async {
    if (widget.lines.isEmpty) return;
    final l10n = context.l10n;
    final address = _addressCtrl.text.trim();
    if (address.isEmpty) {
      setState(() => _addressError = l10n.cartAddressRequired);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.cartAddressRequired),
        ),
      );
      return;
    }
    setState(() => _addressError = null);
    final orderNo = await widget.onPlaceOrder(
      lines: widget.lines,
      subtotal: _subtotal,
      delivery: _delivery,
      discount: _discount,
      total: _total,
      address: address,
    );
    if (!mounted) return;
    if (orderNo != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Text(
            l10n.cartOrderAccepted(orderNo, '${formatSum(_total)} ${l10n.currencySom}'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
      if (widget.onGoShopping != null) {
        widget.onGoShopping!();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.cartOrderFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final promoText = _promoMessage(l10n);

    return ColoredBox(
      color: CartPalette.pageBg(context),
      child: Column(
        children: [
          CraveCartAppBar(
            profile: widget.profile,
            cartCount: widget.cartCount,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: widget.lines.isEmpty
                  ? _EmptyCart(
                      key: const ValueKey('empty'),
                      onGoShopping: widget.onGoShopping,
                    )
                  : _FilledCart(
                      key: const ValueKey('filled'),
                      lines: widget.lines,
                      promoCtrl: _promoCtrl,
                      addressCtrl: _addressCtrl,
                      addressError: _addressError,
                      onApplyPromo: _applyPromo,
                      promoFeedback: promoText,
                      subtotal: _subtotal,
                      delivery: _delivery,
                      discount: _discount,
                      total: _total,
                      onIncrement: widget.onIncrement,
                      onDecrement: widget.onDecrement,
                      onRemove: widget.onRemove,
                      onCheckout: _checkout,
                      bottomInset: bottomInset,
                      checkoutLabel: l10n.cartCheckout,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilledCart extends StatelessWidget {
  const _FilledCart({
    super.key,
    required this.lines,
    required this.promoCtrl,
    required this.addressCtrl,
    required this.addressError,
    required this.onApplyPromo,
    required this.promoFeedback,
    required this.subtotal,
    required this.delivery,
    required this.discount,
    required this.total,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onCheckout,
    required this.bottomInset,
    required this.checkoutLabel,
  });

  final List<CartLine> lines;
  final TextEditingController promoCtrl;
  final TextEditingController addressCtrl;
  final String? addressError;
  final VoidCallback onApplyPromo;
  final String? promoFeedback;
  final int subtotal;
  final int delivery;
  final int discount;
  final int total;
  final void Function(int index) onIncrement;
  final void Function(int index) onDecrement;
  final void Function(int index) onRemove;
  final VoidCallback onCheckout;
  final double bottomInset;
  final String checkoutLabel;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: CartWaveHeader()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final line = lines[index];
                return CraveCartItemCard(
                  product: line.product,
                  quantity: line.quantity,
                  animationIndex: index,
                  onIncrement: () => onIncrement(index),
                  onDecrement: () => onDecrement(index),
                  onRemove: () => onRemove(index),
                );
              },
              childCount: lines.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 18 + bottomInset + 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CartPromoSection(
                  controller: promoCtrl,
                  onApply: onApplyPromo,
                  appliedMessage: promoFeedback,
                ),
                const SizedBox(height: 18),
                CartPriceSummary(
                  subtotal: subtotal,
                  delivery: delivery,
                  discount: discount,
                  total: total,
                ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.04, curve: Curves.easeOutCubic),
                const SizedBox(height: 18),
                CartAddressSection(
                  controller: addressCtrl,
                  errorText: addressError,
                ),
                const SizedBox(height: 18),
                CartCheckoutButton(onPressed: onCheckout, label: checkoutLabel),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({super.key, this.onGoShopping});

  final VoidCallback? onGoShopping;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: CartWaveHeader()),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(28, 12, 28, 24 + bottom + 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        CartPalette.orangeMain.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.01),
                      ],
                    ),
                    boxShadow: CartPalette.cardLift(Theme.of(context).brightness == Brightness.dark),
                  ),
                  child: Icon(
                    Icons.takeout_dining_rounded,
                    size: 56,
                    color: CartPalette.orangeMain.withValues(alpha: 0.85),
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(
                      begin: const Offset(0.92, 0.92),
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 22),
                Text(
                  l10n.cartEmptyTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: CartPalette.textPrimary(context),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.cartEmptySubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: CartPalette.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 26),
                if (onGoShopping != null)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: CartPalette.orangeMain,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    onPressed: onGoShopping,
                    icon: const Icon(Icons.explore_rounded),
                    label: Text(
                      l10n.cartBrowseFoods,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
