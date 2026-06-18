import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../../core/firebase/firebase_media_api.dart';
import 'entities/promo_banner.dart';
import 'food_image_url.dart';

/// Banner rasmi: Firestore → Storage → download URL → UI.
class BannerImageResolveResult {
  const BannerImageResolveResult({
    this.downloadUrl,
    this.storagePath = '',
    this.storageExists = false,
    this.error,
    this.renderStatus = 'unknown',
  });

  final String? downloadUrl;
  final String storagePath;
  final bool storageExists;
  final String? error;
  final String renderStatus;

  bool get canRender =>
      downloadUrl != null && isRenderableNetworkImageUrl(downloadUrl!);
}

abstract final class BannerImagePipeline {
  static const _logName = 'BannerImage';

  static void _log(
    String step, {
    required String bannerId,
    Map<String, String>? data,
  }) {
    if (!kDebugMode) return;
    final parts = data?.entries.map((e) => '${e.key}=${e.value}').join(' | ') ?? '';
    developer.log(
      '[$step] bannerId=$bannerId${parts.isEmpty ? '' : ' | $parts'}',
      name: _logName,
    );
  }

  static void logFirestoreFields(String bannerId, Map<String, dynamic> data) {
    _log(
      '1_firestore_fields',
      bannerId: bannerId,
      data: {
        'imagePath': '${data['imagePath'] ?? data['image_path']}',
        'image': _short('${data['image']}'),
        'imageUrl': _short('${data['imageUrl'] ?? data['image_url']}'),
        'parsed_path': parseBannerImagePath(data, documentId: bannerId),
        'parsed_https': _short(parseFoodImageUrl(data)),
      },
    );
  }

  static String _short(String value, [int max = 72]) {
    final v = value.trim();
    if (v.length <= max) return v.isEmpty ? '(empty)' : v;
    return '${v.substring(0, max)}…';
  }

  static List<String> storagePathCandidates(PromoBanner banner) {
    final paths = <String>{};
    final fromBanner = banner.imagePath.trim();
    if (fromBanner.isNotEmpty) paths.add(fromBanner);

    if (banner.id.isNotEmpty) {
      paths.add(defaultBannerPath(banner.id));
    }
    return paths.toList();
  }

  static Future<bool> storageFileExists(String storagePath) async {
    final path = storagePath.trim();
    if (path.isEmpty) return false;
    try {
      await FirebaseMediaApi.ref(path).getMetadata();
      _log('2_storage_file_exists', bannerId: path, data: {'exists': 'true'});
      return true;
    } catch (e) {
      final notFound = '$e'.contains('object-not-found');
      if (!notFound) {
        _log('2_storage_file_exists', bannerId: path, data: {
          'exists': 'false',
          'error': '$e',
        });
      }
      return false;
    }
  }

  static Future<String?> downloadUrlForPath(String storagePath) async {
    final path = storagePath.trim();
    if (path.isEmpty) return null;

    if (path.startsWith('gs://')) {
      try {
        final url = await FirebaseMediaApi.storage.refFromURL(path).getDownloadURL();
        _log('3_download_url', bannerId: path, data: {'url': _short(url), 'via': 'gs'});
        return url;
      } catch (e) {
        if (!'$e'.contains('object-not-found')) {
          _log('3_download_url', bannerId: path, data: {'error': '$e', 'via': 'gs'});
        }
        return null;
      }
    }

    if (isRenderableNetworkImageUrl(path)) {
      _log('3_download_url', bannerId: path, data: {'url': _short(path), 'via': 'https'});
      return path;
    }

    if (!path.startsWith('banners/')) return null;

    try {
      final url = await FirebaseMediaApi.ref(path).getDownloadURL();
      _log('3_download_url', bannerId: path, data: {'url': _short(url), 'via': 'ref'});
      return FirebaseMediaApi.normalizeDownloadUrl(url);
    } catch (e) {
      if (!'$e'.contains('object-not-found')) {
        _log('3_download_url', bannerId: path, data: {'error': '$e', 'via': 'ref'});
      }
      return null;
    }
  }

  static Future<BannerImageResolveResult> resolveForBanner(
    PromoBanner banner, {
    Map<String, dynamic>? firestoreRaw,
  }) async {
    final id = banner.id.isNotEmpty ? banner.id : 'unknown';

    if (firestoreRaw != null) {
      logFirestoreFields(id, firestoreRaw);
    } else {
      _log('1_firestore_parsed', bannerId: id, data: {
        'imagePath': banner.imagePath.isEmpty ? '(empty)' : banner.imagePath,
        'imageUrl': banner.imageUrl.isEmpty ? '(empty)' : _short(banner.imageUrl),
      });
    }

    final directUrl = FirebaseMediaApi.normalizeDownloadUrl(
      resolveDisplayImageUrl(banner.imageUrl),
    );
    if (isRenderableNetworkImageUrl(directUrl)) {
      _log('4_image_render_status', bannerId: id, data: {
        'status': 'ready_firestore_url',
        'url': _short(directUrl),
      });
      return BannerImageResolveResult(
        downloadUrl: directUrl,
        storagePath: banner.imagePath,
        storageExists: true,
        renderStatus: 'ready_firestore_url',
      );
    }

    for (final path in storagePathCandidates(banner)) {
      final exists = await storageFileExists(path);
      if (!exists) continue;

      final url = await downloadUrlForPath(path);
      if (url != null && isRenderableNetworkImageUrl(url)) {
        _log('4_image_render_status', bannerId: id, data: {
          'status': 'ready_storage',
          'path': path,
          'url': _short(url),
        });
        return BannerImageResolveResult(
          downloadUrl: url,
          storagePath: path,
          storageExists: true,
          renderStatus: 'ready_storage',
        );
      }
    }

    _log('4_image_render_status', bannerId: id, data: {
      'status': 'failed',
      'candidates': storagePathCandidates(banner).join(','),
    });
    return BannerImageResolveResult(
      storagePath: banner.imagePath,
      storageExists: false,
      error: 'Storage fayl topilmadi yoki download URL olinmadi',
      renderStatus: 'failed',
    );
  }

  static void logRenderStatus({
    required String bannerId,
    required String status,
    String? url,
    Object? error,
  }) {
    _log('4_image_render_status', bannerId: bannerId, data: {
      'status': status,
      if (url != null) 'url': _short(url),
      if (error != null) 'error': '$error',
    });
  }
}
