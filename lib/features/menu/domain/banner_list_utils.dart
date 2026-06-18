import 'entities/promo_banner.dart';

/// Bir xil `id` li bannerlarni bittaga qisqartiradi (oxirgisi qoladi).
List<PromoBanner> dedupeBannersById(Iterable<PromoBanner> banners) {
  final byId = <String, PromoBanner>{};
  for (final banner in banners) {
    final id = banner.id.trim();
    if (id.isEmpty) continue;
    byId[id] = banner;
  }
  return byId.values.toList();
}

/// Karusel tartibi: `order` → `createdAt` (yangisi oldin).
void sortBannersForCarousel(List<PromoBanner> banners) {
  banners.sort((a, b) {
    final byOrder = a.order.compareTo(b.order);
    if (byOrder != 0) return byOrder;
    final ca = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final cb = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return cb.compareTo(ca);
  });
}
