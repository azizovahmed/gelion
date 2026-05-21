import 'package:flutter/material.dart';

/// Admin panel icon keys → Material icons (same set as Gelion Admin).
abstract final class CategoryIconRegistry {
  static const Map<String, IconData> icons = {
    'fastfood': Icons.fastfood_rounded,
    'local_pizza': Icons.local_pizza_rounded,
    'local_cafe': Icons.local_cafe_rounded,
    'icecream': Icons.icecream_rounded,
    'lunch_dining': Icons.lunch_dining_rounded,
    'restaurant': Icons.restaurant_rounded,
    'cake': Icons.cake_rounded,
    'liquor': Icons.liquor_rounded,
    'rice_bowl': Icons.rice_bowl_rounded,
  };

  static IconData resolve(String iconName) =>
      icons[iconName] ?? Icons.restaurant_rounded;
}
