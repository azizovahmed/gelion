import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../food_catalog_merge.dart';
import '../product_image_url_resolver.dart';
import '../../domain/home_product.dart';
import '../../domain/repositories/food_repository.dart';

/// Firestore `foods` — real-time.
class FirebaseFoodRepository implements FoodRepository {
  FirebaseFoodRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _foods => _db.collection('foods');

  @override
  Stream<List<HomeProduct>> watchActiveFoods() {
    return _foods.snapshots().asyncMap(_mapActive);
  }

  @override
  Stream<List<HomeProduct>> watchFoodsByCategory(String categoryId) {
    if (categoryId.isEmpty) return watchActiveFoods();
    return _foods.where('categoryId', isEqualTo: categoryId).snapshots().asyncMap(_mapActive);
  }

  Future<List<HomeProduct>> _mapActive(QuerySnapshot<Map<String, dynamic>> snap) async {
    try {
      var list = snap.docs
          .map(HomeProduct.fromDoc)
          .where((f) => f.isActive && f.name.isNotEmpty)
          .toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      list = await mergeFoodAndProductCollections(_db, list);
      // Web: har mahsulot uchun Storage URL — uzoq “loading”, sahifa bo‘sh ko‘rinadi.
      if (kIsWeb) return list;
      return resolveProductImageUrls(list);
    } catch (_) {
      return <HomeProduct>[];
    }
  }
}
