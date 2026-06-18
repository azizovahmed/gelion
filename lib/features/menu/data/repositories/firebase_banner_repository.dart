import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../banner_image_url_resolver.dart';
import '../../domain/banner_image_pipeline.dart';
import '../../domain/banner_list_utils.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/repositories/banner_repository.dart';

class FirebaseBannerRepository implements BannerRepository {
  FirebaseBannerRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<List<PromoBanner>> watchActiveBanners() {
    return _db.collection('banners').snapshots().asyncMap(_mapActive);
  }

  Future<List<PromoBanner>> _mapActive(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) async {
    try {
      final parsed = <PromoBanner>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final banner = PromoBanner.fromDoc(doc);
        if (kDebugMode) {
          BannerImagePipeline.logFirestoreFields(
            banner.id.isNotEmpty ? banner.id : doc.id,
            data,
          );
        }
        if (banner.isActive) parsed.add(banner);
      }

      final list = dedupeBannersById(parsed);
      sortBannersForCarousel(list);
      return resolveBannerImageUrls(list);
    } catch (e, st) {
      developer.log(
        'FirebaseBannerRepository._mapActive failed: $e',
        name: 'BannerImage',
        error: e,
        stackTrace: st,
      );
      return snap.docs
          .map(PromoBanner.fromDoc)
          .where((b) => b.isActive)
          .toList();
    }
  }
}
