/// Banner `link` maydoni — kategoriya yoki mahsulotga yo‘naltirish.
enum BannerLinkKind { none, category, product }

class BannerLinkTarget {
  const BannerLinkTarget._(this.kind, this.id);

  const BannerLinkTarget.none() : this._(BannerLinkKind.none, '');

  const BannerLinkTarget.category(String id) : this._(BannerLinkKind.category, id);

  const BannerLinkTarget.product(String id) : this._(BannerLinkKind.product, id);

  final BannerLinkKind kind;
  final String id;

  static BannerLinkTarget parse(String? raw) {
    final link = raw?.trim() ?? '';
    if (link.isEmpty) return const BannerLinkTarget.none();

    final normalized = link.replaceFirst(RegExp(r'^/'), '');
    final parts = normalized.split(RegExp(r'[:/]')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return const BannerLinkTarget.none();

    if (parts.length >= 2) {
      final type = parts.first.toLowerCase();
      final id = parts.sublist(1).join('/');
      if (_isCategoryType(type) && id.isNotEmpty) {
        return BannerLinkTarget.category(id);
      }
      if (_isProductType(type) && id.isNotEmpty) {
        return BannerLinkTarget.product(id);
      }
    }

    // Faqat ID — avval mahsulot, keyin kategoriya (Firestore tekshiruvi handlerda).
    return BannerLinkTarget.product(parts.first);
  }

  static bool _isCategoryType(String type) =>
      type == 'category' || type == 'categories' || type == 'cat';

  static bool _isProductType(String type) =>
      type == 'product' || type == 'products' || type == 'food' || type == 'foods';
}
