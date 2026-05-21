import '../home_product.dart';

abstract class FoodRepository {
  Stream<List<HomeProduct>> watchActiveFoods();
  Stream<List<HomeProduct>> watchFoodsByCategory(String categoryId);
}
