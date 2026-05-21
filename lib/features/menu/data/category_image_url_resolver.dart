import 'package:firebase_storage/firebase_storage.dart';

import '../domain/entities/menu_category.dart';
import '../domain/food_image_url.dart';

Future<MenuCategory> resolveCategoryImageUrl(MenuCategory category) async {
  var url = await _resolveToHttps(category.imageUrl.trim());
  if (url.isEmpty && category.id.isNotEmpty) {
    url = await _resolveToHttps('categories/${category.id}/avatar.jpg');
  }
  if (url.isEmpty || url == category.imageUrl) return category;
  return MenuCategory(
    id: category.id,
    name: category.name,
    description: category.description,
    imageUrl: url,
    iconName: category.iconName,
    order: category.order,
    isActive: category.isActive,
    createdAt: category.createdAt,
  );
}

Future<List<MenuCategory>> resolveCategoryImageUrls(List<MenuCategory> list) {
  return Future.wait(list.map(resolveCategoryImageUrl));
}

Future<String> _resolveToHttps(String raw) async {
  var url = normalizeFoodImageUrl(raw);
  if (url.isEmpty) return '';
  if (url.startsWith('gs://')) {
    try {
      return await FirebaseStorage.instance.refFromURL(url).getDownloadURL();
    } catch (_) {
      return '';
    }
  }
  if (isRenderableNetworkImageUrl(url)) return url;
  if (!url.contains('://')) {
    try {
      return await FirebaseStorage.instance.ref(url).getDownloadURL();
    } catch (_) {
      return '';
    }
  }
  return '';
}
