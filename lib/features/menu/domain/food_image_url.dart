/// Firestore `image` maydonidan HTTPS URL ajratadi.
String parseFoodImageUrl(Map<String, dynamic> data) {
  for (final key in ['image', 'imageUrl', 'coverImage', 'photoUrl', 'thumbnail']) {
    final url = normalizeFoodImageUrl(data[key]);
    if (url.isNotEmpty) return url;
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
