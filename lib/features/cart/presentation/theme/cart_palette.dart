import 'package:flutter/material.dart';

/// Orange + cream tokens with dark-mode counterparts for the cart experience.
abstract final class CartPalette {
  static bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color pageBg(BuildContext context) => _dark(context)
      ? const Color(0xFF121015)
      : const Color(0xFFFFF6ED);

  static Color creamCard(BuildContext context) => _dark(context)
      ? const Color(0xFF1E1A22)
      : const Color(0xFFFFF1E3);

  static Color cardSurface(BuildContext context) => _dark(context)
      ? const Color(0xFF232029)
      : Colors.white;

  static Color textPrimary(BuildContext context) => _dark(context)
      ? const Color(0xFFF4EDE6)
      : const Color(0xFF2B1E16);

  static Color textSecondary(BuildContext context) => _dark(context)
      ? const Color(0xFFB9A99A)
      : const Color(0xFF7A6558);

  static const Color orangeDeep = Color(0xFFE65100);
  static const Color orangeMain = Color(0xFFFF7A1A);
  static const Color orangeSoft = Color(0xFFFFB574);
  static const Color brownPrice = Color(0xFF8D4E1F);
  static const Color accentYellow = Color(0xFFFFD54A);

  static List<Color> headerGradient(bool dark) => dark
      ? const [Color(0xFFFF8A3D), Color(0xFFFF5C1A), Color(0xFFC62828)]
      : const [Color(0xFFFF9A4A), Color(0xFFFF6B2C), Color(0xFFFF8C42)];

  static List<BoxShadow> cardLift(bool dark) => [
        BoxShadow(
          color: dark
              ? Colors.black.withValues(alpha: 0.45)
              : const Color(0xFFFF9E6B).withValues(alpha: 0.22),
          blurRadius: 22,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: dark
              ? Colors.black.withValues(alpha: 0.35)
              : const Color(0xFF3E2723).withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> glassEdge(bool dark) => [
        BoxShadow(
          color: Colors.white.withValues(alpha: dark ? 0.06 : 0.65),
          blurRadius: 0,
          offset: const Offset(0, 1),
          spreadRadius: 0,
        ),
      ];
}
