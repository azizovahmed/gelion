import '../../../core/config/app_image_config.dart';

/// Standart taom muqovasi: `foods/{id}/cover.jpg`.
String defaultFoodCoverPath(String productId) {
  final id = productId.trim();
  if (id.isEmpty) return '';
  return 'foods/$id/cover.jpg';
}

/// Firebase Storage download URL dan nisbiy yo‘l (`foods/...`).
String extractFoodStoragePathFromDownloadUrl(String url) {
  final value = url.trim();
  if (value.isEmpty || !value.contains('firebasestorage.googleapis.com')) {
    return '';
  }
  try {
    final uri = Uri.parse(value.startsWith('http') ? value : 'https://$value');
    final segments = uri.pathSegments;
    final oIndex = segments.indexOf('o');
    if (oIndex < 0 || oIndex + 1 >= segments.length) return '';
    final decoded = Uri.decodeComponent(segments[oIndex + 1]);
    if (isFoodStorageRelativePath(decoded)) return decoded;
  } catch (_) {}
  return '';
}

/// Firestore `imagePath` — Storage nisbiy yo‘li (masalan `foods/{id}/cover.jpg`).
String parseFoodImagePath(Map<String, dynamic> data, {String? documentId}) {
  final direct =
      ((data['imagePath'] ?? data['image_path']) as String?)?.trim();
  if (direct != null && direct.isNotEmpty && isFoodStorageRelativePath(direct)) {
    return direct;
  }
  for (final key in [
    'image',
    'imageUrl',
    'image_url',
    'coverImage',
    'cover_image',
    'photoUrl',
    'photo_url',
    'thumbnail',
    'imagePath',
    'image_path',
  ]) {
    final raw = data[key];
    if (raw is! String) continue;
    final value = raw.trim();
    if (value.isEmpty) continue;
    if (isFoodStorageRelativePath(value)) return value;
    if (value.startsWith('gs://')) {
      final gsPath = value.replaceFirst(RegExp(r'^gs://[^/]+/'), '');
      if (isFoodStorageRelativePath(gsPath)) return gsPath;
    }
    final fromFirebase = extractFoodStoragePathFromDownloadUrl(value);
    if (fromFirebase.isNotEmpty) return fromFirebase;
  }
  if (documentId != null && documentId.trim().isNotEmpty) {
    final hasLegacy = data.containsKey('image') ||
        data.containsKey('imageUrl') ||
        data.containsKey('image_url') ||
        data.containsKey('imagePath') ||
        data.containsKey('image_path') ||
        parseFoodImageUrl(data).isNotEmpty;
    if (hasLegacy) return defaultFoodCoverPath(documentId);
  }
  return '';
}

bool isFoodStorageRelativePath(String value) {
  final v = value.trim();
  return v.isNotEmpty &&
      !v.contains('://') &&
      v.startsWith('foods/');
}

/// Banner muqovasi: `banners/{id}/banner.jpg`.
String defaultBannerPath(String bannerId) {
  final id = bannerId.trim();
  if (id.isEmpty) return '';
  return 'banners/$id/banner.jpg';
}

/// Firebase Storage download URL dan banner yo‘li.
String extractBannerStoragePathFromDownloadUrl(String url) {
  final value = url.trim();
  if (value.isEmpty || !value.contains('firebasestorage.googleapis.com')) {
    return '';
  }
  try {
    final uri = Uri.parse(value.startsWith('http') ? value : 'https://$value');
    final segments = uri.pathSegments;
    final oIndex = segments.indexOf('o');
    if (oIndex < 0 || oIndex + 1 >= segments.length) return '';
    final decoded = Uri.decodeComponent(segments[oIndex + 1]);
    if (isBannerStorageRelativePath(decoded)) return decoded;
  } catch (_) {}
  return '';
}

/// Banner Storage yo‘li: `banners/{id}/banner.jpg`.
String parseBannerImagePath(Map<String, dynamic> data, {String? documentId}) {
  final direct =
      ((data['imagePath'] ?? data['image_path']) as String?)?.trim();
  if (direct != null && direct.isNotEmpty && isBannerStorageRelativePath(direct)) {
    return direct;
  }
  for (final key in [
    'image',
    'imageUrl',
    'image_url',
    'coverImage',
    'cover_image',
    'photoUrl',
    'photo_url',
    'imagePath',
    'image_path',
  ]) {
    final raw = data[key];
    if (raw is! String) continue;
    final value = raw.trim();
    if (value.isEmpty) continue;
    if (isBannerStorageRelativePath(value)) return value;
    if (value.startsWith('gs://')) {
      final gsPath = value.replaceFirst(RegExp(r'^gs://[^/]+/'), '');
      if (isBannerStorageRelativePath(gsPath)) return gsPath;
    }
    final fromFirebase = extractBannerStoragePathFromDownloadUrl(value);
    if (fromFirebase.isNotEmpty) return fromFirebase;
  }
  if (documentId != null && documentId.trim().isNotEmpty) {
    // HTTPS URL allaqachon bor bo‘lsa, noto‘g‘ri default yo‘lni taxmin qilmaymiz.
    if (parseFoodImageUrl(data).isNotEmpty) return '';
    final hasLegacyKey = data.containsKey('image') ||
        data.containsKey('imageUrl') ||
        data.containsKey('image_url');
    if (hasLegacyKey) return defaultBannerPath(documentId);
  }
  return '';
}

