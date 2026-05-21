import 'home_product.dart';

/// Bosh sahifa / kategoriya ro‘yxati uchun tartiblash.
List<HomeProduct> sortFoodsForDisplay(
  List<HomeProduct> raw, {
  String? categoryId,
}) {
  var list = raw.where((p) => p.isActive).toList();
  final cid = categoryId?.trim();
  if (cid != null && cid.isNotEmpty) {
    list = list.where((p) => p.categoryId == cid).toList();
  }

  final sorted = List<HomeProduct>.from(list);
  sorted.sort((a, b) {
    final popular = (b.isPopular ? 1 : 0).compareTo(a.isPopular ? 1 : 0);
    if (popular != 0) return popular;

    final aDate = a.createdAt;
    final bDate = b.createdAt;
    if (aDate != null && bDate != null) {
      final byDate = bDate.compareTo(aDate);
      if (byDate != 0) return byDate;
    }

    return a.name.compareTo(b.name);
  });
  return sorted;
}

/// Matn bo‘yicha mahsulot qidiruvi (nom).
List<HomeProduct> filterFoodsBySearch(List<HomeProduct> source, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return source;
  return source.where((p) => p.name.toLowerCase().contains(q)).toList();
}
