import 'dart:typed_data';

import 'food_image_url.dart';
import 'product_image_codec.dart';

/// Firestore / admin paneldagi turli `image*` maydonlarini birlashtiradi.
class ParsedProductImage {
  const ParsedProductImage({
    this.networkUrl = '',
    this.imageBytes,
  });

  final String networkUrl;
  final Uint8List? imageBytes;

  bool get hasDisplayableImage =>
      (imageBytes != null && imageBytes!.isNotEmpty) ||
      networkUrl.startsWith('http://') ||
      networkUrl.startsWith('https://') ||
      networkUrl.startsWith('assets/') ||
      networkUrl.startsWith('gs://');
}

ParsedProductImage parseProductImageFields(Map<String, dynamic> data) {
  final bytesOnly = ProductImageCodec.decodeFromFirestore(data['imageBytes']);
  if (bytesOnly != null && bytesOnly.isNotEmpty) {
    final url = parseFoodImageUrl(data);
    return ParsedProductImage(
      networkUrl: url,
      imageBytes: bytesOnly,
    );
  }

  final primaryUrl = parseFoodImageUrl(data);
  if (primaryUrl.isNotEmpty) {
    return ParsedProductImage(networkUrl: primaryUrl);
  }

  final candidates = <dynamic>[
    data['image'],
    data['imageUrl'],
    data['imageBytes'],
    data['coverImage'],
    data['photoUrl'],
    data['thumbnail'],
    data['imagePath'],
    data['imageBase64'],
    data['imageData'],
  ];

  String url = '';
  Uint8List? bytes;

  for (final raw in candidates) {
    final parsed = _parseSingle(raw);
    if (parsed.imageBytes != null && bytes == null) {
      bytes = parsed.imageBytes;
    }
    if (parsed.networkUrl.isNotEmpty && url.isEmpty) {
      url = parsed.networkUrl;
    }
    if (bytes != null && url.isNotEmpty) break;
  }

  if (bytes != null || url.isNotEmpty) {
    return ParsedProductImage(networkUrl: url, imageBytes: bytes);
  }

  return const ParsedProductImage();
}

ParsedProductImage _parseSingle(dynamic raw) {
  if (raw == null) return const ParsedProductImage();

  final fromCodec = ProductImageCodec.decodeFromFirestore(raw);
  if (fromCodec != null) {
    return ParsedProductImage(imageBytes: fromCodec);
  }

  if (raw is! String) return const ParsedProductImage();
  final value = raw.trim();
  if (value.isEmpty) return const ParsedProductImage();

  if (value.startsWith('data:image')) {
    final bytes = _decodeDataUrl(value);
    if (bytes != null) {
      return ParsedProductImage(imageBytes: bytes, networkUrl: value);
    }
    return const ParsedProductImage();
  }

  final normalized = normalizeFoodImageUrl(value);
  if (normalized.isNotEmpty) {
    return ParsedProductImage(networkUrl: normalized);
  }

  if (value.startsWith('assets/')) {
    return ParsedProductImage(networkUrl: value);
  }

  return const ParsedProductImage();
}

Uint8List? _decodeDataUrl(String dataUrl) {
  try {
    final comma = dataUrl.indexOf(',');
    if (comma < 0) return null;
    return ProductImageCodec.decodeFromFirestore(dataUrl.substring(comma + 1));
  } catch (_) {
    return null;
  }
}