bool isBannerStorageRelativePath(String value) {
  final v = value.trim();
  return v.isNotEmpty && !v.contains('://') && v.startsWith('banners/');
}

/// Firestore `image` / `imageUrl` maydonidan to‘liq URL ajratadi.
String parseFoodImageUrl(Map<String, dynamic> data) {
  for (final key in [
    'imageUrl',
    'image_url',
    'image',
    'coverImage',
    'cover_image',
    'photoUrl',
    'photo_url',
    'thumbnail',
    'thumb',
    'imageURL',
    'downloadUrl',
    'downloadURL',
  ]) {
    final raw = data[key];
    if (raw is! String) continue;
    final value = raw.trim();
    if (value.isEmpty) continue;

    if (isPartialFilenameOnly(value)) {
      final coerced = coerceRelativeImageToFull(value);
      if (isRenderableNetworkImageUrl(coerced)) return coerced;
      continue;
    }

    final url = normalizeFoodImageUrl(raw);
    if (url.isNotEmpty && isRenderableNetworkImageUrl(url)) return url;
  }
  return '';
}

/// Turli formatlarni HTTPS URL ga keltiradi.
String normalizeFoodImageUrl(dynamic raw) {
  if (raw == null) return '';

  if (raw is Map) {
    for (final key in ['url', 'downloadUrl', 'downloadURL', 'src', 'uri', 'path']) {
      final nested = normalizeFoodImageUrl(raw[key]);
      if (nested.isNotEmpty) return nested;
    }
    return '';
  }

  if (raw is! String) return '';

  var value = raw.trim();
  if (value.isEmpty) return '';

  if (value.startsWith('//')) {
    value = 'https:$value';
  }

  if (!value.startsWith('http') && value.contains('firebasestorage.googleapis.com')) {
    value = 'https://$value';
  }

  if (value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('gs://')) {
    return value;
  }

  // Storage relative path: foods/{id}/cover.jpg
  if (!value.contains('://') &&
      (value.startsWith('foods/') ||
          value.startsWith('categories/') ||
          value.startsWith('banners/'))) {
    return value;
  }

  return '';
}

bool isRenderableNetworkImageUrl(String url) {
  final u = url.trim();
  return u.startsWith('http://') || u.startsWith('https://');
}

/// Firebase Storage download URL — web brauzer uchun barqaror HTTPS format.
String normalizeFirebaseStorageDownloadUrl(String raw) {
  var url = raw.trim();
  if (url.isEmpty) return '';

  if (!url.contains('firebasestorage.googleapis.com')) {
    return url;
  }

  if (url.startsWith('//')) {
    url = 'https:$url';
  } else if (!url.startsWith('http')) {
    url = 'https://$url';
  }

  try {
    final uri = Uri.parse(url);
    if (uri.host != 'firebasestorage.googleapis.com') return url;

    // Eski `.appspot.com` yoki chala `.firebasestorage` bucket nomini tuzatish.
    final segments = List<String>.from(uri.pathSegments);
    final bucketIndex = segments.indexOf('b');
    if (bucketIndex >= 0 && bucketIndex + 1 < segments.length) {
      var bucket = segments[bucketIndex + 1];
      var fixed = bucket;

      if (fixed.endsWith('.appspot.com')) {
        fixed = fixed.replaceFirst('.appspot.com', '.firebasestorage.app');
      } else if (fixed.endsWith('.firebasestorage') &&
          !fixed.endsWith('.firebasestorage.app')) {
        fixed = '$fixed.app';
      }

      if (fixed != bucket) {
        segments[bucketIndex + 1] = fixed;
        return uri.replace(pathSegments: segments).toString();
      }
    }

    return uri.toString();
  } catch (_) {
    return url;
  }
}

/// UI uchun yakuniy rasm URL (web + mobil).
String resolveDisplayImageUrl(String raw) {
  var url = raw.trim();
  if (url.isEmpty) return '';

  if (isPartialFilenameOnly(url)) {
    url = coerceRelativeImageToFull(url);
  }

  if (!isRenderableNetworkImageUrl(url)) return '';

  return normalizeFirebaseStorageDownloadUrl(url);
}
