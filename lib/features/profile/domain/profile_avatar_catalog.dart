import '../../menu/domain/entities/menu_category.dart';
import '../../menu/domain/home_product.dart';
import 'entities/profile_avatar_item.dart';

/// Kategoriya bo‘yicha avatarlar: mahsulot rasmlari + mahalliy assetlar.
abstract final class ProfileAvatarCatalog {
  static const Map<String, List<String>> _assetsByIcon = {
    'local_pizza': [
      'assets/onboarding_pizza.png',
      'assets/images/onboarding_pizza.png',
    ],
    'fastfood': [
      'assets/splash_food.png',
      'assets/images/splash_food.png',
    ],
    'icecream': [
      'assets/onboarding_icecream.png',
      'assets/images/onboarding_icecream.png',
    ],
    'local_cafe': [
      'assets/onboarding_delivery.png',
      'assets/images/onboarding_delivery.png',
    ],
    'cake': [
      'assets/onboarding_icecream.png',
      'assets/images/onboarding_icecream.png',
    ],
    'liquor': [
      'assets/onboarding_delivery.png',
      'assets/images/onboarding_delivery.png',
    ],
  };

  static const List<String> _defaultAssets = [
    'assets/onboarding_pizza.png',
    'assets/onboarding_icecream.png',
    'assets/onboarding_delivery.png',
    'assets/splash_food.png',
  ];

  static List<ProfileAvatarItem> avatarsForCategory(
    MenuCategory category,
    List<HomeProduct> foods,
  ) {
    final seen = <String>{};
    final items = <ProfileAvatarItem>[];

    for (final food in foods) {
      final url = food.imageUrl.trim();
      if (url.isEmpty || seen.contains(url)) continue;
      seen.add(url);
      items.add(ProfileAvatarItem.network('food_${food.id}', url));
      if (items.length >= 16) break;
    }

    final assets = _assetsByIcon[category.iconName] ?? _defaultAssets;
    for (var i = 0; i < assets.length; i++) {
      final path = assets[i];
      if (seen.add(path)) {
        items.add(ProfileAvatarItem.asset(path, id: 'asset_${category.id}_$i'));
      }
    }

    return items;
  }
}
