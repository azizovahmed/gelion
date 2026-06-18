import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../firebase_options.dart';
import '../config/app_image_config.dart';
import '../../features/menu/domain/food_image_url.dart';

/// Firebase "Backend API" — Storage (public read) + to‘liq image URL.
abstract final class FirebaseMediaApi {
  static const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: AppImageConfig.apiBaseUrl,
  );

  static String get storageBucket =>
      DefaultFirebaseOptions.currentPlatform.storageBucket ?? '';

  static FirebaseStorage get storage {
    final bucket = storageBucket;
    if (bucket.isEmpty) return FirebaseStorage.instance;
    return FirebaseStorage.instanceFor(
      app: Firebase.app(),
      bucket: bucket,
    );
  }

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static Reference ref(String path) => storage.ref(path);

  /// Firestore’dagi eski/noto‘g‘ri bucket nomli download URL ni joriy bucket ga moslaydi.
  static String normalizeDownloadUrl(String raw) {
    var url = raw.trim();
    if (url.isEmpty || !url.contains('firebasestorage.googleapis.com')) {
      return url;
    }
    if (!url.startsWith('http')) url = 'https://$url';

    final bucket = storageBucket.trim();
    if (bucket.isEmpty) return url;

    final match = RegExp(r'/b/([^/]+)/o/').firstMatch(url);
    if (match == null) return url;

    final inUrl = match.group(1)!;
    if (inUrl == bucket) return url;

    // Masalan: `gelion-99b07.firebasestorage` → `gelion-99b07.firebasestorage.app`
    final sameProject = inUrl.split('.').first == bucket.split('.').first;
    if (sameProject || inUrl.contains('appspot.com') || !inUrl.contains('.')) {
      return url.replaceFirst('/b/$inUrl/', '/b/$bucket/');
    }
    return url;
  }

  /// Chala nom yoki Storage yo‘li → to‘liq https URL.
  static Future<String> resolveFullImageUrl({
    String? imageUrl,
    String? imagePath,
  }) async {
    final direct = normalizeDownloadUrl((imageUrl ?? '').trim());
    if (isRenderableNetworkImageUrl(direct)) return direct;

    if (isPartialFilenameOnly(direct)) {
      final coerced = coerceRelativeImageToFull(
        direct,
        baseUrl: serverUrl.isNotEmpty ? serverUrl : AppImageConfig.apiBaseUrl,
      );
      if (isRenderableNetworkImageUrl(coerced)) return coerced;
    }

    final path = (imagePath ?? '').trim();
    if (path.isEmpty) return '';

    if (isRenderableNetworkImageUrl(path)) return path;

    if (path.startsWith('foods/') ||
        path.startsWith('banners/') ||
        path.startsWith('categories/')) {
      try {
        return await ref(path).getDownloadURL();
      } catch (_) {
        return '';
      }
    }

    return '';
  }

  static Future<Map<String, dynamic>> mealToApiJson(
    Map<String, dynamic> data, {
    required String documentId,
  }) async {
    final imagePath = parseFoodImagePath(data, documentId: documentId);
    final imageUrl = await resolveFullImageUrl(
      imageUrl: parseFoodImageUrl(data),
      imagePath: imagePath,
    );
    return {
      ...data,
      'id': documentId,
      'image_path': imagePath,
      'image_url': imageUrl,
    };
  }

  static Future<Map<String, dynamic>> bannerToApiJson(
    Map<String, dynamic> data, {
    required String documentId,
  }) async {
    final imagePath = parseBannerImagePath(data, documentId: documentId);
    final imageUrl = await resolveFullImageUrl(
      imageUrl: parseFoodImageUrl(data),
      imagePath: imagePath,
    );
    return {
      ...data,
      'id': documentId,
      'image_path': imagePath,
      'image_url': imageUrl,
    };
  }
}
