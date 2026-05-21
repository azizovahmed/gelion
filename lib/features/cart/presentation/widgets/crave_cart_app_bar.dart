import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../theme/cart_palette.dart';

/// White top bar: avatar, “Crave & Melt”, shopping bag.
class CraveCartAppBar extends StatelessWidget {
  const CraveCartAppBar({
    super.key,
    required this.profile,
    required this.cartCount,
    this.onBagTap,
  });

  final AppUser? profile;
  final int cartCount;
  final VoidCallback? onBagTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? const Color(0xFF1A171E) : Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 8, 16, 14),
        child: Row(
          children: [
            _Avatar(profile: profile),
            Expanded(
              child: Text(
                l10n.cartTitleBar,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.3,
                  color: CartPalette.orangeMain,
                  shadows: [
                    Shadow(
                      color: CartPalette.orangeMain.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            _BagIcon(count: cartCount, onTap: onBagTap),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final AppUser? profile;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.35 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFFFFE0B2),
        child: ClipOval(
          child: Image.asset(
            'assets/onboarding_pizza.png',
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.person_rounded,
              color: Colors.brown.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

class _BagIcon extends StatelessWidget {
  const _BagIcon({required this.count, this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.shopping_bag_rounded,
                size: 28,
                color: CartPalette.textPrimary(context),
              ),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7043), Color(0xFFFF3D00)],
                      ),
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5722).withValues(alpha: 0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
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
