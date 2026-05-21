import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/home_product.dart';

/// `foods` + `products` kolleksiyalarini birlashtiradi (admin panel mosligi).
Future<List<HomeProduct>> mergeFoodAndProductCollections(
  FirebaseFirestore db,
  List<HomeProduct> fromFoods,
) async {
  if (!fromFoods.any((f) => !f.hasImage)) return fromFoods;
  try {
    final productsSnap = await db.collection('products').get();
    if (productsSnap.docs.isEmpty) return fromFoods;

    final byId = {for (final f in fromFoods) f.id: f};

    for (final doc in productsSnap.docs) {
      final fromProducts = HomeProduct.fromDoc(doc);
      if (fromProducts.name.isEmpty) continue;

      final existing = byId[fromProducts.id];
      if (existing == null) {
        byId[fromProducts.id] = fromProducts;
      } else {
        byId[fromProducts.id] = existing.fillMissingImageFrom(fromProducts);
      }
    }

    final merged = byId.values.toList();
    merged.sort((a, b) => a.name.compareTo(b.name));
    return merged;
  } catch (_) {
    return fromFoods;
  }
}
