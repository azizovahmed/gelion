import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_product_rules.dart';
import 'product_image_parser.dart';

/// Taom — Firestore `imagePath` → Firebase Storage → runtime download URL.
class HomeProduct {
  const HomeProduct({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl = '',
    this.imagePath = '',
    this.firestoreImage = '',
    this.imageBytes,
    this.category,
    this.categoryId,
    this.description,
    this.ingredients,
    this.isPopular = false,
    this.isRecommended = false,
    this.isActive = true,
    this.stock = CartProductRules.unlimitedStock,
    this.createdAt,
  });

  final String id;
  final String name;
  final int price;
  final String imageUrl;
  final String imagePath;
  /// Raw Firestore `image` field (path or HTTPS URL).
  final String firestoreImage;
  final Uint8List? imageBytes;
  final int stock;
  final String? category;
  final String? categoryId;
  final String? description;
  final String? ingredients;
  final bool isPopular;
  final bool isRecommended;
  final bool isActive;
  final DateTime? createdAt;

  /// Firestore `image` maydoni (Storage yo‘li yoki HTTPS URL).
  String get image {
    final raw = firestoreImage.trim();
    if (raw.isNotEmpty) return raw;
    return imageUrl.trim();
  }

  bool get hasNetworkImage {
    final u = imageUrl.trim();
    return u.startsWith('http://') || u.startsWith('https://');
  }

  /// Firestore/Storage zanjirida rasm borligi.
  bool get hasImage =>
      hasNetworkImage ||
      imagePath.isNotEmpty ||
      (imageBytes != null && imageBytes!.isNotEmpty);

  /// Boshqa manbadan rasmni to‘ldiradi (masalan `products` kolleksiyasi).
  HomeProduct fillMissingImageFrom(HomeProduct other) {
    if (hasImage || !other.hasImage) return this;
    return copyWith(
      imageUrl: other.imageUrl,
      imagePath: other.imagePath,
      imageBytes: other.imageBytes,
    );
  }

  factory HomeProduct.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final rawPrice = d['price'];
    int p = 0;
    if (rawPrice is int) {
      p = rawPrice;
    } else if (rawPrice is double) {
      p = rawPrice.round();
    } else if (rawPrice is num) {
      p = rawPrice.toInt();
    }
    final categoryId = (d['categoryId'] as String?)?.trim();
    final categoryName = (d['categoryName'] as String?)?.trim() ??
        (d['category'] as String?)?.trim();

    final id = (d['id'] as String?)?.trim().isNotEmpty == true
        ? (d['id'] as String).trim()
        : doc.id;
    final image = parseProductImageFields(d, documentId: id);

    return HomeProduct(
      id: id,
      name: (d['name'] as String?)?.trim() ?? '',
      price: p,
      imageUrl: image.networkUrl,
      imagePath: image.storagePath,
      firestoreImage: (d['image'] as String?)?.trim() ?? '',
      imageBytes: image.imageBytes,
      category: categoryName,
      categoryId: categoryId,
      description: (d['description'] as String?)?.trim(),
      ingredients: (d['ingredients'] as String?)?.trim(),
      isPopular: _readBool(d['isPopular'] ?? d['popular'], false),
      isRecommended: _readBool(d['isRecommended'], false),
      isActive: _readBool(d['isAvailable'] ?? d['isActive'] ?? d['available'], true),
      stock: _readStock(d['stock']),
      createdAt: _readDate(d['createdAt']),
    );
  }

  HomeProduct copyWith({
    String? imageUrl,
    String? imagePath,
    String? firestoreImage,
    Uint8List? imageBytes,
    bool clearImageBytes = false,
  }) {
    return HomeProduct(
      id: id,
      name: name,
      price: price,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      firestoreImage: firestoreImage ?? this.firestoreImage,
      imageBytes: clearImageBytes ? null : (imageBytes ?? this.imageBytes),
      category: category,
      categoryId: categoryId,
      description: description,
      ingredients: ingredients,
      isPopular: isPopular,
      isRecommended: isRecommended,
      isActive: isActive,
      stock: stock,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap({bool includeCreatedAt = false}) {
    final path = imagePath.trim();
    return {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        if (path.isNotEmpty) 'imagePath': path,
        if (imageUrl.trim().isNotEmpty) 'imageUrl': imageUrl.trim(),
        if (categoryId != null && categoryId!.isNotEmpty)
          'categoryId': categoryId,
        if (category != null && category!.isNotEmpty) 'categoryName': category,
        if (description != null && description!.isNotEmpty)
          'description': description,
        if (ingredients != null && ingredients!.isNotEmpty)
          'ingredients': ingredients,
        'isPopular': isPopular,
        'isRecommended': isRecommended,
        'isActive': isActive,
        'isAvailable': isActive,
        if (includeCreatedAt) 'createdAt': FieldValue.serverTimestamp(),
      };
  }
}

bool _readBool(dynamic value, bool fallback) {
  if (value is bool) return value;
  if (value is String) {
    final v = value.toLowerCase();
    return v == 'true' || v == '1';
  }
  return fallback;
}

DateTime? _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

int _readStock(dynamic value) {
  if (value == null) return CartProductRules.unlimitedStock;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return CartProductRules.unlimitedStock;
    return int.tryParse(trimmed) ?? CartProductRules.unlimitedStock;
  }
  return CartProductRules.unlimitedStock;
}

typedef OnAddToCart = void Function(HomeProduct product, {int count});
