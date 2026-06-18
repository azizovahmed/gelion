import 'package:flutter/material.dart';

import '../../../../core/widgets/safe_network_image.dart';
import '../../data/category_icon_registry.dart';
import '../../domain/entities/menu_category.dart';
import '../../domain/food_image_url.dart';

/// Kategoriya avatari: Storage HTTPS yoki Material icon.
class CategoryNetworkAvatar extends StatelessWidget {
  const CategoryNetworkAvatar({
    super.key,
    required this.category,
    required this.size,
    required this.icon,
    this.active = false,
    this.inactiveIconColor,
  });

  final MenuCategory? category;
  final double size;
  final IconData icon;
  final bool active;
  final Color? inactiveIconColor;

  @override
  Widget build(BuildContext context) {
    final url = resolveDisplayImageUrl(category?.imageUrl ?? '');
    final hasUrl = isRenderableNetworkImageUrl(url);
    final iconColor = active
        ? Colors.white
        : (inactiveIconColor ?? const Color(0xFF8D6E63));

    if (category != null && hasUrl) {
      return ClipOval(
        child: SafeNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          memCacheWidth: (size * 2).round().clamp(64, 256),
          errorLabel: '',
        ),
      );
    }

    return _IconFallback(icon: icon, size: size, color: iconColor);
  }

  static IconData iconFor(MenuCategory? category) {
    if (category == null) return Icons.grid_view_rounded;
    return CategoryIconRegistry.resolve(category.iconName);
  }
}

class _IconFallback extends StatelessWidget {
  const _IconFallback({
    required this.icon,
    required this.size,
    required this.color,
  });

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: size * 0.42);
  }
}
