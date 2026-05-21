import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog_admin_repository.dart';
import '../data/favorites_repository.dart';
import '../data/firebase_category_repository.dart';
import '../data/repositories/firebase_banner_repository.dart';
import '../data/repositories/firebase_food_repository.dart';
import '../domain/entities/menu_category.dart';
import '../domain/entities/promo_banner.dart';
import '../domain/home_product.dart';
import '../domain/repositories/banner_repository.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/food_repository.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) => FirebaseFoodRepository());

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) => FirebaseCategoryRepository());

final bannerRepositoryProvider = Provider<BannerRepository>((ref) => FirebaseBannerRepository());

final catalogAdminRepositoryProvider = Provider<CatalogAdminRepository>((ref) => CatalogAdminRepository());

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) => FavoritesRepository());

/// Admin taom editori: tanlangan rasm modal qayta qurilsa ham saqlanadi.
final adminProductImageDraftProvider = StateProvider<Uint8List?>((ref) => null);

final activeCategoriesProvider = StreamProvider<List<MenuCategory>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchActiveCategories();
});

final activeBannersProvider = StreamProvider<List<PromoBanner>>((ref) {
  return ref.watch(bannerRepositoryProvider).watchActiveBanners();
});

final activeFoodsProvider = StreamProvider<List<HomeProduct>>((ref) {
  return ref.watch(foodRepositoryProvider).watchActiveFoods();
});

/// Kategoriya bo‘yicha taomlar (`null` / `''` — barcha faol).
final categoryFoodsProvider = StreamProvider.family<List<HomeProduct>, String?>((ref, categoryId) {
  final repo = ref.watch(foodRepositoryProvider);
  if (categoryId == null || categoryId.isEmpty) {
    return repo.watchActiveFoods();
  }
  return repo.watchFoodsByCategory(categoryId);
});

final favoriteIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(favoritesRepositoryProvider).watchIds();
});

final homeSearchQueryProvider = StateProvider<String>((ref) => '');

final homeSelectedCategoryIdProvider = StateProvider<String?>((ref) => null);

final recommendedFoodsProvider = Provider.family<List<HomeProduct>, String>((ref, categoryId) {
  final foods = ref.watch(activeFoodsProvider).valueOrNull ?? const <HomeProduct>[];
  return foods
      .where((f) => f.categoryId == categoryId && f.isRecommended && f.isActive)
      .take(6)
      .toList();
});

final adminCategoriesProvider = StreamProvider<List<MenuCategory>>((ref) {
  return ref.watch(catalogAdminRepositoryProvider).watchAllCategories();
});

final adminFoodsProvider = StreamProvider<List<HomeProduct>>((ref) {
  return ref.watch(catalogAdminRepositoryProvider).watchAllFoods();
});

final adminBannersProvider = StreamProvider<List<PromoBanner>>((ref) {
  return ref.watch(catalogAdminRepositoryProvider).watchAllBanners();
});
