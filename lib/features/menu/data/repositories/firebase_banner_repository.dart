import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/promo_banner.dart';
import '../../domain/repositories/banner_repository.dart';

class FirebaseBannerRepository implements BannerRepository {
  FirebaseBannerRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<List<PromoBanner>> watchActiveBanners() {
    return _db.collection('banners').snapshots().map((snap) {
      final list = snap.docs
          .map(PromoBanner.fromDoc)
          .where((b) => b.isActive && b.imageUrl.isNotEmpty)
          .toList();
      list.sort((a, b) {
        final byOrder = a.order.compareTo(b.order);
        if (byOrder != 0) return byOrder;
        final ca = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final cb = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return cb.compareTo(ca);
      });
      return list;
    });
  }
}
