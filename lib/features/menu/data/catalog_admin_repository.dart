import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/entities/menu_category.dart';
import '../domain/entities/promo_banner.dart';
import '../domain/food_image_url.dart';
import '../domain/home_product.dart';
import '../domain/product_image_debug.dart';
import '../domain/product_image_prepare.dart';
import 'category_image_url_resolver.dart';
import 'food_catalog_merge.dart';
import 'product_image_url_resolver.dart';

/// Admin: `categories`, `foods`, `banners` CRUD + Storage rasmlar.
class CatalogAdminRepository {
  CatalogAdminRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  // ——— Categories ———

  Stream<List<MenuCategory>> watchAllCategories() {
    return _db.collection('categories').orderBy('order').snapshots().asyncMap((snap) async {
      final list = snap.docs.map(MenuCategory.fromDoc).toList();
      return resolveCategoryImageUrls(list);
    });
  }

  Future<void> saveCategory(MenuCategory category, {Uint8List? imageBytes}) async {
    final id = category.id.isNotEmpty ? category.id : _db.collection('categories').doc().id;
    var imageUrl = category.imageUrl;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      imageUrl = await _uploadBytes('categories/$id/avatar.jpg', imageBytes);
    }
    final data = <String, dynamic>{
      'id': id,
      'name': category.name,
      'description': category.description,
      'image': imageUrl,
      'icon': category.iconName,
      'order': category.order,
      'isActive': category.isActive,
      'createdAt': category.createdAt != null
          ? Timestamp.fromDate(category.createdAt!)
          : FieldValue.serverTimestamp(),
    };
    if (imageBytes == null || imageBytes.isEmpty) {
      final existing = await _db.collection('categories').doc(id).get();
      final prev = existing.data();
      if (prev != null) {
        final kept = normalizeFoodImageUrl(prev['image'] ?? prev['imageUrl']);
        if (kept.isNotEmpty) data['image'] = kept;
      }
    }

    await _db.collection('categories').doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
    try {
      await _storage.ref().child('categories').child(id).delete();
    } catch (_) {}
  }

  // ——— Foods ———

  Stream<List<HomeProduct>> watchAllFoods() {
    return _db.collection('foods').snapshots().asyncMap((snap) async {
      var list = snap.docs.map(HomeProduct.fromDoc).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      list = await mergeFoodAndProductCollections(_db, list);
      return resolveProductImageUrls(list);
    });
  }

  Future<void> saveFood(HomeProduct food, {Uint8List? imageBytes, bool setCreatedAt = false}) async {
    final id = food.id.isNotEmpty ? food.id : _db.collection('foods').doc().id;
    var imageUrl = food.imageUrl.trim();

    logProductImageDebug(
      'saveFood:start',
      imageBytes: imageBytes,
      productId: id,
    );

    if (imageBytes != null && imageBytes.isNotEmpty) {
      final prepared = await prepareProductImageBytesForStorage(imageBytes);
      try {
        imageUrl = await _uploadBytes('foods/$id/cover.jpg', prepared);
        developer.log(
          '[saveFood] Storage OK | image=$imageUrl',
          name: 'ProductImage',
        );
      } catch (e, st) {
        developer.log(
          '[saveFood] Storage FAILED: $e',
          name: 'ProductImage',
          error: e,
          stackTrace: st,
        );
        throw StateError(
          'Rasm Firebase Storage ga yuklanmadi. Storage qoidalarini tekshiring.',
        );
      }
    }

    final trimmedUrl = imageUrl.trim();
    if (imageBytes != null && imageBytes.isNotEmpty && trimmedUrl.isEmpty) {
      throw StateError('downloadURL olinmadi. Qayta urinib ko‘ring.');
    }

    final data = <String, dynamic>{
      'id': id,
      'name': food.name,
      'price': food.price,
      'description': food.description ?? '',
      'categoryId': food.categoryId ?? '',
      'isPopular': food.isPopular,
      'isRecommended': food.isRecommended,
      'isActive': food.isActive,
      'isAvailable': food.isActive,
      'stock': food.stock,
      if (food.ingredients != null && food.ingredients!.isNotEmpty)
        'ingredients': food.ingredients,
      if (food.category != null && food.category!.isNotEmpty) 'categoryName': food.category,
      if (setCreatedAt) 'createdAt': FieldValue.serverTimestamp(),
    };

    if (trimmedUrl.isNotEmpty) {
      data['image'] = trimmedUrl;
      data['imageUrl'] = trimmedUrl;
      data['imageBytes'] = FieldValue.delete();
    } else if (imageBytes == null || imageBytes.isEmpty) {
      // Tahrirlashda yangi rasm tanlanmasa — mavjud URL saqlanadi.
      final existing = await _db.collection('foods').doc(id).get();
      final prev = existing.data();
      if (prev != null) {
        final kept = parseFoodImageUrl(prev);
        if (kept.isNotEmpty) {
          data['image'] = kept;
          data['imageUrl'] = kept;
        }
      }
    }

    logProductImageDebug(
      'saveFood:firestorePayload',
      imageBytes: imageBytes,
      payload: data,
      productId: id,
    );

    if (setCreatedAt) {
      await _db.collection('foods').doc(id).set(data);
    } else {
      await _db.collection('foods').doc(id).set(data, SetOptions(merge: true));
    }

    developer.log(
      '[saveFood] Firestore foods/$id | image=$trimmedUrl',
      name: 'ProductImage',
    );
  }

  Future<void> deleteFood(String id) async {
    await _db.collection('foods').doc(id).delete();
    try {
      await _storage.ref().child('foods').child(id).delete();
    } catch (_) {}
  }

  // ——— Banners ———

  Stream<List<PromoBanner>> watchAllBanners() {
    return _db.collection('banners').snapshots().map((snap) {
      final list = snap.docs.map(PromoBanner.fromDoc).toList();
      list.sort((a, b) {
        final ca = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final cb = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return cb.compareTo(ca);
      });
      return list;
    });
  }

  Future<void> saveBanner(PromoBanner banner, {Uint8List? imageBytes, bool setCreatedAt = false}) async {
    final id = banner.id.isNotEmpty ? banner.id : _db.collection('banners').doc().id;
    var imageUrl = banner.imageUrl;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      imageUrl = await _uploadBytes('banners/$id/banner.jpg', imageBytes);
    }
    final data = banner
        .copyWithId(id, imageUrl: imageUrl)
        .toMap();
    if (setCreatedAt) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await _db.collection('banners').doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteBanner(String id) async {
    await _db.collection('banners').doc(id).delete();
    try {
      await _storage.ref().child('banners').child(id).delete();
    } catch (_) {}
  }

  Future<String> _uploadBytes(String path, Uint8List bytes) async {
    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}

extension _PromoBannerCopy on PromoBanner {
  PromoBanner copyWithId(String id, {String? imageUrl}) => PromoBanner(
        id: id,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl ?? this.imageUrl,
        buttonText: buttonText,
        link: link,
        discount: discount,
        isActive: isActive,
        order: order,
        createdAt: createdAt,
      );
}
