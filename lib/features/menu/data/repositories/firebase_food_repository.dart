import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../food_catalog_merge.dart';
import '../product_image_url_resolver.dart';
import '../../domain/home_product.dart';
import '../../domain/product_image_pipeline.dart';
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
      var list = <HomeProduct>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final product = HomeProduct.fromDoc(doc);
        if (kDebugMode) {
          ProductImagePipeline.logFirestoreFields(
            product.id.isNotEmpty ? product.id : doc.id,
            data,
          );
        }
        if (product.isActive && product.name.isNotEmpty) {
          list.add(product);
        }
      }
      list.sort((a, b) => a.name.compareTo(b.name));
      list = await mergeFoodAndProductCollections(_db, list);
      return resolveProductImageUrls(list);
    } catch (e, st) {
      developer.log(
        'FirebaseFoodRepository._mapActive failed: $e',
        name: 'ProductImage',
        error: e,
        stackTrace: st,
      );
      return snap.docs
          .map(HomeProduct.fromDoc)
          .where((f) => f.isActive && f.name.isNotEmpty)
          .toList();
    }
  }
}
