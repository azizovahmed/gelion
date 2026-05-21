import 'package:cloud_firestore/cloud_firestore.dart';

import 'category_image_url_resolver.dart';
import '../domain/entities/menu_category.dart';
import '../domain/repositories/category_repository.dart';

/// Firestore `categories` — faqat faol kategoriyalar, `order` bo'yicha.
class FirebaseCategoryRepository implements CategoryRepository {
  FirebaseCategoryRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection('categories');

  @override
  Stream<List<MenuCategory>> watchActiveCategories() {
    return _ref.snapshots().asyncMap((snap) async {
      try {
        var list = snap.docs
            .map(MenuCategory.fromDoc)
            .where((c) => c.isActive && c.name.isNotEmpty)
            .toList();
        list.sort((a, b) {
          final o = a.order.compareTo(b.order);
          if (o != 0) return o;
          return a.name.compareTo(b.name);
        });
        return resolveCategoryImageUrls(list);
      } catch (_) {
        return <MenuCategory>[];
      }
    });
  }
}
