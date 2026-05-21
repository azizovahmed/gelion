import '../entities/menu_category.dart';

abstract class CategoryRepository {
  Stream<List<MenuCategory>> watchActiveCategories();
}
