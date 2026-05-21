import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/widgets/scale_tap.dart';

/// Light mode: oq pill, apelsin faol, shafq rang faol emas (reference home).
/// Dark mode: to‘q panel.
abstract final class _NavChrome {
  static const Color activeOrange = Color(0xFFFF8C00);
  static const Color activeOrangeDeep = Color(0xFFFF7A1A);
  static const Color inactiveLight = Color(0xFFC4A68A);
  static const Color inactiveOnDark = Color(0xE6FFFFFF);
  static const Color cartInset = Color(0xFF2E2E32);
  static const Color cartIconOrange = Color(0xFFFF9E40);
}

/// 0: Bosh, 1: Qidiruv, 2: Savat, 3: Profil
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
    final isAppDark = Theme.of(context).brightness == Brightness.dark;
    final barFill = isAppDark
        ? const Color(0xFF121214).withValues(alpha: 0.96)
        : Colors.white.withValues(alpha: 0.98);
    final barBorder = isAppDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFFFE0B2).withValues(alpha: 0.45);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
          decoration: BoxDecoration(
            color: barFill,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: barBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isAppDark ? 0.5 : 0.08),
                blurRadius: isAppDark ? 28 : 22,
                offset: const Offset(0, 12),
              ),
              if (!isAppDark)
                BoxShadow(
                  color: _NavChrome.activeOrange.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _SideTab(
                  icon: Icons.home_rounded,
                  label: l10n.navHome,
                  selected: index == 0,
                  dark: isAppDark,
                  onTap: () => onSelect(0),
                ),
              ),
              Expanded(
                child: _SideTab(
                  icon: Icons.search_rounded,
                  label: l10n.navSearch,
                  selected: index == 1,
                  dark: isAppDark,
                  onTap: () => onSelect(1),
                ),
              ),
              Expanded(
                child: _CartHub(
                  icon: Icons.shopping_bag_rounded,
                  label: l10n.navCart,
                  selected: index == 2,
                  dark: isAppDark,
                  count: cartBadge,
                  onTap: () => onSelect(2),
                ),
              ),
              Expanded(
                child: _SideTab(
                  icon: Icons.person_rounded,
                  label: l10n.navProfile,
                  selected: index == 3,
                  dark: isAppDark,
                  onTap: () => onSelect(3),
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
    required this.dark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactive = dark ? _NavChrome.inactiveOnDark : _NavChrome.inactiveLight;
    final compact = MediaQuery.sizeOf(context).width < 380;

    return ScaleTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: selected ? 6 : 2, vertical: compact ? 6 : 8),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_NavChrome.activeOrange, _NavChrome.activeOrangeDeep],
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _NavChrome.activeOrange.withValues(alpha: dark ? 0.55 : 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: selected ? Colors.white : inactive),
            SizedBox(height: compact ? 2 : 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 8 : 9,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? Colors.white : inactive,
                  letterSpacing: 0.1,
                ),
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
    required this.icon,
    required this.label,
    required this.selected,
    required this.dark,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool dark;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactive = dark ? _NavChrome.inactiveOnDark : _NavChrome.inactiveLight;
    final compact = MediaQuery.sizeOf(context).width < 380;

    return ScaleTap(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: compact ? 52 : 58,
                height: compact ? 52 : 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected
                      ? const LinearGradient(
                          colors: [_NavChrome.activeOrange, _NavChrome.activeOrangeDeep],
                        )
                      : null,
                  color: selected
                      ? null
                      : (dark ? _NavChrome.cartInset : const Color(0xFFFFF3E0)),
                  border: Border.all(
                    color: selected
                        ? _NavChrome.activeOrange
                        : (dark ? Colors.white24 : const Color(0xFFFFE0B2)),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _NavChrome.activeOrange.withValues(alpha: selected ? 0.45 : 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : (dark ? _NavChrome.cartIconOrange : _NavChrome.activeOrange),
                  size: 26,
                ),
              ),
              if (count > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
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
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: compact ? 8 : 9,
                fontWeight: FontWeight.w700,
                color: selected ? _NavChrome.activeOrange : inactive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
