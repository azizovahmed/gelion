import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/firebase/firebase_media_api.dart';
import '../domain/banner_image_pipeline.dart';
import '../domain/banner_list_utils.dart';
import '../domain/entities/menu_category.dart';
import '../domain/entities/promo_banner.dart';
import '../domain/food_image_url.dart';
import '../domain/home_product.dart';
import '../domain/product_image_debug.dart';
import '../domain/product_image_pipeline.dart';
import '../domain/product_image_prepare.dart';
import 'banner_image_url_resolver.dart';
import 'category_image_url_resolver.dart';
import 'food_catalog_merge.dart';
import 'product_image_url_resolver.dart';

/// Admin: `categories`, `foods`, `banners` CRUD + Storage rasmlar.
class CatalogAdminRepository {
  CatalogAdminRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _db = firestore ?? FirebaseMediaApi.firestore,
        _storage = storage ?? FirebaseMediaApi.storage;

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
      final categoryPath = 'categories/$id/avatar.jpg';
      await _uploadBytes(categoryPath, imageBytes);
      imageUrl = await _storage.ref().child(categoryPath).getDownloadURL();
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
    var imagePath = food.imagePath.trim();
    String? fullImageUrl;

    logProductImageDebug(
      'saveFood:start',
      imageBytes: imageBytes,
      productId: id,
    );

