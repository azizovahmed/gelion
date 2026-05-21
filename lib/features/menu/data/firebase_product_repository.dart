import '../domain/home_product.dart';
import '../domain/repositories/food_repository.dart';
import 'repositories/firebase_food_repository.dart';

/// Back-compat wrapper — uses Firestore `foods` via [FoodRepository].
class FirebaseProductRepository {
  FirebaseProductRepository({FoodRepository? repository})
      : _repo = repository ?? FirebaseFoodRepository();

  final FoodRepository _repo;

  Stream<List<HomeProduct>> watchProducts({String? categoryId}) {
    if (categoryId == null || categoryId.isEmpty) {
      return _repo.watchActiveFoods();
    }
    return _repo.watchFoodsByCategory(categoryId);
  }
}
