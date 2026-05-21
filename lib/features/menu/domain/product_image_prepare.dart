import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Firebase Storage upload uchun JPEG.
Future<Uint8List> prepareProductImageBytesForStorage(Uint8List raw) async {
  return _encodeJpeg(raw, maxWidth: 1024, maxBytes: 400000, startQuality: 85);
}

/// Admin preview (local memory, uploaddan oldin).
Future<Uint8List> prepareProductImagePreviewBytes(Uint8List raw) async {
  return _encodeJpeg(raw, maxWidth: 640, maxBytes: 120000, startQuality: 78);
}

Future<Uint8List> _encodeJpeg(
  Uint8List raw, {
  required int maxWidth,
  required int maxBytes,
  required int startQuality,
}) async {
  if (raw.isEmpty) return raw;

  try {
    final decoded = img.decodeImage(raw);
    if (decoded == null) return raw;

    final resized = decoded.width > maxWidth
        ? img.copyResize(decoded, width: maxWidth)
        : decoded;

    var quality = startQuality;
    var jpg = Uint8List.fromList(img.encodeJpg(resized, quality: quality));

    while (jpg.length > maxBytes && quality > 40) {
      quality -= 8;
      jpg = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    }

    return jpg;
  } catch (_) {
    return raw;
  }
}