    if (imageBytes != null && imageBytes.isNotEmpty) {
      imagePath = 'foods/$id/cover.jpg';
      final prepared = await prepareProductImageBytesForStorage(imageBytes);
      try {
        await _uploadBytes(imagePath, prepared);
        final exists = await ProductImagePipeline.storageFileExists(imagePath);
        if (!exists) {
          throw StateError(
            'Rasm Storage ga yozildi, lekin tekshiruvda topilmadi: $imagePath',
          );
        }
        final verifyUrl = await ProductImagePipeline.downloadUrlForPath(imagePath);
        if (verifyUrl == null || verifyUrl.isEmpty) {
          throw StateError('downloadURL olinmadi: $imagePath');
        }
        fullImageUrl = verifyUrl;
        developer.log(
          '[saveFood] Storage OK | imagePath=$imagePath | url=$verifyUrl',
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
    } else if (imagePath.isEmpty) {
      final existing = await _db.collection('foods').doc(id).get();
      final prev = existing.data() ?? {};
      imagePath = parseFoodImagePath(prev, documentId: id);
      if (imagePath.isEmpty &&
          (parseFoodImageUrl(prev).isNotEmpty || prev.containsKey('image') || prev.containsKey('imageUrl'))) {
        imagePath = 'foods/$id/cover.jpg';
      }
      fullImageUrl = parseFoodImageUrl(prev);
    }

    if ((fullImageUrl == null || fullImageUrl!.isEmpty) && imagePath.isNotEmpty) {
      fullImageUrl = await FirebaseMediaApi.resolveFullImageUrl(imagePath: imagePath);
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
      'image': FieldValue.delete(),
      'imageBytes': FieldValue.delete(),
    };

    if (imagePath.isNotEmpty) {
      data['imagePath'] = imagePath;
      data['image_path'] = imagePath;
    } else {
      data['imagePath'] = FieldValue.delete();
      data['image_path'] = FieldValue.delete();
    }

    if (fullImageUrl != null && fullImageUrl!.trim().isNotEmpty) {
      final url = fullImageUrl!.trim();
      if (isRenderableNetworkImageUrl(url)) {
        data['imageUrl'] = url;
        data['image_url'] = url;
      } else {
        data['imageUrl'] = FieldValue.delete();
        data['image_url'] = FieldValue.delete();
        developer.log(
          '[saveFood] imageUrl rad etildi (to‘liq URL emas): $url',
          name: 'ProductImage',
        );
      }
    } else {
      data['imageUrl'] = FieldValue.delete();
      data['image_url'] = FieldValue.delete();
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
      '[saveFood] Firestore foods/$id | imagePath=$imagePath | imageUrl=$fullImageUrl',
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
    return _db.collection('banners').snapshots().asyncMap((snap) async {
      final list = dedupeBannersById(snap.docs.map(PromoBanner.fromDoc));
      sortBannersForCarousel(list);
      return resolveBannerImageUrls(list);
    });
  }

  Future<void> saveBanner(PromoBanner banner, {Uint8List? imageBytes, bool setCreatedAt = false}) async {
    final isNew = banner.id.isEmpty;
    final id = isNew ? _db.collection('banners').doc().id : banner.id;
    var imagePath = banner.imagePath.trim();
    String? fullImageUrl;

    if (imageBytes != null && imageBytes.isNotEmpty) {
      imagePath = 'banners/$id/banner.jpg';
      final prepared = await prepareProductImageBytesForStorage(imageBytes);
      try {
        await _uploadBytes(imagePath, prepared);
        final verifyUrl = await BannerImagePipeline.downloadUrlForPath(imagePath);
        if (verifyUrl == null || verifyUrl.isEmpty) {
          throw StateError('Banner downloadURL olinmadi: $imagePath');
        }
        fullImageUrl = FirebaseMediaApi.normalizeDownloadUrl(verifyUrl);
        developer.log(
          '[saveBanner] Storage OK | bannerId=$id | imagePath=$imagePath | imageUrl=$fullImageUrl',
          name: 'BannerImage',
        );
      } catch (e, st) {
        developer.log(
          '[saveBanner] Storage FAILED: $e',
          name: 'BannerImage',
          error: e,
          stackTrace: st,
        );
        throw StateError(
          'Banner rasmi Firebase Storage ga yuklanmadi. Storage qoidalarini tekshiring.',
        );
      }
    } else if (imagePath.isEmpty) {
      final prev = await _db.collection('banners').doc(id).get();
      final prevData = prev.data() ?? {};
      imagePath = parseBannerImagePath(prevData, documentId: id);
      if (imagePath.isEmpty &&
          (parseFoodImageUrl(prevData).isNotEmpty ||
              prevData.containsKey('image') ||
              prevData.containsKey('imageUrl'))) {
        imagePath = 'banners/$id/banner.jpg';
      }
      fullImageUrl = parseFoodImageUrl(prevData);
    }

    if ((fullImageUrl == null || fullImageUrl!.isEmpty) && imagePath.isNotEmpty) {
      fullImageUrl = await FirebaseMediaApi.resolveFullImageUrl(imagePath: imagePath);
    }

    if (imagePath.isEmpty) {
      throw StateError('Banner rasmi yuklanmadi. Qayta urinib ko‘ring.');
    }

    final data = banner.copyWithId(id, imagePath: imagePath).toMap();
    if (isNew || setCreatedAt) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    data['updatedAt'] = FieldValue.serverTimestamp();
    data['image'] = FieldValue.delete();
    data['image_path'] = imagePath;
    if (fullImageUrl != null && fullImageUrl!.trim().isNotEmpty) {
      final url = FirebaseMediaApi.normalizeDownloadUrl(fullImageUrl!.trim());
      if (isRenderableNetworkImageUrl(url)) {
        data['imageUrl'] = url;
        data['image_url'] = url;
      } else {
        data['imageUrl'] = FieldValue.delete();
        data['image_url'] = FieldValue.delete();
        developer.log(
          '[saveBanner] imageUrl rad etildi (to‘liq URL emas): $url',
          name: 'BannerImage',
        );
      }
    } else {
      data['imageUrl'] = FieldValue.delete();
      data['image_url'] = FieldValue.delete();
    }
    await _db.collection('banners').doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteBanner(String id) async {
    await _db.collection('banners').doc(id).delete();
    try {
      await _storage.ref().child('banners').child(id).delete();
    } catch (_) {}
  }

  Future<void> _uploadBytes(String path, Uint8List bytes) async {
    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
  }
}

extension _PromoBannerCopy on PromoBanner {
  PromoBanner copyWithId(String id, {String? imagePath}) => PromoBanner(
        id: id,
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        imagePath: imagePath ?? this.imagePath,
        buttonText: buttonText,
        link: link,
        discount: discount,
        isActive: isActive,
        order: order,
        createdAt: createdAt,
      );
}
