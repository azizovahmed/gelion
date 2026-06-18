import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/theme/cart_palette.dart';
import '../../../cart/presentation/widgets/scale_tap.dart';

/// 0: Bosh sahifa, 1: Savat (markaz), 2: Profil — `MainShellPage` bilan mos.
class CraveFloatingBottomNav extends StatelessWidget {
  const CraveFloatingBottomNav({
    super.key,
    required this.index,
    required this.cartBadge,
    required this.onSelect,
  });

  final int index;
  final int cartBadge;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          height: 88,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: dark
                        ? const Color(0xFF1C1820).withValues(alpha: 0.94)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.9),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: dark ? 0.45 : 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                      BoxShadow(
                        color: CartPalette.orangeMain.withValues(alpha: 0.12),
                        blurRadius: 40,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SideTab(
                          icon: Icons.home_rounded,
                          label: l10n.navHome,
                          selected: index == 0,
                          onTap: () => onSelect(0),
                        ),
                      ),
                      const SizedBox(width: 56),
                      Expanded(
                        child: _SideTab(
                          icon: Icons.person_rounded,
                          label: l10n.navProfile,
                          selected: index == 2,
                          onTap: () => onSelect(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 34,
                child: Center(
                  child: _CartHub(
                    label: l10n.navCart,
                    selected: index == 1,
                    count: cartBadge,
                    onTap: () => onSelect(1),
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

class _SideTab extends StatelessWidget {
  const _SideTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: selected ? CartPalette.orangeMain : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: CartPalette.orangeMain.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? Colors.white : CartPalette.textSecondary(context),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? Colors.white : CartPalette.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartHub extends StatelessWidget {
  const _CartHub({
    required this.label,
    required this.selected,
    required this.count,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ScaleTap(
      minScale: 0.9,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? const [Color(0xFFFF9100), Color(0xFFFF3D00)]
                : dark
                    ? const [Color(0xFF3A3038), Color(0xFF2A242E)]
                    : const [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          ),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.35)
                : dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.95),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (selected ? CartPalette.orangeMain : Colors.black)
                  .withValues(alpha: selected ? 0.45 : (dark ? 0.35 : 0.14)),
              blurRadius: selected ? 26 : 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.shopping_bag_rounded,
              size: 30,
              color: selected ? Colors.white : CartPalette.orangeMain,
            ),
            if (count > 0)
              Positioned(
                top: 6,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.92)
                      : CartPalette.textSecondary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
